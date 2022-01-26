//
//  DLController.m
//  Discord Lite
//
//  Created by Collin Mistr on 10/25/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLController.h"

@implementation DLController

static DLController* sharedObject = nil;

-(id)init {
    self = [super init];
    [[DLWSController sharedInstance] setDelegate:self];
    loadedChannels = [[NSMutableDictionary alloc] init];
    loadedServers = [[NSMutableDictionary alloc] init];
    [self loadUserDefaults];
    return self;
}

+(DLController *)sharedInstance {
    if (!sharedObject) {
        sharedObject = [[[super allocWithZone: NULL] init] retain];
    }
    return sharedObject;
}
-(void)loadUserDefaults {
    token = [[NSUserDefaults standardUserDefaults] objectForKey:@kDefaultsToken];
    NSLog(@"Loaded token: %@", token);
}

-(DLServer *)selectedServer {
    return selectedServer;
}
-(DLChannel *)selectedChannel {
    return selectedChannel;
}
-(void)setSelectedChannel:(DLChannel *)c {
    selectedChannel = c;
}
-(void)setLoginDelegate:(id <DLLoginDelegate>)inLoginDelegate {
    loginDelegate = inLoginDelegate;
}

-(void)setDelegate:(id <DLControllerDelegate>)inDelegate {
    delegate = inDelegate;
}
-(void)setCaptchaKey:(NSString *)inKey {
    captchaKey = inKey;
}

-(BOOL)isLoggedIn {
    return (token && ![token isEqualToString:@""]);
}

-(void)loginWithEmail:(NSString *)email andPassword:(NSString *)password {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:email, password, nil] forKeys:[NSArray arrayWithObjects:@"email", @"password", nil]];
    if (captchaKey) {
        [params setObject:captchaKey forKey:@"captcha_key"];
    }
    AsyncHTTPPostRequest *req = [[AsyncHTTPPostRequest alloc] init];
    [req setDelegate:self];
    [req setParameters:params];
    [req setIdentifier:RequestIDLogin];
    
    [req setUrl:[NSURL URLWithString:[@API_ROOT stringByAppendingPathComponent:@"auth/login"]]];
    [req start];
}

-(void)loginWithTwoFactorAuthCode:(NSString *)twoFactorCode {
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:twoFactorTicket, twoFactorCode, nil] forKeys:[NSArray arrayWithObjects:@"ticket", @"code", nil]];
    AsyncHTTPPostRequest *req = [[AsyncHTTPPostRequest alloc] init];
    [req setDelegate:self];
    [req setParameters:params];
    [req setIdentifier:RequestIDTwoFactor];
    
    [req setUrl:[NSURL URLWithString:[@API_ROOT stringByAppendingPathComponent:@"auth/mfa/totp"]]];
    [req start];
}

-(void)loadMessagesForChannel:(DLChannel *)c beforeMessage:(DLMessage *)m quantity:(NSInteger)numMsgs {
    if (![c isEqual:selectedChannel]) {
        [selectedChannel release];
        [c retain];
        selectedChannel = c;
        if ([selectedServer isEqual:myServerItem]) {
            [[DLWSController sharedInstance] updateWSForDirectMessageChannel:c];
        } else {
            [[DLWSController sharedInstance] updateWSForChannel:c inServer:selectedServer];
        }
    }
    
    AsyncHTTPGetRequest *req = [[AsyncHTTPGetRequest alloc] init];
    [req setDelegate:self];
    [req setHeaders:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:token, nil] forKeys:[NSArray arrayWithObjects:@"Authorization", nil]]];
    [req setIdentifier:RequestIDMessages];
    NSString *requestURL = [@API_ROOT stringByAppendingPathComponent:[NSString stringWithFormat:@"channels/%@/messages?limit=%ld", c.channelID, numMsgs]];
    if (m != nil) {
        requestURL = [requestURL stringByAppendingString:[NSString stringWithFormat:@"&before=%@", m.messageID]];
    }
    [req setUrl:[NSURL URLWithString:requestURL]];
    [req start];
}

