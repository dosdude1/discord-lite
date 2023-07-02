//
//  DLUtil.m
//  Discord Lite
//
//  Created by Collin Mistr on 10/27/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLUtil.h"

@implementation DLUtil

static NSDictionary *superPropertiesDict;

+(NSImage *)imageResize:(NSImage*)anImage newSize:(NSSize)newSize cornerRadius:(CGFloat)radius {
    /*if (! anImage.isValid) return nil;
    
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
    return [newImage autorelease];*/
    
    [anImage setScalesWhenResized:YES];
    NSImage *smallImage = [[NSImage alloc] initWithSize: newSize];
    [smallImage lockFocus];
    [anImage setSize: newSize];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    if (radius != 0) {
        NSBezierPath *clipPath = [BezierPathRoundedRect bezierPathWithRoundedRect:NSMakeRect(0, 0, anImage.size.width, anImage.size.height) radius:radius];
        [clipPath setWindingRule:NSEvenOddWindingRule];
        [clipPath addClip];
    }
    [anImage drawAtPoint:NSZeroPoint fromRect:NSMakeRect(0, 0, newSize.width, newSize.height) operation:NSCompositeSourceOver fraction:1.0];
    [smallImage unlockFocus];
    return [smallImage autorelease];
}
+(NSString *)appVersionString {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}
+(NSString *)networkVersionString {
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
+(NSString *)userAgentString {
    return [NSString stringWithFormat:@"DiscordLite/%@ CFNetwork/%@ Darwin/%@", [DLUtil appVersionString], [DLUtil networkVersionString], [DLUtil kernelVersion]];
}
+(NSString *)superPropertiesString {
    if (!superPropertiesDict) {
        superPropertiesDict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"Mac OS X", @"Discord Client", @"stable", @"0.0.266", [DLUtil kernelVersion], @"x64", @"en-US", @"209354", [NSNull null], nil] forKeys:[NSArray arrayWithObjects:@"os", @"browser", @"release_channel", @"client_version", @"os_version", @"os_arch", @"system_locale", @"client_build_number", @"client_event_source", nil]];
    }
    NSData *serializedData = [[CJSONSerializer serializer] serializeDictionary:superPropertiesDict error:nil];
    return [[NSString encodeBase64WithData:serializedData] autorelease];
}

@end
