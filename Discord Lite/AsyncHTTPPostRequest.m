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
    [super initializeRequest];
    
    curl_easy_setopt(curlRequestHandle, CURLOPT_CUSTOMREQUEST, [method UTF8String]);
    
    
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
        
        rootHeader = curl_slist_append(rootHeader, [[NSString stringWithFormat:@"Content-Type: multipart/form-data; boundary=%@", boundary] UTF8String]);
        
    } else {
        //NSLog(@"Req: %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
        queryData = jsonData;
        rootHeader = curl_slist_append(rootHeader, [@"Content-Type: application/json" UTF8String]);
    }
    
    postData = malloc([queryData length]);
    memcpy(postData, [queryData bytes], [queryData length]);
    curl_easy_setopt(curlRequestHandle, CURLOPT_POSTFIELDSIZE, [queryData length]);
    curl_easy_setopt(curlRequestHandle, CURLOPT_POSTFIELDS, postData);
    
    rootHeader = curl_slist_append(rootHeader, [@"Accept: */*" UTF8String]);
    
    if (headers) {
        
        NSEnumerator *e = [[headers allKeys] objectEnumerator];
        NSString *key;
        while (key = [e nextObject]) {
            rootHeader = curl_slist_append(rootHeader, [[NSString stringWithFormat:@"%@: %@", key, [headers objectForKey:key]] UTF8String]);
        }
    }
    curl_easy_setopt(curlRequestHandle, CURLOPT_HTTPHEADER, rootHeader);
    [super start];
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
