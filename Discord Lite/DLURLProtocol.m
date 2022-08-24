//
//  DLURLProtocol.m
//  Discord Lite
//
//  Created by Collin Mistr on 8/22/22.
//  Copyright (c) 2022 dosdude1. All rights reserved.
//

#import "DLURLProtocol.h"



@implementation DLURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (id)initWithRequest:(NSURLRequest *)request
       cachedResponse:(NSCachedURLResponse *)cachedResponse
               client:(id<NSURLProtocolClient>)client {
    if (self = [super initWithRequest:request
                       cachedResponse:cachedResponse
                               client:client]) {
        HTTPMessage = [self newMessageWithURLRequest:self.request];
    }
    return self;
}

- (void)startLoading {
    [self openHttpStream];
}

- (void)stopLoading {
    [self closeHttpStream];
    
    if (HTTPMessage) CFRelease(HTTPMessage);
    HTTPMessage = NULL;
}

- (void)openHttpStream {
    NSInputStream *bodyStream = self.request.HTTPBodyStream;
    CFReadStreamRef stream;
    if (bodyStream) {
        stream = CFReadStreamCreateForStreamedHTTPRequest(NULL, HTTPMessage, (CFReadStreamRef)bodyStream);
    } else {
        stream = CFReadStreamCreateForHTTPRequest(NULL, HTTPMessage);
    }
    
    if (stream == NULL) {
        NSString *desc = @"Could not create HTTP stream";
        
        
        [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:@"com.dosdude1.Discord-Lite"
                                                                           code:1
                                                                       userInfo:[NSDictionary dictionaryWithObject:desc forKey:NSLocalizedDescriptionKey]]];
        return;
    }
    
    // We have to manage redirects for ourselves
    CFReadStreamSetProperty(stream, kCFStreamPropertyHTTPShouldAutoredirect, kCFBooleanFalse);
    
    CFReadStreamSetProperty(stream, kCFStreamPropertyHTTPAttemptPersistentConnection, kCFBooleanFalse);
    
    
    // Handle SSL manually, to allow us to ask the user about it
    if([[self.request.URL.scheme lowercaseString] isEqualToString:@"https"]) {
        NSDictionary *d = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO], @"kCFStreamSocketSecurityLevelTLSv1_2", nil] forKeys:[NSArray arrayWithObjects:(NSString *)kCFStreamSSLAllowsExpiredCertificates, (NSString *)kCFStreamSSLAllowsExpiredRoots, (NSString *)kCFStreamSSLValidatesCertificateChain, (NSString *)kCFStreamSSLLevel, nil]];
        CFReadStreamSetProperty(stream, kCFStreamPropertySSLSettings, (CFDictionaryRef)d);
    } else {
        // Ignore in case of http
        validatesSecureCertificate = NO;
    }
    
    if ([[DLPreferencesHandler sharedInstance] shouldUseSOCKSProxy]) {
        CFMutableDictionaryRef socksConfig = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionarySetValue(socksConfig, kCFStreamPropertySOCKSProxyHost, (CFStringRef)[[DLPreferencesHandler sharedInstance] SOCKSProxyHost]);
        CFDictionarySetValue(socksConfig, kCFStreamPropertySOCKSProxyPort, (CFNumberRef)[NSNumber numberWithInt:[[DLPreferencesHandler sharedInstance] SOCKSProxyPort]]);
        CFDictionarySetValue(socksConfig, kCFStreamPropertySOCKSVersion, kCFStreamSocketSOCKSVersion5);
        
        if ([[DLPreferencesHandler sharedInstance] SOCKSProxyRequiresPassword]) {
            CFDictionarySetValue(socksConfig, kCFStreamPropertySOCKSUser, (CFStringRef)[[DLPreferencesHandler sharedInstance] SOCKSProxyUsername]);
            CFDictionarySetValue(socksConfig, kCFStreamPropertySOCKSPassword, (CFStringRef)[[DLPreferencesHandler sharedInstance] SOCKSProxyPassword]);
        }
        
        CFReadStreamSetProperty(stream, kCFStreamPropertySOCKSProxy, socksConfig);
    }
    
    HTTPStream = (NSInputStream *)stream;
    [HTTPStream setDelegate:self];
    [HTTPStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [HTTPStream open];
    
}

