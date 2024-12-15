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

const NSTimeInterval TYPING_SEND_INTERVAL = 8.0;
const CGFloat MY_USER_AVATAR_RADIUS = 18.0f;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [messageEntryTextView setSelectedTextAttributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DLTextParser DEFAULT_TEXT_COLOR], [DLTextParser DEFAULT_TEXT_HIGHLIGHT_COLOR], nil] forKeys:[NSArray arrayWithObjects:NSForegroundColorAttributeName, NSBackgroundColorAttributeName, nil]]];
    
    [channelViewHeader setBackgroundColor:[channelsScrollView backgroundColor]];
    [channelViewHeader setNeedsDisplay:YES];
    
    [chatViewHeader setBackgroundColor:[chatScrollView backgroundColor]];
    [chatViewHeader setNeedsDisplay:YES];
    
    [userInfoView setBackgroundColor:[NSColor colorWithCalibratedRed:26.0/255.0 green:27.0/255.0 blue:30.0/255.0 alpha:1.0f]];
    [userInfoView setNeedsDisplay:YES];
    
    [messageEntryContainerView setBackgroundColor:[NSColor colorWithCalibratedRed:37.0/255.0 green:38.0/255.0 blue:42.0/255.0 alpha:1.0f]];
    [messageEntryContainerView setNeedsDisplay:YES];
    
    [serverViewScroller setBackgroundColor:[serversScrollView backgroundColor]];
    [serverViewScroller setNeedsDisplay:YES];
    
    [channelViewScroller setBackgroundColor:[channelsScrollView backgroundColor]];
    [channelViewScroller setNeedsDisplay:YES];
    
    [chatViewScroller setBackgroundColor:[chatScrollView backgroundColor]];
    [chatViewScroller setNeedsDisplay:YES];
    
    [messageEntryViewScroller setBackgroundColor:[messageEntryTextView backgroundColor]];
    [messageEntryViewScroller setNeedsDisplay:YES];
    
    [tagSelectionViewScroller setBackgroundColor:[tagSelectionScrollView backgroundColor]];
    [tagSelectionViewScroller setNeedsDisplay:YES];
    
    [pendingAttachmentViewScroller setBackgroundColor:[pendingAttachmentsScrollView backgroundColor]];
    [pendingAttachmentViewScroller setNeedsDisplay:YES];
    
    lastMessage = nil;
    editingLocation = NSNotFound;
    tagIndex = NSNotFound;
    messageEditor = [[DLMessageEditor alloc] init];
    [messageEditor setDelegate:self];
    isLoadingMessages = NO;
    isLoadingViews = NO;
    isTyping = NO;
    madeMentionChange = NO;
    serverViews = [[NSArray alloc] init];
    [[DLController sharedInstance] setDelegate:self];
    [chatScrollView.contentView setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatScrollViewBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:chatScrollView.contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serversScrollViewBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:serversScrollView.contentView];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [myUserAvatarImage setImage:[DLUtil imageResize:[[[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"discord_placeholder.png"]] autorelease] newSize:myUserAvatarImage.frame.size cornerRadius:MY_USER_AVATAR_RADIUS]];
    [messageEntryTextView setDelegate:self];
    [chatScrollView setDelegate:self];
    currentMessageScrollHeight = messageEntryScrollView.frame.size.height;
    typingUsers = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTextViewSizing) name:NSWindowDidResizeNotification object:nil];
}

-(void)setDelegate:(id<DLMainWindowDelegate>)inDelegate {
    delegate = inDelegate;
}

-(void)resetUI {
    isTyping = NO;
    [typingTimer invalidate];
    typingTimer = nil;
    [typingUsers removeAllObjects];
    [self updateTypingString];
    [self hidePendingAttachmentView];
    [self hideReplyToView];
    [messageEditor clear];
    [messageEntryTextView setString:@""];
    [self textDidChange:nil];
}

