//
//  DLLoginWindowController.h
//  Discord Lite
//
//  Created by Collin Mistr on 10/26/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DLController.h"
#import "DLErrorHandler.h"

@protocol DLLoginWindowDelegate <NSObject>
@optional
-(void)loginWasSuccessful;

@end

@interface DLLoginWindowController : NSWindowController <DLLoginDelegate> {
    
    IBOutlet NSSecureTextField *passwordField;
    IBOutlet NSTextField *emailField;
    id<DLLoginWindowDelegate> delegate;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSButton *loginButton;
}
- (IBAction)login:(id)sender;
-(void)setDelegate:(id<DLLoginWindowDelegate>)inDelegate;

@end
