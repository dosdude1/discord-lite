//
//  AsyncHTTPRequest.h
//  Discord Lite
//
//  Created by Collin Mistr on 10/26/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"
#import "DLUtil.h"
#import "HTTPCache.h"

typedef enum {
    HTTPResultOK = 0,
    HTTPResultErrConnecting = 1,
    HTTPResultErrParameter = 2,
    HTTPResultErrGeneral = 3
}HTTPResult;

@class AsyncHTTPRequest;

@protocol AsyncHTTPRequestDelegate <NSObject>
@optional
-(void)requestDidFinishLoading:(AsyncHTTPRequest *)request;
-(void)responseDataDidUpdateWithSize:(NSInteger)size;
@end

@interface AsyncHTTPRequest : NSObject {
    NSMutableData *responseData;
    HTTPResult result;
    NSDictionary *headers;
    NSURL *url;
    NSFileHandle *downloadingFile;
    int identifier;
    NSInteger dataLength;
    id <AsyncHTTPRequestDelegate> delegate;
    BOOL cached;
    BOOL isFileDownload;
}
-(id)init;
-(void)start;
-(NSData *)responseData;
-(HTTPResult)result;
-(int)identifier;
-(NSString *)userAgentString;

-(void)setHeaders:(NSDictionary *)inHeaders;
-(void)setUrl:(NSURL *)inUrl;
-(void)setIdentifier:(int)inIdentifier;
-(void)setDelegate:(id <AsyncHTTPRequestDelegate>)inDelegate;
-(void)setCached:(BOOL)inCached;
-(void)setDownloadingFile:(NSFileHandle *)inDownloadingFile;

@end
