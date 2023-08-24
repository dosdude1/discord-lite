//
//  DLMessage.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/2/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLUser.h"
#import "DLAttachment.h"
#import "RegexKitLite.h"

@protocol DLMessageDelegate <NSObject>
-(void)messageContentWasUpdated;
-(void)messageWasDeleted;
@end

@interface DLMessage : NSObject {
    NSString *messageID;
    NSString *content;
    NSString *channelID;
    NSString *serverID;
    DLUser *author;
    NSArray *attachments;
    NSDate *timestamp;
    NSDate *editedTimestamp;
    NSArray *mentionedUsers;
    BOOL mentionedEveryone;
    DLMessage *referencedMessage;
    id<DLMessageDelegate> delegate;
}

-(id)init;
-(id)initWithDict:(NSDictionary *)d;
-(void)updateWithDict:(NSDictionary *)d;

-(NSDictionary *)dictRepresentation;

-(NSString *)messageID;
-(NSString *)content;
-(NSString *)channelID;
-(NSString *)serverID;
-(DLUser *)author;
-(NSArray *)attachments;
-(NSDate *)timestamp;
-(NSDate *)editedTimestamp;
-(NSArray *)mentionedUsers;
-(DLMessage *)referencedMessage;
-(BOOL)mentionedEveryone;

-(void)setDelegate:(id<DLMessageDelegate>)inDelegate;

-(void)setMessageID:(NSString *)msgID;
-(void)setContent:(NSString *)inContent;
-(void)setAttachments:(NSArray *)inAttachments;
-(void)setReferencedMessage:(DLMessage *)m;
-(void)setChannelID:(NSString *)inChannelID;
-(void)setServerID:(NSString *)inServerID;
-(void)remove;

-(BOOL)isEqual:(DLMessage *)m;

@end
