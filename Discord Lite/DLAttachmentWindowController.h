//
//  DLAttachmentWindowController.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/12/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DLAttachment.h"
#import "NSView+Events.h"

@protocol DLAttachmentWindowDelegate <NSObject>
@optional
-(void)viewerWindowDidClose;
@end

@interface DLAttachmentWindowController : NSWindowController <DLAttachmentViewerDelegate, NSViewEventDelegate> {
    DLAttachment *viewedAttachment;
    IBOutlet NSView *attachmentTemplateView;
    NSImageView *imgView;
    IBOutlet NSProgressIndicator *progressIndicator;
    id<DLAttachmentWindowDelegate> delegate;
}


-(void)setDelegate:(id<DLAttachmentWindowDelegate>)inDelegate;
-(void)setViewedAttachmemt:(DLAttachment *)a;


@end
