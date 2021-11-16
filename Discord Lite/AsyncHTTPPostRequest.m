//
//  AsyncHTTPPostRequest.m
//  Discord Lite
//
//  Created by Collin Mistr on 10/26/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "AsyncHTTPPostRequest.h"

@implementation AsyncHTTPPostRequest

-(id)init {
    self = [super init];
    method = @"POST";
    return self;
}

-(void)start {
    [super start];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    
    
    NSData *jsonData = [[CJSONSerializer serializer] serializeDictionary:parameters error:nil];
    NSData *queryData = nil;
    if (files) {
        NSMutableData *formData = [[NSMutableData alloc] init];
        NSString *boundary = [NSString stringWithFormat:@"---------------------------%@", [DLUtil randomStringWithLength:30]];
        NSEnumerator *e = [[files allKeys] objectEnumerator];
        NSString *fileName;
        while (fileName = [e nextObject]) {
            NSData *fileData = [files objectForKey:fileName];
            NSString *mimeType = [DLUtil mimeTypeForExtension:[fileName pathExtension]];
            [formData appendData:[[NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n", boundary, fileName, fileName, mimeType] dataUsingEncoding:NSUTF8StringEncoding]];
            [formData appendData:fileData];
            [formData appendData:[@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        NSString *content = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"content\"\r\n\r\n%@\r\n", boundary, [parameters objectForKey:@"content"]];
        [formData appendData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        [formData appendData:[[NSString stringWithFormat:@"--%@--\r\n\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        queryData = formData;
        
        [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
        
    } else {
        queryData = jsonData;
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    
    NSString *queryLength = [NSString stringWithFormat:@"%lu", (unsigned long)[queryData length]];
    [request setValue:queryLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:queryData];
    
    [request setURL:url];
    [request setHTTPMethod:method];
    [request setValue:[self userAgentString] forHTTPHeaderField:@"User-Agent"];
    
    
    if (headers) {
        
        NSEnumerator *e = [[headers allKeys] objectEnumerator];
        NSString *key;
        while (key = [e nextObject]) {
            [request setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)setParameters:(NSDictionary *)inParameters {
    [parameters release];
    [inParameters retain];
    parameters = inParameters;
}
-(void)setMethod:(NSString *)inMethod {
    [method release];
    [inMethod retain];
    method = inMethod;
}
-(void)setFiles:(NSDictionary *)inFiles {
    [files release];
    [inFiles retain];
    files = inFiles;
}

@end
