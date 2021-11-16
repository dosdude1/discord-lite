//
//  HTTPCacheData.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/3/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPCacheData : NSObject {
    NSString *url;
    NSData *data;
}

-(id)init;
-(NSString *)url;
-(NSData *)data;

-(void)setUrl:(NSString *)inUrl;
-(void)setData:(NSData *)inData;

@end
