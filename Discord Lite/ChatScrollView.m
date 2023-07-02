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
    // Drawing code here.
}
-(void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenResize) name:NSWindowDidResizeNotification object:nil];
    NSRect frame = [self.contentView frame];
    frame.size.height = 100;
    [self.documentView setFrame: frame];
}
-(void)setDelegate:(id<ChatScrollViewDelegate>)inDelegate {
    delegate = inDelegate;
}
-(NSArray *)content {
    return content;
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
-(void)setContent:(NSArray *)inContent {
    NSEnumerator *e = [content objectEnumerator];
    ChatItemViewController *item;
    while (item = [e nextObject]) {
        [item.view removeFromSuperview];
    }
    [content release];
    content = [[NSMutableArray alloc] initWithArray:inContent];
    CGFloat height = 0;
    e = [content reverseObjectEnumerator];
    while (item = [e nextObject]) {
        CGFloat expectedHeight = [item expectedHeight];
        NSRect itemFrame = item.view.frame;
        height += expectedHeight;
        itemFrame.size.height = expectedHeight;
        itemFrame.size.width = [self.documentView frame].size.width;
        itemFrame.origin.y = [self.documentView frame].size.height - height;
        item.view.frame = itemFrame;
        [self.documentView addSubview:item.view];
        [item.view setNeedsDisplay:YES];
    }
    NSRect frame = [self.documentView frame];
    frame.origin.x = self.frame.origin.x;
    frame.origin.y = self.frame.origin.y;
    frame.size.height = height;
    [self.documentView setFrame: frame];
    [self.documentView setNeedsDisplay:YES];
    [self performSelector:@selector(screenResize) withObject:nil afterDelay:0.5];
}
-(void)appendContent:(NSArray *)inContent {
    CGFloat height = [self.documentView frame].size.height;
    NSEnumerator *e = [inContent objectEnumerator];
    ChatItemViewController *item;
    while (item = [e nextObject]) {
        [content addObject:item];
        CGFloat expectedHeight = [item expectedHeight];
        NSRect itemFrame = item.view.frame;
        height += expectedHeight;
        itemFrame.size.height = expectedHeight;
        itemFrame.size.width = [self.documentView frame].size.width;
        itemFrame.origin.y = [self.documentView frame].size.height - height;
        item.view.frame = itemFrame;
        [self.documentView addSubview:item.view];
        [item.view setNeedsDisplay:YES];
    }
    
    NSRect frame = [self.documentView frame];
    frame.origin.x = self.frame.origin.x;
    frame.origin.y = self.frame.origin.y;
    frame.size.height = height;
    [self.documentView setFrame: frame];
    [self.documentView setNeedsDisplay:YES];
    [self screenResize];
    [self performSelector:@selector(screenResize) withObject:nil afterDelay:0.5];
}
-(void)prependViewController:(ChatItemViewController *)vc {
    CGFloat expectedHeight = [vc expectedHeight];
    NSRect itemFrame = vc.view.frame;
    itemFrame.size.height = expectedHeight;
    itemFrame.size.width = [self.contentView frame].size.width;
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
-(void)removeViewController:(ChatItemViewController *)vc {
    [vc.view removeFromSuperview];
    [content removeObject:vc];
    [self screenResize];
}
-(void)endAllChatContentEditing {
    NSEnumerator *e = [content objectEnumerator];
    ChatItemViewController *item;
    while (item = [e nextObject]) {
        [item endEditingContent];
    }
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark File Dragging Functions

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender {
    return NSDragOperationCopy;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender {
    return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
    if (filenames.count > 0) {
        [delegate updatePendingAttachmentsWithFilePaths:filenames];
        return YES;
    }
    return NO;
}

@end
