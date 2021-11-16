//
//  DLErrorHandler.m
//  Discord Lite
//
//  Created by Collin Mistr on 10/27/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLErrorHandler.h"

@implementation DLErrorHandler

+(NSAlert *)alertForError:(DLError *)e {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:[e messageText]];
    [alert setInformativeText:[e infoText]];
    [alert addButtonWithTitle:@"OK"];
    return [alert autorelease];

}

+(void)displayErrorAsModal:(DLError *)e {
    NSAlert *a = [self alertForError:e];
    [a runModal];
}
+(void)displayError:(DLError *)e onWindow:(NSWindow *)window {
    NSAlert *a = [self alertForError:e];
    [a beginSheetModalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

@end
