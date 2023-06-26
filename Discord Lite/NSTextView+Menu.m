//
//  NSTextView+Menu.m
//  Discord Lite
//
//  Created by Collin Mistr on 1/9/22.
//  Copyright (c) 2022 dosdude1. All rights reserved.
//

#import "NSTextView+Menu.h"

@implementation NSTextView_Menu

-(id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    bordered = NO;
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if (bordered) {
        NSRect frameRect = [self bounds];
        
        if(dirtyRect.size.height < frameRect.size.height)
            return;
        
        NSBezierPath *border = [NSBezierPath bezierPathWithRect:dirtyRect];
        [border setLineWidth:1];
        [[NSColor windowFrameColor] set];
        [border stroke];
    }
    // Drawing code here.
}

-(void)setMenuDelegate:(id<NSTextViewMenuDelegate>)inDelegate {
    menuDelegate = inDelegate;
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
    NSMenu *menu = [super menuForEvent:event];
    if ([menuDelegate respondsToSelector:@selector(textViewContextMenu)]) {
        NSMenu *textViewContextMenu = [menuDelegate textViewContextMenu];
        if (textViewContextMenu) {
            [menu addItem:[NSMenuItem separatorItem]];
            NSEnumerator *e = [[textViewContextMenu itemArray] objectEnumerator];
            NSMenuItem *item;
            while (item = [e nextObject]) {
                [menu addItem:[item copy]];
            }
        }
    }
    return menu;
}
-(void)setShouldShowBorder:(BOOL)isBordered {
    bordered = isBordered;
    [self setNeedsDisplay:YES];
}
- (void)keyDown:(NSEvent *)theEvent
{
    switch([theEvent keyCode]) {
        case 53:
            [menuDelegate escapeKeyWasPressed];
            break;
        default:
            [super keyDown:theEvent];
    }
}

@end
