//
//  DirectMessageItemViewController.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/3/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DirectMessageItemViewController.h"

@implementation DirectMessageItemViewController

+(CGFloat)AVATAR_RADIUS {
    return 19.0f;
}

-(void)awakeFromNib {
    defaultTextColor = [[usernameTextField textColor] retain];
    [view setDelegate:self];
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
    [avatarImageView setImage:[DLUtil imageResize:[[[NSImage alloc] initWithData:[representedObject imageData]] autorelease] newSize:avatarImageView.frame.size cornerRadius:[DirectMessageItemViewController AVATAR_RADIUS]]];
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
        [view setBackgroundColor:[NSColor colorWithCalibratedRed:50.0/255.0 green:54.0/255.0 blue:60.0/255.0 alpha:1.0f]];
        [usernameTextField setTextColor:[NSColor whiteColor]];
        [view setNeedsDisplay:YES];
    } else {
        [view setBackgroundColor:[NSColor clearColor]];
        [usernameTextField setTextColor:defaultTextColor];
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
    [representedObject setDelegate:nil];
    [representedObject release];
    [view setDelegate:nil];
    [view release];
    [super dealloc];
}

#pragma mark Delegated Functions

-(void)channel:(DLDirectMessageChannel *)c imageDidUpdateWithData:(NSData *)d {
    [avatarImageView setImage:[DLUtil imageResize:[[[NSImage alloc] initWithData:d] autorelease] newSize:avatarImageView.frame.size cornerRadius:[DirectMessageItemViewController AVATAR_RADIUS]]];
}
-(void)mentionsUpdatedForChannel:(DLChannel *)c {
    [self updateMentionsLabel];
}

@end
