//
//  DLMainWindowController.h
//  Discord Lite
//
//  Created by Collin Mistr on 10/27/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DLController.h"
#import "DLErrorHandler.h"
#import "ServerItemViewController.h"
#import "DynamicScrollView.h"
#import "ChatScrollView.h"
#import "ChannelItemViewController.h"
#import "ChatItemViewController.h"
#import "PaddedTextView.h"
#import "DirectMessageItemViewController.h"
#import "NSView+Border.h"
#import "DLAudioPlayer.h"
#import "HorizontalDynamicScrollView.h"
#import "PendingAttachmentViewController.h"
#import "TagSelectionViewController.h"
#import "DLMessageEditor.h"

@protocol DLMainWindowDelegate <NSObject>
@optional
-(void)logoutWasSuccessful;
@end

@interface DLMainWindowController : NSWindowController <DLControllerDelegate, ServerItemDelegate, ChannelItemDelegate, DLUserDelegate, DMChannelItemDelegate, PendingAttachmentItemDelegate, DLUserTypingDelegate, TagSelectionItemDelegate, DLMessageEditorDelegate, ChatItemViewControllerDelegate, ChatScrollViewDelegate> {
    
    BOOL isLoadingViews;
    BOOL isLoadingMessages;
    BOOL isTyping;
    BOOL madeMentionChange;
    
    IBOutlet NSView_BGColor *messageEntryContainerView;
    IBOutlet NSView_BGColor *channelViewHeader;
    IBOutlet NSView_BGColor *chatViewHeader;
    IBOutlet NSView_BGColor *userInfoView;
    
    NSInteger editingLocation;
    NSInteger tagIndex;
    
    IBOutlet NSScroller_BGColor *serverViewScroller;
    IBOutlet NSScroller_BGColor *channelViewScroller;
    IBOutlet NSScroller_BGColor *chatViewScroller;
    IBOutlet NSScroller_BGColor *messageEntryViewScroller;
    IBOutlet NSScroller_BGColor *tagSelectionViewScroller;
    IBOutlet NSScroller_BGColor *pendingAttachmentViewScroller;
    
    
    IBOutlet DynamicScrollView *serversScrollView;
    IBOutlet DynamicScrollView *channelsScrollView;
    IBOutlet DynamicScrollView *tagSelectionScrollView;
    IBOutlet PaddedTextView *messageEntryTextView;
    IBOutlet NSScrollView *messageEntryScrollView;
    IBOutlet ChatScrollView *chatScrollView;
    IBOutlet NSImageView *myUserAvatarImage;
    IBOutlet NSTextField *myUsernameTextField;
    IBOutlet NSTextField *myDiscTextField;
    IBOutlet NSButton *attachButton;
    
    
    IBOutlet NSTextField *serverLabel;
    IBOutlet NSImageView *chatHeaderImage;
    IBOutlet NSTextField *chatHeaderLabel;
    IBOutlet HorizontalDynamicScrollView *pendingAttachmentsScrollView;
    IBOutlet NSTextField *typingStatusTextField;
    
    IBOutlet NSView *replyToView;
    IBOutlet NSTextField *replyToTextField;
    
    
    DLMessage *lastMessage;
    DLMessageEditor *messageEditor;
    ServerItemViewController *me;
    
    NSArray *serverViews;
    NSArray *channelViews;
    
    NSMutableArray *typingUsers;
    
    CGFloat currentMessageScrollHeight;
    
    NSTimer *typingTimer;
    NSTimer *serverItemTrackingTimer;
    
    id<DLMainWindowDelegate> delegate;
}
- (IBAction)showFileOpenDialog:(id)sender;
- (IBAction)showSettingsMenu:(id)sender;
- (IBAction)removeReferencedMessage:(id)sender;

-(void)setDelegate:(id<DLMainWindowDelegate>)inDelegate;
@end
