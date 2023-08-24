//
//  DLChannel.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/1/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLMessage.h"

typedef enum {
    ChannelTypeStandard = 0,
    ChannelTypeDM = 1,
    ChannelTypeGroup = 3,
    ChannelTypeVoice = 2,
    ChannelTypeHeader = 4,
    ChannelTypeAnnouncements = 5
} ChannelType;

@class DLChannel;

@protocol DLChannelDelegate <NSObject>
@optional
-(void)channel:(DLChannel *)c imageDidUpdateWithData:(NSData *)d;
-(void)mentionsUpdatedForChannel:(DLChannel *)c;
-(void)unreadStatusUpdatedForChannel:(DLChannel *)c;
@end

@interface DLChannel : NSObject {
    NSString *channelID;
    ChannelType type;
    NSData *imageData;
    NSData *subImageData;
    NSString *name;
    NSInteger mentionCount;
    id<DLChannelDelegate> delegate;
    BOOL hasUnreadMessages;
    DLMessage *lastMessage;
}

-(id)init;
-(id)initWithDict:(NSDictionary *)d;
-(void)updateWithDict:(NSDictionary *)d;

-(void)setDelegate:(id<DLChannelDelegate>)inDelegate;

-(NSString *)channelID;
-(ChannelType)type;
-(NSString *)name;
-(NSData *)imageData;
-(NSData *)subImageData;
-(NSArray *)children;
-(NSInteger)mentionCount;
-(NSString *)serverID;
-(BOOL)hasUnreadMessages;
-(DLMessage *)lastMessage;

-(DLUser *)recipientWithUserID:(NSString *)userID;
-(NSArray *)recipientsWithUsernameContainingString:(NSString *)username;

-(void)setServerID:(NSString *)inServerID;

-(BOOL)isEqual:(DLChannel *)c;

-(void)notifyOfNewMention;
-(void)setMentionCount:(NSInteger)inMentions;
- (NSComparisonResult)compare:(DLChannel *)o;
-(void)setLastMessage:(DLMessage *)msg;
-(void)setHasUnreadMessages:(BOOL)unread;

@end
