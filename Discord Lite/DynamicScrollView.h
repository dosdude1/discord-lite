//
//  DynamicScrollView.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/1/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViewController.h"

@protocol DynamicScrollViewDelegate <NSObject>
@optional
-(void)didSelectItemAtIndex:(NSInteger)index;

@end

@interface DynamicScrollView : NSScrollView {
    NSArray *content;
    id<DynamicScrollViewDelegate> delegate;
}

-(void)setContent:(NSArray *)inContent;
-(void)setDelegate:(id<DynamicScrollViewDelegate>)inDelegate;

@end
