//
//  ChatScrollView.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/2/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "ChatScrollView.h"

@implementation ChatScrollView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self.documentView setAutoresizingMask:NSViewWidthSizable];
    // Drawing code here.
}
-(void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenResize) name:NSWindowDidResizeNotification object:nil];
    NSRect frame = [self.contentView frame];
    frame.size.height = 100;
    [self.documentView setFrame: frame];
}
-(void)setVisibleSubviews {
    for (int i=0; i<[self.documentView subviews].count; i++) {
        [[[self.documentView subviews] objectAtIndex:i] removeFromSuperviewWithoutNeedingDisplay];
    }
    CGFloat height = 0;
    NSEnumerator *e = [content reverseObjectEnumerator];
    ChatItemViewController *item;
    while (item = [e nextObject]) {
        CGFloat expectedHeight = [item expectedHeight];
        NSRect itemFrame = item.view.frame;
        height += expectedHeight;
        itemFrame.size.height = expectedHeight;
        itemFrame.size.width = [self.contentView frame].size.width;
        itemFrame.origin.y = [self.documentView frame].size.height - height;
        item.view.frame = itemFrame;
        [self.documentView addSubview:item.view];
        [item.view setNeedsDisplay:YES];
    }
    NSRect frame = [self frame];
    frame.size.height = height;
    [self.documentView setFrame: frame];
    [self.documentView setNeedsDisplay:YES];
    [self performSelector:@selector(screenResize) withObject:nil afterDelay:0.5];
}
-(void)setContent:(NSArray *)inContent {
    NSEnumerator *e = [content reverseObjectEnumerator];
    ChatItemViewController *item;
    while (item = [e nextObject]) {
        [item.view release];
    }
    [content release];
    content = [[NSMutableArray alloc] initWithArray:inContent];
    [self setVisibleSubviews];
}
-(void)appendContent:(NSArray *)inContent {
    NSEnumerator *e = [inContent objectEnumerator];
    ChatItemViewController *item;
    while (item = [e nextObject]) {
        [content addObject:item];
        
    }
    [self setVisibleSubviews];
}
-(void)prependViewController:(ChatItemViewController *)vc {
    CGFloat expectedHeight = [vc expectedHeight];
    NSRect itemFrame = vc.view.frame;
    itemFrame.size.height = expectedHeight;
    itemFrame.size.width = [self.documentView frame].size.width - 15;
    itemFrame.origin.y = 0;
    vc.view.frame = itemFrame;
    [vc.view setNeedsDisplay:YES];
    NSRect frame = [self.documentView frame];
    frame.size.height += expectedHeight;
    [self.documentView setFrame: frame];
    [content insertObject:vc atIndex:0];
    [self.documentView addSubview:vc.view];
    [self performSelector:@selector(screenResize) withObject:nil afterDelay:0.5];
}
-(void)screenResize {
    CGFloat currentHeight = 0;
    NSEnumerator *e = [content objectEnumerator];
    ChatItemViewController *item;
    while (item = [e nextObject]) {
        currentHeight += [item expectedHeight];
    }
    NSRect frame = [self.documentView frame];
    frame.size.height = currentHeight;
    [self.documentView setFrame: frame];
    currentHeight = 0;
    e = [content objectEnumerator];
    while (item = [e nextObject]) {
        NSRect itemFrame = item.view.frame;
        itemFrame.size.height = [item expectedHeight];
        itemFrame.origin.y = currentHeight;
        item.view.frame = itemFrame;
        [item.view setNeedsDisplay:YES];
        currentHeight += [item expectedHeight];
    }
    [self.documentView setNeedsDisplay:YES];
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
@end
