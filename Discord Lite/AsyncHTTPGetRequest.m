//
//  AsyncHTTPGetRequest.m
//  Discord Lite
//
//  Created by Collin Mistr on 10/26/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "AsyncHTTPGetRequest.h"

@implementation AsyncHTTPGetRequest

-(id)init {
    self = [super init];
    return self;
}

-(void)start {
    [self initializeRequest];
    
    
    if (headers) {
        rootHeader = nil;
        NSEnumerator *e = [[headers allKeys] objectEnumerator];
        NSString *key;
        while (key = [e nextObject]) {
            rootHeader = curl_slist_append(rootHeader, [[NSString stringWithFormat:@"%@: %@", key, [headers objectForKey:key]] UTF8String]);
        }
        curl_easy_setopt(curlRequestHandle, CURLOPT_HTTPHEADER, rootHeader);
    }
    
    if (cached) {
        if ([[HTTPCache sharedInstance] cachedDataForURL:url]) {
            [responseData release];
            responseData = (NSMutableData *)[[[HTTPCache sharedInstance] cachedDataForURL:url] retain];
            result = HTTPResultOK;
            [delegate requestDidFinishLoading:self];
        } else {
            [super start];
        }
    } else {
        [super start];
    }
}

@end
