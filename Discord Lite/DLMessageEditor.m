//
//  DLMessageEditor.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/28/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLMessageEditor.h"

@implementation DLMessageEditor

const CGFloat MESSAGE_EDITOR_FONT_SIZE = 13.0;

+(NSColor *)DEFAULT_EDITOR_TEXT_COLOR {
    return [NSColor colorWithCalibratedRed:212.0/255.0 green:213.0/255.0 blue:214.0/255.0 alpha:1.0f];
}

-(id)init {
    self = [super init];
    mentionedUsers = [[NSMutableArray alloc] init];
    attachments = [[NSMutableArray alloc] init];
    return self;
}
-(void)setDelegate:(id<DLMessageEditorDelegate>)inDelegate {
    delegate = inDelegate;
}


-(NSAttributedString *)attributedUserString {
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:userContent];
    NSInteger lastLocation = -1;
    NSInteger index = 0;
    [as addAttribute:NSForegroundColorAttributeName value:[DLMessageEditor DEFAULT_EDITOR_TEXT_COLOR] range:NSMakeRange(0, [as string].length)];
    while (lastLocation != NSNotFound) {
        lastLocation = [userContent rangeOfString:@"@" options:0 range:NSMakeRange(lastLocation + 1, userContent.length - (lastLocation + 1))].location;
        if (lastLocation != NSNotFound) {
            if (mentionedUsers.count >= index + 1) {
                DLUser *user = [mentionedUsers objectAtIndex:index];
                if ([user globalName].length <= userContent.length - (lastLocation + 1)) {
                    NSString *globalName = [userContent substringWithRange:NSMakeRange(lastLocation + 1, [user globalName].length)];
                    if ([globalName isEqualToString:[user globalName]]) {
                        NSRange tagRange = NSMakeRange(lastLocation, [user globalName].length + 1);
                        [as addAttribute:NSBackgroundColorAttributeName value:[NSColor colorWithCalibratedRed:52.0/255.0 green:61.0/255.0 blue:106.0/255.0 alpha:1.0f] range:tagRange];
                        [as addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:MESSAGE_EDITOR_FONT_SIZE] range:tagRange];
                        [as addAttribute:@kTagAttribute value:[NSNumber numberWithBool:YES] range:tagRange];
                        NSRange nonTagRange = NSMakeRange(tagRange.location + tagRange.length + 1, [as string].length - (tagRange.location + tagRange.length + 1));
                        [as addAttribute:NSForegroundColorAttributeName value:[DLMessageEditor DEFAULT_EDITOR_TEXT_COLOR] range:nonTagRange];
                        [as addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:MESSAGE_EDITOR_FONT_SIZE] range:nonTagRange];
                        index++;
                    }
                }
            }
        }
    }
    return [as autorelease];
}

-(void)setContent:(NSString *)inContent {
    userContent = inContent;
}
-(void)addMentionedUser:(DLUser *)u byReplacingStringInRange:(NSRange)range {
    
    NSString *previousTags = [userContent substringToIndex:range.location];
    NSInteger insertionIndex = 0;
    NSInteger lastLocation = -1;
    while (lastLocation != NSNotFound) {
        lastLocation = [previousTags rangeOfString:@"@" options:0 range:NSMakeRange(lastLocation + 1, previousTags.length - (lastLocation + 1))].location;
        if (lastLocation != NSNotFound) {
            if (mentionedUsers.count >= insertionIndex + 1) {
                DLUser *user = [mentionedUsers objectAtIndex:insertionIndex];
                if ([user globalName].length <= previousTags.length - (lastLocation + 1)) {
                    NSString *globalName = [previousTags substringWithRange:NSMakeRange(lastLocation + 1, [user globalName].length)];
                    if ([globalName isEqualToString:[user globalName]]) {
                        insertionIndex++;
                    }
                }
            }
        }
    }
    [mentionedUsers insertObject:u atIndex:insertionIndex];
    NSMutableString *contentTemp = [userContent mutableCopy];
    [contentTemp replaceCharactersInRange:range withString:[NSString stringWithFormat:@"@%@ ", [u globalName]]];
    userContent = [contentTemp copy];
    [delegate editorContentDidUpdateWithAttributedString:[self attributedUserString]];
}
-(void)removeMentionedUserAtStringIndex:(NSInteger)sIndex {
    NSAttributedString *as = [self attributedUserString];
    NSInteger indexToRemove = 0;
    NSInteger lastLocation = -1;
    while ((lastLocation != NSNotFound) && (lastLocation <= sIndex)) {
        lastLocation = [[as string] rangeOfString:@"@" options:0 range:NSMakeRange(lastLocation + 1, as.length - (lastLocation + 1))].location;
        if (lastLocation != NSNotFound) {
            NSDictionary *attributes = [as attributesAtIndex:lastLocation effectiveRange:nil];
            if ([[attributes objectForKey:@kTagAttribute] boolValue]) {
                indexToRemove++;
            }
        }
    }
    [mentionedUsers removeObjectAtIndex:indexToRemove];
    [delegate editorContentDidUpdateWithAttributedString:[self attributedUserString]];
    
}
-(void)addAttachment:(DLAttachment *)a {
    [attachments addObject:a];
}
-(void)removeAttachment:(DLAttachment *)a {
    [attachments removeObject:a];
}

-(void)setReferencedMessage:(DLMessage *)m {
    [referencedMessage release];
    [m retain];
    referencedMessage = m;
}
-(void)removeReferencedMessage {
    [referencedMessage release];
    referencedMessage = nil;
}

-(DLMessage *)finalizedMessage {
    
    NSMutableString *rawContent = [userContent mutableCopy];
    NSEnumerator *e = [mentionedUsers objectEnumerator];
    DLUser *user;
    NSInteger lastLocation = -1;
    while (user = [e nextObject]) {
        NSRange tagRange = [rawContent rangeOfString:[NSString stringWithFormat:@"@%@", [user globalName]] options:0 range:NSMakeRange(lastLocation + 1, rawContent.length - (lastLocation + 1))];
        if (tagRange.location != NSNotFound) {
            lastLocation = tagRange.location;
            [rawContent replaceCharactersInRange:tagRange withString:[NSString stringWithFormat:@"<@%@>", [user userID]]];
        }
    }
    DLMessage *m = [[DLMessage alloc] init];
    [m setContent:rawContent];
    [m setAttachments:attachments];
    [m setReferencedMessage:referencedMessage];
    return m;
}

-(void)clear {
    [mentionedUsers removeAllObjects];
    [attachments removeAllObjects];
    [referencedMessage release];
    referencedMessage = nil;
    userContent = @"";
}

@end
