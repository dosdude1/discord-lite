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
-(BOOL)chatViewShouldBeginEditing:(ChatItemViewController *)chatView;
-(void)chatViewUpdatedWithEnteredText;
-(void)chatView:(ChatItemViewController *)chatView didEndEditingWithCommit:(BOOL)didCommit;
@end

@interface ChatItemViewController : ViewController <DLUserDelegate, NSViewEventDelegate, NSTextViewMenuDelegate, DLMessageDelegate> {
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
    BOOL viewHasLoaded;
    NSMenu *contextMenu;
    NSMenuItem *editItem;
    BOOL isEditing;
    IBOutlet NSTextField *editDismissInfoLabel;
    IBOutlet NSTextField *editedInfoLabel;
}

-(DLMessage *)representedObject;
-(CGFloat)expectedHeight;

-(void)setDelegate:(id<ChatItemViewControllerDelegate>)inDelegate;
-(void)setRepresentedObject:(DLMessage *)obj;
-(void)setAllowsEditingContent:(BOOL)editable;
-(void)beginEditingContent;
-(void)endEditingContent;
-(BOOL)isBeingEdited;
-(void)becomeWindowFirstResponderForEditing:(NSWindow *)window;

@end
