//
//  DLUser.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/2/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncHTTPGetRequest.h"

#define AvatarCDNRoot "https://cdn.discordapp.com/avatars"

@protocol DLUserDelegate <NSObject>
@optional
-(void)avatarDidUpdateWithData:(NSData *)data;
@end

@interface DLUser : NSObject <AsyncHTTPRequestDelegate> {
    NSString *userID;
    NSString *username;
    NSString *avatarID;
    NSData *avatarImageData;
    NSString *discriminator;
    AsyncHTTPRequest *req;
    id<DLUserDelegate> delegate;
}

-(id)init;
-(id)initWithDict:(NSDictionary *)d;

-(NSString *)userID;
-(NSString *)username;
-(NSString *)avatarID;
-(NSData *)avatarImageData;
-(NSString *)discriminator;

-(BOOL)isEqual:(DLUser *)object;

-(void)loadAvatarData;

-(void)setDelegate:(id<DLUserDelegate>)inDelegate;

@end
