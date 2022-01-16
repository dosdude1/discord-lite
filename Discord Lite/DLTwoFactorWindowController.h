//
//  DLTwoFactorWindowController.h
//  Discord Lite
//
//  Created by Collin Mistr on 1/16/22.
//  Copyright (c) 2022 dosdude1. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TwoFactorEntryFormatter.h"

@protocol DLTwoFactorWindowDelegate <NSObject>
@optional
-(void)didSubmitTwoFactorWithCode:(NSString *)twoFactorCode;
-(void)didCancelTwoFactorEntry;
@end

@interface DLTwoFactorWindowController : NSWindowController {
    id<DLTwoFactorWindowDelegate> delegate;
    
    TwoFactorEntryFormatter *entryFormatter;
    
    IBOutlet NSTextField *tfaField1;
    IBOutlet NSTextField *tfaField2;
    IBOutlet NSTextField *tfaField3;
    IBOutlet NSTextField *tfaField4;
    IBOutlet NSTextField *tfaField5;
    IBOutlet NSTextField *tfaField6;
    
    NSArray *entryFields;
}

-(void)setDelegate:(id<DLTwoFactorWindowDelegate>)inDelegate;
-(void)clear;
- (IBAction)cancelEntry:(id)sender;
- (IBAction)submitEntry:(id)sender;

@end
