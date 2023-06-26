//
//  AsyncHTTPRequestSequencer.h
//  Discord Lite
//
//  Created by Collin Mistr on 6/23/23.
//  Copyright (c) 2023 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncHTTPRequestSequencerObject.h"

#define MAX_CONCURRENT_REQUESTS 10

@interface AsyncHTTPRequestSequencer : NSObject {
    AsyncHTTPRequestSequencerObject *waitingFirstObject;
    AsyncHTTPRequestSequencerObject *waitingLastObject;
    
    int numConcurrentRequests;
}

+(AsyncHTTPRequestSequencer *)sharedInstance;

-(void)enqueueRequest:(id<AsyncHTTPRequestSequencerProtocol>)req;
-(void)requestDidFinish:(id<AsyncHTTPRequestSequencerProtocol>)req;

@end
