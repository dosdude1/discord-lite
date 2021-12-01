//
//  DLServerChannel.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/1/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLChannel.h"

@interface DLServerChannel : DLChannel {
    NSString *parentID;
    NSString *serverID;
    NSString *topic;
    NSInteger position;
    NSArray *children;
}

-(id)initWithDict:(NSDictionary *)d;
-(void)updateWithDict:(NSDictionary *)d;

-(NSString *)name;
-(NSString *)parentID;
-(NSString *)serverID;
-(NSString *)topic;
-(NSInteger) position;
-(NSArray *)children;

- (NSComparisonResult)compare:(DLServerChannel *)o;

-(void)setChildren:(NSArray *)inChildren;
-(void)setServerID:(NSString *)inServerID;


@end