-(void)loadMainContent {
    DLUser *u = [[DLController sharedInstance] myUser];
    [u setDelegate:self];
    [myUserAvatarImage setImage:[DLUtil imageResize:[[[NSImage alloc] initWithData:[u avatarImageData]] autorelease] newSize:myUserAvatarImage.frame.size cornerRadius:MY_USER_AVATAR_RADIUS]];
    [myUsernameTextField setStringValue:[u globalName]];
    [myDiscTextField setStringValue:[u username]];
    [u loadAvatarData];
}

-(void)populateUserServers {
    NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
    if (!isLoadingViews) {
        isLoadingViews = YES;
        NSMutableArray *views = [[NSMutableArray alloc] init];
        
        me = [[[ServerItemViewController alloc] initWithNibNamed:@"ServerItemViewController" bundle:nil] autorelease];
        [me setType:ServerItemViewTypeMe];
        [me setRepresentedObject:[[DLController sharedInstance] myServerItem]];
        [me setDelegate:self];
        if ([[[DLController sharedInstance] selectedServer] isEqual:[[DLController sharedInstance] myServerItem]]) {
            [me setSelected:YES];
        }
        
        ServerItemViewController *separator = [[[ServerItemViewController alloc] initWithNibNamed:@"ServerItemViewController" bundle:nil] autorelease];
        [separator setType:ServerItemViewTypeSeparator];
        
        [views addObject:me];
        [views addObject:separator];
        
        NSEnumerator *e = [[[DLController sharedInstance] userServers] objectEnumerator];
        DLServer *item;
        while (item = [e nextObject]) {
            if (![item isEqual:[[DLController sharedInstance] myServerItem]]) {
                ServerItemViewController *view = [[[ServerItemViewController alloc] initWithNibNamed:@"ServerItemViewController" bundle:nil] autorelease];
                
                
                [view setRepresentedObject:item];
                [view setDelegate:self];
                if ([[[DLController sharedInstance] selectedServer] isEqual:item]) {
                    [view setSelected:YES];
                }
                [views addObject:view];
            }
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
        
        NSArray *channels = [[DLController sharedInstance] channelsForServer:[item representedObject]];
        NSMutableArray *views = [[NSMutableArray alloc] init];
        NSEnumerator *e = [channels objectEnumerator];
        DLServerChannel *channelItem;
        while (channelItem = [e nextObject]) {
            ChannelItemViewController *view = [[[ChannelItemViewController alloc] initWithNibNamed:@"ChannelItemViewController" bundle:nil] autorelease];
            [view setDelegate:self];
            [view setRepresentedObject:channelItem];
            [views addObject:view];
            NSEnumerator *ee = [[channelItem children] objectEnumerator];
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
        
        NSArray *channels = [[DLController sharedInstance] directMessageChannels];
        NSMutableArray *views = [[NSMutableArray alloc] init];
        NSEnumerator *e = [channels objectEnumerator];
        DLDirectMessageChannel *item;
        while (item = [e nextObject]) {
            DirectMessageItemViewController *view = [[DirectMessageItemViewController alloc] initWithNibNamed:@"DirectMessageItemViewController" bundle:nil];
            [view setDelegate:self];
            [view setRepresentedObject:item];
            if ([item isEqual:[[DLController sharedInstance] selectedChannel]]) {
                [view setSelected:YES];
            }
            [views addObject:view];
            [view release];
            
        }
        [serverLabel performSelectorOnMainThread:@selector(setStringValue:) withObject:@"Direct Messages" waitUntilDone:NO];
        [channelsScrollView performSelectorOnMainThread:@selector(setContent:) withObject:views waitUntilDone:NO];
        [channelViews release];
        channelViews = views;
        e = [channels objectEnumerator];
        while (item = [e nextObject]) {
            [item performSelectorOnMainThread:@selector(loadAvatarImageData) withObject:nil waitUntilDone:NO];
        }
        isLoadingViews = NO;
    }
    
    [autoreleasepool release];
}

-(void)showPendingAttachmentView {
    if (![pendingAttachmentsScrollView superview]) {
        
        //CGPoint originalScrollOrigin = [chatScrollView frame].origin;
        
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
        
        if ([replyToView superview]) {
            NSRect replyToViewFrame = replyToView.frame;
            replyToViewFrame.origin.y -= attachmentsViewFrame.size.height;
            [replyToView setFrame:replyToViewFrame];
            [replyToView setNeedsDisplay:YES];
        }
        
        //[chatScrollView.documentView scrollPoint:NSMakePoint(0, [[chatScrollView contentView] bounds].origin.y + originalScrollOrigin.y)];
    }
}

-(void)hidePendingAttachmentView {
    if ([pendingAttachmentsScrollView superview]) {
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
        
        if ([replyToView superview]) {
            NSRect replyToViewFrame = replyToView.frame;
            replyToViewFrame.origin.y += attachmentsViewFrame.size.height;
            [replyToView setFrame:replyToViewFrame];
            [replyToView setNeedsDisplay:YES];
        }
    }
}

-(void)showReplyToView {
    if (![replyToView superview]) {
        NSRect replyToViewFrame = replyToView.frame;
        replyToViewFrame.origin.y = messageEntryScrollView.frame.size.height + 35;
        replyToViewFrame.size.width = messageEntryContainerView.frame.size.width;
        [replyToView setFrame:replyToViewFrame];
        
        NSRect chatViewFrame = chatScrollView.frame;
        chatViewFrame.size.height -= replyToViewFrame.size.height;
        chatViewFrame.origin.y += replyToViewFrame.size.height;
        [chatScrollView setFrame:chatViewFrame];
        
        NSRect containerFrame = messageEntryContainerView.frame;
        containerFrame.size.height += replyToViewFrame.size.height;
        [messageEntryContainerView setFrame:containerFrame];
        
        [messageEntryContainerView addSubview:replyToView];
        [messageEntryContainerView setNeedsDisplay:YES];
        [chatScrollView setNeedsDisplay:YES];
    }
}

-(void)hideReplyToView {
    if ([replyToView superview]) {
        NSRect replyToViewFrame = replyToView.frame;
        
        NSRect chatViewFrame = chatScrollView.frame;
        chatViewFrame.size.height += replyToViewFrame.size.height;
        chatViewFrame.origin.y -= replyToViewFrame.size.height;
        [chatScrollView setFrame:chatViewFrame];
        
        NSRect containerFrame = messageEntryContainerView.frame;
        containerFrame.size.height -= replyToViewFrame.size.height;
        [messageEntryContainerView setFrame:containerFrame];
        
        [replyToView removeFromSuperview];
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
        
        [self updatePendingAttachmentsWithFilePaths:[openDlg filenames]];
    }
}

- (IBAction)showSettingsMenu:(id)sender {
    NSMenu *contextMenu = [[NSMenu alloc] init];
    [contextMenu addItemWithTitle:@"Log Out" action:@selector(logOutUser) keyEquivalent:@""];
    [NSMenu popUpContextMenu:contextMenu withEvent:[NSApp currentEvent] forView:(NSButton *)sender];
}

-(void)showTagSelectionViewWithContent:(NSArray *)content {
    
    NSInteger limit = 10;
    NSInteger startIndex = 0;
    
    if (content.count > limit) {
        startIndex = content.count - limit;
    }
    
    if (content.count > 0) {
        NSRect frame = [tagSelectionScrollView frame];
        frame.size.width = [messageEntryContainerView frame].size.width;
        frame.origin.y = [messageEntryContainerView frame].size.height;
        frame.origin.x = [messageEntryContainerView frame].origin.x;
        [tagSelectionScrollView setFrame:frame];
        
        if (![tagSelectionScrollView superview]) {
            [self.window.contentView addSubview:tagSelectionScrollView];
        }
        
        NSMutableArray *views = [[NSMutableArray alloc] init];
        for (NSInteger i=startIndex; i<content.count; i++) {
            TagSelectionViewController *view = [[TagSelectionViewController alloc] initWithNibNamed:@"TagSelectionViewController" bundle:nil];
            if (i == content.count - 1) {
                [view setSelected:YES];
            }
            [view setRepresentedObject:[content objectAtIndex:i]];
            [view setDelegate:self];
            [views addObject: view];
            [view release];
        }
        [tagSelectionScrollView setContent:views];
        [views release];
        
        CGFloat newHeight = [[tagSelectionScrollView documentView] frame].size.height + 2;
        if (newHeight > 300) {
            newHeight = 300;
        }
        
        frame = [tagSelectionScrollView frame];
        frame.size.height = newHeight;
        [tagSelectionScrollView setFrame:frame];
        
    } else {
        [tagSelectionScrollView removeFromSuperview];
    }
    [chatScrollView setNeedsDisplay:YES];
    [tagSelectionScrollView setNeedsDisplay:YES];
}

-(void)hideTagSelectionView {
    if ([tagSelectionScrollView superview]) {
        [tagSelectionScrollView removeFromSuperview];
        [chatScrollView setNeedsDisplay:YES];
        [tagSelectionScrollView setNeedsDisplay:YES];
    }
}

-(void)updateTextViewSizing {
    [messageEntryTextView.layoutManager glyphRangeForTextContainer:messageEntryTextView.textContainer];
    NSRect textFrame = [messageEntryTextView.layoutManager usedRectForTextContainer:messageEntryTextView.textContainer];
    if (textFrame.size.height <= 126) {
        NSRect scrollViewFrame = messageEntryScrollView.frame;
        scrollViewFrame.size.height = textFrame.size.height + 8;
        [messageEntryScrollView setFrame:scrollViewFrame];
        
        CGFloat change = scrollViewFrame.size.height - currentMessageScrollHeight;
        
        if (change) {
            
            NSRect containerFrame = messageEntryContainerView.frame;
            containerFrame.size.height += change;
            [messageEntryContainerView setFrame:containerFrame];
            
            NSRect chatViewFrame = chatScrollView.frame;
            chatViewFrame.size.height -= change;
            chatViewFrame.origin.y += change;
            [chatScrollView setFrame:chatViewFrame];
            
            [chatScrollView setNeedsDisplay:YES];
            [messageEntryContainerView setNeedsDisplay:YES];
        }
        currentMessageScrollHeight = scrollViewFrame.size.height;
    }
}

-(void)updateTypingStatus {
    if (isTyping) {
        isTyping = NO;
        [typingTimer invalidate];
        typingTimer = nil;
    }
}

- (IBAction)removeReferencedMessage:(id)sender {
    [messageEditor removeReferencedMessage];
    [self hideReplyToView];
}

-(BOOL)isEditingTag {
    NSString *textPreSelection = [[messageEntryTextView string] substringToIndex:editingLocation];
    tagIndex = [textPreSelection rangeOfString:@"@" options:NSBackwardsSearch].location;
    return (tagIndex != NSNotFound) && ([[textPreSelection substringFromIndex:tagIndex] rangeOfString:@" "].location == NSNotFound);
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (contextInfo == DLDialogConfirmMessageDelete) {
        if (returnCode == NSAlertSecondButtonReturn) {
            [[DLController sharedInstance] deleteMessage:messagePendingDeletion];
        }
        messagePendingDeletion = nil;
    }
}

-(void)updateServerViewMouseTracking {
    serverItemTrackingTimer = nil;
    NSEnumerator *e = [serverViews objectEnumerator];
    ServerItemViewController *serverView;
    while (serverView = [e nextObject]) {
        [serverView updateRectTracking];
    }
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

-(void)updatePendingAttachmentsWithFilePaths:(NSArray *)paths {
    [self showPendingAttachmentView];
    NSEnumerator *e = [paths objectEnumerator];
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

-(void)editorContentDidUpdateWithAttributedString:(NSAttributedString *)as {
    NSInteger lenChange = as.length - [messageEntryTextView string].length;
    NSUInteger tempLoc = editingLocation + lenChange;
    [[messageEntryTextView textStorage] beginEditing];
    [[messageEntryTextView textStorage] setAttributedString:as];
    [[messageEntryTextView textStorage] endEditing];
    [messageEntryTextView setSelectedRange:NSMakeRange(tempLoc, 0)];
    [self updateTextViewSizing];
}

-(void)chatScrollViewBoundsDidChange:(NSNotification *)note {
    NSClipView *scrolledClipView = [note object];
    if ([chatScrollView.documentView bounds].size.height <= [scrolledClipView bounds].size.height + [scrolledClipView bounds].origin.y) {
        if (!isLoadingMessages) {
            isLoadingMessages = YES;
            if ([[DLController sharedInstance] selectedChannel]) {
                [[DLController sharedInstance] loadMessagesForChannel:[[DLController sharedInstance] selectedChannel] beforeMessage:lastMessage quantity:25];
            }
        }
    }
}

-(void)serversScrollViewBoundsDidChange:(NSNotification *)note {
    if (serverItemTrackingTimer) {
        [serverItemTrackingTimer invalidate];
        serverItemTrackingTimer = nil;
    }
    serverItemTrackingTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(updateServerViewMouseTracking) userInfo:nil repeats:NO];
}

-(void)initialDataWasReceived {
    [NSThread detachNewThreadSelector:@selector(populateUserServers) toTarget:self withObject:nil];
    [self loadMainContent];
}

-(void)requestDidFailWithError:(DLError *)e {
    [DLErrorHandler displayError:e onWindow:self.window];
}

-(void)user:(DLUser *)u avatarDidUpdateWithData:(NSData *)data {
    [myUserAvatarImage setImage:[DLUtil imageResize:[[[NSImage alloc] initWithData:data] autorelease] newSize:myUserAvatarImage.frame.size cornerRadius:MY_USER_AVATAR_RADIUS]];
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
    [chatScrollView unregisterDraggedTypes];
    [self resetUI];
    [[DLController sharedInstance] setSelectedChannel:nil];
    [chatScrollView setContent:[NSArray array]];
    
    if (item == me) {
        [NSThread detachNewThreadSelector:@selector(loadDirectMessageChannels) toTarget:self withObject:nil];
    } else {
        [NSThread detachNewThreadSelector:@selector(loadChannelsForServerItem:) toTarget:self withObject:item];
    }
    
}

-(void)serverItemHoverActiveWithDetailView:(NSView *)detail atPoint:(CGPoint)p {
    NSRect r = [serversScrollView documentVisibleRect];
    
    [detail setFrame:NSMakeRect(p.x, p.y - r.origin.y, detail.frame.size.width, detail.frame.size.height)];
    [self.window.contentView addSubview:detail];
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
    [chatScrollView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    [self resetUI];
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
    [chatScrollView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    [self resetUI];
    [[DLController sharedInstance] loadMessagesForChannel:[item representedObject] beforeMessage:nil quantity:25];
}

-(void)tagSelectionItemWasSelected:(TagSelectionViewController *)item {
    NSEnumerator *e = [[tagSelectionScrollView content] objectEnumerator];
    TagSelectionViewController *itm;
    while (itm = [e nextObject]) {
        if (item != itm) {
            [itm setSelected:NO];
        }
    }
    [messageEditor addMentionedUser:[item representedObject] byReplacingStringInRange:NSMakeRange(tagIndex, editingLocation - tagIndex)];
    [self hideTagSelectionView];
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
        [view setDelegate:self];
        [view setRepresentedObject:item];
        if ([[item author] isEqual:[[DLController sharedInstance] myUser]]) {
            [view setIsMyContent:YES];
        }
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
        if ([c hasUnreadMessages] || [c mentionCount] > 0) {
            [[DLController sharedInstance] acknowledgeMessage:[c lastMessage]];
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
        [view setDelegate:self];
        if ([[m author] isEqual:[[DLController sharedInstance] myUser]]) {
            [view setIsMyContent:YES];
        }
        [chatScrollView prependViewController:view];
        [[m author] setTyping:NO];
        [self userDidStopTyping:[m author]];
        if ([self.window isKeyWindow]) {
            [[DLController sharedInstance] acknowledgeMessage:m];
        }
    }
    
    BOOL mentioned = NO;
    NSEnumerator *e = [[m mentionedUsers] objectEnumerator];
    DLUser *user;
    if (![[m author] isEqual:[[DLController sharedInstance] myUser]]) {
        while (user = [e nextObject]) {
            if ([user isEqual:[[DLController sharedInstance] myUser]]) {
                mentioned = YES;
            }
        }
        if ([m mentionedEveryone]) {
            mentioned = YES;
        }
        
        if (mentioned || [c isKindOfClass:[DLDirectMessageChannel class]]) {
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
    }
    
    if (![c isEqual:[[DLController sharedInstance] selectedChannel]]) {
        [c setHasUnreadMessages:YES];
        if (![s isEqual:[[DLController sharedInstance] myServerItem]]) {
            [s setHasUnreadMessages:YES];
        }
    }
    
    if ([s isEqual:[[DLController sharedInstance] myServerItem]] && [[[DLController sharedInstance] selectedServer] isEqual:[[DLController sharedInstance] myServerItem]]) {
        [NSThread detachNewThreadSelector:@selector(loadDirectMessageChannels) toTarget:self withObject:nil];
    }
}

-(void)didLogoutSuccessfully {
    [delegate logoutWasSuccessful];
}

-(void)updateTypingString {
    if (typingUsers.count > 0) {
        NSString *typingString = @"";
        [typingStatusTextField setHidden:NO];
        if (typingUsers.count == 1) {
            typingString = [NSString stringWithFormat:@"%@ is Typing...", [[typingUsers objectAtIndex:0] globalName]];
        } else if (typingUsers.count < 4) {
            for (int i = 0; i<typingUsers.count; i++) {
                if (i < typingUsers.count - 1) {
                    typingString = [typingString stringByAppendingString:[NSString stringWithFormat:@"%@", [[typingUsers objectAtIndex:i] globalName]]];
                    if (i < typingUsers.count - 2) {
                        typingString = [typingString stringByAppendingString:@", "];
                    } else {
                        typingString = [typingString stringByAppendingString:@" "];
                    }
                } else {
                    typingString = [typingString stringByAppendingString:[NSString stringWithFormat:@"and %@ are Typing...", [[typingUsers objectAtIndex:i] globalName]]];
                }
            }
        } else {
            typingString = @"Several People are Typing...";
        }
        [typingStatusTextField setStringValue:typingString];
    } else {
        [typingStatusTextField setHidden:YES];
    }
}

-(void)userDidStartTypingInSelectedChannel:(DLUser *)u {
    [u setTypingDelegate:self];
    if (![typingUsers containsObject:u]) {
        [typingUsers addObject:u];
    }
    [self updateTypingString];
}

-(void)userDidStopTyping:(DLUser *)u {
    [typingUsers removeObject:u];
    [self updateTypingString];
}

-(void)members:(NSArray *)members didUpdateForServer:(DLServer *)s {
    if ([self isEditingTag]) {
        NSMutableArray *users = [[NSMutableArray alloc] init];
        NSEnumerator *e = [members objectEnumerator];
        DLServerMember *m;
        while (m = [e nextObject]) {
            [users addObject:[m user]];
        }
        [self showTagSelectionViewWithContent:users];
    }
}

-(void)addReferencedMessage:(DLMessage *)m {
    if (![[[DLController sharedInstance] selectedServer] isEqual:[[DLController sharedInstance] myServerItem]]) {
        [m setServerID:[[[DLController sharedInstance] selectedServer] serverID]];
    }
    [messageEditor setReferencedMessage:m];
    NSString *baseString = [NSString stringWithFormat:@"Replying to %@", [[m author] globalName]];
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:baseString];
    [as addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:13] range:[baseString rangeOfString:[[m author] globalName]]];
    [replyToTextField setAttributedStringValue:as];
    [self showReplyToView];
}
-(BOOL)chatViewShouldBeginEditing:(ChatItemViewController *)chatView {
    [chatScrollView endAllChatContentEditing];
    [chatView becomeWindowFirstResponderForEditing:self.window];
    return YES;
}
-(void)chatViewUpdatedWithEnteredText:(ChatItemViewController *)chatView {
    [chatScrollView screenResize];
}

-(void)chatViewContentWasUpdated:(ChatItemViewController *)chatView {
    [chatScrollView performSelector:@selector(screenResize) withObject:nil afterDelay:0.5];
}

-(void)chatView:(ChatItemViewController *)chatView didEndEditingWithCommit:(BOOL)didCommit {
    if (didCommit) {
        [[DLController sharedInstance] submitEditedMessage:[chatView representedObject]];
    } else {
        [chatScrollView performSelector:@selector(screenResize) withObject:nil afterDelay:0.5];
    }
    [self.window makeFirstResponder:messageEntryTextView];
}

-(void)chatViewMessageShouldBeDeleted:(ChatItemViewController *)chatView {
    messagePendingDeletion = [chatView representedObject];
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Delete Message"];
    [alert setInformativeText:@"Are you sure you want to delete the selected message?"];
    [alert addButtonWithTitle:@"No"];
    [alert addButtonWithTitle:@"Yes"];
    [alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:DLDialogConfirmMessageDelete];
}

-(void)chatViewMessageWasDeleted:(ChatItemViewController *)chatView {
    [chatScrollView removeViewController:chatView];
}

#pragma mark Text View Delegated Functions

- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)aSelector
{
    if (aSelector == @selector(insertNewline:)) {
        NSEvent * event = [NSApp currentEvent];
        if ((event.modifierFlags & NSShiftKeyMask) != NSShiftKeyMask) {
            if ([tagSelectionScrollView superview]) {
                DLUser *selectedUser = nil;
                NSEnumerator *e = [[tagSelectionScrollView content] objectEnumerator];
                TagSelectionViewController *vc;
                while (vc = [e nextObject]) {
                    if ([vc isSelected]) {
                        selectedUser = [vc representedObject];
                        [messageEditor addMentionedUser:selectedUser byReplacingStringInRange:NSMakeRange(tagIndex, editingLocation - tagIndex)];
                    }
                }
                [self hideTagSelectionView];
            } else {
                
                NSEnumerator *e = [[pendingAttachmentsScrollView content] objectEnumerator];
                PendingAttachmentViewController *vc;
                while (vc = [e nextObject]) {
                    [messageEditor addAttachment:[vc representedObject]];
                }
                DLMessage *toSend = [messageEditor finalizedMessage];
                [[DLController sharedInstance] sendMessage:toSend toChannel:[[DLController sharedInstance] selectedChannel]];
                [toSend release];
                [messageEditor clear];
                [messageEntryTextView setString:@""];
                [self textDidChange:nil];
                [self hidePendingAttachmentView];
                [self hideReplyToView];
            }
            
            return YES;
        }
    }
    if(aSelector == @selector(moveUp:)){
        if ([tagSelectionScrollView superview]) {
            NSInteger selectedIndex = [tagSelectionScrollView content].count;
            for (NSInteger i=[tagSelectionScrollView content].count - 1; i >= 0; i--) {
                if ([[[tagSelectionScrollView content] objectAtIndex:i] isSelected]) {
                    selectedIndex = i;
                }
                [[[tagSelectionScrollView content] objectAtIndex:i] setSelected:NO];
            }
            if (selectedIndex == 0) {
                selectedIndex = [tagSelectionScrollView content].count;
            }
            TagSelectionViewController *item = [[tagSelectionScrollView content] objectAtIndex:selectedIndex - 1];
            [item setSelected:YES];
        } else {
            [chatScrollView endAllChatContentEditing];
            NSEnumerator *e = [[chatScrollView content] reverseObjectEnumerator];
            ChatItemViewController *item;
            while (item = [e nextObject]) {
                if ([[[item representedObject] author] isEqual:[[DLController sharedInstance] myUser]]) {
                    [item beginEditingContent];
                    [item becomeWindowFirstResponderForEditing:self.window];
                }
            }
        }
        return YES;
    }
    if(aSelector == @selector(moveDown:)){
        NSInteger selectedIndex = -1;
        for (NSInteger i = 0; i < [tagSelectionScrollView content].count; i++) {
            if ([[[tagSelectionScrollView content] objectAtIndex:i] isSelected]) {
                selectedIndex = i;
            }
            [[[tagSelectionScrollView content] objectAtIndex:i] setSelected:NO];
        }
        if (selectedIndex == [tagSelectionScrollView content].count - 1) {
            selectedIndex = -1;
        }
        TagSelectionViewController *item = [[tagSelectionScrollView content] objectAtIndex:selectedIndex + 1];
        [item setSelected:YES];
        return YES;
    }
    return NO;
}
-(void)textViewDidChangeSelection:(NSNotification *)notification {
    editingLocation = [[[messageEntryTextView selectedRanges] objectAtIndex:0] rangeValue].location;
    
    [messageEntryTextView setTypingAttributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DLTextParser DEFAULT_TEXT_COLOR], [messageEntryTextView backgroundColor], nil] forKeys:[NSArray arrayWithObjects:NSForegroundColorAttributeName, NSBackgroundColorAttributeName, nil]]];
    
    if ([self isEditingTag]) {
        NSString *textPreSelection = [[messageEntryTextView string] substringToIndex:editingLocation];
        tagIndex = [textPreSelection rangeOfString:@"@" options:NSBackwardsSearch].location;
        NSString *enteredUsername = [textPreSelection substringFromIndex:tagIndex];
        if ([[[DLController sharedInstance] selectedServer] isEqual:[[DLController sharedInstance] myServerItem]]) {
            if ([enteredUsername isEqualToString:@"@"]) {
                [self showTagSelectionViewWithContent:[(DLDirectMessageChannel *)[[DLController sharedInstance] selectedChannel] recipients]];
            } else {
                [self showTagSelectionViewWithContent:[[[DLController sharedInstance] selectedChannel] recipientsWithUsernameContainingString:[enteredUsername substringFromIndex:1]]];
            }
        } else {
            if ([enteredUsername isEqualToString:@"@"]) {
                NSMutableArray *users = [[NSMutableArray alloc] init];
                NSEnumerator *e = [[[[DLController sharedInstance] selectedServer] members] objectEnumerator];
                DLServerMember *m;
                while (m = [e nextObject]) {
                    if (![[m user] isEqual:[[DLController sharedInstance] myUser]]) {
                        [users addObject:[m user]];
                    }
                }
                [self showTagSelectionViewWithContent:users];
            } else {
                [[DLController sharedInstance] queryServer:[[DLController sharedInstance] selectedServer] forMembersContainingUsername:[enteredUsername substringFromIndex:1]];
            }
        }
    } else {
        [self hideTagSelectionView];
    }
}

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString {
    if ((NSInteger)affectedCharRange.location <= (NSInteger)([messageEntryTextView string].length - 1)) {
        NSDictionary *attributes = [[messageEntryTextView textStorage] attributesAtIndex:affectedCharRange.location effectiveRange:nil];
        if ([[attributes objectForKey:@kTagAttribute] boolValue]) {
            if ([[messageEntryTextView string] characterAtIndex:affectedCharRange.location] == '@') {
                if ([replacementString isEqualToString:@""]) {
                    madeMentionChange = YES;
                }
            } else {
                madeMentionChange = YES;
            }
        }
    }
    return YES;
}

-(void)textDidChange:(NSNotification *)notification {
    [messageEditor setContent:[messageEntryTextView string]];
    if (madeMentionChange) {
        [messageEditor removeMentionedUserAtStringIndex:tagIndex];
        madeMentionChange = NO;
    }
    
    [self updateTextViewSizing];
    
    if (!isTyping && (![[messageEntryTextView string] isEqualToString:@""])) {
        [[DLController sharedInstance] informTypingInChannel:[[DLController sharedInstance] selectedChannel]];
        isTyping = YES;
        typingTimer = [NSTimer scheduledTimerWithTimeInterval:TYPING_SEND_INTERVAL target:self selector:@selector(updateTypingStatus) userInfo:nil repeats:NO];
    }
}

@end
