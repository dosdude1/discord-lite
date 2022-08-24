//
//  DLURLProtocol.h
//  Discord Lite
//
//  Created by Collin Mistr on 8/22/22.
//  Copyright (c) 2022 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+Compress.h"
#import "DLPreferencesHandler.h"

typedef enum {
    SGIdentity = 0,
    SGGzip = 1,
    SGDeflate = 2
} SGCompression;

@interface DLURLProtocol : NSURLProtocol {
    NSInputStream *HTTPStream;
    CFHTTPMessageRef HTTPMessage;
    NSHTTPURLResponse *URLResponse;
    NSMutableData *buffer;
    BOOL validatesSecureCertificate;
    SGCompression compression;
}

@end
