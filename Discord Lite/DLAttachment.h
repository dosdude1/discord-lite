//
//  DLAttachment.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/2/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncHTTPGetRequest.h"

typedef enum {
    AttachmentRequestPreview = 0,
    AttachmentRequestFull = 1,
    AttachmentRequestDownload = 2
}AttachmentRequest;

typedef enum {
    AttachmentTypeImage = 0,
    AttachmentTypeFile = 1
} AttachmentType;

@class DLAttachment;

@protocol DLAttachmentViewerDelegate <NSObject>
@optional
-(void)attachment:(DLAttachment *)a viewerDataWasUpdated:(NSData *)data;
@end

@protocol DLAttachmentPreviewDelegate <NSObject>
@optional
-(void)attachment:(DLAttachment *)a previewDataWasUpdated:(NSData *)data;
-(void)attachment:(DLAttachment *)a downloadPercentageWasUpdated:(float)percent;
-(void)attachmentDownloadDidComplete:(DLAttachment *)a;
@end

@interface DLAttachment : NSObject <AsyncHTTPRequestDelegate> {
    NSString *attachmentID;
    NSString *filename;
    NSString *url;
    NSString *proxyURL;
    NSInteger width;
    NSInteger height;
    NSData *attachmentData;
    NSData *scaledAttachmentData;
    NSString *mimeType;
    CGFloat maxScaledWidth;
    NSInteger fileSize;
    AttachmentType type;
    AsyncHTTPRequest *req;
    NSFileHandle *downloadFileHandle;
    id<DLAttachmentViewerDelegate> viewerDelegate;
    id<DLAttachmentPreviewDelegate> previewDelegate;
}

-(id)init;
-(id)initWithDict:(NSDictionary *)d;

-(void)loadScaledData;
-(void)loadFullData;
-(void)downloadToPath:(NSString *)path;
-(void)saveToPath:(NSString *)path;

-(NSString *)attachmentID;
-(NSString *)filename;
-(NSString *)url;
-(NSString *)proxyURL;
-(NSInteger)width;
-(NSInteger)height;
-(CGFloat)scaledWidth;
-(CGFloat)scaledHeight;
-(NSData *)attachmentData;
-(NSData *)scaledAttachmentData;
-(NSString *)mimeType;
-(NSInteger)fileSize;
-(AttachmentType)type;

-(void)setAttachmentData:(NSData *)d;
-(void)setFilename:(NSString *)inFilename;
-(void)setWidth:(CGFloat)inWidth;
-(void)setHeight:(CGFloat)inHeight;
-(void)setType:(AttachmentType)inType;
-(void)setMaxScaledWidth:(CGFloat)inWidth;
-(void)setMimeType:(NSString *)inMimeType;

-(void)setViewerDelegate:(id<DLAttachmentViewerDelegate>)inDelegate;
-(void)setPreviewDelegate:(id<DLAttachmentPreviewDelegate>)inDelegate;

@end
