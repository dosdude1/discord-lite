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
#include "curl_headers/curl.h"
#import "AsyncHTTPRequestSequencer.h"

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

@interface AsyncHTTPRequest : NSObject <AsyncHTTPRequestSequencerProtocol> {
    CURL *curlRequestHandle;
    NSMutableData *responseData;
    HTTPResult result;
    NSDictionary *headers;
    NSString *url;
    NSFileHandle *downloadingFile;
    int identifier;
    id <AsyncHTTPRequestDelegate> delegate;
    BOOL cached;
    BOOL isFileDownload;
    struct curl_slist *rootHeader;
    char *postData;
}
-(id)init;
-(void)initializeRequest;
-(void)start;
-(NSMutableData *)responseData;
-(HTTPResult)result;
-(int)identifier;
-(NSString *)userAgentString;
-(NSFileHandle *)downloadingFile;

-(void)setHeaders:(NSDictionary *)inHeaders;
-(void)setUrl:(NSString *)inUrl;
-(void)setIdentifier:(int)inIdentifier;
-(void)setDelegate:(id <AsyncHTTPRequestDelegate>)inDelegate;
-(void)setCached:(BOOL)inCached;
-(void)setDownloadingFile:(NSFileHandle *)inDownloadingFile;

-(void)requestDidFinishLoading;
-(void)dataChunkWasDownloaded;

@end
