//
//  DLServerMember.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/22/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLServerMember.h"

@implementation DLServerMember

-(id)init {
    self = [super init];
    return self;
}

-(id)initWithDict:(NSDictionary *)d {
    self = [self init];
    user = [[DLUser alloc] initWithDict:[d objectForKey:@"user"]];
    roles = [[d objectForKey:@"roles"] retain];
    return self;
}

-(DLUser *)user {
    return user;
}
-(NSArray *)roles {
    return roles;
}

-(void)dealloc {
    [user release];
    [super dealloc];
}

@end
