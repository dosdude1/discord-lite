//
//  PendingAttachmentViewController.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/14/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "ViewController.h"
#import "DLAttachment.h"

@class PendingAttachmentViewController;

@protocol PendingAttachmentItemDelegate <NSObject>
@optional
-(void)pendingAttachmentItemWasRemoved:(PendingAttachmentViewController *)item;
@end

@interface PendingAttachmentViewController : ViewController {
    IBOutlet NSImageView *attachmentImageView;
    DLAttachment *representedObject;
    id<PendingAttachmentItemDelegate> delegate;
    IBOutlet NSTextField *filenameTextField;
}

-(DLAttachment *)representedObject;

-(void)setDelegate:(id<PendingAttachmentItemDelegate>)inDelegate;
-(void)setRepresentedObject:(DLAttachment *)a;

- (IBAction)deleteItem:(id)sender;

@end
