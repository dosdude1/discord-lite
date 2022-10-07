//
//  NSView+Events.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/12/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "NSView+Events.h"

@implementation NSView_Events

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Drawing code here.
}

-(void)setDelegate:(id<NSViewEventDelegate>)inDelegate {
    delegate = inDelegate;
}
-(void)mouseDown:(NSEvent *)theEvent {
    if ([delegate respondsToSelector:@selector(mouseWasDepressedWithEvent:)]) {
        [delegate mouseWasDepressedWithEvent:theEvent];
    }
}
-(void)rightMouseDown:(NSEvent *)theEvent {
    if ([delegate respondsToSelector:@selector(mouseRightButtonWasDepressedWithEvent:)]) {
        [delegate mouseRightButtonWasDepressedWithEvent:theEvent];
    }
}
-(void)viewDidMoveToWindow {
    if ([delegate respondsToSelector:@selector(viewMovedToWindow:)]) {
        [delegate viewMovedToWindow:self];
    }
}
-(void)dealloc {
    
    [super dealloc];
}
@end
