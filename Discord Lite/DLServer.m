//
//  DLServer.m
//  Discord Lite
//
//  Created by Collin Mistr on 10/27/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLServer.h"

@implementation DLServer


-(id)init {
    self = [super init];
    mentionCount = 0;
    serverID = @"";
    return self;
}

-(id)initWithDict:(NSDictionary *)d {
    self = [self init];
    serverID = [[d objectForKey:@"id"] retain];
    name = [[d objectForKey:@"name"] retain];
    iconID = [[d objectForKey:@"icon"] retain];
    NSMutableArray *membersList = [[NSMutableArray alloc] init];
    NSEnumerator *e = [[d objectForKey:@"members"] objectEnumerator];
    NSDictionary *memberData;
    while (memberData = [e nextObject]) {
        DLServerMember *m = [[DLServerMember alloc] initWithDict:memberData];
        [membersList addObject:m];
        [m release];
    }
    members = membersList;
    [self loadIconData];
    return self;
}


-(void)loadIconData {
    if (iconID && ![iconID isKindOfClass:[NSNull class]]) {
        AsyncHTTPGetRequest *req = [[AsyncHTTPGetRequest alloc] init];
        [req setDelegate:self];
        [req setUrl:[@IconCDNRoot stringByAppendingString:[NSString stringWithFormat:@"/%@/%@.png", serverID, iconID]]];
        [req setCached:YES];
        [req start];
    }
}
-(NSString *)serverID {
    return serverID;
}
-(NSString *)name {
    return name;
}
-(NSString *)iconID {
    return iconID;
}
-(NSData *)iconImageData {
    if (!iconImageData) {
        iconImageData = [NSData dataWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"discord_placeholder.png"]];
    }
    return iconImageData;
}
-(NSInteger)mentionCount {
    return mentionCount;
}
-(NSArray *)members {
    return members;
}
-(void)setDelegate:(id <DLServerDelegate>)inDelegate {
    delegate = inDelegate;
}

-(void)setServerID:(NSString *)inId {
    [serverID release];
    [inId retain];
    serverID = inId;
}
-(void)setName:(NSString *)inName {
    [name release];
    [inName retain];
    name = inName;
}
-(void)setIconImageData:(NSData *)data {
    [iconImageData release];
    [data retain];
    iconImageData = data;
}

-(void)addMember:(DLServerMember *)m {
    [members addObject:m];
}

-(DLServerMember *)memberWithUserID:(NSString *)userID {
    NSEnumerator *e = [members objectEnumerator];
    DLServerMember *m;
    while (m = [e nextObject]) {
        if ([[[m user] userID] isEqualToString:userID]) {
            return m;
        }
    }
    return nil;
}

-(NSArray *)membersWithUsernameContainingString:(NSString *)username {
    NSMutableArray *matchedMembers = [[NSMutableArray alloc] init];
    NSEnumerator *e = [members objectEnumerator];
    DLServerMember *m;
    while (m = [e nextObject]) {
        if ([[[m user] username] rangeOfString:username].location != NSNotFound) {
            [matchedMembers addObject:m];
        }
    }
    return matchedMembers;
}

-(void)notifyOfNewMention {
    mentionCount++;
    [delegate mentionCountDidUpdate];
}
-(void)addMentionCount:(NSInteger)inMentions; {
    mentionCount += inMentions;
    [delegate mentionCountDidUpdate];
}

-(BOOL)isEqual:(DLServer *)object {
    return [serverID isEqualToString:[object serverID]];
}

#pragma mark Delegated Functions

-(void)requestDidFinishLoading:(AsyncHTTPRequest *)request {
    
    if ([request result] == HTTPResultOK) {
        iconImageData = [[request responseData] retain];
        [delegate iconDidUpdateWithData:[request responseData]];
    }
    [request release];
}

@end
