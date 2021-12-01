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
    [insetView setBackgroundColor:[NSColor whiteColor]];
    [chatTextView setEditable:NO];
    [chatTextView setFont:[NSFont systemFontOfSize:13]];
    
}
-(CGFloat)expectedHeight {
    CGFloat textViewHeight = 0;
    if (![[representedObject content] isEqualToString:@""]) {
        textViewHeight = chatTextView.frame.size.height;
    }
    CGFloat height = 0;
    height += textViewHeight + VIEW_HEADER_SPACING;
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
    return height;
}
-(DLMessage *)representedObject {
    return representedObject;
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
        frame.origin.x = chatTextView.frame.origin.x;
        [[attachmentVC attachmentView] setFrame:frame];
        [views addObject:attachmentVC];
        [insetView addSubview:attachmentVC.attachmentView];
        attachmentsHeight += [attachment scaledHeight] + ATTACHMENT_SPACING;
        [attachmentVC release];
    }
    attachmentViews = views;
}

-(void)dealloc {
    [attachmentViews release];
    [representedObject release];
    [self.view release];
    [super dealloc];
}

#pragma mark Delegated Functions

-(void)avatarDidUpdateWithData:(NSData *)data {
    [avatarImageView setImage:[[[NSImage alloc] initWithData:data] autorelease]];
}

@end
