//
//  DLLoginWindowController.m
//  Discord Lite
//
//  Created by Collin Mistr on 10/26/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLLoginWindowController.h"

@interface DLLoginWindowController ()

@end

@implementation DLLoginWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [[DLController sharedInstance] setLoginDelegate:self];
}

- (IBAction)login:(id)sender {
    if (![[DLController sharedInstance] authFingerprint]) {
        [[DLController sharedInstance] getAuthFingerprint];
    } else {
        [[DLController sharedInstance] loginWithEmail:[emailField stringValue] andPassword:[passwordField stringValue]];
    }
    
    [progressIndicator setHidden:NO];
    [progressIndicator startAnimation:self];
    [emailField setEnabled:NO];
    [passwordField setEnabled:NO];
    [loginButton setEnabled:NO];
}

-(void)setDelegate:(id<DLLoginWindowDelegate>)inDelegate {
    delegate = inDelegate;
}

-(void)resetUI {
    [progressIndicator stopAnimation:self];
    [progressIndicator setHidden:YES];
    [emailField setEnabled:YES];
    [passwordField setEnabled:YES];
    [loginButton setEnabled:YES];
}

-(void)dealloc {
    [captchaWindow release];
    [twoFactorWindow release];
    [super dealloc];
}

#pragma mark Delegated Functions

-(void)didLoginWithError:(DLError *)e {
    [self resetUI];
    if (e) {
        [DLErrorHandler displayError:e onWindow:self.window];
    } else {
        [delegate loginWasSuccessful];
    }
    
}

-(void)didReceiveCaptchaRequestOfType:(NSString *)captchaType withSiteKey:(NSString *)siteKey {
    if (!captchaWindow) {
        captchaWindow = [[DLCaptchaWindowController alloc] initWithWindowNibName:@"DLCaptchaWindowController"];
        [captchaWindow setDelegate:self];
    }
    [captchaWindow showWindow:captchaWindow.window];
    if ([captchaType isEqualToString:@"hcaptcha"]) {
        [captchaWindow loadHCaptchaWithSiteKey:siteKey];
    } else if ([captchaType isEqualToString:@"recaptcha"]) {
        [captchaWindow loadRecaptchaWithSiteKey:siteKey];
    }
}

-(void)didReceiveTwoFactorAuthRequest {
    if (!twoFactorWindow) {
        twoFactorWindow = [[DLTwoFactorWindowController alloc] initWithWindowNibName:@"DLTwoFactorWindowController"];
        [twoFactorWindow setDelegate:self];
    }
    [twoFactorWindow clear];
    [NSApp beginSheet:twoFactorWindow.window modalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

-(void)didReceiveAuthFingerprint:(NSString *)fingerprint {
    [[DLController sharedInstance] loginWithEmail:[emailField stringValue] andPassword:[passwordField stringValue]];
}
-(void)authFingerprintFailedWithError:(DLError *)e {
    [self resetUI];
    [DLErrorHandler displayError:e onWindow:self.window];
}

#pragma mark CaptchaDelegate

-(void)didCompleteCaptchaSuccessfully:(BOOL)success {
    if (success) {
        [[DLController sharedInstance] loginWithEmail:[emailField stringValue] andPassword:[passwordField stringValue]];
    } else {
        [self resetUI];
    }
}

#pragma mark TwoFactorDelegate

-(void)didSubmitTwoFactorWithCode:(NSString *)twoFactorCode {
    [NSApp endSheet:twoFactorWindow.window];
    [twoFactorWindow.window orderOut:self];
    [[DLController sharedInstance] loginWithTwoFactorAuthCode:twoFactorCode];
}
-(void)didCancelTwoFactorEntry {
    [NSApp endSheet:twoFactorWindow.window];
    [twoFactorWindow.window orderOut:self];
    [self resetUI];
}

@end
