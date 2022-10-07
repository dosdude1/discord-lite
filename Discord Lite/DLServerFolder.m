//
//  DLServerFolder.m
//  Discord Lite
//
//  Created by Collin Mistr on 10/6/22.
//  Copyright (c) 2022 dosdude1. All rights reserved.
//

#import "DLServerFolder.h"

@implementation DLServerFolder

-(id)init {
    self = [super init];
    return self;
}

-(id)initWithDict:(NSDictionary *)d {
    self = [self init];
    serverIDs = [[d objectForKey:@"guild_ids"] retain];
    return self;
}

-(NSArray *)serverIDs {
    return serverIDs;
}

@end
