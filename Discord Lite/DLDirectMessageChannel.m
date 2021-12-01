//
//  DLDirectMessageChannel.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/3/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLDirectMessageChannel.h"

@implementation DLDirectMessageChannel

-(id)init {
    self = [super init];
    return self;
}

-(id)initWithDict:(NSDictionary *)d {
    self = [super initWithDict:d];
    [self updateWithDict:d];
    return self;
}

-(void)updateWithDict:(NSDictionary *)d {
    [super updateWithDict:d];
    NSMutableArray *rec = [[NSMutableArray alloc] init];
    NSEnumerator *e = [[d objectForKey:@"recipients"] objectEnumerator];
    NSDictionary *recipientData;
    while (recipientData = [e nextObject]) {
        DLUser *user = [[DLUser alloc] initWithDict:recipientData];
        [user setDelegate:self];
        [user loadAvatarData];
        [rec addObject:user];
        [user release];
    }
    recipients = rec;
    [self setUpdateTimestamp];
    
    if (recipients.count == 1) {
        imageData = [[recipients objectAtIndex:0] avatarImageData];
    } else if (recipients.count > 1) {
        imageData = [[NSData alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"discord_group.png"]];
    }
    
    if (recipients.count > 1) {
        subImageData = [[NSData alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"f5k.png"]];
    } else if (recipients.count == 1) {
        subImageData = [[NSData alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"at.png"]];
    }
}

-(void)setUpdateTimestamp {
    if (![lastMessageID isEqual:[NSNull null]]) {
        uint64_t timeMillis = (([lastMessageID doubleValue] / 4194304) + 1420070400000);
        lastUpdateTimestamp = [[NSDate dateWithTimeIntervalSince1970:timeMillis/1000] retain];
    } else {
        lastUpdateTimestamp = [[NSDate dateWithTimeIntervalSince1970:0] retain];
    }
}

-(BOOL)isGroupMessage {
    return recipients.count > 1;
}

-(NSArray *)recipients {
    return recipients;
}
-(NSString *)name {
    if (name == nil || [name isKindOfClass:[NSNull class]]) {
        if (recipients.count == 1) {
            return [[recipients objectAtIndex:0] username];
        } else if (recipients.count > 1) {
            NSString *usernames = @"";
            for (int i = 0; i<recipients.count; i++) {
                if (i < recipients.count - 1) {
                    usernames = [usernames stringByAppendingString:[NSString stringWithFormat:@"%@, ", [[recipients objectAtIndex:i] username]]];
                } else {
                    usernames = [usernames stringByAppendingString:[[recipients objectAtIndex:i] username]];
                }
            }
            return usernames;
        }
    }
    return name;
}
-(NSData *)imageData {
    return imageData;
}
-(NSData *)subImageData {
    return subImageData;
}
-(NSString *)serverID {
    return @"@me";
}
-(NSDate *)lastUpdateTimestamp {
    return lastUpdateTimestamp;
}

-(DLUser *)recipientWithUserID:(NSString *)userID {
    NSEnumerator *e = [recipients objectEnumerator];
    DLUser *user;
    while (user = [e nextObject]) {
        if ([[user userID] isEqualToString:userID]) {
            return user;
        }
    }
    return nil;
}

-(NSArray *)recipientsWithUsernameContainingString:(NSString *)username {
    NSMutableArray *matchedUsers = [[NSMutableArray alloc] init];
    NSEnumerator *e = [recipients objectEnumerator];
    DLUser *user;
    while (user = [e nextObject]) {
        if ([[user username] rangeOfString:username].location != NSNotFound) {
            [matchedUsers addObject:user];
        }
    }
    return matchedUsers;
}

- (NSComparisonResult)compare:(DLDirectMessageChannel *)o {
    if (lastUpdateTimestamp && [o lastUpdateTimestamp]) {
        if ([lastUpdateTimestamp isGreaterThan: [o lastUpdateTimestamp]]) {
            return NSOrderedAscending;
        } else if ([lastUpdateTimestamp isLessThan: [o lastUpdateTimestamp]]) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }
    return NSOrderedSame;
}

-(void)setLastMessageID:(NSString *)msgID {
    [super setLastMessageID:msgID];
    [self setUpdateTimestamp];
}

-(void)dealloc {
    [recipients release];
    [super dealloc];
}

#pragma mark Delegated Functions

-(void)avatarDidUpdateWithData:(NSData *)data {
    if (recipients.count == 1) {
        imageData = data;
        [delegate channel:self imageDidUpdateWithData:data];
    }
}

@end
