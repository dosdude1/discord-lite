//
//  ChannelItemViewController.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/1/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "ViewController.h"
#import "DLServerChannel.h"
#import "BadgeTextField.h"

typedef enum {
    ChannelItemViewTypeParent = 0,
    ChannelItemViewTypeChild = 1,
    ChannelItemViewTypeDM = 2
} ChannelItemViewType;

@class ChannelItemViewController;

@protocol ChannelItemDelegate <NSObject>
@optional
-(void)channelItemWasSelected:(ChannelItemViewController *)item;
@end

@interface ChannelItemViewController : ViewController <DLChannelDelegate, NSViewEventDelegate> {
    NSColor *defaultTextColor;
    IBOutlet NSView_BGColor *headerView;
    IBOutlet NSView_BGColor *dmView;
    ChannelItemViewType type;
    DLChannel *representedObject;
    IBOutlet NSTextField *childChannelLabel;
    IBOutlet NSTextField *parentChannelLabel;
    id<ChannelItemDelegate> delegate;
    IBOutlet BadgeTextField *mentionBadgeLabel;
}

-(DLChannel *)representedObject;

-(void)setType:(ChannelItemViewType)t;
-(void)setRepresentedObject:(DLChannel *)c;
-(void)setDelegate:(id<ChannelItemDelegate>)inDelegate;
-(void)setSelected:(BOOL)selected;
@end
