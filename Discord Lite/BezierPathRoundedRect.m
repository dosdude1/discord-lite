//
//  BezierPathRoundedRect.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/5/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "BezierPathRoundedRect.h"

@implementation BezierPathRoundedRect

+(NSBezierPath *)bezierPathWithRoundedRect:(NSRect)rect radius:(CGFloat)radius {
    NSBezierPath *path = [[NSBezierPath alloc] init];
    [path moveToPoint:NSMakePoint(radius / 2.0, 0)];
    
    [path lineToPoint:NSMakePoint(rect.size.width - (radius / 2.0), 0)];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(rect.size.width, 0) toPoint:NSMakePoint(rect.size.width, radius / 2.0) radius:radius];
    
    [path lineToPoint:NSMakePoint(rect.size.width, rect.size.height - (radius / 2.0))];
    
    [path appendBezierPathWithArcFromPoint:NSMakePoint(rect.size.width, rect.size.height) toPoint:NSMakePoint(rect.size.width  - (radius / 2.0), rect.size.height) radius:radius];
    
    [path lineToPoint:NSMakePoint(radius / 2.0, rect.size.height)];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(0, rect.size.height) toPoint:NSMakePoint(0, rect.size.height - (radius / 2.0)) radius:radius];
    
    [path lineToPoint:NSMakePoint(0, radius / 2.0)];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(0, 0) toPoint:NSMakePoint(radius / 2.0, 0) radius:radius];
    return [path autorelease];
}

@end
