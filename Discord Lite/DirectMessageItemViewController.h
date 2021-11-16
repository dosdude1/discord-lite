//
//  DirectMessageItemViewController.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/3/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "ViewController.h"
#import "DLDirectMessageChannel.h"
#import "BadgeTextField.h"

@class DirectMessageItemViewController;

@protocol DMChannelItemDelegate <NSObject>
@optional
-(void)dmChannelItemWasSelected:(DirectMessageItemViewController *)item;
@end

@interface DirectMessageItemViewController : ViewController <DLChannelDelegate, NSViewEventDelegate> {
    DLDirectMessageChannel *representedObject;
    IBOutlet NSImageView *avatarImageView;
    IBOutlet NSTextField *usernameTextField;
    id<DMChannelItemDelegate> delegate;
    IBOutlet BadgeTextField *notificationBadgeLabel;
}

-(DLDirectMessageChannel *)representedObject;


-(void)setSelected:(BOOL)selected;
-(void)setRepresentedObject:(DLDirectMessageChannel *)c;
-(void)setDelegate:(id<DMChannelItemDelegate>)inDelegate;

@end
