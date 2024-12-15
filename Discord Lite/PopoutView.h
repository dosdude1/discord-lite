//
//  PopoutView.h
//  Discord Lite
//
//  Created by Collin Mistr on 12/14/24.
//  Copyright (c) 2024 dosdude1. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PopoutView : NSView {
    NSColor *backgroundColor;
}

-(void)setBackgroundColor:(NSColor *)bgColor;

@end
