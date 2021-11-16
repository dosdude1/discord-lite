//
//  AttachmentPreviewViewController.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/3/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "ViewController.h"
#import "DLAttachment.h"
#import "NSView+Events.h"
#import "DLAttachmentWindowController.h"

@interface AttachmentPreviewViewController : ViewController <DLAttachmentPreviewDelegate, NSViewEventDelegate, DLAttachmentWindowDelegate> {
    NSView *attachmentView;
    NSImageView *imageView;
    DLAttachment *representedObject;
    DLAttachmentWindowController *attachmentViewerWindow;
    NSString *saveFilePath;
    IBOutlet NSView_BGColor *nonImageAttachmentView;
    
    IBOutlet NSImageView *fileIconImageView;
    IBOutlet NSTextField *filenameTextField;
    IBOutlet NSTextField *sizeTextField;
    IBOutlet NSProgressIndicator *downloadProgressIndicator;
    IBOutlet NSButton *downloadButton;
    
}

-(NSView *)attachmentView;

-(void)setRepresentedObject:(DLAttachment *)inRepresentedObject;

- (IBAction)downloadAttachment:(id)sender;

@end
