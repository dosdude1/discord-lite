//
//  DLTwoFactorWindowController.m
//  Discord Lite
//
//  Created by Collin Mistr on 1/16/22.
//  Copyright (c) 2022 dosdude1. All rights reserved.
//

#import "DLTwoFactorWindowController.h"

@interface DLTwoFactorWindowController ()

@end

@implementation DLTwoFactorWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    entryFormatter = [[TwoFactorEntryFormatter alloc] init];
    entryFields = [[NSArray alloc] initWithObjects:tfaField1, tfaField2, tfaField3, tfaField4, tfaField5, tfaField6, nil];
    NSEnumerator *e = [entryFields objectEnumerator];
    NSTextField *f;
    while (f = [e nextObject]) {
        [f setFormatter:entryFormatter];
    }
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)setDelegate:(id<DLTwoFactorWindowDelegate>)inDelegate {
    delegate = inDelegate;
}

-(void)clear {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:NSControlTextDidChangeNotification object:nil];
    NSEnumerator *e = [entryFields objectEnumerator];
    NSTextField *f;
    while (f = [e nextObject]) {
        [f setStringValue:@""];
    }
    [[entryFields objectAtIndex:0] becomeFirstResponder];
}

- (IBAction)cancelEntry:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [delegate didCancelTwoFactorEntry];
}

- (IBAction)submitEntry:(id)sender {
    NSString *twoFactorCode = @"";
    NSEnumerator *e = [entryFields objectEnumerator];
    NSTextField *f;
    while (f = [e nextObject]) {
        twoFactorCode = [twoFactorCode stringByAppendingString:[f stringValue]];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [delegate didSubmitTwoFactorWithCode:twoFactorCode];
}

-(void)textDidChange:(NSNotification *)notification {
    int firstResponderIndex = -1;
    for (int i=0; i<entryFields.count; i++) {
        if ([[entryFields objectAtIndex:i] currentEditor]) {
            firstResponderIndex = i;
        }
    }
    
    if ([[[entryFields objectAtIndex:firstResponderIndex] stringValue] isEqualToString:@""]) {
        //Retard position
        if (firstResponderIndex > 0) {
            [[entryFields objectAtIndex:firstResponderIndex - 1] becomeFirstResponder];
        }
    } else {
        //Advance position
        if (firstResponderIndex < entryFields.count - 1) {
            [[entryFields objectAtIndex:firstResponderIndex + 1] becomeFirstResponder];
        } else {
            [self performSelector:@selector(submitEntry:) withObject:self afterDelay:0.15];
        }
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
