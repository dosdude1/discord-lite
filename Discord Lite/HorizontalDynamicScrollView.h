//
//  HorizontalDynamicScrollView.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/14/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViewController.h"

@interface HorizontalDynamicScrollView : NSScrollView {
    NSArray *content;
    CGFloat docViewWidth;
}

-(void)setContent:(NSArray *)inContent;
-(void)appendContent:(ViewController *)item;
-(void)removeContent:(ViewController *)item;

-(NSArray *)content;

@end
