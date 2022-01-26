//
//  ChannelItemViewController.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/1/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "ChannelItemViewController.h"

@implementation ChannelItemViewController

-(void)awakeFromNib {
    [view setDelegate:self];
    [dmView setDelegate:self];
    [view setNeedsDisplay:YES];
}

-(DLChannel *)representedObject {
    return representedObject;
}

-(void)setRepresentedObject:(DLChannel *)c {
    [representedObject release];
    [c retain];
    representedObject = c;
    [representedObject setDelegate:self];
    if ([representedObject type] == ChannelTypeHeader) {
        [self setType:ChannelItemViewTypeParent];
        [parentChannelLabel setStringValue:[(DLServerChannel *)representedObject name]];
    } else {
        [childChannelLabel setStringValue:[(DLServerChannel *)representedObject name]];
    }
    [self updateMentionsLabel];
}

-(void)setType:(ChannelItemViewType)t {
    switch (t) {
        case ChannelItemViewTypeParent:
            view = headerView;
            break;
        case ChannelItemViewTypeDM:
            view = dmView;
            break;
        default:
            break;
    }
    type = t;
}
-(void)setDelegate:(id<ChannelItemDelegate>)inDelegate {
    delegate = inDelegate;
}
-(void)mouseWasDepressedWithEvent:(NSEvent *)event {
    [delegate channelItemWasSelected:self];
    [self setSelected:YES];
}
-(void)setSelected:(BOOL)selected {
    if (selected) {
        [view setBackgroundColor:[[NSColor selectedControlColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace]];
        [view setNeedsDisplay:YES];
    } else {
        [view setBackgroundColor:[NSColor clearColor]];
        [view setNeedsDisplay:YES];
    }
}
-(void)updateMentionsLabel {
    NSInteger mentionCount = [representedObject mentionCount];
    if (mentionCount < 1) {
        [mentionBadgeLabel setHidden:YES];
    } else {
        [mentionBadgeLabel setHidden:NO];
        [mentionBadgeLabel setStringValue:[NSString stringWithFormat:@"%ld", mentionCount]];
    }
}

-(void)dealloc {
    [representedObject release];
    [self.view release];
    [super dealloc];
}


#pragma mark Delegated Functions 

-(void)mentionsUpdatedForChannel:(DLChannel *)c {
    [self updateMentionsLabel];
}

@end
