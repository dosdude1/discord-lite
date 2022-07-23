//
//  DLServerChannel.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/1/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLServerChannel.h"

@implementation DLServerChannel

-(id)initWithDict:(NSDictionary *)d {
    self = [super initWithDict:d];
    [self updateWithDict:d];
    return self;
}

-(void)updateWithDict:(NSDictionary *)d {
    [super updateWithDict:d];
    parentID = [[d objectForKey:@"parent_id"] retain];
    serverID = [[d objectForKey:@"guild_id"] retain];
    topic = [[d objectForKey:@"topic"] retain];
    position = [[d objectForKey:@"position"] intValue];
}

-(NSString *)name {
    return name;
}
-(NSString *)parentID {
    return parentID;
}
-(NSString *)serverID {
    return serverID;
}
-(NSString *)topic {
    return topic;
}
-(NSInteger) position {
    return position;
}

- (NSComparisonResult)compare:(DLServerChannel *)o {
    if (position > o.position) {
        return NSOrderedDescending;
    } else if (position < o.position) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }
}

-(NSArray *)children {
    return children;
}

-(void)setChildren:(NSArray *)inChildren {
    [children release];
    [inChildren retain];
    children = inChildren;
}
-(void)setServerID:(NSString *)inServerID {
    [serverID release];
    [inServerID retain];
    serverID = inServerID;
}

-(void)dealloc {
    [children release];
    [serverID release];
    [super dealloc];
}

@end
