//
//  DLServerMember.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/22/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLUser.h"

@interface DLServerMember : NSObject {
    DLUser *user;
    NSArray *roles;
}

-(id)initWithDict:(NSDictionary *)d;

-(DLUser *)user;
-(NSArray *)roles;

@end
