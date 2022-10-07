//
//  ServerStatusIndicatorView.m
//  Discord Lite
//
//  Created by Collin Mistr on 10/4/22.
//  Copyright (c) 2022 dosdude1. All rights reserved.
//

#import "ServerStatusIndicatorView.h"

@implementation ServerStatusIndicatorView

-(id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
    [[NSColor clearColor] set];
    NSRectFillUsingOperation([self bounds], NSCompositeSourceOver);
    
    switch (indicatorToDraw) {
        case ServerStatusIndicatorUnread:
            [self drawUnreadIndicator];
            break;
        case ServerStatusIndicatorHover:
            [self drawHoverIndicator];
            break;
        case ServerStatusIndicatorSelected:
            [self drawSelectedIndicator];
            break;
        case ServerStatusIndicatorNone:
            break;
        default:
            break;
    }
}

-(void)setDrawnIndicator:(ServerStatusIndicator)ind {
    indicatorToDraw = ind;
}

-(void)drawUnreadIndicator {
    NSPoint start = NSMakePoint(0, self.frame.size.height/2);
    NSBezierPath *path = [[NSBezierPath alloc] init];
    [path moveToPoint:start];
    
    [path lineToPoint:NSMakePoint(start.x, start.y + 4)];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(start.x + 4, start.y + 4) toPoint:NSMakePoint(start.x + 4, start.y) radius:4.0f];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(start.x + 4, start.y - 4) toPoint:NSMakePoint(start.x , start.y - 4) radius:4.0f];
    
    [path closePath];
    [[NSColor whiteColor] set];
    [path fill];
    [[NSColor whiteColor] set];
    [path stroke];
}

-(void)drawHoverIndicator {
    NSPoint start = NSMakePoint(0, self.frame.size.height/2);
    NSBezierPath *path = [[NSBezierPath alloc] init];
    [path moveToPoint:start];
    
    [path lineToPoint:NSMakePoint(start.x, start.y + 10)];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(start.x + 4, start.y + 10) toPoint:NSMakePoint(start.x + 4, start.y + 5) radius:4.0f];
    
    [path lineToPoint:NSMakePoint(start.x + 4, start.y - 5)];
    
    [path appendBezierPathWithArcFromPoint:NSMakePoint(start.x + 4, start.y - 10) toPoint:NSMakePoint(start.x , start.y - 10) radius:4.0f];
    
    [path closePath];
    [[NSColor whiteColor] set];
    [path fill];
    [[NSColor whiteColor] set];
    [path stroke];
}

-(void)drawSelectedIndicator {
    NSPoint start = NSMakePoint(0, self.frame.size.height/2);
    NSBezierPath *path = [[NSBezierPath alloc] init];
    [path moveToPoint:start];
    
    [path lineToPoint:NSMakePoint(start.x, start.y + 20)];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(start.x + 4, start.y + 20) toPoint:NSMakePoint(start.x + 4, start.y + 10) radius:4.0f];
    
    [path lineToPoint:NSMakePoint(start.x + 4, start.y - 10)];
    
    [path appendBezierPathWithArcFromPoint:NSMakePoint(start.x + 4, start.y - 20) toPoint:NSMakePoint(start.x , start.y - 20) radius:4.0f];
    
    [path closePath];
    [[NSColor whiteColor] set];
    [path fill];
    [[NSColor whiteColor] set];
    [path stroke];
}

@end
