//
//  ServerItemViewController.m
//  Discord Lite
//
//  Created by Collin Mistr on 10/27/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "ServerItemViewController.h"

@implementation ServerItemViewController

+(CGFloat)AVATAR_RADIUS {
    return 27.0f;
}

-(id)init {
    self = [super init];
    type = ServerItemViewTypeServer;
    isSelected = NO;
    return self;
}
-(void)awakeFromNib {
    [view setDelegate:self];
}

-(void)setRepresentedObject:(DLServer *)inRepresentedObject {
    [representedObject release];
    [inRepresentedObject retain];
    representedObject = inRepresentedObject;
    [representedObject setDelegate:self];
    iconImage = [[NSImage alloc] initWithData:[representedObject iconImageData]];
    [selectionButton setImage:[DLUtil imageResize:iconImage newSize:NSSizeFromCGSize(CGSizeMake(selectionButton.frame.size.width - 5, selectionButton.frame.size.height - 5)) cornerRadius:[ServerItemViewController AVATAR_RADIUS]]];
    [self mentionCountDidUpdate];
    [self updateStatusIndicator];
}

-(DLServer *)representedObject {
    return representedObject;
}

-(void)updateStatusIndicator {
    if (!isSelected) {
        if ([representedObject hasUnreadMessages]) {
            [statusIndicatorView setDrawnIndicator:ServerStatusIndicatorUnread];
        } else {
            [statusIndicatorView setDrawnIndicator:ServerStatusIndicatorNone];
        }
        [statusIndicatorView setNeedsDisplay:YES];
    }
}

- (IBAction)selectItem:(id)sender {
    [self setSelected:YES];
    [delegate serverItemWasSelected:self];
}

-(void)setSelected:(BOOL)selected {
    if (type != ServerItemViewTypeSeparator) {
        isSelected = selected;
        if (selected) {
            [statusIndicatorView setDrawnIndicator:ServerStatusIndicatorSelected];
            [statusIndicatorView setNeedsDisplay:YES];
            [selectionButton setImage:[DLUtil imageResize:iconImage newSize:NSMakeSize(selectionButton.frame.size.width - 5, selectionButton.frame.size.height - 5) cornerRadius:20.0f]];
            [view setNeedsDisplay:YES];
        } else {
            [self updateStatusIndicator];
            [selectionButton setImage:[DLUtil imageResize:iconImage newSize:NSMakeSize(selectionButton.frame.size.width - 5, selectionButton.frame.size.height - 5) cornerRadius:[ServerItemViewController AVATAR_RADIUS]]];
            [view setNeedsDisplay:YES];
        }
    }
}

-(ServerItemViewType)type {
    return type;
}
-(void)setType:(ServerItemViewType)inType {
    if (inType == ServerItemViewTypeSeparator) {
        [view release];
        view = separatorView;
    } else if (inType == ServerItemViewTypeMe) {
        iconImage = [[NSImage alloc] initWithData:[representedObject iconImageData]];
        [selectionButton setImage:[DLUtil imageResize:iconImage newSize:NSMakeSize(selectionButton.frame.size.width - 5, selectionButton.frame.size.height - 5) cornerRadius:[ServerItemViewController AVATAR_RADIUS]]];
    }
    type = inType;
}

-(void)setDelegate:(id<ServerItemDelegate>)inDelegate {
    delegate = inDelegate;
}

- (void)viewMovedToWindow:(NSView *)v {
    if (type != ServerItemViewTypeSeparator) {
        trackingRect = [selectionButton addTrackingRect:selectionButton.bounds owner:self userData:nil assumeInside:NO];
    }
}

- (void)mouseEntered:(NSEvent *)theEvent{
    if (!isSelected) {
        [selectionButton setImage:[DLUtil imageResize:iconImage newSize:NSMakeSize(selectionButton.frame.size.width - 5, selectionButton.frame.size.height - 5) cornerRadius:20.0f]];
        [statusIndicatorView setDrawnIndicator:ServerStatusIndicatorHover];
        [statusIndicatorView setNeedsDisplay:YES];
    }
}

- (void)mouseExited:(NSEvent *)theEvent{
    if (!isSelected) {
        [selectionButton setImage:[DLUtil imageResize:iconImage newSize:NSMakeSize(selectionButton.frame.size.width - 5, selectionButton.frame.size.height - 5) cornerRadius:[ServerItemViewController AVATAR_RADIUS]]];
        [self updateStatusIndicator];
    }
}

-(void)updateRectTracking {
    if (type != ServerItemViewTypeSeparator) {
        [self mouseExited:nil];
        [selectionButton removeTrackingRect:trackingRect];
        trackingRect = [selectionButton addTrackingRect:selectionButton.bounds owner:self userData:nil assumeInside:NO];
    }
}

-(void)dealloc {
    [representedObject release];
    if (type != ServerItemViewTypeSeparator) {
        [selectionButton removeTrackingRect:trackingRect];
    }
    [self.view release];
    [super dealloc];
}

#pragma mark Delegated Functions

-(void)iconDidUpdateWithData:(NSData *)data {
    iconImage = [[NSImage alloc] initWithData:[representedObject iconImageData]];
    [selectionButton setImage:[DLUtil imageResize:iconImage newSize:NSMakeSize(selectionButton.frame.size.width - 5, selectionButton.frame.size.height - 5) cornerRadius:[ServerItemViewController AVATAR_RADIUS]]];
}

-(void)mentionCountDidUpdate {
    NSInteger mentionCount = [representedObject mentionCount];
    if (mentionCount < 1) {
        [mentionBadgeLabel setHidden:YES];
    } else {
        [mentionBadgeLabel setHidden:NO];
        [mentionBadgeLabel setStringValue:[NSString stringWithFormat:@"%ld", mentionCount]];
    }
    
}

-(void)unreadStatusDidUpdate {
    [self updateStatusIndicator];
}

@end
