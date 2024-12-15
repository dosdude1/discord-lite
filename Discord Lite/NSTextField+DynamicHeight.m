//
//  NSTextField+DynamicHeight.m
//  Discord Lite
//
//  Created by Collin Mistr on 12/14/24.
//  Copyright (c) 2024 dosdude1. All rights reserved.
//

#import "NSTextField+DynamicHeight.h"

@implementation NSTextField_DynamicHeight

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(NSSize)intrinsicContentSize {
    
    NSRect frame = [self frame];
    
    CGFloat contentWidth = [self.cell cellSizeForBounds: frame].width;
    CGFloat width = frame.size.width;
    
    if (contentWidth < width) {
        width = contentWidth;
    }
    
    frame.size.height = CGFLOAT_MAX;
    
    CGFloat height = [self.cell cellSizeForBounds: frame].height;
    
    return NSMakeSize(width, height);
}


@end
