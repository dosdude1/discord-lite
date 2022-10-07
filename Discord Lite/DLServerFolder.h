//
//  DLServerFolder.h
//  Discord Lite
//
//  Created by Collin Mistr on 10/6/22.
//  Copyright (c) 2022 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLServerFolder : NSObject {
    NSArray *serverIDs;
}

-(id)init;
-(id)initWithDict:(NSDictionary *)d;
-(NSArray *)serverIDs;

@end
