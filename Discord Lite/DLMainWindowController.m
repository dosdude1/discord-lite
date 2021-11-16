//
//  DLMainWindowController.m
//  Discord Lite
//
//  Created by Collin Mistr on 10/27/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLMainWindowController.h"

@interface DLMainWindowController ()

@end

@implementation DLMainWindowController


- (void)windowDidLoad {
    [super windowDidLoad];
    
    lastMessage = nil;
    isLoadingMessages = NO;
    isLoadingViews = NO;
    attachmentViewVisible = NO;
    serverViews = [[NSArray alloc] init];
    [[DLController sharedInstance] setDelegate:self];
    [chatScrollView.contentView setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatScrollViewBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:chatScrollView.contentView];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [messageEntryTextView setDelegate:self];
    currentMessageScrollHeight = messageEntryScrollView.frame.size.height;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:NSWindowDidResizeNotification object:nil];
}

-(void)setDelegate:(id<DLMainWindowDelegate>)inDelegate {
    delegate = inDelegate;
}

-(void)loadMainContent {
    DLUser *u = [[DLController sharedInstance] myUser];
    [u setDelegate:self];
    [myUserAvatarImage setImage:[[[NSImage alloc] initWithData:[u avatarImageData]] autorelease]];
    [myUsernameTextField setStringValue:[u username]];
    [myDiscTextField setStringValue:[NSString stringWithFormat:@"#%@", [u discriminator]]];
    [u loadAvatarData];
}

-(void)populateUserServers {
    NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
    if (!isLoadingViews) {
        isLoadingViews = YES;
        NSMutableArray *views = [[NSMutableArray alloc] init];
        NSEnumerator *e = [[[DLController sharedInstance] userServers] objectEnumerator];
        
        me = [[[ServerItemViewController alloc] initWithNibNamed:@"ServerItemViewController" bundle:nil] autorelease];
        [me setType:ServerItemViewTypeMe];
        [me setRepresentedObject:[[DLController sharedInstance] myServerItem]];
        [me setDelegate:self];
        
        ServerItemViewController *separator = [[[ServerItemViewController alloc] initWithNibNamed:@"ServerItemViewController" bundle:nil] autorelease];
        [separator setType:ServerItemViewTypeSeparator];
        
        [views addObject:me];
        [views addObject:separator];
        
        DLServer *item;
        while (item = [e nextObject]) {
            ServerItemViewController *view = [[[ServerItemViewController alloc] initWithNibNamed:@"ServerItemViewController" bundle:nil] autorelease];
            
            
            [view setRepresentedObject:item];
            [view setDelegate:self];
            [views addObject:view];
            
        }
        [serversScrollView performSelectorOnMainThread:@selector(setContent:) withObject:views waitUntilDone:NO];
        [serverViews release];
        serverViews = views;
        isLoadingViews = NO;
    }
    
    [autoreleasepool release];
}

-(void)loadChannelsForServerItem:(ServerItemViewController *)item {
    NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
    if (!isLoadingViews) {
        isLoadingViews = YES;
        
        //Clear delegates to prevent sending to released objects.
        NSEnumerator *e = [channelViews objectEnumerator];
        ViewController *v;
        while (v = [e nextObject]) {
            [[v representedObject] setDelegate:nil];
        }
        
        NSArray *channels = [[DLController sharedInstance] channelsForServer:[item representedObject]];
        NSMutableArray *views = [[NSMutableArray alloc] init];
        e = [channels objectEnumerator];
        DLServerChannel *channelItem;
        while (channelItem = [e nextObject]) {
            ChannelItemViewController *view = [[[ChannelItemViewController alloc] initWithNibNamed:@"ChannelItemViewController" bundle:nil] autorelease];
            [view setDelegate:self];
            [view setRepresentedObject:channelItem];
            [views addObject:view];
            NSEnumerator *ee = [[channelItem children]objectEnumerator];
            DLServerChannel *child;
            while (child = [ee nextObject]) {
                ChannelItemViewController *view = [[[ChannelItemViewController alloc] initWithNibNamed:@"ChannelItemViewController" bundle:nil] autorelease];
                [view setDelegate:self];
                [view setRepresentedObject:child];
                [views addObject:view];
            }
        }
        [serverLabel performSelectorOnMainThread:@selector(setStringValue:) withObject:[[item representedObject] name] waitUntilDone:NO];
        [channelsScrollView performSelectorOnMainThread:@selector(setContent:) withObject:views waitUntilDone:NO];
        [channelViews release];
        channelViews = views;
        isLoadingViews = NO;
    }
    
    [autoreleasepool release];
}

