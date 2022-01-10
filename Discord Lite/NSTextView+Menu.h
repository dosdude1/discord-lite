//
//  NSTextView+Menu.h
//  Discord Lite
//
//  Created by Collin Mistr on 1/9/22.
//  Copyright (c) 2022 dosdude1. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol NSTextViewMenuDelegate <NSObject>
@optional
-(NSMenu *)textViewContextMenu;
@end

@interface NSTextView_Menu : NSTextView {
    id<NSTextViewMenuDelegate> menuDelegate;
}

-(void)setMenuDelegate:(id<NSTextViewMenuDelegate>)inDelegate;

@end
