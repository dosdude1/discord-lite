//
//  DynamicScrollView.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/1/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DynamicScrollView.h"

@implementation DynamicScrollView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Drawing code here.
}

-(void)awakeFromNib {
    NSRect frame = [self.contentView frame];
    frame.size.height = 100;
    [self.documentView setFrame: frame];
}

-(void)setDelegate:(id<DynamicScrollViewDelegate>)inDelegate {
    delegate = inDelegate;
}

-(void)setContent:(NSArray *)inContent {
    NSEnumerator *e = [content objectEnumerator];
    ViewController *item;
    while (item = [e nextObject]) {
        [item.view removeFromSuperview];
    }
    
    [content release];
    [inContent retain];
    content = inContent;
    CGFloat height = 0;
    e = [content objectEnumerator];
    while (item = [e nextObject]) {
        NSRect itemFrame = item.view.frame;
        height += itemFrame.size.height;
        itemFrame.origin.y = [self.documentView frame].size.height - height;
        itemFrame.size.width = [self.contentView frame].size.width;
        item.view.frame = itemFrame;
        [self.documentView addSubview:item.view];
    }
    NSRect frame = [self frame];
    frame.size.height = height;
    [self.documentView setFrame: frame];
}

-(NSArray *)content {
    return content;
}

@end