-(void)sendMessage:(DLMessage *)m toChannel:(DLChannel *)c {
    AsyncHTTPPostRequest *req = [[AsyncHTTPPostRequest alloc] init];
    [req setDelegate:self];
    [req setParameters:[m dictRepresentation]];
    if ([m attachments].count > 0) {
        NSMutableDictionary *files = [[NSMutableDictionary alloc] init];
        NSEnumerator *e = [[m attachments] objectEnumerator];
        DLAttachment *a;
        while (a = [e nextObject]) {
            [files setObject:[a attachmentData] forKey:[a filename]];
        }
        [req setFiles:files];
    }
    [req setHeaders:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:token, nil] forKeys:[NSArray arrayWithObjects:@"Authorization", nil]]];
    [req setIdentifier:RequestIDSendMessage];
    NSString *requestURL = [@API_ROOT stringByAppendingPathComponent:[NSString stringWithFormat:@"channels/%@/messages", c.channelID]];
    [req setUrl:[NSURL URLWithString:requestURL]];
    [req start];
}

-(void)acknowledgeMessage:(DLMessage *)m {
    AsyncHTTPPostRequest *req = [[AsyncHTTPPostRequest alloc] init];
    [req setDelegate:self];
    [req setParameters:[NSDictionary dictionaryWithObject:[NSNull null] forKey:@"token"]];
    [req setHeaders:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: token, nil] forKeys:[NSArray arrayWithObjects:@"Authorization", nil]]];
    [req setIdentifier:RequestIDAckMessage];
    NSString *requestURL = [@API_ROOT stringByAppendingPathComponent:[NSString stringWithFormat:@"channels/%@/messages/%@/ack", [m channelID], [m messageID]]];
    [req setUrl:[NSURL URLWithString:requestURL]];
    [req start];
}

-(void)logOutUser {
    AsyncHTTPPostRequest *req = [[AsyncHTTPPostRequest alloc] init];
    [req setDelegate:self];
    [req setParameters:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"apns_voip", @"apns", nil] forKeys:[NSArray arrayWithObjects:@"voip_provider", @"provider", nil]]];
    [req setHeaders:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:token, nil] forKeys:[NSArray arrayWithObjects:@"Authorization", nil]]];
    [req setIdentifier:RequestIDLogout];
    NSString *requestURL = [@API_ROOT stringByAppendingPathComponent:@"auth/logout"];
    [req setUrl:[NSURL URLWithString:requestURL]];
    [req start];
}

-(void)informTypingInChannel:(DLChannel *)c {
    AsyncHTTPPostRequest *req = [[AsyncHTTPPostRequest alloc] init];
    [req setDelegate:self];
    [req setParameters:[NSDictionary dictionaryWithObject:[NSNull null] forKey:@"token"]];
    [req setHeaders:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: token, nil] forKeys:[NSArray arrayWithObjects:@"Authorization", nil]]];
    [req setIdentifier:RequestIDTyping];
    NSString *requestURL = [@API_ROOT stringByAppendingPathComponent:[NSString stringWithFormat:@"channels/%@/typing", [c channelID]]];
    [req setUrl:[NSURL URLWithString:requestURL]];
    [req start];
}

