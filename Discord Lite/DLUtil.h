//
//  DLUtil.h
//  Discord Lite
//
//  Created by Collin Mistr on 10/27/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <sys/sysctl.h>
#import "BezierPathRoundedRect.h"

@interface DLUtil : NSObject

+(NSImage *)imageResize:(NSImage*)anImage newSize:(NSSize)newSize cornerRadius:(CGFloat)radius;
+(NSString *)appVersionString;
+(NSString *)CFNetworkVersionString;
+(NSString *)kernelVersion;
+(NSString *)randomStringWithLength:(NSInteger)len;
+(NSString *)mimeTypeForExtension:(NSString *)ext;
+(NSString *)downloadsPath;
+(NSString *)generateSnowflake;
+(NSDate *)dateFromTimestampString:(NSString *)timestampString;

@end