-(void)loadDirectMessageChannels {
    NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
    if (!isLoadingViews) {
        isLoadingViews = YES;
        
        //Clear delegates to prevent sending to released objects.
        NSEnumerator *e = [channelViews objectEnumerator];
        ViewController *v;
        while (v = [e nextObject]) {
            [[v representedObject] setDelegate:nil];
        }
        
        NSArray *channels = [[DLController sharedInstance] directMessageChannels];
        NSMutableArray *views = [[NSMutableArray alloc] init];
        e = [channels objectEnumerator];
        DLDirectMessageChannel *item;
        while (item = [e nextObject]) {
            DirectMessageItemViewController *view = [[DirectMessageItemViewController alloc] initWithNibNamed:@"DirectMessageItemViewController" bundle:nil];
            [view setDelegate:self];
            [view setRepresentedObject:item];
            if ([[view representedObject] isEqual:[[DLController sharedInstance] selectedChannel]]) {
                [view setSelected:YES];
            }
            [views addObject:view];
            [view release];
            
        }
        [serverLabel performSelectorOnMainThread:@selector(setStringValue:) withObject:@"Direct Messages" waitUntilDone:NO];
        [channelsScrollView performSelectorOnMainThread:@selector(setContent:) withObject:views waitUntilDone:NO];
        [channelViews release];
        channelViews = views;
        isLoadingViews = NO;
    }
    
    [autoreleasepool release];
}

-(void)showPendingAttachmentView {
    if (!attachmentViewVisible) {
        attachmentViewVisible = YES;
        NSRect attachmentsViewFrame = pendingAttachmentsScrollView.frame;
        attachmentsViewFrame.origin.y = messageEntryContainerView.frame.size.height;
        attachmentsViewFrame.size.width = messageEntryContainerView.frame.size.width;
        [pendingAttachmentsScrollView setFrame:attachmentsViewFrame];
        
        NSRect chatViewFrame = chatScrollView.frame;
        chatViewFrame.size.height -= attachmentsViewFrame.size.height;
        chatViewFrame.origin.y += attachmentsViewFrame.size.height;
        [chatScrollView setFrame:chatViewFrame];
        
        NSRect containerFrame = messageEntryContainerView.frame;
        containerFrame.size.height += attachmentsViewFrame.size.height;
        [messageEntryContainerView setFrame:containerFrame];
        
        [messageEntryContainerView addSubview:pendingAttachmentsScrollView];
        [messageEntryContainerView setNeedsDisplay:YES];
        [chatScrollView setNeedsDisplay:YES];
    }
}

-(void)hidePendingAttachmentView {
    if (attachmentViewVisible) {
        attachmentViewVisible = NO;
        [pendingAttachmentsScrollView setContent:[[NSArray alloc] init]];
        NSRect attachmentsViewFrame = pendingAttachmentsScrollView.frame;
        
        NSRect chatViewFrame = chatScrollView.frame;
        chatViewFrame.size.height += attachmentsViewFrame.size.height;
        chatViewFrame.origin.y -= attachmentsViewFrame.size.height;
        [chatScrollView setFrame:chatViewFrame];
        
        NSRect containerFrame = messageEntryContainerView.frame;
        containerFrame.size.height -= attachmentsViewFrame.size.height;
        [messageEntryContainerView setFrame:containerFrame];
        
        [pendingAttachmentsScrollView removeFromSuperview];
        [messageEntryContainerView setNeedsDisplay:YES];
        [chatScrollView setNeedsDisplay:YES];
    }
}

-(void)logOutUser {
    [[DLController sharedInstance] logOutUser];
}

- (IBAction)showFileOpenDialog:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowsMultipleSelection:YES];
    [openDlg setCanChooseDirectories:NO];
    if ([openDlg runModalForDirectory:nil file:nil] == NSOKButton) {
        
        if (!attachmentViewVisible) {
            [self showPendingAttachmentView];
        }
        NSEnumerator *e = [[openDlg filenames] objectEnumerator];
        NSString *filepath;
        while (filepath = [e nextObject]) {
            NSData *fileData = [NSData dataWithContentsOfFile:filepath];
            DLAttachment *a = [[DLAttachment alloc] init];
            [a setFilename:[filepath lastPathComponent]];
            [a setMimeType:[DLUtil mimeTypeForExtension:[filepath pathExtension]]];
            [a setAttachmentData:fileData];
            PendingAttachmentViewController *view = [[PendingAttachmentViewController alloc] initWithNibNamed:@"PendingAttachmentViewController" bundle:nil];
            [view setRepresentedObject:a];
            [view setDelegate:self];
            [pendingAttachmentsScrollView appendContent:view];
            [view release];
            [a release];
        }
    }
}

