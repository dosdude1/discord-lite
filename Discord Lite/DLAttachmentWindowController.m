//
//  DLAttachmentWindowController.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/12/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLAttachmentWindowController.h"

@interface DLAttachmentWindowController ()

@end

@implementation DLAttachmentWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [progressIndicator startAnimation:self];
    [viewedAttachment loadFullData];
    
    contextMenu = [[NSMenu alloc] init];
    [contextMenu addItemWithTitle:@"Save Image" action:@selector(saveAttachment) keyEquivalent:@""];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)setDelegate:(id<DLAttachmentWindowDelegate>)inDelegate {
    delegate = inDelegate;
}


-(void)setViewedAttachmemt:(DLAttachment *)a {
    [viewedAttachment release];
    [a retain];
    viewedAttachment = a;
    [viewedAttachment setViewerDelegate:self];
    NSRect windowFrame = self.window.frame;
    windowFrame.size.width = [viewedAttachment scaledWidth] * 2;
    windowFrame.size.height = [viewedAttachment scaledHeight] * 2;
    
    CGFloat xPos = NSWidth([[self.window screen] frame])/2 - NSWidth(windowFrame)/2;
    CGFloat yPos = NSHeight([[self.window screen] frame])/2 - NSHeight(windowFrame)/2;
    
    windowFrame.origin.x = xPos;
    windowFrame.origin.y = yPos;
    
    [self.window setFrame:windowFrame display:YES];
    [self.window setTitle:[viewedAttachment filename]];
    
    imgView = [[[NSImageView alloc] initWithFrame:attachmentTemplateView.frame] autorelease];
    //[imgView setImage:[[[NSImage alloc] initWithData:[viewedAttachment attachmentData]] autorelease]];
    [imgView setAutoresizingMask:attachmentTemplateView.autoresizingMask];
    [attachmentTemplateView addSubview:imgView];
    eventHandlerView = [[NSView_Events alloc] initWithFrame:attachmentTemplateView.frame];
    [eventHandlerView setAutoresizingMask:attachmentTemplateView.autoresizingMask];
    [eventHandlerView setDelegate:self];
    [imgView addSubview:eventHandlerView];
}

-(void)delegateWindowDidClose {
    [delegate viewerWindowDidClose];
}

-(void)saveAttachment {
    NSString *path = [DLUtil downloadsPath];
    
    NSFileManager *man = [NSFileManager defaultManager];
    NSString *newFilePath = [path stringByAppendingPathComponent:[viewedAttachment filename]];
    
    NSInteger i = 1;
    while ([man fileExistsAtPath:newFilePath]) {
        NSString *testName = [NSString stringWithFormat:@"%@-%ld.%@", [[viewedAttachment filename] stringByDeletingPathExtension], i, [[viewedAttachment filename] pathExtension]];
        newFilePath = [path stringByAppendingPathComponent:testName];
        i++;
    }
    [viewedAttachment saveToPath:newFilePath];
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.DownloadFileFinished" object:newFilePath];

}

-(void)dealloc {
    [eventHandlerView setDelegate:nil];
    [eventHandlerView release];
    [viewedAttachment setViewerDelegate:nil];
    [viewedAttachment release];
    [super dealloc];
}

#pragma mark Delegated Functions

-(void)attachment:(DLAttachment *)a viewerDataWasUpdated:(NSData *)data {
    [progressIndicator stopAnimation:self];
    [progressIndicator setHidden:YES];
    
    [imgView setImage:[[[NSImage alloc] initWithData:data] autorelease]];
}

- (void)windowWillClose:(NSNotification *)notification {
    [self performSelector:@selector(delegateWindowDidClose) withObject:nil afterDelay:0.1];
}

-(void)mouseWasDepressedWithEvent:(NSEvent *)event {
    if ((event.modifierFlags & NSControlKeyMask) == NSControlKeyMask) {
        [NSMenu popUpContextMenu:contextMenu withEvent:event forView:nil];
    }
}

-(void)mouseRightButtonWasDepressedWithEvent:(NSEvent *)event {
    [NSMenu popUpContextMenu:contextMenu withEvent:event forView:nil];
}

@end
