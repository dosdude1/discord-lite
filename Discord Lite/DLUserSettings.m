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
    NSArray *folderData = [d objectForKey:@"guild_folders"];
    NSMutableArray *tempFolders = [[NSMutableArray alloc] init];
    NSEnumerator *e = [folderData objectEnumerator];
    NSDictionary *folder;
    while (folder = [e nextObject]) {
        [tempFolders addObject:[[[DLServerFolder alloc] initWithDict:folder] autorelease]];
    }
    serverFolders = tempFolders;
    return self;
}

-(NSArray *)serverFolders {
    return serverFolders;
}

@end
