//
//  DLWSController.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/4/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLWSController.h"

@implementation DLWSController

static DLWSController* sharedObject = nil;

-(id)init {
    self = [super init];
    heartbeatResponseReceived = YES;
    shouldResume = NO;
    sequenceNumber = 0;
    return self;
}

+(DLWSController *)sharedInstance
{
    if (!sharedObject) {
        sharedObject = [[[super allocWithZone: NULL] init] retain];
    }
    return sharedObject;
}

-(void)setDelegate:(id<DLWSControllerDelegate>)inDelegate {
    delegate = inDelegate;
}

-(void)startWithAuthToken:(NSString *)inToken {
    token = inToken;
    NSURL *wsURL = [NSURL URLWithString:@WS_GATEWAY_URL];
    webSocket = [[WSWebSocket alloc] initWithURL:wsURL protocols:nil];
    [webSocket setDelegate:self];
    [webSocket open];
}
-(void)stop {
    [webSocket close];
    shouldResume = NO;
    heartbeatResponseReceived = YES;
}
-(void)sendWSHeartbeat {
    if(heartbeatResponseReceived){
        heartbeatResponseReceived = NO;
        NSDictionary *response = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:OPCodeHeartbeat], [NSNumber numberWithInt:sequenceNumber], nil] forKeys:[NSArray arrayWithObjects:@kWSOperation, @kWSData ,nil]];
        NSString *toSend = [[NSString alloc] initWithData:[[CJSONSerializer serializer] serializeDictionary:response error:nil] encoding:NSUTF8StringEncoding];
        [webSocket sendText:toSend];
    }else{
        shouldResume = YES;
        [webSocket close];
        [self startWithAuthToken:token];
    }
}

#pragma mark Delegated Functions


-(void)wsTextReceived:(NSString *)text {
    NSData *resData = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:resData error:nil];
    OPCode c = [[res objectForKey:@kWSOperation] intValue];
    switch (c) {
        case OPCodeGeneral: {
            sequenceNumber = [[res objectForKey:@kWSSequence] intValue];
            NSString *type = [res objectForKey:@kWSType];
            if ([type isEqualToString:@"MESSAGE_CREATE"]) {
                DLMessage *m = [[DLMessage alloc] initWithDict:[res objectForKey:@kWSData]];
                [delegate wsDidReceiveMessage:m];
                [m release];
            } else if ([type isEqualToString:@"READY"]) {
                NSDictionary *wsData = [res objectForKey:@kWSData];
                sessionID = [[wsData objectForKey:@"session_id"] retain];
                [delegate wsDidReceiveUserSettings:[[DLUserSettings alloc] initWithDict:[wsData
                                                                                         objectForKey:@"user_settings"]]];
                [delegate wsDidReceiveUserData:[[DLUser alloc] initWithDict:[wsData objectForKey:@"user"]]];
                [delegate wsDidReceiveServerData:[wsData objectForKey:@"guilds"]];
                [delegate wsDidReceivePrivateChannelData:[wsData objectForKey:@"private_channels"]];
                [delegate wsDidLoadAllData];
                [delegate wsDidReceiveReadStateData:[wsData
                                                     objectForKey:@"read_state"]];
                
            } else if ([type isEqualToString:@"MESSAGE_ACK"]) {
                NSDictionary *wsData = [res objectForKey:@kWSData];
                NSMutableDictionary *messageData = [[[NSMutableDictionary alloc] init] autorelease];
                [messageData setObject:[wsData objectForKey:@"message_id"] forKey:@"id"];
                [messageData setObject:[wsData objectForKey:@"channel_id"] forKey:@"channel_id"];
                [delegate wsDidAcknowledgeMessage:[[DLMessage alloc] initWithDict:messageData]];
            }
            break;
        }
        case OPCodeHello: {
            heartbeatResponseReceived = YES;
            if (shouldResume ) {
                shouldResume = NO;
                NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
                [d setObject:[NSNumber numberWithInt:OPCodeResume] forKey:@kWSOperation];
                NSDictionary *data = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:token, sessionID, [NSNumber numberWithInt:sequenceNumber], nil] forKeys:[NSArray arrayWithObjects:@"token", @"session_id", @"seq", nil]];
                [d setObject:data forKey:@kWSData];
                NSString *str = [[NSString alloc] initWithData:[[CJSONSerializer serializer] serializeDictionary:d error:nil] encoding:NSUTF8StringEncoding];
                [webSocket sendText:str];
            } else {
                NSDictionary *wsData = [res objectForKey:@kWSData];
                heartbeatInterval = [[wsData objectForKey:@"heartbeat_interval"] intValue];
                [NSTimer scheduledTimerWithTimeInterval:heartbeatInterval/1000 target:self selector:@selector(sendWSHeartbeat) userInfo:nil repeats:YES];
                
                NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
                [d setObject:[NSNumber numberWithInt:OPCodeIdentify] forKey:@kWSOperation];
                [d setObject:[NSNumber numberWithBool:NO] forKey:@"compress"];
                NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
                [data setObject:[NSString stringWithString:token] forKey:@"token"];
                NSMutableDictionary *platformProps = [[NSMutableDictionary alloc] init];
                [platformProps setObject:@"Apple macOS" forKey:@"$os"];
                [platformProps setObject:@"Apple macOS" forKey:@"$browser"];
                [platformProps setObject:@"Apple Mac" forKey:@"$device"];
                [data setObject:platformProps forKey:@"properties"];
                [d setObject:data forKey:@kWSData];
                NSString *str = [[NSString alloc] initWithData:[[CJSONSerializer serializer] serializeDictionary:d error:nil] encoding:NSUTF8StringEncoding];
                [webSocket sendText:str];
            }
            
            break;
        }
        case OPCodeHeartbeatAck:
            heartbeatResponseReceived = YES;
            break;
    }
}

@end
