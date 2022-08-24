//
//  DLPreferencesHandler.h
//  Discord Lite
//
//  Created by Collin Mistr on 8/22/22.
//  Copyright (c) 2022 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kShouldUseSOCKSProxy "UseSOCKSProxy"
#define kSOCKSProxyPort "SOCKSProxyPort"
#define kSOCKSProxyHost "SOCKSProxyHost"
#define kSOCKSProxyRequiresPassword "SOCKSRequiresPassword"
#define kSOCKSProxyUsername "SOCKSUsername"
#define kSOCKSProxyPassword "SOCKSPassword"

@interface DLPreferencesHandler : NSObject

+(DLPreferencesHandler *)sharedInstance;

-(BOOL)shouldUseSOCKSProxy;
-(NSInteger)SOCKSProxyPort;
-(NSString *)SOCKSProxyHost;
-(BOOL)SOCKSProxyRequiresPassword;
-(NSString *)SOCKSProxyUsername;
-(NSString *)SOCKSProxyPassword;

-(void)setShouldUseSOCKSProxy:(BOOL)shouldUse;
-(void)setSOCKSProxyPort:(NSInteger)proxyPort;
-(void)setSOCKSProxyHost:(NSString *)proxyHost;
-(void)setSOCKSProxyRequiresPassword:(BOOL)requiresPassword;
-(void)setSOCKSProxyUsername:(NSString *)username;
-(void)setSOCKSProxyPassword:(NSString *)password;

@end
