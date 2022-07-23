//
//  DLUtil.m
//  Discord Lite
//
//  Created by Collin Mistr on 10/27/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLUtil.h"

@implementation DLUtil

+ (NSImage *)imageResize:(NSImage*)anImage newSize:(NSSize)newSize {
    if (! anImage.isValid) return nil;
    
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
                             initWithBitmapDataPlanes:NULL
                             pixelsWide:newSize.width
                             pixelsHigh:newSize.height
                             bitsPerSample:8
                             samplesPerPixel:4
                             hasAlpha:YES
                             isPlanar:NO
                             colorSpaceName:NSCalibratedRGBColorSpace
                             bytesPerRow:0
                             bitsPerPixel:0];
    rep.size = newSize;
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:rep]];
    [anImage drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    
    NSImage *newImage = [[NSImage alloc] initWithSize:newSize];
    [newImage addRepresentation:rep];
    [rep release];
    return [newImage autorelease];
}
+(NSString *)appVersionString {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}
+(NSString *)CFNetworkVersionString {
    return [[NSBundle bundleWithIdentifier:@"com.apple.CFNetwork"] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
}
+(NSString *)kernelVersion {
    size_t size = 0;
    int mib[] = {CTL_KERN, KERN_OSRELEASE};
    sysctl(mib, sizeof mib / sizeof(int), NULL, &size, NULL, 0);
    if (size > 0) {
        char *str = malloc(size);
        sysctl(mib, sizeof mib / sizeof(int), str, &size, NULL, 0);
        NSString *ret = [[NSString stringWithUTF8String:str] retain];
        free(str);
        return ret;
    }
    return @"";
}
+(NSString *)randomStringWithLength:(NSInteger)len {
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%d", arc4random() % 10];
    }
    
    return randomString;
}
+(NSString *)mimeTypeForExtension:(NSString *)ext {
    NSString *UTI = (NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)ext, NULL);
    NSString *mimeType = (NSString *)UTTypeCopyPreferredTagWithClass((CFStringRef)UTI, kUTTagClassMIMEType);
    if (!mimeType) {
        mimeType = @"application/octet-stream";
    }
    return mimeType;
}
+(NSString *)downloadsPath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Downloads"]]) {
        return [NSHomeDirectory() stringByAppendingPathComponent:@"Downloads"];
    }
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"];
}
+(NSString *)generateSnowflake {
    NSTimeInterval date = [[NSDate date] timeIntervalSince1970];
    long snowflake = (((long)date * 1000) - 1420070400000) * 4194304;
    return [[NSString stringWithFormat:@"%ld", snowflake] autorelease];
}
+(NSDate *)dateFromTimestampString:(NSString *)timestampString {
    if ([timestampString rangeOfString:@"."].location != NSNotFound) {
        timestampString = [timestampString substringToIndex:[timestampString rangeOfString:@"."].location];
    } else {
        timestampString = [timestampString substringToIndex:[timestampString rangeOfString:@"+"].location];
    }
    timestampString = [timestampString stringByAppendingString:@"+0000"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *date = [formatter dateFromString:timestampString];
    [formatter release];
    return date;
}

@end