-(NSArray *)userServers {
    NSMutableArray *servers = [[NSMutableArray alloc] init];
    NSEnumerator *e = [[myUserSettings serverPositions] objectEnumerator];
    NSString *serverID;
    while (serverID = [e nextObject]) {
        if ([loadedServers objectForKey:serverID]) {
            [servers addObject:[loadedServers objectForKey:serverID]];
        }
    }
    //Load unordered servers
    e = [[loadedServers allKeys] objectEnumerator];
    while (serverID = [e nextObject]) {
        if ([loadedServers objectForKey:serverID]) {
            if (![servers containsObject:[loadedServers objectForKey:serverID]]) {
                [servers addObject:[loadedServers objectForKey:serverID]];
            }
        }
    }
    [loadedServers setObject:[self myServerItem] forKey:[[self myServerItem] serverID]];
    return servers;
}
-(NSArray *)channelsForServer:(DLServer *)s {
    selectedServer = s;
    [selectedChannel release];
    selectedChannel = [[DLChannel alloc] init];
    NSMutableArray *channels = [[NSMutableArray alloc] init];
    
    NSEnumerator *e = [[loadedChannels allKeys] objectEnumerator];
    NSString *channelKey;
    while (channelKey = [e nextObject]) {
        DLServerChannel *c = [loadedChannels objectForKey:channelKey];
        if ([[c serverID] isEqualToString:[s serverID]]) {
            [channels addObject:c];
        }
    }
    
    NSMutableArray *parentChannels = [[NSMutableArray alloc] init];
    NSMutableArray *uncategorizedChannels = [[NSMutableArray alloc] init];
    NSMutableArray *childChannels = [[NSMutableArray alloc] init];
    
    e = [channels objectEnumerator];
    DLServerChannel *c;
    while (c = [e nextObject]) {
        if (c.type == ChannelTypeHeader) {
            [parentChannels addObject:c];
        } else if (!c.parentID || [c.parentID isEqual:[NSNull null]]) {
            [uncategorizedChannels addObject:c];
            
        } else {
            [childChannels addObject:c];
        }
    }
    
    NSMutableArray *sortedParentChannels = [NSMutableArray arrayWithArray:[[[parentChannels sortedArrayUsingSelector:@selector(compare:)] objectEnumerator] allObjects]];
    NSArray *sortedChildChannels = [[[childChannels sortedArrayUsingSelector:@selector(compare:)] objectEnumerator] allObjects];
    NSArray *sortedUncategorizedChannels = [[[uncategorizedChannels sortedArrayUsingSelector:@selector(compare:)] objectEnumerator] allObjects];
    
    
    
    e = [sortedParentChannels objectEnumerator];
    while (c = [e nextObject]) {
        NSMutableArray *children = [[NSMutableArray alloc] init];
        DLServerChannel *cc;
        NSEnumerator *ee = [sortedChildChannels objectEnumerator];
        while(cc = [ee nextObject]) {
            if ((!cc.parentID || ![cc.parentID isEqual:[NSNull null]]) && [cc.parentID isEqualToString:c.channelID]) {
                [children addObject:cc];
            }
        }
        [c setChildren:children];
        [children release];
    }
    
    e = [sortedUncategorizedChannels objectEnumerator];
    while (c = [e nextObject]) {
        if (c) {
            [sortedParentChannels insertObject:c atIndex:0];
        }
    }
    
    [channels release];
    [uncategorizedChannels release];
    [childChannels release];
    [parentChannels release];
    return sortedParentChannels;
}

-(NSArray *)directMessageChannels {
    selectedServer = [self myServerItem];
    NSMutableArray *dms = [[NSMutableArray alloc] init];
    NSEnumerator *e = [[loadedChannels allKeys] objectEnumerator];
    NSString *channelKey;
    while (channelKey = [e nextObject]) {
        DLDirectMessageChannel *c = [loadedChannels objectForKey:channelKey];
        if ([[c serverID] isEqualToString:[[self myServerItem] serverID]]) {
            [dms addObject:c];
        }
        
    }
    NSArray *sorted = [dms sortedArrayUsingSelector:@selector(compare:)];
    [dms release];
    return sorted;
}

-(DLUser *)myUser {
    return myUser;
}

-(void)startWebSocket {
    [[DLWSController sharedInstance] startWithAuthToken:token];
}
-(void)stopWebSocket {
    [[DLWSController sharedInstance] stop];
}

