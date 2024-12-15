//
//  PopoutView.m
//  Discord Lite
//
//  Created by Collin Mistr on 12/14/24.
//  Copyright (c) 2024 dosdude1. All rights reserved.
//

#import "PopoutView.h"

@implementation PopoutView

const CGFloat SHADOW_INSET = 40.0f;
const CGFloat CORNER_RADIUS = 15.0f;
const CGFloat ARROW_INSET = 5.0f;

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor clearColor] set];
    NSRectFillUsingOperation([self bounds], NSCompositeSourceOver);
    
    CGPoint origin = CGPointMake(SHADOW_INSET / 2.0, SHADOW_INSET / 2.0);
    CGPoint end = CGPointMake(self.frame.size.width - (SHADOW_INSET / 2), self.frame.size.height - (SHADOW_INSET / 2));
    
    
    NSBezierPath *path = [[NSBezierPath alloc] init];
    
    
    [path moveToPoint:NSMakePoint(origin.x, self.frame.size.height / 2)];
    
    [path lineToPoint:NSMakePoint(origin.x + ARROW_INSET, (self.frame.size.height / 2) + ARROW_INSET)];
    
    [path lineToPoint:NSMakePoint(origin.x + ARROW_INSET, end.y - CORNER_RADIUS)];
    
    [path curveToPoint:NSMakePoint(origin.x + ARROW_INSET + CORNER_RADIUS, end.y) controlPoint1:NSMakePoint(origin.x + ARROW_INSET, end.y) controlPoint2:NSMakePoint(origin.x + ARROW_INSET, end.y)];
    
    [path lineToPoint:NSMakePoint(end.x - CORNER_RADIUS, end.y)];
    
    [path curveToPoint:NSMakePoint(end.x, end.y - CORNER_RADIUS) controlPoint1:NSMakePoint(end.x, end.y) controlPoint2:NSMakePoint(end.x, end.y)];
    
    [path lineToPoint:NSMakePoint(end.x, origin.y + CORNER_RADIUS)];
    
    [path curveToPoint:NSMakePoint(end.x - CORNER_RADIUS, origin.y) controlPoint1:NSMakePoint(end.x, origin.y) controlPoint2:NSMakePoint(end.x, origin.y)];
    
    [path lineToPoint:NSMakePoint(origin.x + ARROW_INSET + CORNER_RADIUS, origin.y)];
    
    [path curveToPoint:NSMakePoint(origin.x + ARROW_INSET, origin.y + CORNER_RADIUS) controlPoint1:NSMakePoint(origin.x + ARROW_INSET, origin.y) controlPoint2:NSMakePoint(origin.x + ARROW_INSET, origin.y)];
    
    [path lineToPoint:NSMakePoint(origin.x + ARROW_INSET, (self.frame.size.height / 2) - ARROW_INSET)];
    
    [path lineToPoint:NSMakePoint(origin.x, self.frame.size.height / 2)];
    
    
    [path closePath];
    
    
    NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
    [shadow setShadowColor:[NSColor colorWithCalibratedRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5f]];
    [shadow setShadowBlurRadius:20.0f];
    [shadow setShadowOffset:NSMakeSize(0.f, 0.f)];
    [shadow set];
    
    if (!backgroundColor) {
        backgroundColor = [NSColor blackColor];
    }
    
    [backgroundColor set];
    [path fill];
    [backgroundColor set];
    [path stroke];
    [path release];
}

-(void)setBackgroundColor:(NSColor *)bgColor {
    [backgroundColor release];
    [bgColor retain];
    backgroundColor = bgColor;
}

@end
