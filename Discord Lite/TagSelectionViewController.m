//
//  TagSelectionViewController.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/23/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "TagSelectionViewController.h"

@implementation TagSelectionViewController

+(CGFloat)AVATAR_RADIUS {
    return 9.0f;
}

-(void)awakeFromNib {
    isSelected = NO;
    [view setDelegate:self];
}

-(id)init {
    self = [super init];
    return self;
}

-(void)setRepresentedObject:(DLUser *)u {
    [representedObject release];
    [u retain];
    representedObject = u;
    [avatarImageView setImage:[DLUtil imageResize:[[[NSImage alloc] initWithData:[u avatarImageData]] autorelease] newSize:avatarImageView.frame.size cornerRadius:[TagSelectionViewController AVATAR_RADIUS]]];
    [u setDelegate:self];
    [u loadAvatarData];
    [usernameTextField setStringValue:[u username]];
}

-(void)setDelegate:(id <TagSelectionItemDelegate>)inDelegate {
    delegate = inDelegate;
}

-(DLUser *)representedObject {
    return representedObject;
}

-(void)setSelected:(BOOL)selected {
    isSelected = selected;
    if (selected) {
        [view setBackgroundColor:[NSColor colorWithCalibratedRed:50.0/255.0 green:54.0/255.0 blue:60.0/255.0 alpha:1.0f]];
        [view setNeedsDisplay:YES];
    } else {
        [view setBackgroundColor:[NSColor clearColor]];
        [view setNeedsDisplay:YES];
    }
}

-(BOOL)isSelected {
    return isSelected;
}

-(void)dealloc {
    [representedObject setDelegate:nil];
    [representedObject release];
    [self.view release];
    [super dealloc];
}

#pragma mark Delegated Functions

-(void)user:(DLUser *)u avatarDidUpdateWithData:(NSData *)data {
    [avatarImageView setImage:[DLUtil imageResize:[[[NSImage alloc] initWithData:data] autorelease] newSize:avatarImageView.frame.size cornerRadius:[TagSelectionViewController AVATAR_RADIUS]]];
}

-(void)mouseWasDepressedWithEvent:(NSEvent *)event {
    [delegate tagSelectionItemWasSelected:self];
    [self setSelected:YES];
}

@end
