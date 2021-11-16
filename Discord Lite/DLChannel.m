//
//  DLChannel.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/1/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLChannel.h"

@implementation DLChannel

-(id)init {
    self = [super init];
    mentionCount = 0;
    channelID = @"";
    subImageData = [[NSData alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"uI4.png"]];
    return self;
}

-(id)initWithDict:(NSDictionary *)d {
    self = [self init];
    [self updateWithDict:d];
    return self;
}

-(void)updateWithDict:(NSDictionary *)d {
    channelID = [[d objectForKey:@"id"] retain];
    name = [[d objectForKey:@"name"] retain];
    type = [[d objectForKey:@"type"] intValue];
    lastMessageID = [[d objectForKey:@"last_message_id"] retain];
}

-(void)setDelegate:(id<DLChannelDelegate>)inDelegate {
    delegate = inDelegate;
}

-(NSString *)channelID {
    return channelID;
}
-(ChannelType)type {
    return type;
}
-(NSString *)name {
    return name;
}
-(NSData *)imageData {
    return imageData;
}
-(NSData *)subImageData {
    return subImageData;
}
-(NSArray *)children {
    return nil;
}
-(NSInteger)mentionCount {
    return mentionCount;
}
-(NSString *)serverID {
    return @"none";
}
-(NSString *)lastMessageID {
    return lastMessageID;
}
-(void)setServerID:(NSString *)inServerID {
    //Doesn't exist
}
-(void)setLastMessageID:(NSString *)msgID {
    [lastMessageID release];
    [msgID retain];
    lastMessageID = msgID;
}
-(BOOL)isEqual:(DLChannel *)c {
    return [channelID isEqualToString:[c channelID]];
}
-(void)notifyOfNewMention {
    mentionCount++;
    [delegate mentionsUpdatedForChannel:self];
}
-(void)setMentionCount:(NSInteger)inMentions {
    mentionCount = inMentions;
    [delegate mentionsUpdatedForChannel:self];
}
- (NSComparisonResult)compare:(DLChannel *)o {
    return NSOrderedSame;
}
@end
