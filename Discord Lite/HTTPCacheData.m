//
//  HTTPCacheData.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/3/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "HTTPCacheData.h"

@implementation HTTPCacheData

-(id)init {
    self = [super init];
    return self;
}
-(NSString *)url {
    return url;
}
-(NSData *)data {
    return data;
}

-(void)setUrl:(NSString *)inUrl {
    [url release];
    [inUrl retain];
    url = inUrl;
}
-(void)setData:(NSData *)inData {
    [data release];
    [inData retain];
    data = inData;
}

@end
