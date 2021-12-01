//
//  TagSelectionViewController.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/23/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "ViewController.h"
#import "DLUser.h"

@class TagSelectionViewController;

@protocol TagSelectionItemDelegate <NSObject>
@optional
-(void)tagSelectionItemWasSelected:(TagSelectionViewController *)item;
@end

@interface TagSelectionViewController : ViewController <DLUserDelegate, NSViewEventDelegate> {
    BOOL isSelected;
    
    IBOutlet NSImageView *avatarImageView;
    IBOutlet NSTextField *usernameTextField;
    DLUser *representedObject;
    id<TagSelectionItemDelegate> delegate;
}

-(id)init;
-(void)setRepresentedObject:(DLUser *)u;
-(void)setDelegate:(id <TagSelectionItemDelegate>)inDelegate;
-(void)setSelected:(BOOL)selected;

-(DLUser *)representedObject;
-(BOOL)isSelected;

@end