-(DLServer *)loadedServerWithID:(NSString *)srvID {
    if ([loadedServers objectForKey:srvID]) {
        return [loadedServers objectForKey:srvID];
    }
    return nil;
}
-(DLChannel *)loadedChannelWithID:(NSString *)chanID {
    if ([loadedChannels objectForKey:chanID]) {
        return [loadedChannels objectForKey:chanID];
    }
    return nil;
}

-(DLServer *)myServerItem {
    if (!myServerItem) {
        myServerItem = [[DLServer alloc] init];
        [myServerItem setIconImageData:[NSData dataWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"discord_purple.png"]]];
        [myServerItem setServerID:@"@me"];
    }
    return myServerItem;
}

-(void)queryServer:(DLServer *)s forMembersContainingUsername:(NSString *)username {
    [[DLWSController sharedInstance] queryServer:s forMembersContainingUsername:username];
}


#pragma mark Response Handlers

-(void)handleLoginRequestResponse:(AsyncHTTPRequest *)req {
    
    switch ([req result]) {
        case HTTPResultOK: {
            NSDictionary *resDict = nil;
            if ([req responseData]) {
                resDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:[req responseData] error:nil];
            }
            if ([resDict objectForKey:@"token"] && ![[resDict objectForKey:@"token"] isKindOfClass:[NSNull class]]) {
                token = [[resDict objectForKey:@"token"] retain];
                [[NSUserDefaults standardUserDefaults] setObject:token forKey:@kDefaultsToken];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [loginDelegate didLoginWithError:nil];
            } else if ([resDict objectForKey:@"ticket"] && ![[resDict objectForKey:@"ticket"] isKindOfClass:[NSNull class]]) {
                twoFactorTicket = [[resDict objectForKey:@"ticket"] retain];
                [loginDelegate didReceiveTwoFactorAuthRequest];
            }
            break;
        }
        case HTTPResultErrParameter: {
            NSDictionary *resDict = nil;
            if ([req responseData]) {
                resDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:[req responseData] error:nil];
            }
            if ([resDict objectForKey:@"captcha_key"]) {
                [loginDelegate didReceiveCaptchaRequestOfType:[resDict objectForKey:@"captcha_service"] withSiteKey:[resDict objectForKey:@"captcha_sitekey"]];
            } else {
                NSString *message = @"";
                if ([[resDict objectForKey:[resDict.allKeys objectAtIndex:0]] isKindOfClass:[NSArray class]]) {
                    message = [[resDict objectForKey:[resDict.allKeys objectAtIndex:0]] objectAtIndex:0];
                } else {
                    message = [resDict objectForKey:@"message"];
                }
                [loginDelegate didLoginWithError:[DLError requestErrorWithMessage:message]];
            }
            
            break;
        }
        case HTTPResultErrGeneral: {
            NSDictionary *resDict = nil;
            if ([req responseData]) {
                resDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:[req responseData] error:nil];
            }
            [loginDelegate didLoginWithError:[DLError requestErrorWithMessage:[resDict objectForKey:@"message"]]];
            break;
        }
        case HTTPResultErrConnecting:
            [loginDelegate didLoginWithError:[DLError generalConnectionError]];
            break;
        default:
            break;
    }
}

-(void)handleMessagesRequestResponse:(AsyncHTTPRequest *)req {
    if ([req result] == HTTPResultOK) {
        NSArray *resArray = [[CJSONDeserializer deserializer] deserializeAsArray:[req responseData] error:nil];
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        NSEnumerator *e = [resArray objectEnumerator];
        NSDictionary *messageData;
        while (messageData = [e nextObject]) {
            DLMessage *m = [[DLMessage alloc] initWithDict:messageData];
            [messages addObject:m];
            [m release];
        }
        [delegate messages:messages receivedForChannel:selectedChannel];
        [messages release];
    } else {
        [self handleHTTPRequestError:req];
    }
}

