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

-(void)beginRequest {
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    
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

-(void)start {
    [super start];
    if (cached) {
        if ([[HTTPCache sharedInstance] cachedDataForURL:[url absoluteString]]) {
            responseData = (NSMutableData *)[[HTTPCache sharedInstance] cachedDataForURL:[url absoluteString]];
            result = HTTPResultOK;
            [delegate requestDidFinishLoading:self];
        } else {
            [self beginRequest];
        }
    } else {
        [self beginRequest];
    }
}

@end
