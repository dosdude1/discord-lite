//
//  PendingAttachmentViewController.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/14/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "PendingAttachmentViewController.h"

@implementation PendingAttachmentViewController

-(void)setDelegate:(id<PendingAttachmentItemDelegate>)inDelegate {
    delegate = inDelegate;
}

-(void)setRepresentedObject:(DLAttachment *)a {
    [representedObject release];
    [a retain];
    representedObject = a;
    
    if ([representedObject type] == AttachmentTypeImage) {
        [attachmentImageView setImage:[[[NSImage alloc] initWithData:[representedObject attachmentData]] autorelease]];
    } else {
        [attachmentImageView setImage:[[NSWorkspace sharedWorkspace] iconForFileType:[[representedObject filename] pathExtension]]];
        [filenameTextField setHidden:NO];
        [filenameTextField setStringValue:[representedObject filename]];
    }
    
    
}

-(DLAttachment *)representedObject {
    return representedObject;
}

- (IBAction)deleteItem:(id)sender {
    [delegate pendingAttachmentItemWasRemoved:self];
}

-(void)dealloc {
    [representedObject release];
    [self.view release];
    [super dealloc];
}
@end
