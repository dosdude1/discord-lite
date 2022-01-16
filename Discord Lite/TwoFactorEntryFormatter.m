//
//  TwoFactorEntryFormatter.m
//  Discord Lite
//
//  Created by Collin Mistr on 1/16/22.
//  Copyright (c) 2022 dosdude1. All rights reserved.
//

#import "TwoFactorEntryFormatter.h"

@implementation TwoFactorEntryFormatter

-(id)init {
    self = [super init];
    [self setNumberStyle:NSNumberFormatterNoStyle];
    [self setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [self setMaximumFractionDigits:0];
    [self setMinimumFractionDigits:0];
    return self;
}

- (BOOL)isPartialStringValid:(NSString*)partialString newEditingString:(NSString**)newString errorDescription:(NSString**)error
{
    
    if (!nonDecimalCharacters) {
        nonDecimalCharacters = [[[NSCharacterSet decimalDigitCharacterSet] invertedSet] retain];
    }
    
    if ([partialString length] == 0) {
        return YES;
    } else if ([partialString rangeOfCharacterFromSet:nonDecimalCharacters].location != NSNotFound) {
        return NO;
    }
    if ([partialString length] > 1) {
        return NO;
    }
    return YES;
}

@end
