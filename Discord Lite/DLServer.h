//
//  DLServer.h
//  Discord Lite
//
//  Created by Collin Mistr on 10/27/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncHTTPGetRequest.h"
#import "DLServerMember.h"

#define IconCDNRoot "https://cdn.discordapp.com/icons"

@protocol DLServerDelegate <NSObject>
@optional
-(void)iconDidUpdateWithData:(NSData *)data;
-(void)mentionCountDidUpdate;
-(void)unreadStatusDidUpdate;
@end

@interface DLServer : NSObject <AsyncHTTPRequestDelegate> {
    NSString *serverID;
    NSString *name;
    NSString *iconID;
    NSData *iconImageData;
    NSInteger mentionCount;
    NSMutableArray *members;
    id<DLServerDelegate> delegate;
    BOOL hasUnreadMessages;
}

-(id)init;
-(id)initWithDict:(NSDictionary *)d;

-(NSString *)serverID;
-(NSString *)name;
-(NSString *)iconID;
-(NSData *)iconImageData;
-(NSInteger)mentionCount;
-(NSArray *)members;
-(BOOL)hasUnreadMessages;

-(void)setServerID:(NSString *)inId;
-(void)setName:(NSString *)inName;
-(void)setIconImageData:(NSData *)data;

-(void)addMember:(DLServerMember *)m;

-(DLServerMember *)memberWithUserID:(NSString *)userID;
-(NSArray *)membersWithUsernameContainingString:(NSString *)username;

-(void)setDelegate:(id <DLServerDelegate>)inDelegate;
-(BOOL)isEqual:(DLServer *)object;

-(void)notifyOfNewMention;
-(void)addMentionCount:(NSInteger)inMentions;
-(void)setMentionCount:(NSInteger)inMentions;

-(void)setHasUnreadMessages:(BOOL)unread;

@end
