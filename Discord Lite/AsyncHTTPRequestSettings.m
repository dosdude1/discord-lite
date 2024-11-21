//
//  AsyncHTTPRequestSettings.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/21/24.
//  Copyright (c) 2024 dosdude1. All rights reserved.
//

#import "AsyncHTTPRequestSettings.h"

static AsyncHTTPRequestSettings* sharedObject = nil;

@implementation AsyncHTTPRequestSettings

+(AsyncHTTPRequestSettings *)sharedInstance {
    if (!sharedObject) {
        sharedObject = [[[super allocWithZone: NULL] init] retain];
    }
    return sharedObject;
}

-(id)init {
    self = [super init];
    userAgentString = @"DiscordLite";
    persistentPOSTHeaders = [[NSDictionary alloc] init];
    return self;
}

-(NSDictionary *)persistentPOSTHeaders {
    return persistentPOSTHeaders;
}
-(NSString *)userAgentString {
    return userAgentString;
}

-(void)setPersistentPOSTHeaders:(NSDictionary *)headers {
    [persistentPOSTHeaders release];
    [headers retain];
    persistentPOSTHeaders = headers;
}
-(void)setUserAgentString:(NSString *)userAgent {
    [userAgentString release];
    [userAgent retain];
    userAgentString = userAgent;
}

@end
