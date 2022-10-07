//
//  NSScroller+BGColor.h
//  Discord Lite
//
//  Created by Collin Mistr on 10/4/22.
//  Copyright (c) 2022 dosdude1. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSScroller_BGColor : NSScroller {
    NSColor *backgroundColor;
}

-(void)setBackgroundColor:(NSColor *)bgColor;

@end
