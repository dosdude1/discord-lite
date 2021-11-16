//
//  BadgeTextField.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/5/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "BadgeTextField.h"

@implementation BadgeTextField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)setStringValue:(NSString *)aString {
    [super setStringValue:aString];
    CGFloat originalWidth = [self frame].size.width;
    [self sizeToFit];
    NSRect frame = [self frame];
    CGFloat newWidth = frame.size.width;
    frame.origin.x -= newWidth - originalWidth;
    [self setFrame:frame];
}

@end
