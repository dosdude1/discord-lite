//
//  DLPreferencesWindowController.m
//  Discord Lite
//
//  Created by Collin Mistr on 8/23/22.
//  Copyright (c) 2022 dosdude1. All rights reserved.
//

#import "DLPreferencesWindowController.h"

@interface DLPreferencesWindowController ()

@end

@implementation DLPreferencesWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self initPreferences];
    [self updateUIState];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)initPreferences {
    if ([[DLPreferencesHandler sharedInstance] shouldUseSOCKSProxy]) {
        [useSOCKSCheckbox setState:NSOnState];
    }
    if ([[DLPreferencesHandler sharedInstance] SOCKSProxyRequiresPassword]) {
        [SOCKSPasswordCheckbox setState:NSOnState];
    }
    
    if ([[DLPreferencesHandler sharedInstance] SOCKSProxyHost]) {
        [hostTextField setStringValue:[[DLPreferencesHandler sharedInstance] SOCKSProxyHost]];
    }
    if ([[DLPreferencesHandler sharedInstance] SOCKSProxyPort]) {
        [portTextField setStringValue:[NSString stringWithFormat:@"%ld", [[DLPreferencesHandler sharedInstance] SOCKSProxyPort]]];
    }
    if ([[DLPreferencesHandler sharedInstance] SOCKSProxyUsername]) {
        [SOCKSUsernameTextField setStringValue:[[DLPreferencesHandler sharedInstance] SOCKSProxyUsername]];
    }
    if ([[DLPreferencesHandler sharedInstance] SOCKSProxyPassword]) {
        [SOCKSPasswordTextField setStringValue:[[DLPreferencesHandler sharedInstance] SOCKSProxyPassword]];
    }
}

-(void)updateUIState {
    if (useSOCKSCheckbox.state == NSOnState) {
        [hostTextField setEnabled:YES];
        [portTextField setEnabled:YES];
        [SOCKSPasswordCheckbox setEnabled:YES];
    } else {
        [hostTextField setEnabled:NO];
        [portTextField setEnabled:NO];
        [SOCKSPasswordCheckbox setEnabled:NO];
    }
    
    if (SOCKSPasswordCheckbox.state == NSOnState) {
        [SOCKSUsernameTextField setEnabled:YES];
        [SOCKSPasswordTextField setEnabled:YES];
    } else {
        [SOCKSUsernameTextField setEnabled:NO];
        [SOCKSPasswordTextField setEnabled:NO];
    }
}

- (IBAction)useProxyToggled:(id)sender {
    [self updateUIState];
}

- (IBAction)useSOCKSPasswordToggled:(id)sender {
    [self updateUIState];
}

- (IBAction)applyChanges:(id)sender {
    if (useSOCKSCheckbox.state == NSOnState) {
        [[DLPreferencesHandler sharedInstance] setShouldUseSOCKSProxy:YES];
    } else {
        [[DLPreferencesHandler sharedInstance] setShouldUseSOCKSProxy:NO];
    }
    
    if (SOCKSPasswordCheckbox.state == NSOnState) {
        [[DLPreferencesHandler sharedInstance] setSOCKSProxyRequiresPassword:YES];
    } else {
        [[DLPreferencesHandler sharedInstance] setSOCKSProxyRequiresPassword:NO];
    }
    
    [[DLPreferencesHandler sharedInstance] setSOCKSProxyHost:[hostTextField stringValue]];
    [[DLPreferencesHandler sharedInstance] setSOCKSProxyPort:[[portTextField stringValue] intValue]];
    [[DLPreferencesHandler sharedInstance] setSOCKSProxyUsername:[SOCKSUsernameTextField stringValue]];
    [[DLPreferencesHandler sharedInstance] setSOCKSProxyPassword:[SOCKSPasswordTextField stringValue]];
    
    [self.window close];
    
}
@end
