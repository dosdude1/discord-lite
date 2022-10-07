//
//  NSScroller+BGColor.m
//  Discord Lite
//
//  Created by Collin Mistr on 10/4/22.
//  Copyright (c) 2022 dosdude1. All rights reserved.
//

#import "NSScroller+BGColor.h"

@implementation NSScroller_BGColor

- (void)drawRect:(NSRect)dirtyRect {
    
    if (backgroundColor) {
        [backgroundColor setFill];
        NSRectFillUsingOperation([self bounds], NSCompositeSourceOver);
    }
    
    NSUsableScrollerParts usableParts = [self usableParts];
    if (usableParts == NSAllScrollerParts) {
        [self drawKnob];
    }
}

-(void)setBackgroundColor:(NSColor *)bgColor {
    [backgroundColor release];
    [bgColor retain];
    backgroundColor = bgColor;
}

@end
