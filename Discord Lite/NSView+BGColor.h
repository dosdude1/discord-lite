//
//  NSView+BGColor.h
//  Discord Lite
//
//  Created by Collin Mistr on 10/31/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSView+Events.h"

@interface NSView_BGColor : NSView_Events {
    NSColor *backgroundColor;
}

-(void)setBackgroundColor:(NSColor *)bgColor;

@end
