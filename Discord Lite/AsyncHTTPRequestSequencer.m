//
//  AsyncHTTPRequestSequencer.m
//  Discord Lite
//
//  Created by Collin Mistr on 6/23/23.
//  Copyright (c) 2023 dosdude1. All rights reserved.
//

#import "AsyncHTTPRequestSequencer.h"

@implementation AsyncHTTPRequestSequencer

static AsyncHTTPRequestSequencer* sharedObject = nil;

-(id)init {
    self = [super init];
    numConcurrentRequests = 0;
    return self;
}

+(AsyncHTTPRequestSequencer *)sharedInstance {
    if (!sharedObject) {
        sharedObject = [[[super allocWithZone: NULL] init] retain];
    }
    return sharedObject;
}

-(void)enqueueRequest:(id<AsyncHTTPRequestSequencerProtocol>)req {
    
    if (numConcurrentRequests < MAX_CONCURRENT_REQUESTS) {
        [req shouldBeginRequest];
        numConcurrentRequests++;
    } else {
        if (!waitingFirstObject) {
            waitingFirstObject = [[AsyncHTTPRequestSequencerObject alloc] init];
            [waitingFirstObject setHttpRequest:req];
            waitingLastObject = waitingFirstObject;
        } else {
            AsyncHTTPRequestSequencerObject *obj = [[AsyncHTTPRequestSequencerObject alloc] init];
            [obj setHttpRequest:req];
            [waitingLastObject setNextObject:obj];
            waitingLastObject = obj;
        }
    }
}
-(void)requestDidFinish:(id<AsyncHTTPRequestSequencerProtocol>)req {
    
    numConcurrentRequests--;
    
    while (waitingFirstObject && (numConcurrentRequests < MAX_CONCURRENT_REQUESTS)) {
        [[waitingFirstObject httpRequest] shouldBeginRequest];
        AsyncHTTPRequestSequencerObject *temp = waitingFirstObject;
        waitingFirstObject = [waitingFirstObject nextObject];
        [temp release];
        numConcurrentRequests++;
    }
}

@end
