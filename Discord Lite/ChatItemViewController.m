//
//  ChatItemViewController.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/1/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "ChatItemViewController.h"

@implementation ChatItemViewController

const NSInteger VIEW_HEADER_SPACING = 60;
const NSInteger ATTACHMENT_SPACING = 15;

-(void)awakeFromNib {
    baseViewHeight = view.frame.size.height;
    [insetView setBackgroundColor:[NSColor controlBackgroundColor]];
    [chatTextView setEditable:NO];
    [chatTextView setFont:[NSFont systemFontOfSize:13]];
    [chatTextView setMenuDelegate:self];
    [chatTextView setDrawsBackground:NO];
    
    [insetView setDelegate:self];
    
    contextMenu = [[NSMenu alloc] init];
    NSMenuItem *replyItem = [[NSMenuItem alloc] initWithTitle:@"Reply" action:@selector(addReply) keyEquivalent:@""];
    [replyItem setTarget:self];
    [contextMenu addItem:replyItem];
    [replyItem release];
    
    NSMenuItem *copyItem = [[NSMenuItem alloc] initWithTitle:@"Copy Message" action:@selector(copyMessageContent) keyEquivalent:@""];
    [copyItem setTarget:self];
    [contextMenu addItem:copyItem];
    [copyItem release];
}

-(CGFloat)expectedHeight {
    CGFloat textViewHeight = 0;
    if (![[representedObject content] isEqualToString:@""]) {
        textViewHeight = chatTextView.frame.size.height;
    }
    CGFloat height = VIEW_HEADER_SPACING;
    height += textViewHeight;
    CGFloat attachmentsHeight = 0;
    NSEnumerator *e = [[representedObject attachments] objectEnumerator];
    DLAttachment *attachment;
    while (attachment = [e nextObject]) {
        attachmentsHeight += [attachment scaledHeight] + ATTACHMENT_SPACING;
    }
    NSRect frame = chatTextView.frame;
    frame.origin.y = attachmentsHeight + 20;
    frame.size.height = textViewHeight;
    [chatTextView setFrame:frame];
    height += attachmentsHeight;
    if ([representedObject referencedMessage]) {
        height += referencedMessageView.frame.size.height;
    }
    return height;
}
-(DLMessage *)representedObject {
    return representedObject;
}
-(void)setDelegate:(id<ChatItemViewControllerDelegate>)inDelegate {
    delegate = inDelegate;
}
-(void)setRepresentedObject:(DLMessage *)obj {
    [representedObject release];
    [obj retain];
    representedObject = obj;
    [[representedObject author] setDelegate:self];
    
    [[chatTextView textStorage] setAttributedString:[DLTextParser attributedContentStringForMessage:representedObject]];
    
    [usernameTextField setStringValue:[[representedObject author] username]];
    [avatarImageView setImage:[[[NSImage alloc] initWithData:[[representedObject author] avatarImageData]] autorelease]];
    [[representedObject author] loadAvatarData];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    NSDate *today = [cal dateFromComponents:comps];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:-1];
    NSDate *yesterday = [cal dateByAddingComponents:components toDate:today options:0];
    NSString *dateFormat = @"h:mm a";
    NSString *dateUserString = @"Today at";
    if ([[representedObject timestamp] isGreaterThan:today]) {
        dateUserString = @"Today at";
    } else if ([[representedObject timestamp] isGreaterThan:yesterday]) {
        dateUserString = @"Yesterday at";
    } else {
        dateUserString = @"";
        dateFormat = @"M/dd/yyyy";
    }
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateFormat:dateFormat];
    NSString *timestamp = [formatter stringFromDate:[representedObject timestamp]];
    [timestampTextField setStringValue:[NSString stringWithFormat:@"%@ %@", dateUserString, timestamp]];
    
    [components release];
    
    CGFloat attachmentsHeight = 0;
    NSMutableArray *views = [[NSMutableArray alloc] init];
    NSEnumerator *e = [[representedObject attachments] objectEnumerator];
    DLAttachment *attachment;
    while (attachment = [e nextObject]) {
        AttachmentPreviewViewController *attachmentVC = [[AttachmentPreviewViewController alloc] initWithNibNamed:@"AttachmentPreviewViewController" bundle:nil];
        [attachmentVC setRepresentedObject:attachment];
        NSRect frame = [attachmentVC attachmentView].frame;
        frame.origin.y = ((([self expectedHeight] - attachmentsHeight) - VIEW_HEADER_SPACING) - chatTextView.frame.size.height) - frame.size.height;
        if ([representedObject referencedMessage]) {
            frame.origin.y -= referencedMessageView.frame.size.height;
        }
        frame.origin.x = chatTextView.frame.origin.x;
        [[attachmentVC attachmentView] setFrame:frame];
        [views addObject:attachmentVC];
        [insetView addSubview:attachmentVC.attachmentView];
        attachmentsHeight += [attachment scaledHeight] + ATTACHMENT_SPACING;
        [attachmentVC release];
    }
    attachmentViews = views;
    
    CGFloat shift = 0;
    if ([representedObject referencedMessage]) {
        [[[representedObject referencedMessage] author] setDelegate:self];
        shift = referencedMessageView.frame.size.height;
        
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[[[[representedObject referencedMessage] author] username] stringByAppendingString:@" "]];
        [attStr addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:12] range:NSMakeRange(0, attStr.length)];
        [attStr appendAttributedString:[DLTextParser attributedContentStringForMessage:[representedObject referencedMessage]]];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        [attStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attStr.length)];
        [referencedMessageTextField setAttributedStringValue:attStr];
        
        [referencedMessageAvatarImageView setImage:[[[NSImage alloc] initWithData:[[[representedObject referencedMessage] author]avatarImageData]] autorelease]];
        NSRect frame = usernameTextField.frame;
        frame.origin.y -= shift;
        [usernameTextField setFrame:frame];
        frame = timestampTextField.frame;
        frame.origin.y -= shift;
        [timestampTextField setFrame:frame];
        frame = avatarImageView.frame;
        frame.origin.y -= shift;
        [avatarImageView setFrame:frame];
        
        frame = referencedMessageView.frame;
        frame.origin.y = 31;
        frame.size.width = insetView.frame.size.width - 5;
        [referencedMessageView setFrame:frame];
        [insetView addSubview:referencedMessageView];
        
        [[[representedObject referencedMessage] author] loadAvatarData];
    }
}

