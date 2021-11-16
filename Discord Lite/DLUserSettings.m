//
//  DLUserSettings.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/6/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLUserSettings.h"

@implementation DLUserSettings

-(id)init {
    self = [super init];
    return self;
}

-(id)initWithDict:(NSDictionary *)d {
    self = [self init];
    serverPositions = [[d objectForKey:@"guild_positions"] retain];
    return self;
}

-(NSArray *)serverPositions {
    return serverPositions;
}

@end
