//
//  PaddedTextView.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/2/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "PaddedTextView.h"

@implementation PaddedTextView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Drawing code here.
}

- (void)awakeFromNib {
    [super setTextContainerInset:NSMakeSize(0.0f, 3.0f)];
}

@end
