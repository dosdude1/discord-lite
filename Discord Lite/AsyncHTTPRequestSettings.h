//
//  AsyncHTTPRequestSettings.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/21/24.
//  Copyright (c) 2024 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsyncHTTPRequestSettings : NSObject {
    NSDictionary *persistentPOSTHeaders;
    NSString *userAgentString;
}

+(AsyncHTTPRequestSettings *)sharedInstance;

-(NSDictionary *)persistentPOSTHeaders;
-(NSString *)userAgentString;

-(void)setPersistentPOSTHeaders:(NSDictionary *)headers;
-(void)setUserAgentString:(NSString *)userAgent;

@end
