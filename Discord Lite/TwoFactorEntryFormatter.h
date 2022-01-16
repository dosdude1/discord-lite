//
//  TwoFactorEntryFormatter.h
//  Discord Lite
//
//  Created by Collin Mistr on 1/16/22.
//  Copyright (c) 2022 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TwoFactorEntryFormatter : NSNumberFormatter {
    NSCharacterSet *nonDecimalCharacters;
}

-(id)init;
-(BOOL)isPartialStringValid:(NSString*)partialString newEditingString:(NSString**)newString errorDescription:(NSString**)error;

@end
