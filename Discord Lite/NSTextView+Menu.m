//
//  NSTextView+Menu.m
//  Discord Lite
//
//  Created by Collin Mistr on 1/9/22.
//  Copyright (c) 2022 dosdude1. All rights reserved.
//

#import "NSTextView+Menu.h"

@implementation NSTextView_Menu

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)setMenuDelegate:(id<NSTextViewMenuDelegate>)inDelegate {
    menuDelegate = inDelegate;
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
    if ([menuDelegate respondsToSelector:@selector(textViewContextMenu)]) {
        if ([menuDelegate textViewContextMenu]) {
            return [menuDelegate textViewContextMenu];
        }
    }
    return [super menuForEvent:event];
}

@end
