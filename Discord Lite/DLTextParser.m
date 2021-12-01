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
    
    return [as autorelease];
}

@end
