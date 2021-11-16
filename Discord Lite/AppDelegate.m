//
//  AppDelegate.m
//  Discord Lite
//
//  Created by Collin Mistr on 10/26/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    if (![[DLController sharedInstance] isLoggedIn]) {
        loginWindow = [[DLLoginWindowController alloc] initWithWindowNibName:@"DLLoginWindowController"];
        [loginWindow setDelegate:self];
        [loginWindow showWindow:loginWindow.window];
    } else {
        [[DLController sharedInstance] startWebSocket];
        mainWindow = [[DLMainWindowController alloc] initWithWindowNibName:@"DLMainWindowController"];
        [mainWindow setDelegate:self];
        [mainWindow showWindow:mainWindow.window];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark Delegated Functions

-(void)loginWasSuccessful {
    [loginWindow close];
    [loginWindow release];
    [[DLController sharedInstance] startWebSocket];
    mainWindow = [[DLMainWindowController alloc] initWithWindowNibName:@"DLMainWindowController"];
    [mainWindow setDelegate:self];
    [mainWindow showWindow:mainWindow.window];
}

-(void)logoutWasSuccessful {
    [mainWindow close];
    [mainWindow release];
    [[DLController sharedInstance] stopWebSocket];
    loginWindow = [[DLLoginWindowController alloc] initWithWindowNibName:@"DLLoginWindowController"];
    [loginWindow setDelegate:self];
    [loginWindow showWindow:loginWindow.window];
}

@end