-(void)handleLogoutRequestResponse:(AsyncHTTPRequest *)req {
    if ([req result] == HTTPResultOK) {
        token = @"";
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:@kDefaultsToken];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [loadedChannels release];
        [loadedServers release];
        loadedChannels = [[NSMutableDictionary alloc] init];
        loadedServers = [[NSMutableDictionary alloc] init];
        [myServerItem release];
        myServerItem = nil;
        [myUser release];
        myUser = nil;
        [myUserSettings release];
        myUserSettings = nil;
        [selectedServer release];
        selectedServer = nil;
        [selectedChannel release];
        selectedChannel = nil;
        [delegate didLogoutSuccessfully];
    } else {
        [self handleHTTPRequestError:req];
    }
}

-(void)handleSendMessageRequestResponse:(AsyncHTTPRequest *)req {
    if ([req result] != HTTPResultOK) {
        [self handleHTTPRequestError:req];
    }
}


-(void)handleHTTPRequestError:(AsyncHTTPRequest *)req {
    switch ([req result]) {
        case HTTPResultErrParameter: {
            NSDictionary *resDict = nil;
            if ([req responseData]) {
                resDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:[req responseData] error:nil];
            }
            NSString *message = @"";
            if ([[resDict objectForKey:[resDict.allKeys objectAtIndex:0]] isKindOfClass:[NSArray class]]) {
                message = [[resDict objectForKey:[resDict.allKeys objectAtIndex:0]] objectAtIndex:0];
            } else {
                message = [resDict objectForKey:@"message"];
            }
            [delegate requestDidFailWithError:[DLError requestErrorWithMessage:message]];
            break;
        }
        case HTTPResultErrGeneral: {
            NSDictionary *resDict = nil;
            if ([req responseData]) {
                resDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:[req responseData] error:nil];
            }
            [delegate requestDidFailWithError:[DLError requestErrorWithMessage:[resDict objectForKey:@"message"]]];
            break;
        }
        case HTTPResultErrConnecting:
            [delegate requestDidFailWithError:[DLError generalConnectionError]];
            break;
        default:
            break;
    }
}

#pragma mark Delegated Functions

-(void)requestDidFinishLoading:(AsyncHTTPRequest *)request {
    switch ([request identifier]) {
        case RequestIDLogin:
        case RequestIDTwoFactor:
            [self handleLoginRequestResponse:request];
            break;
        case RequestIDMessages:
            [self handleMessagesRequestResponse:request];
            break;
        case RequestIDLogout:
            [self handleLogoutRequestResponse:request];
            break;
        case RequestIDSendMessage:
            [self handleSendMessageRequestResponse:request];
            break;
        case RequestIDTyping:
            break;
        default:
            break;
    }
    [request release];
}

#pragma mark Websocket Delegated Functions

-(void)wsDidReceiveMessage:(DLMessage *)m {
    DLChannel *c = [self loadedChannelWithID:[m channelID]];
    DLServer *s = [self loadedServerWithID:[c serverID]];
    [c setLastMessageID:[m messageID]];
    [delegate newMessage:m receivedForChannel:c inServer:s];
}

-(void)wsDidReceivePrivateChannelData:(NSArray *)data {
    NSEnumerator *e = [data objectEnumerator];
    NSDictionary *channelData;
    while (channelData = [e nextObject]) {
        if (![loadedChannels objectForKey:[channelData objectForKey:@"id"]]) {
            DLDirectMessageChannel *c = [[DLDirectMessageChannel alloc] initWithDict:channelData];
            [loadedChannels setObject:c forKey:[channelData objectForKey:@"id"]];
            [c release];
        }
    }
}

