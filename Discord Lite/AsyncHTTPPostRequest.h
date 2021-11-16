//
//  AsyncHTTPPostRequest.h
//  Discord Lite
//
//  Created by Collin Mistr on 10/26/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "AsyncHTTPRequest.h"
#import "DLUtil.h"

@interface AsyncHTTPPostRequest : AsyncHTTPRequest {
    NSDictionary *parameters;
    NSDictionary *files;
    NSString *method;
}

-(id)init;
-(void)start;

-(void)setParameters:(NSDictionary *)inParameters;
-(void)setMethod:(NSString *)inMethod;
-(void)setFiles:(NSDictionary *)inFiles;

@end
