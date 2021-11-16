//
//  DLAudioPlayer.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/8/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

typedef enum {
    AudioIDNotificationNewMention = 0
} AudioID;

@interface DLAudioPlayer : NSObject {
    NSSound *newMention;
}

+(DLAudioPlayer *)sharedInstance;
-(void)playAudioWithID:(AudioID)audioID;

@end
