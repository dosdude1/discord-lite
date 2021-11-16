//
//  HorizontalDynamicScrollView.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/14/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "HorizontalDynamicScrollView.h"

@implementation HorizontalDynamicScrollView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self.documentView setAutoresizingMask:NSViewHeightSizable];
    // Drawing code here.
}

-(void)awakeFromNib {
    docViewWidth = 0;
    NSRect frame = [self.contentView frame];
    frame.size.width = 50;
    frame.origin.y = 0;
    [self.documentView setFrame: frame];
    content = [[NSMutableArray alloc] init];
}

-(void)setVisibleSubviews {
    
    NSEnumerator *e = [content objectEnumerator];
    ViewController *item;
    while (item = [e nextObject]) {
        [item.view removeFromSuperview];
    }
    
    docViewWidth = 0;
    e = [content objectEnumerator];
    while (item = [e nextObject]) {
        NSRect itemFrame = item.view.frame;
        itemFrame.origin.x = docViewWidth;
        docViewWidth += itemFrame.size.width;
        item.view.frame = itemFrame;
        [self.documentView addSubview:item.view];
    }
    NSRect frame = [self.contentView frame];
    frame.size.width = docViewWidth;
    [self.documentView setFrame: frame];
}

-(void)setContent:(NSArray *)inContent {
    NSEnumerator *e = [content objectEnumerator];
    ViewController *item;
    while (item = [e nextObject]) {
        [item.view removeFromSuperview];
        [item.view release];
    }
    
    [content release];
    [inContent retain];
    content = [[NSMutableArray alloc] initWithArray:inContent];
    [self setVisibleSubviews];
}
-(void)appendContent:(ViewController *)item {
    [content addObject:item];
    NSRect itemFrame = item.view.frame;
    itemFrame.origin.x = docViewWidth;
    docViewWidth += itemFrame.size.width;
    item.view.frame = itemFrame;
    NSRect frame = [self.documentView frame];
    frame.size.width = docViewWidth;
    [self.documentView setFrame:frame];
    [self.documentView addSubview:item.view];
}
-(void)removeContent:(ViewController *)item {
    [item.view removeFromSuperview];
    [item.view release];
    [content removeObject:item];
    [self setVisibleSubviews];
}

-(NSArray *)content {
    return content;
}

@end
