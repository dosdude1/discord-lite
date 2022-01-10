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
#import "NSTextView+Menu.h"

@class ChatItemViewController;

@protocol ChatItemViewControllerDelegate <NSObject>
@optional
-(void)addReferencedMessage:(DLMessage *)m;
@end

@interface ChatItemViewController : ViewController <DLUserDelegate, NSViewEventDelegate, NSTextViewMenuDelegate> {
    DLMessage *representedObject;
    id<ChatItemViewControllerDelegate> delegate;
    IBOutlet NSView_BGColor *insetView;
    IBOutlet NSTextView_Menu *chatTextView;
    CGFloat baseViewHeight;
    IBOutlet NSTextField *usernameTextField;
    IBOutlet NSImageView *avatarImageView;
    IBOutlet NSTextField *timestampTextField;
    NSArray *attachmentViews;
    IBOutlet NSView *referencedMessageView;
    IBOutlet NSTextField *referencedMessageTextField;
    IBOutlet NSImageView *referencedMessageAvatarImageView;
    NSMenu *contextMenu;
}

-(DLMessage *)representedObject;
-(CGFloat)expectedHeight;

-(void)setDelegate:(id<ChatItemViewControllerDelegate>)inDelegate;
-(void)setRepresentedObject:(DLMessage *)obj;

@end