- (void)closeHttpStream {
    if (HTTPStream && HTTPStream.streamStatus != NSStreamStatusClosed) {
        HTTPStream.delegate = nil;
        // This method has to be called on the same thread as startLoading
        [HTTPStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [HTTPStream close];
    }
    [HTTPStream release];
    [URLResponse release];
    [buffer release];
    HTTPStream = nil;
    URLResponse = nil;
    buffer = nil;
}

- (void)stream:(NSInputStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
    BOOL proceed = YES;
    if (!URLResponse)// Handle the response as soon as it's available
        proceed = [self parseStreamHttpHeader:theStream];
    
    if (!proceed) return;
    
    switch (streamEvent) {
        case NSStreamEventHasBytesAvailable: {
            
            
            while ([theStream hasBytesAvailable]) {
                uint8_t buf[1024];
                NSInteger len = [theStream read:buf maxLength:1024];
                if (len > 0) {
                    // If there is no buffer, there is no compression specified. Therefore we can just send the data
                    if (buffer) [buffer appendBytes:(const void *)buf length:len];
                    else [self.client URLProtocol:self didLoadData:[NSData dataWithBytes:buf length:len]];
                }
            }
            break;
        }
            
        case NSStreamEventEndEncountered: { // Report the end of the stream to the delegate
            if (buffer) {
                if (compression == SGGzip) {
                    [self.client URLProtocol:self didLoadData:[buffer gzipInflate]];
                } else if (compression == SGDeflate) {
                    [self.client URLProtocol:self didLoadData:[buffer zlibInflate]];
                }
            }
            
            [self.client URLProtocolDidFinishLoading:self];
            buffer = nil;
            break;
        }
            
        case NSStreamEventErrorOccurred: { // Report an error in the stream as the operation failing
            [self closeHttpStream];
            
            NSError *error = theStream.streamError;
            
            
            [self.client URLProtocol:self didFailWithError:error];
            
            break;
        }
            
        default:
            break;
    }
}

- (BOOL)parseStreamHttpHeader:(NSInputStream *)theStream {
    
    CFHTTPMessageRef response = (CFHTTPMessageRef)[theStream propertyForKey:(NSString *)kCFStreamPropertyHTTPResponseHeader];
    if (response && CFHTTPMessageIsHeaderComplete(response)) {
        
        // Construct a NSURLResponse object from the HTTP message
        NSURL *URL = [theStream propertyForKey:(NSString *)kCFStreamPropertyHTTPFinalURL];
        NSInteger statusCode = (NSInteger)CFHTTPMessageGetResponseStatusCode(response);
        NSString *HTTPVersion = (NSString *)CFHTTPMessageCopyVersion(response);
        NSDictionary *headerFields = (NSDictionary *)CFHTTPMessageCopyAllHeaderFields(response);
        
        URLResponse = [[NSHTTPURLResponse alloc] initWithURL:URL
                                                   statusCode:statusCode
                                                  HTTPVersion:HTTPVersion
                                                 headerFields:headerFields];
        
        //NSLog(@"URL: %@ Status: %d Header: %@", URL, statusCode, headerFields);
        
        if (URLResponse == nil) {
            [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:@"com.dosdude1.Discord-Lite"
                                                                               code:1
                                                                           userInfo:[NSDictionary dictionaryWithObject:@"Invalid HTTP response" forKey:NSLocalizedDescriptionKey]]];
            [self closeHttpStream];
            return NO;
        }
        
        if ([self.request HTTPShouldHandleCookies]) {
            [self handleCookiesWithURLResponse:URLResponse];
        }
        
        NSString *location = [URLResponse.allHeaderFields objectForKey:@"Location"];
        
        // If the response was an authentication failure, try to request fresh credentials.
        if (location && ((statusCode >= 301 && statusCode <= 303) || statusCode == 307 || statusCode == 308)) {
            
            NSURL *nextURL = [[NSURL URLWithString:location relativeToURL:URL] absoluteURL];
            if (nextURL) {
                NSMutableURLRequest *nextRequest;
                if (statusCode == 307 || statusCode == 308) {
                    nextRequest = [self.request mutableCopy];
                    nextRequest.URL = nextURL;
                } else {
                    nextRequest = [NSMutableURLRequest requestWithURL:nextURL
                                                          cachePolicy:self.request.cachePolicy
                                                      timeoutInterval:self.request.timeoutInterval];
                    [nextRequest setValue:[self.request valueForHTTPHeaderField:@"Accept"] forHTTPHeaderField:@"Accept"];
                    [nextRequest setValue:[self.request valueForHTTPHeaderField:@"User-Agent"] forHTTPHeaderField:@"User-Agent"];
                }
                
                NSString *referer = [self.request valueForHTTPHeaderField:@"Referer"];
                if (!referer) referer = self.request.URL.absoluteString;
                [nextRequest setValue:referer forHTTPHeaderField:@"Referer"];
                [self.client URLProtocol:self wasRedirectedToRequest:nextRequest redirectResponse:URLResponse];
                
                [self closeHttpStream];
                [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
                return NO;
            }
        }
        
        NSString *cEncoding = [[URLResponse.allHeaderFields objectForKey:@"Content-Encoding"] lowercaseString];
        if (cEncoding.length > 0) {
            cEncoding = [cEncoding stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
            if ([cEncoding isEqualToString:@"gzip"]) {
                compression = SGGzip;
            } else if ([cEncoding isEqualToString:@"deflate"]) {
                compression = SGDeflate;
            }
        } else compression = SGIdentity;
        
        if (compression != SGIdentity) {
            long long capacity = URLResponse.expectedContentLength;
            if (capacity == NSURLResponseUnknownLength || capacity == 0)
                capacity = 1024*512;//5M buffer capacity
            buffer = [[NSMutableData alloc] initWithCapacity:capacity];
        }
        
        [self.client URLProtocol:self didReceiveResponse:URLResponse cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    }
    return YES;
}

- (CFHTTPMessageRef)newMessageWithURLRequest:(NSURLRequest *)request {
    CFHTTPMessageRef message = CFHTTPMessageCreateRequest(kCFAllocatorDefault,
                                                          (CFStringRef)[request HTTPMethod],
                                                          (CFURLRef)[request URL],
                                                          kCFHTTPVersion1_1);
    if (message == NULL) return NULL;
    
    //NSString *locale = [[[NSLocale preferredLanguages] subarrayWithRange:NSMakeRange(0, 3)] componentsJoinedByString:@","];
    
    CFHTTPMessageSetHeaderFieldValue(message, CFSTR("Host"), (CFStringRef)request.URL.host);
    CFHTTPMessageSetHeaderFieldValue(message, CFSTR("Accept-Language"), CFSTR("en-US,en;q=0.5"));
    CFHTTPMessageSetHeaderFieldValue(message, CFSTR("Accept-Charset"), CFSTR("ISO-8859-1,utf-8;q=0.7,*;q=0.3"));
    CFHTTPMessageSetHeaderFieldValue(message, CFSTR("Accept-Encoding"), CFSTR("gzip,deflate"));
    
    if (request.HTTPShouldHandleCookies) {
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookies = [cookieStorage cookiesForURL:request.URL];
        NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
        
        NSEnumerator *e = [[headers allKeys] objectEnumerator];
        NSString *key;
        while (key = [e nextObject]) {
            NSString *val = [headers objectForKey:key];
            CFHTTPMessageSetHeaderFieldValue(message,
                                             (CFStringRef)key,
                                             (CFStringRef)val);
        }
    }
    
    NSEnumerator *e = [[request.allHTTPHeaderFields allKeys] objectEnumerator];
    NSString *key;
    while (key = [e nextObject]) {
        NSString *val = [request.allHTTPHeaderFields objectForKey:key];
        CFHTTPMessageSetHeaderFieldValue(message,
                                         (CFStringRef)key,
                                         (CFStringRef)val);
    }
    
    if (request.HTTPBody) CFHTTPMessageSetBody(message, (CFDataRef)request.HTTPBody);
    
    return message;
}

- (void)handleCookiesWithURLResponse:(NSHTTPURLResponse *)response {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:response.allHeaderFields
                                                              forURL:response.URL];
    [cookieStorage setCookies:cookies
                       forURL:response.URL
              mainDocumentURL:self.request.mainDocumentURL];
}

- (BOOL)evaluateTrust:(SecTrustRef)trust {
    return YES;
}

- (void)dealloc {
    if (HTTPMessage) CFRelease(HTTPMessage);
    [super dealloc];
}

@end
