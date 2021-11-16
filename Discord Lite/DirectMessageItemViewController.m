//
//  DirectMessageItemViewController.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/3/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DirectMessageItemViewController.h"

@implementation DirectMessageItemViewController

-(void)awakeFromNib {
    [view setDelegate:self];
    [view setBackgroundColor:[NSColor whiteColor]];
    [view setNeedsDisplay:YES];
}

-(DLDirectMessageChannel *)representedObject {
    return representedObject;
}

-(void)setRepresentedObject:(DLDirectMessageChannel *)c {
    [representedObject release];
    [c retain];
    representedObject = c;
    [representedObject setDelegate:self];
    [usernameTextField setStringValue:[representedObject name]];
    [avatarImageView setImage:[[[NSImage alloc] initWithData:[representedObject imageData]] autorelease]];
    [self updateMentionsLabel];
}

-(void)setDelegate:(id<DMChannelItemDelegate>)inDelegate {
    delegate = inDelegate;
}

-(void)mouseWasDepressedWithEvent:(NSEvent *)event {
    [delegate dmChannelItemWasSelected:self];
    [self setSelected:YES];
}
-(void)setSelected:(BOOL)selected {
    if (selected) {
        [view setBackgroundColor:[[NSColor selectedControlColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace]];
        [view setNeedsDisplay:YES];
    } else {
        [view setBackgroundColor:[[NSColor whiteColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace]];
        [view setNeedsDisplay:YES];
    }
}
-(void)updateMentionsLabel {
    NSInteger mentionCount = [representedObject mentionCount];
    if (mentionCount < 1) {
        [notificationBadgeLabel setHidden:YES];
    } else {
        [notificationBadgeLabel setHidden:NO];
        [notificationBadgeLabel setStringValue:[NSString stringWithFormat:@"%ld", mentionCount]];
    }
}

-(void)dealloc {
    [representedObject release];
    [super dealloc];
}

#pragma mark Delegated Functions

-(void)channel:(DLDirectMessageChannel *)c imageDidUpdateWithData:(NSData *)d {
    [avatarImageView setImage:[[[NSImage alloc] initWithData:d] autorelease]];
}
-(void)mentionsUpdatedForChannel:(DLChannel *)c {
    [self updateMentionsLabel];
}

@end
