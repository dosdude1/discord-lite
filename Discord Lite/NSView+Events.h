//
//  NSView+Events.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/12/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol NSViewEventDelegate <NSObject>
@optional
-(void)mouseWasDepressedWithEvent:(NSEvent *)event;
-(void)mouseRightButtonWasDepressedWithEvent:(NSEvent *)event;
@end

@interface NSView_Events : NSView {
    id<NSViewEventDelegate> delegate;
}

-(void)setDelegate:(id<NSViewEventDelegate>)inDelegate;

@end
