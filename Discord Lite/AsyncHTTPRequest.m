//
//  AsyncHTTPRequest.m
//  Discord Lite
//
//  Created by Collin Mistr on 10/26/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "AsyncHTTPRequest.h"

@implementation NSURLRequest(DataController)

+(BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host {
    return YES;
}

@end

@implementation AsyncHTTPRequest

-(id)init {
    self = [super init];
    cached = NO;
    isFileDownload = NO;
    dataLength = 0;
    return self;
}

-(void)start {
    
    if (isFileDownload) {
        [downloadingFile seekToEndOfFile];
    } else {
        responseData = [[NSMutableData alloc] init];
    }
}

-(HTTPResult)result {
    return result;
}
-(NSData *)responseData {
    return responseData;
}
-(int)identifier {
    return identifier;
}
-(NSString *)userAgentString {
    return [NSString stringWithFormat:@"DiscordLite/%@ CFNetwork/%@ Darwin/%@", [DLUtil appVersionString], [DLUtil CFNetworkVersionString], [DLUtil kernelVersion]];
}


-(void)setUrl:(NSURL *)inUrl {
    [url release];
    [inUrl retain];
    url = inUrl;
}

-(void)setDelegate:(id <AsyncHTTPRequestDelegate>)inDelegate {
    delegate = inDelegate;
}
-(void)setIdentifier:(int)inIdentifier {
    identifier = inIdentifier;
}
-(void)setHeaders:(NSDictionary *)inHeaders {
    [headers release];
    [inHeaders retain];
    headers = inHeaders;
}
-(void)setCached:(BOOL)inCached {
    cached = inCached;
}
-(void)setDownloadingFile:(NSFileHandle *)inDownloadingFile {
    isFileDownload = YES;
    downloadingFile = inDownloadingFile;
}


#pragma mark Delegated Functions

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    switch ([httpResponse statusCode]) {
        case 200:
            result = HTTPResultOK;
            break;
        case 204:
            result = HTTPResultOK;
            break;
        case 400:
            result = HTTPResultErrParameter;
            break;
        default:
            result = HTTPResultErrGeneral;
            break;
    }
    dataLength = 0;
    if (isFileDownload) {
        [downloadingFile seekToEndOfFile];
    } else {
        [responseData setLength:0];
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    dataLength += data.length;
    if (isFileDownload) {
        [downloadingFile writeData:data];
    } else {
        [responseData appendData:data];
    }
    if ([delegate respondsToSelector:@selector(responseDataDidUpdateWithSize:)]) {
        [delegate responseDataDidUpdateWithSize:dataLength];
    }
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    if (isFileDownload) {
        [downloadingFile closeFile];
    } else {
        if (cached) {
            [[HTTPCache sharedInstance] setCachedData:responseData forURL:[url absoluteString]];
        }
    }
    [delegate requestDidFinishLoading:self];
    [connection release];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
    result = HTTPResultErrConnecting;
    if (isFileDownload) {
        [downloadingFile closeFile];
    }
    [delegate requestDidFinishLoading:self];
    [connection release];
}

/*- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:@"NSURLAuthenticationMethodServerTrust"];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
#ifndef __ppc__
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:@"NSURLAuthenticationMethodServerTrust"]) {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }
#endif
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}*/

-(void)dealloc {
    [url release];
    [responseData release];
    [super dealloc];
}

@end
