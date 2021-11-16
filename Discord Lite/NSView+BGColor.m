//
//  NSView+BGColor.m
//  Discord Lite
//
//  Created by Collin Mistr on 10/31/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "NSView+BGColor.h"

@implementation NSView_BGColor

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if (!backgroundColor) {
        backgroundColor = [NSColor controlColor];
    }
    
    [backgroundColor set];
    NSRectFill([self bounds]);
    // Drawing code here.
}
-(void)setBackgroundColor:(NSColor *)bgColor {
    [backgroundColor release];
    [bgColor retain];
    backgroundColor = bgColor;
}

@end
