//
//  DLTextParser.m
//  Discord Lite
//
//  Created by Collin Mistr on 11/28/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLTextParser.h"

@implementation DLTextParser

const CGFloat MESSAGE_VIEW_FONT_SIZE = 13.0;

+(NSAttributedString *)attributedContentStringForMessage:(DLMessage *)m {
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:[m content]];
    [as addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:MESSAGE_VIEW_FONT_SIZE] range:NSMakeRange(0, [m content].length)];
    [as addAttribute:NSForegroundColorAttributeName value:[NSColor textColor] range:NSMakeRange(0, [m content].length)];
    
    NSString *userTagRegex = @"<@(!)?([0-9]*)>";
    NSString *userIDRegex = @"[0-9]+";
    
    NSArray *tagMatches = [[m content] componentsMatchedByRegex:userTagRegex];
    NSEnumerator *e = [tagMatches objectEnumerator];
    NSString *matchedTag;
    while (matchedTag = [e nextObject]) {
        NSString *userID = [matchedTag stringByMatching:userIDRegex];
        NSEnumerator *ee = [[m mentionedUsers] objectEnumerator];
        DLUser *user;
        while (user = [ee nextObject]) {
            if ([[user userID] isEqualToString:userID]) {
                NSString *username = [NSString stringWithFormat:@"@%@", [user username]];
                NSRange replacementRange = [[as string] rangeOfString:matchedTag];
                [as replaceCharactersInRange:replacementRange withString:username];
                [as addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:MESSAGE_VIEW_FONT_SIZE] range:NSMakeRange(replacementRange.location, username.length)];
            }
        }
    }
    
    NSInteger lastLocation = -1;
    while (lastLocation != NSNotFound) {
        NSRange everyoneRange = [[as string] rangeOfString:@"@everyone" options:0 range:NSMakeRange(lastLocation + 1, [as string].length - (lastLocation + 1))];
        lastLocation = everyoneRange.location;
        if (lastLocation != NSNotFound) {
            [as addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:MESSAGE_VIEW_FONT_SIZE] range:everyoneRange];
        }
    }
    
    NSString *urlRegex = @"(?i)\\b(?:(?:https?|ftp)://)(?:\\S+(?::\\S*)?@)?(?:(?!(?:10|127)(?:\\.\\d{1,3}){3})(?!(?:169\\.254|192\\.168)(?:\\.\\d{1,3}){2})(?!172\\.(?:1[6-9]|2\\d|3[0-1])(?:\\.\\d{1,3}){2})(?:[1-9]\\d?|1\\d\\d|2[01]\\d|22[0-3])(?:\\.(?:1?\\d{1,2}|2[0-4]\\d|25[0-5])){2}(?:\\.(?:[1-9]\\d?|1\\d\\d|2[0-4]\\d|25[0-4]))|(?:(?:[a-z\\u00a1-\\uffff0-9]-*)*[a-z\\u00a1-\\uffff0-9]+)(?:\\.(?:[a-z\\u00a1-\\uffff0-9]-*)*[a-z\\u00a1-\\uffff0-9]+)*(?:\\.(?:[a-z\\u00a1-\\uffff]{2,}))\\.?)(?::\\d{2,5})?(?:[/?#]\\S*)?\\b";
    
    NSArray *urlMatches = [[m content] componentsMatchedByRegex:urlRegex];
    e = [urlMatches objectEnumerator];
    NSString *matchedUrl;
    while (matchedUrl = [e nextObject]) {
        [as addAttribute: NSLinkAttributeName value:matchedUrl range:[[as string] rangeOfString:matchedUrl]];
    }
    
    return [as autorelease];
}

@end
