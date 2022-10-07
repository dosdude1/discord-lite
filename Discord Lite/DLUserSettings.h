//
//  DLUserSettings.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/6/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLServerFolder.h"

@interface DLUserSettings : NSObject {
    NSArray *serverFolders;
}

-(id)init;
-(id)initWithDict:(NSDictionary *)d;

-(NSArray *)serverFolders;

@end
