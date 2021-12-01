//
//  ChatItemViewController.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/1/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "ViewController.h"
#import "DLMessage.h"
#import "AttachmentPreviewViewController.h"
#import "DLTextParser.h"

@interface ChatItemViewController : ViewController <DLUserDelegate> {
    DLMessage *representedObject;
    IBOutlet NSView_BGColor *insetView;
    IBOutlet NSTextView *chatTextView;
    CGFloat baseViewHeight;
    IBOutlet NSTextField *usernameTextField;
    IBOutlet NSImageView *avatarImageView;
    IBOutlet NSTextField *timestampTextField;
    NSArray *attachmentViews;
}

-(DLMessage *)representedObject;
-(CGFloat)expectedHeight;

-(void)setRepresentedObject:(DLMessage *)obj;

@end
