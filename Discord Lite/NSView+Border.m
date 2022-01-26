//
//  NSView+Border.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/3/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "NSView+Border.h"

@implementation NSView_Border

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSRect frameRect = [self bounds];
    
    if(dirtyRect.size.height < frameRect.size.height)
        return;
    
    NSBezierPath *border = [NSBezierPath bezierPathWithRect:dirtyRect];
    [border setLineWidth:1];
    [[NSColor windowFrameColor] set];
    [border stroke];
    // Drawing code here.
}

@end
