//
//  DLController.h
//  Discord Lite
//
//  Created by Collin Mistr on 10/25/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncHTTPPostRequest.h"
#import "AsyncHTTPGetRequest.h"
#import "DLError.h"
#import "DLServer.h"
#import "DLServerChannel.h"
#import "DLMessage.h"
#import "DLDirectMessageChannel.h"
#import "DLWSController.h"

#define API_ROOT "https://discordapp.com/api/v6"

#define kDefaultsToken "token"

typedef enum {
    RequestIDLogin = 0,
    RequestIDMessages = 1,
    RequestIDSendMessage = 2,
    RequestIDAckMessage = 3,
    RequestIDLogout = 4,
    RequestIDTyping = 5,
    RequestIDTwoFactor = 6,
    RequestIDMessageEdit = 7
} RequestID;

@protocol DLLoginDelegate <NSObject>
@optional
-(void)didLoginWithError:(DLError *)e;
-(void)didReceiveCaptchaRequestOfType:(NSString *)captchaType withSiteKey:(NSString *)siteKey;
-(void)didReceiveTwoFactorAuthRequest;
@end

@protocol DLControllerDelegate <NSObject>
@optional
-(void)requestDidFailWithError:(DLError *)e;
-(void)initialDataWasReceived;
-(void)messages:(NSArray *)messages receivedForChannel:(DLChannel *)c;
-(void)newMessage:(DLMessage *)m receivedForChannel:(DLChannel *)c inServer:(DLServer *)s;
-(void)didLogoutSuccessfully;
-(void)userDidStartTypingInSelectedChannel:(DLUser *)u;
-(void)members:(NSArray *)members didUpdateForServer:(DLServer *)s;
@end

@interface DLController : NSObject <AsyncHTTPRequestDelegate, DLWSControllerDelegate> {
    NSString *token;
    NSString *twoFactorTicket;
    id <DLControllerDelegate> delegate;
    id <DLLoginDelegate> loginDelegate;
    NSString *captchaKey;
    DLServer *selectedServer;
    DLServer *myServerItem;
    DLChannel *selectedChannel;
    DLUser *myUser;
    DLUserSettings *myUserSettings;
    NSMutableDictionary *loadedServers;
    NSMutableDictionary *loadedChannels;
    NSMutableArray *loadedMessages;
}

-(DLServer *)selectedServer;
-(DLChannel *)selectedChannel;

-(void)setSelectedChannel:(DLChannel *)c;

-(void)setLoginDelegate:(id <DLLoginDelegate>)inLoginDelegate;
-(void)setDelegate:(id <DLControllerDelegate>)inDelegate;

-(void)setCaptchaKey:(NSString *)inKey;

+(DLController *)sharedInstance;

-(void)loadUserDefaults;
-(BOOL)isLoggedIn;
-(void)loginWithEmail:(NSString *)email andPassword:(NSString *)password;
-(void)loginWithTwoFactorAuthCode:(NSString *)twoFactorCode;
-(void)loadMessagesForChannel:(DLChannel *)c beforeMessage:(DLMessage *)m quantity:(NSInteger)numMsgs;
-(void)sendMessage:(DLMessage *)m toChannel:(DLChannel *)c;
-(void)acknowledgeMessage:(DLMessage *)m;
-(void)logOutUser;
-(void)informTypingInChannel:(DLChannel *)c;
-(void)submitEditedMessage:(DLMessage *)m;

-(void)startWebSocket;
-(void)stopWebSocket;

-(NSArray *)userServers;
-(NSArray *)channelsForServer:(DLServer *)s;
-(NSArray *)directMessageChannels;

-(void)queryServer:(DLServer *)s forMembersContainingUsername:(NSString *)username;


-(DLServer *)myServerItem;

-(DLUser *)myUser;
-(DLServer *)loadedServerWithID:(NSString *)srvID;
-(DLChannel *)loadedChannelWithID:(NSString *)chanID;

@end