- (IBAction)showSettingsMenu:(id)sender {
    NSMenu *contextMenu = [[NSMenu alloc] init];
    [contextMenu addItemWithTitle:@"Log Out" action:@selector(logOutUser) keyEquivalent:@""];
    [NSMenu popUpContextMenu:contextMenu withEvent:[NSApp currentEvent] forView:(NSButton *)sender];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark Delegated Functions

-(void)pendingAttachmentItemWasRemoved:(PendingAttachmentViewController *)item {
    [pendingAttachmentsScrollView removeContent:item];
    if ([pendingAttachmentsScrollView content].count < 1) {
        [self hidePendingAttachmentView];
    }
    
}

-(void)chatScrollViewBoundsDidChange:(NSNotification *)note {
    NSClipView *scrolledClipView = [note object];
    if ([chatScrollView.documentView bounds].size.height <= [scrolledClipView bounds].size.height + [scrolledClipView bounds].origin.y) {
        if (!isLoadingMessages) {
            isLoadingMessages = YES;
            if ([[DLController sharedInstance]selectedChannel]) {
                [[DLController sharedInstance] loadMessagesForChannel:[[DLController sharedInstance]selectedChannel] beforeMessage:lastMessage quantity:25];
            }
        }
    }
}

-(void)initialDataWasReceived {
    [NSThread detachNewThreadSelector:@selector(populateUserServers) toTarget:self withObject:nil];
    [self loadMainContent];
}

-(void)requestDidFailWithError:(DLError *)e {
    [DLErrorHandler displayError:e onWindow:self.window];
}

-(void)avatarDidUpdateWithData:(NSData *)data {
    [myUserAvatarImage setImage:[[[NSImage alloc] initWithData:data] autorelease]];
}

-(void)serverItemWasSelected:(ServerItemViewController *)item {
    NSEnumerator *e = [serverViews objectEnumerator];
    ServerItemViewController *itm;
    while (itm = [e nextObject]) {
        if (item != itm) {
            [itm setSelected:NO];
        }
    }
    
    [attachButton setEnabled:NO];
    [messageEntryTextView setEditable:NO];
    [self hidePendingAttachmentView];
    [messageEntryTextView setString:@""];
    [self textDidChange:nil];
    [[DLController sharedInstance] setSelectedChannel:nil];
    [chatScrollView setContent:[[NSArray alloc] init]];
    
    if (item == me) {
        [NSThread detachNewThreadSelector:@selector(loadDirectMessageChannels) toTarget:self withObject:nil];
    } else {
        [NSThread detachNewThreadSelector:@selector(loadChannelsForServerItem:) toTarget:self withObject:item];
    }
    
}

-(void)channelItemWasSelected:(ChannelItemViewController *)item {
    lastMessage = nil;
    NSEnumerator *e = [channelViews objectEnumerator];
    ChannelItemViewController *itm;
    while (itm = [e nextObject]) {
        if (item != itm) {
            [itm setSelected:NO];
        }
    }
    [attachButton setEnabled:YES];
    [messageEntryTextView setEditable:YES];
    [self hidePendingAttachmentView];
    [messageEntryTextView setString:@""];
    [self textDidChange:nil];
    [[DLController sharedInstance] loadMessagesForChannel:[item representedObject] beforeMessage:nil quantity:25];
}
-(void)dmChannelItemWasSelected:(DirectMessageItemViewController *)item {
    lastMessage = nil;
    NSEnumerator *e = [channelViews objectEnumerator];
    DirectMessageItemViewController *itm;
    while (itm = [e nextObject]) {
        if (item != itm) {
            [itm setSelected:NO];
        }
    }
    [attachButton setEnabled:YES];
    [messageEntryTextView setEditable:YES];
    [self hidePendingAttachmentView];
    [messageEntryTextView setString:@""];
    [self textDidChange:nil];
    [[DLController sharedInstance] loadMessagesForChannel:[item representedObject] beforeMessage:nil quantity:25];
}

-(void)messages:(NSArray *)messages receivedForChannel:(DLChannel *)c {
    BOOL newChannel = YES;
    NSMutableArray *views = [[NSMutableArray alloc] init];
    NSEnumerator *e = [messages objectEnumerator];
    DLMessage *item;
    if (lastMessage) {
        newChannel = NO;
    }
    while (item = [e nextObject]) {
        ChatItemViewController *view = [[ChatItemViewController alloc] initWithNibNamed:@"ChatItemViewController" bundle:nil];
        [view setRepresentedObject:item];
        [views addObject:view];
        lastMessage = item;
        [view release];
    }
    if (newChannel) {
        [chatHeaderLabel setStringValue:[c name]];
        [chatHeaderImage setImage:[[[NSImage alloc] initWithData:[c subImageData]] autorelease]];
        [chatScrollView setContent:views];
        [[chatScrollView contentView] scrollToPoint: NSMakePoint(chatScrollView.frame.origin.x, chatScrollView.frame.origin.y)];
        [chatScrollView reflectScrolledClipView: [chatScrollView contentView]];
        if ([c mentionCount] > 0) {
            [[DLController sharedInstance] acknowledgeMessage:lastMessage];
        }
    } else {
        [chatScrollView appendContent:views];
    }
    [views release];
    isLoadingMessages = NO;
}


-(void)newMessage:(DLMessage *)m receivedForChannel:(DLChannel *)c inServer:(DLServer *)s {
    
    if ([c isEqual:[[DLController sharedInstance] selectedChannel]]) {
        ChatItemViewController *view = [[[ChatItemViewController alloc] initWithNibNamed:@"ChatItemViewController" bundle:nil] autorelease];
        [view setRepresentedObject:m];
        [chatScrollView prependViewController:view];
        if ([self.window isKeyWindow]) {
            [[DLController sharedInstance] acknowledgeMessage:m];
        }
    }
    
    BOOL mentioned = NO;
    NSEnumerator *e = [[m mentionedUsers] objectEnumerator];
    DLUser *user;
    while (user = [e nextObject]) {
        if ([user isEqual:[[DLController sharedInstance] myUser]]) {
            mentioned = YES;
        }
    }
    if ([m mentionedEveryone]) {
        mentioned = YES;
    }
    
    if ([c isKindOfClass:[DLDirectMessageChannel class]] || mentioned) {
        if ([[[DLController sharedInstance] selectedChannel] isEqual:c]) {
            if (![self.window isKeyWindow]) {
                [c notifyOfNewMention];
                [s notifyOfNewMention];
                [[DLAudioPlayer sharedInstance] playAudioWithID:AudioIDNotificationNewMention];
            }
        } else {
            [c notifyOfNewMention];
            [s notifyOfNewMention];
            [[DLAudioPlayer sharedInstance] playAudioWithID:AudioIDNotificationNewMention];
        }
    }
    
    if ([s isEqual:[[DLController sharedInstance] myServerItem]] && [[[DLController sharedInstance] selectedServer] isEqual:[[DLController sharedInstance] myServerItem]]) {
        [NSThread detachNewThreadSelector:@selector(loadDirectMessageChannels) toTarget:self withObject:nil];
    }
}

-(void)didLogoutSuccessfully {
    [delegate logoutWasSuccessful];
}

#pragma mark Text View Delegated Functions

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString {
    
    return YES;
}

- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)aSelector
{
    if (aSelector == @selector(insertNewline:)) {
        NSEvent * event = [NSApp currentEvent];
        if ((event.modifierFlags & NSShiftKeyMask) != NSShiftKeyMask) {
            DLMessage *toSend = [[DLMessage alloc] init];
            [toSend setContent:[messageEntryTextView string]];
            
            NSMutableArray *attachments = [[NSMutableArray alloc] init];
            NSEnumerator *e = [[pendingAttachmentsScrollView content] objectEnumerator];
            PendingAttachmentViewController *vc;
            while (vc = [e nextObject]) {
                [attachments addObject:[vc representedObject]];
            }
            [toSend setAttachments:attachments];
            [attachments release];
            [[DLController sharedInstance] sendMessage:toSend toChannel:[[DLController sharedInstance] selectedChannel]];
            [toSend release];
            [messageEntryTextView setString:@""];
            [self textDidChange:nil];
            [self hidePendingAttachmentView];
            return YES;
        }
    }
    return NO;
}

-(void)textDidChange:(NSNotification *)notification {
    NSRect textFrame = [messageEntryTextView.layoutManager usedRectForTextContainer:messageEntryTextView.textContainer];
    if (textFrame.size.height <= 126) {
        NSRect scrollViewFrame = messageEntryScrollView.frame;
        scrollViewFrame.size.height = textFrame.size.height + 8;
        [messageEntryScrollView setFrame:scrollViewFrame];
        
        CGFloat change = scrollViewFrame.size.height - currentMessageScrollHeight;
        
        NSRect containerFrame = messageEntryContainerView.frame;
        containerFrame.size.height += change;
        [messageEntryContainerView setFrame:containerFrame];
        
        NSRect chatViewFrame = chatScrollView.frame;
        chatViewFrame.size.height -= change;
        chatViewFrame.origin.y += change;
        [chatScrollView setFrame:chatViewFrame];
        
        currentMessageScrollHeight = scrollViewFrame.size.height;
        if (change) {
            [chatScrollView setNeedsDisplay:YES];
            [messageEntryContainerView setNeedsDisplay:YES];
        }
    }
}

@end
