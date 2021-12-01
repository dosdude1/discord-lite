//
//  TagSelectionViewController.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/23/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "TagSelectionViewController.h"

@implementation TagSelectionViewController

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
    [avatarImageView setImage:[[[NSImage alloc] initWithData:[u avatarImageData]] autorelease]];
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
        [view setBackgroundColor:[[NSColor selectedControlColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace]];
        [view setNeedsDisplay:YES];
    } else {
        [view setBackgroundColor:[[NSColor controlColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace]];
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

-(void)avatarDidUpdateWithData:(NSData *)data {
    [avatarImageView setImage:[[[NSImage alloc] initWithData:data] autorelease]];
}

-(void)mouseWasDepressedWithEvent:(NSEvent *)event {
    [delegate tagSelectionItemWasSelected:self];
    [self setSelected:YES];
}

@end
