//
//  ServerItemViewController.m
//  Discord Lite
//
//  Created by Collin Mistr on 10/27/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "ServerItemViewController.h"

@interface ServerItemViewController ()

@end

@implementation ServerItemViewController



-(id)init {
    self = [super init];
    type = ServerItemViewTypeServer;
    return self;
}

-(void)setRepresentedObject:(DLServer *)inRepresentedObject {
    [representedObject release];
    [inRepresentedObject retain];
    representedObject = inRepresentedObject;
    [representedObject setDelegate:self];
    [selectionButton setImage:[DLUtil imageResize:[[[NSImage alloc] initWithData:[representedObject iconImageData]] autorelease] newSize:NSSizeFromCGSize(CGSizeMake(view.frame.size.width - 15, view.frame.size.height - 15))]];
    [self mentionCountDidUpdate];
}

-(DLServer *)representedObject {
    return representedObject;
}

- (IBAction)selectItem:(id)sender {
    [self setSelected:YES];
    [delegate serverItemWasSelected:self];
}

-(void)setSelected:(BOOL)selected {
    if (type != ServerItemViewTypeSeparator) {
        if (selected) {
            [view setBackgroundColor:[[NSColor selectedControlColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace]];
            [view setNeedsDisplay:YES];
        } else {
            [view setBackgroundColor:[NSColor clearColor]];
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
        [selectionButton setImage:[DLUtil imageResize:[[[NSImage alloc] initWithData:[representedObject iconImageData]]autorelease] newSize:NSSizeFromCGSize(CGSizeMake(view.frame.size.width - 15, view.frame.size.height - 15))]];
    }
    type = inType;
}

-(void)setDelegate:(id<ServerItemDelegate>)inDelegate {
    delegate = inDelegate;
}

-(void)dealloc {
    [representedObject release];
    [self.view release];
    [super dealloc];
}

#pragma mark Delegated Functions

-(void)iconDidUpdateWithData:(NSData *)data {
    [selectionButton setImage:[DLUtil imageResize:[[[NSImage alloc] initWithData:[representedObject iconImageData]]autorelease] newSize:NSSizeFromCGSize(CGSizeMake(view.frame.size.width - 15, view.frame.size.height - 15))]];
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

@end
