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

@protocol DLMainWindowDelegate <NSObject>
@optional
-(void)logoutWasSuccessful;
@end

@interface DLMainWindowController : NSWindowController <DLControllerDelegate, ServerItemDelegate, ChannelItemDelegate, DLUserDelegate, DMChannelItemDelegate, PendingAttachmentItemDelegate> {
    
    BOOL isLoadingViews;
    BOOL isLoadingMessages;
    BOOL attachmentViewVisible;
    
    IBOutlet DynamicScrollView *serversScrollView;
    IBOutlet DynamicScrollView *channelsScrollView;
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
    IBOutlet NSView_Border *messageEntryContainerView;
    IBOutlet HorizontalDynamicScrollView *pendingAttachmentsScrollView;
    
    DLMessage *lastMessage;
    ServerItemViewController *me;
    
    NSArray *serverViews;
    NSArray *channelViews;
    
    CGFloat currentMessageScrollHeight;
    
    id<DLMainWindowDelegate> delegate;
}
- (IBAction)showFileOpenDialog:(id)sender;
- (IBAction)showSettingsMenu:(id)sender;

-(void)setDelegate:(id<DLMainWindowDelegate>)inDelegate;
@end