-(void)addReply {
    [delegate addReferencedMessage:representedObject];
}
-(void)copyMessageContent {
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
    [pasteBoard setString:[representedObject content] forType:NSStringPboardType];
}

-(void)dealloc {
    [attachmentViews release];
    [representedObject release];
    [self.view release];
    [super dealloc];
}

#pragma mark Delegated Functions

-(void)user:(DLUser *)u avatarDidUpdateWithData:(NSData *)data {
    if ([u isEqual:[representedObject author]]) {
        [avatarImageView setImage:[[[NSImage alloc] initWithData:data] autorelease]];
    }
    if ([representedObject referencedMessage]) {
        if ([u isEqual:[[representedObject referencedMessage] author]]) {
            [referencedMessageAvatarImageView setImage:[[[NSImage alloc] initWithData:data] autorelease]];
        }
    }
}

-(void)mouseWasDepressedWithEvent:(NSEvent *)event {
    if ((event.modifierFlags & NSControlKeyMask) == NSControlKeyMask) {
        [NSMenu popUpContextMenu:contextMenu withEvent:event forView:nil];
    }
}
-(void)mouseRightButtonWasDepressedWithEvent:(NSEvent *)event {
    [NSMenu popUpContextMenu:contextMenu withEvent:event forView:nil];
}

-(NSMenu *)textViewContextMenu {
    return contextMenu;
}

@end
