//
//  AttachmentPreviewViewController.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/3/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "AttachmentPreviewViewController.h"

@implementation AttachmentPreviewViewController

-(NSView *)attachmentView {
    return attachmentView;
}

-(void)setRepresentedObject:(DLAttachment *)inRepresentedObject {
    [representedObject release];
    [inRepresentedObject retain];
    representedObject = inRepresentedObject;
    [representedObject setPreviewDelegate:self];
    
    NSRect frame = NSMakeRect(0, 0, [representedObject scaledWidth], [representedObject scaledHeight]);
    
    if ([representedObject type] == AttachmentTypeImage) {
        imageView = [[[NSImageView alloc] initWithFrame:frame] autorelease];
        attachmentView = imageView;
        
        //Add invisible overlay to handle mouse events
        NSView_Events *eventHandlerView = [[[NSView_Events alloc] initWithFrame:frame] autorelease];
        [eventHandlerView setDelegate:self];
        [attachmentView addSubview:eventHandlerView];
        [representedObject loadScaledData];
    } else {
        attachmentView = nonImageAttachmentView;
        
        [fileIconImageView setImage:[[NSWorkspace sharedWorkspace] iconForFileType:[[representedObject filename] pathExtension]]];
        [filenameTextField setStringValue:[representedObject filename]];
        NSString *sizeString = @"";
        if ([representedObject fileSize] < 100000) {
            sizeString = [NSString stringWithFormat:@"%.2f KB", [representedObject fileSize] / 1000.0];
        } else if ([representedObject fileSize] > 100000 && [representedObject fileSize] < 100000000) {
            sizeString = [NSString stringWithFormat:@"%.2f MB", [representedObject fileSize] / 1000000.0];
        } else {
            sizeString = [NSString stringWithFormat:@"%.2f GB", [representedObject fileSize] / 100000000.0];
        }
        [sizeTextField setStringValue:sizeString];
    }
}

- (IBAction)downloadAttachment:(id)sender {
    [downloadButton setHidden:YES];
    [downloadProgressIndicator setHidden:NO];
    [downloadProgressIndicator setIndeterminate:YES];
    [downloadProgressIndicator startAnimation:self];
    
    [saveFilePath release];
    
    NSString *path = [DLUtil downloadsPath];
    
    NSFileManager *man = [NSFileManager defaultManager];
    saveFilePath = [path stringByAppendingPathComponent:[representedObject filename]];
    
    NSInteger i = 1;
    while ([man fileExistsAtPath:saveFilePath]) {
        NSString *testName = [NSString stringWithFormat:@"%@-%ld.%@", [[representedObject filename] stringByDeletingPathExtension], i, [[representedObject filename] pathExtension]];
        saveFilePath = [path stringByAppendingPathComponent:testName];
        i++;
    }
    
    [saveFilePath retain];
    [representedObject downloadToPath:saveFilePath];
}

-(void)dealloc {
    [representedObject setPreviewDelegate:nil];
    [representedObject release];
    [attachmentViewerWindow setDelegate:nil];
    [attachmentViewerWindow release];
    [super dealloc];
}

#pragma mark Delegated Functions

-(void)attachment:(DLAttachment *)a previewDataWasUpdated:(NSData *)data {
    //Check type
    //if image:
    [imageView setImage:[[[NSImage alloc] initWithData:data] autorelease]];
}
-(void)attachment:(DLAttachment *)a downloadPercentageWasUpdated:(float)percent {
    if ([downloadProgressIndicator isIndeterminate]) {
        [downloadProgressIndicator setIndeterminate:NO];
        [downloadProgressIndicator setMinValue:0.0];
        [downloadProgressIndicator setMaxValue:100.0];
    }
    [downloadProgressIndicator setDoubleValue:percent];
}
-(void)attachmentDownloadDidComplete:(DLAttachment *)a {
    [downloadProgressIndicator stopAnimation:self];
    [downloadProgressIndicator setHidden:YES];
    [downloadButton setHidden:NO];
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.DownloadFileFinished" object:saveFilePath];
}
-(void)mouseWasDepressedWithEvent:(NSEvent *)event {
    attachmentViewerWindow = [[DLAttachmentWindowController alloc] initWithWindowNibName:@"DLAttachmentWindowController"];
    [attachmentViewerWindow setDelegate:self];
    [attachmentViewerWindow setViewedAttachmemt:representedObject];
    [attachmentViewerWindow showWindow:attachmentViewerWindow.window];
    
}
-(void)viewerWindowDidClose {
    [attachmentViewerWindow release];
    attachmentViewerWindow = nil;
}


@end
