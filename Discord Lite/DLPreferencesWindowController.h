//
//  DLPreferencesWindowController.h
//  Discord Lite
//
//  Created by Collin Mistr on 8/23/22.
//  Copyright (c) 2022 dosdude1. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DLPreferencesHandler.h"

@interface DLPreferencesWindowController : NSWindowController {
    
    IBOutlet NSButton *useSOCKSCheckbox;
    IBOutlet NSTextField *hostTextField;
    IBOutlet NSTextField *portTextField;
    IBOutlet NSButton *SOCKSPasswordCheckbox;
    IBOutlet NSTextField *SOCKSUsernameTextField;
    IBOutlet NSSecureTextField *SOCKSPasswordTextField;
    IBOutlet NSButton *applyButton;
}
- (IBAction)useProxyToggled:(id)sender;
- (IBAction)useSOCKSPasswordToggled:(id)sender;
- (IBAction)applyChanges:(id)sender;

@end
