//
//  RoundedTextFieldCell.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/5/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "RoundedTextFieldCell.h"

@implementation RoundedTextFieldCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSBezierPath *roundedBounds = [BezierPathRoundedRect bezierPathWithRoundedRect:cellFrame radius:6.0f];
    
    [roundedBounds addClip];
    [super drawWithFrame:cellFrame inView:controlView];
    /*if (self.isBezeled) {
        [betterBounds setLineWidth:2];
        [[NSColor colorWithCalibratedRed:0.510 green:0.643 blue:0.804 alpha:1] setStroke];
        [betterBounds stroke];
    }*/
}

@end
