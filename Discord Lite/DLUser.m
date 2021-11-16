//
//  DLUser.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/2/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLUser.h"

@implementation DLUser

-(id)init {
    self = [super init];
    return self;
}
-(id)initWithDict:(NSDictionary *)d {
    self = [self init];
    userID = [[d objectForKey:@"id"] retain];
    username = [[d objectForKey:@"username"] retain];
    avatarID = [[d objectForKey:@"avatar"] retain];
    discriminator = [[d objectForKey:@"discriminator"] retain];
    return self;
}

-(void)setDelegate:(id<DLUserDelegate>)inDelegate {
    delegate = inDelegate;
}

-(void)loadAvatarData {
    if (avatarID && ![avatarID isKindOfClass:[NSNull class]]) {
        req = [[AsyncHTTPGetRequest alloc] init];
        [req setDelegate:self];
        [req setUrl:[NSURL URLWithString:[@AvatarCDNRoot stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.png?size=128", userID, avatarID]]]];
        [req setCached:YES];
        [req start];
    }
}
-(NSString *)userID {
    return userID;
}
-(NSString *)username {
    return username;
}
-(NSString *)avatarID {
    return avatarID;
}
-(NSData *)avatarImageData {
    if (!avatarImageData) {
        avatarImageData = [[NSData dataWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"discord_placeholder.png"]] retain];
    }
    return avatarImageData;
}

-(NSString *)discriminator {
    return discriminator;
}

-(BOOL)isEqual:(DLUser *)object {
    return [userID isEqualToString:[object userID]];
}

-(void)dealloc {
    //NSLog(@"Data: %ld for: %@", [avatarImageData retainCount], username);
    [avatarImageData release];
    [self setDelegate:nil];
    [req setDelegate:nil];
    [super dealloc];
}

#pragma mark Delegated Functions

-(void)requestDidFinishLoading:(AsyncHTTPRequest *)request {
    
    if ([request result] == HTTPResultOK) {
        [avatarImageData release];
        avatarImageData = [[request responseData] retain];
        [delegate avatarDidUpdateWithData:[request responseData]];
    }
    [request release];
    req = nil;
}

@end
