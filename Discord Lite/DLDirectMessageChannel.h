//
//  DLDirectMessageChannel.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/3/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLChannel.h"
#import "DLUser.h"



@interface DLDirectMessageChannel : DLChannel <DLUserDelegate> {
    NSArray *recipients;
    NSDate *lastUpdateTimestamp;
}

-(id)init;
-(id)initWithDict:(NSDictionary *)d;
-(void)updateWithDict:(NSDictionary *)d;

-(BOOL)isGroupMessage;
-(NSArray *)recipients;
-(NSString *)name;
-(NSData *)imageData;
-(NSData *)subImageData;
-(NSString *)serverID;
-(NSDate *)lastUpdateTimestamp;
-(DLUser *)recipientWithUserID:(NSString *)userID;
-(NSArray *)recipientsWithUsernameContainingString:(NSString *)username;
-(void)loadAvatarImageData;

-(void)setLastMessage:(DLMessage *)msg;

- (NSComparisonResult)compare:(DLDirectMessageChannel *)o;

@end
