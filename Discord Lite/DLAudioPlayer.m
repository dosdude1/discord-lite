//
//  DLAudioPlayer.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/8/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLAudioPlayer.h"

#define kOutputBus 0
#define kInputBus 1

@implementation DLAudioPlayer

static DLAudioPlayer* sharedObject = nil;

-(id)init {
    self = [super init];
    newMention = [[NSSound alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"mention_notification.mp3"] byReference:NO];
    return self;
}

+(DLAudioPlayer *)sharedInstance {
    if (!sharedObject) {
        sharedObject = [[[super allocWithZone: NULL] init] retain];
    }
    return sharedObject;
}

-(void)playAudioWithID:(AudioID)audioID {
    switch (audioID) {
        case AudioIDNotificationNewMention:
            [newMention play];
            break;
    }
}


@end
