//
//  DLWSController.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/4/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLChannel.h"
#import "DLUserSettings.h"
#import "WSWebSocket.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"



#define WS_GATEWAY_URL "wss://gateway.discord.gg/?encoding=json&v=6"

#define kWSOperation "op"
#define kWSData "d"
#define kWSSequence "s"
#define kWSType "t"

typedef enum {
    OPCodeGeneral = 0,
    OPCodeHeartbeat = 1,
    OPCodeIdentify = 2,
    OPCodeResume = 6,
    OPCodeHello = 10,
    OPCodeHeartbeatAck = 11
} OPCode;

@protocol DLWSControllerDelegate <NSObject>
@optional
-(void)wsDidReceiveMessage:(DLMessage *)m;
-(void)wsDidReceivePrivateChannelData:(NSArray *)data;
-(void)wsDidReceiveServerData:(NSArray *)data;
-(void)wsDidReceiveReadStateData:(NSArray *)data;
-(void)wsDidReceiveUserData:(DLUser *)u;
-(void)wsDidReceiveUserSettings:(DLUserSettings *)s;
-(void)wsDidLoadAllData;
-(void)wsDidAcknowledgeMessage:(DLMessage *)m;
@end

@interface DLWSController : NSObject <WSWebSocketDelegate> {
    WSWebSocket *webSocket;
    NSString *token;
    NSString *sessionID;
    int heartbeatInterval;
    id<DLWSControllerDelegate> delegate;
    BOOL heartbeatResponseReceived;
    BOOL shouldResume;
    int sequenceNumber;
}

+(DLWSController *)sharedInstance;
-(void)setDelegate:(id<DLWSControllerDelegate>)inDelegate;

-(void)startWithAuthToken:(NSString *)inToken;
-(void)stop;

@end
