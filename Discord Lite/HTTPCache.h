//
//  HTTPCache.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/3/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPCacheData.h"

@interface HTTPCache : NSObject {
    NSMutableDictionary *cacheData;
}

-(id)init;
+(HTTPCache *)sharedInstance;
-(NSData *)cachedDataForURL:(NSString *)url;
-(void)setCachedData:(NSData *)data forURL:(NSString *)url;

@end
