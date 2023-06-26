//
//  AsyncHTTPRequestSequencerObject.h
//  Discord Lite
//
//  Created by Collin Mistr on 6/23/23.
//  Copyright (c) 2023 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AsyncHTTPRequestSequencerObject;

@protocol AsyncHTTPRequestSequencerProtocol <NSObject>
@optional
-(void)shouldBeginRequest;
@end

@interface AsyncHTTPRequestSequencerObject : NSObject {
    AsyncHTTPRequestSequencerObject *nextObject;
    id<AsyncHTTPRequestSequencerProtocol> httpRequest;
}

-(AsyncHTTPRequestSequencerObject *)nextObject;
-(id<AsyncHTTPRequestSequencerProtocol>)httpRequest;

-(void)setHttpRequest:(id<AsyncHTTPRequestSequencerProtocol>)req;
-(void)setNextObject:(AsyncHTTPRequestSequencerObject *)nextObj;


@end