-(void)wsDidReceiveServerData:(NSArray *)data {
    NSEnumerator *e = [data objectEnumerator];
    NSDictionary *serverData;
    while (serverData = [e nextObject]) {
        if (![loadedServers objectForKey:[serverData objectForKey:@"id"]]) {
            DLServer *s = [[DLServer alloc] initWithDict:serverData];
            [loadedServers setObject:s forKey:[serverData objectForKey:@"id"]];
            [s release];
        }
        NSEnumerator *ee = [[serverData objectForKey:@"channels"] objectEnumerator];
        NSDictionary *channelData;
        while (channelData = [ee nextObject]) {
            if (![loadedChannels objectForKey:[channelData objectForKey:@"id"]]) {
                DLServerChannel *c = [[DLServerChannel alloc] initWithDict:channelData];
                [c setServerID:[serverData objectForKey:@"id"]];
                [loadedChannels setObject:c forKey:[channelData objectForKey:@"id"]];
                [c release];
            }
        }
    }
}

-(void)wsDidReceiveReadStateData:(NSArray *)data {
    NSEnumerator *e = [data objectEnumerator];
    NSDictionary *channelData;
    while (channelData = [e nextObject]) {
        if ([loadedChannels objectForKey:[channelData objectForKey:@"id"]]) {
            DLChannel *c = [loadedChannels objectForKey:[channelData objectForKey:@"id"]];
            [c setMentionCount:[[channelData objectForKey:@"mention_count"] intValue]];
            [[self loadedServerWithID:[c serverID]] addMentionCount:[[channelData objectForKey:@"mention_count"] intValue]];
        }
    }
}

-(void)wsDidReceiveUserData:(DLUser *)u {
    [myUser release];
    [u retain];
    myUser = u;
}

-(void)wsDidReceiveUserSettings:(DLUserSettings *)s {
    [myUserSettings release];
    [s retain];
    myUserSettings = s;
}

-(void)wsDidLoadAllData {
    [delegate initialDataWasReceived];
}

-(void)wsDidAcknowledgeMessage:(DLMessage *)m {
    DLChannel *c = [self loadedChannelWithID:[m channelID]];
    [[self loadedServerWithID:[c serverID]] addMentionCount:[c mentionCount] * -1];
    [c setMentionCount:0];
}

-(void)wsUserWithID:(NSString *)userID didStartTypingInServerWithID:(NSString *)serverID inChannelWithID:(NSString *)channelID withMemberData:(NSDictionary *)memberData {
    if ([channelID isEqualToString:[selectedChannel channelID]]) {
        DLServerMember *m = [[self loadedServerWithID:serverID] memberWithUserID:userID];
        if (!m) {
            m = [[DLServerMember alloc] initWithDict:memberData];
            [[self loadedServerWithID:serverID] addMember:m];
            [m release];
        }
        DLUser *u = [m user];
        if (u && (![u isEqual:myUser])) {
            [u setTyping:YES];
            [delegate userDidStartTypingInSelectedChannel:u];
        }
    }
}
-(void)wsUserWithID:(NSString *)userID didStartTypingInDirectMessageChannelWithID:(NSString *)channelID {
    if ([channelID isEqualToString:[selectedChannel channelID]]) {
        DLUser *u = [selectedChannel recipientWithUserID:userID];
        if (u && (![u isEqual:myUser])) {
            [u setTyping:YES];
            [delegate userDidStartTypingInSelectedChannel:u];
        }
    }
}

-(void)wsDidReceiveMemberData:(NSArray *)memberData forServerWithID:(NSString *)serverID {
    NSMutableArray *members = [[NSMutableArray alloc] init];
    NSEnumerator *e = [memberData objectEnumerator];
    NSDictionary *memberDict;
    while (memberDict = [e nextObject]) {
        DLServerMember *m = [[DLServerMember alloc] initWithDict:memberDict];
        [members addObject:m];
        [m release];
    }
    [delegate members:members didUpdateForServer:[self loadedServerWithID:serverID]];
}
-(void)wsMessageWithID:(NSString *)messageID wasUpdatedWithData:(NSDictionary *)data {
    
}

@end
