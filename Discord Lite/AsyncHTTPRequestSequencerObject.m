//
//  AsyncHTTPRequestSequencerObject.m
//  Discord Lite
//
//  Created by Collin Mistr on 6/23/23.
//  Copyright (c) 2023 dosdude1. All rights reserved.
//

#import "AsyncHTTPRequestSequencerObject.h"

@implementation AsyncHTTPRequestSequencerObject

-(AsyncHTTPRequestSequencerObject *)nextObject {
    return nextObject;
}
-(id)httpRequest {
    return httpRequest;
}

-(void)setHttpRequest:(id<AsyncHTTPRequestSequencerProtocol>)req {
    [httpRequest release];
    [req retain];
    httpRequest = req;
}
-(void)setNextObject:(AsyncHTTPRequestSequencerObject *)nextObj {
    [nextObject release];
    [nextObj retain];
    nextObject = nextObj;
}

-(void)dealloc {
    [httpRequest release];
    [nextObject release];
    [super dealloc];
}

@end
