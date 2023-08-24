//
//  DLAttachment.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/2/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLAttachment.h"

@implementation DLAttachment

-(id)init {
    self = [super init];
    type = AttachmentTypeImage;
    maxScaledWidth = 275.0;
    return self;
}
-(id)initWithDict:(NSDictionary *)d {
    self = [self init];
    attachmentID = [[d objectForKey:@"id"] retain];
    filename = [[d objectForKey:@"filename"] retain];
    url = [[d objectForKey:@"url"] retain];
    proxyURL = [[d objectForKey:@"proxy_url"] retain];
    width = [[d objectForKey:@"width"] intValue];
    height = [[d objectForKey:@"height"] intValue];
    mimeType = [[d objectForKey:@"content_type"] retain];
    if (!mimeType) {
        mimeType = @"application/octet-stream";
    }
    fileSize = [[d objectForKey:@"size"] intValue];
    if ([mimeType rangeOfString:@"image/"].location != NSNotFound) {
        type = AttachmentTypeImage;
    } else {
        type = AttachmentTypeFile;
    }
    return self;
}

-(void)loadScaledData {
    req = [[AsyncHTTPGetRequest alloc] init];
    [req setDelegate:self];
    [req setUrl:[proxyURL stringByAppendingString:[NSString stringWithFormat:@"?width=%ld&height=%ld", (NSInteger)[self scaledWidth], (NSInteger)[self scaledHeight]]]];
    [req setCached:NO];
    [req setIdentifier:AttachmentRequestPreview];
    [req start];
}
-(void)loadFullData {
    req = [[AsyncHTTPGetRequest alloc] init];
    [req setDelegate:self];
    [req setUrl:proxyURL];
    [req setCached:NO];
    [req setIdentifier:AttachmentRequestFull];
    [req start];
}
-(void)downloadToPath:(NSString *)path {
    [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    downloadFileHandle = [[NSFileHandle fileHandleForUpdatingAtPath:path] retain];
    req = [[AsyncHTTPGetRequest alloc] init];
    [req setDelegate:self];
    [req setUrl:url];
    [req setCached:NO];
    [req setDownloadingFile:downloadFileHandle];
    [req setIdentifier:AttachmentRequestDownload];
    [req start];
}
-(void)saveToPath:(NSString *)path {
    [attachmentData writeToFile:path atomically:YES];
}

-(void)setViewerDelegate:(id<DLAttachmentViewerDelegate>)inDelegate {
    viewerDelegate = inDelegate;
}
-(void)setPreviewDelegate:(id<DLAttachmentPreviewDelegate>)inDelegate {
    previewDelegate = inDelegate;
}

-(NSString *)attachmentID {
    return attachmentID;
}
-(NSString *)filename {
    return filename;
}
-(NSString *)url {
    return url;
}
-(NSString *)proxyURL {
    return proxyURL;
}
-(NSInteger)width {
    return width;
}
-(NSInteger)height {
    return height;
}
-(CGFloat)scaledWidth {
    if (type == AttachmentTypeImage) {
        if (width <= maxScaledWidth) {
            return width;
        }
        return maxScaledWidth;
    }
    return 275;
}
-(CGFloat)scaledHeight {
    if (type == AttachmentTypeImage) {
        if (width > maxScaledWidth) {
            CGFloat ratio = maxScaledWidth * 1.0 / width;
            return height * ratio;
        }
        return height;
    }
    return 62;
}
-(NSData *)attachmentData {
    return attachmentData;
}
-(NSData *)scaledAttachmentData {
    return scaledAttachmentData;
}
-(NSString *)mimeType {
    return mimeType;
}
-(NSInteger)fileSize {
    return fileSize;
}
-(AttachmentType)type {
    return type;
}

-(void)setAttachmentData:(NSData *)d {
    [attachmentData release];
    [d retain];
    attachmentData = d;
}
-(void)setFilename:(NSString *)inFilename {
    [filename release];
    [inFilename retain];
    filename = inFilename;
}
-(void)setWidth:(CGFloat)inWidth {
    width = inWidth;
}
-(void)setHeight:(CGFloat)inHeight {
    height = inHeight;
}
-(void)setType:(AttachmentType)inType {
    type = inType;
}
-(void)setMaxScaledWidth:(CGFloat)inWidth {
    maxScaledWidth = inWidth;
}
-(void)setMimeType:(NSString *)inMimeType {
    [mimeType release];
    [inMimeType retain];
    mimeType = inMimeType;
    if ([mimeType rangeOfString:@"image/"].location != NSNotFound) {
        type = AttachmentTypeImage;
    } else {
        type = AttachmentTypeFile;
    }
}

-(BOOL)isEqual:(DLAttachment *)a {
    return [filename isEqualToString:[a filename]];
}

-(void)dealloc {
    [req setDelegate:nil];
    [self setPreviewDelegate:nil];
    [self setViewerDelegate:nil];
    [attachmentData release];
    [scaledAttachmentData release];
    [super dealloc];
}


#pragma mark Delegated Functions

-(void)requestDidFinishLoading:(AsyncHTTPRequest *)request {
    
    if ([request result] == HTTPResultOK) {
        if ([request identifier] == AttachmentRequestPreview) {
            [scaledAttachmentData release];
            scaledAttachmentData = [[request responseData] retain];
            [previewDelegate attachment:self previewDataWasUpdated:[request responseData]];
        } else if ([request identifier] == AttachmentRequestFull) {
            [attachmentData release];
            attachmentData = [[request responseData] retain];
            [viewerDelegate attachment:self viewerDataWasUpdated:[request responseData]];
            
        } else if ([request identifier] == AttachmentRequestDownload) {
            [downloadFileHandle release];
            [previewDelegate attachmentDownloadDidComplete:self];
        }
    }
    [request release];
    req = nil;
}

-(void)responseDataDidUpdateWithSize:(NSInteger)size {
    if ([previewDelegate respondsToSelector:@selector(attachment:downloadPercentageWasUpdated:)]) {
        float percent = ((100.0/fileSize)*size);
        [previewDelegate attachment:self downloadPercentageWasUpdated:percent];
    }
}

@end
