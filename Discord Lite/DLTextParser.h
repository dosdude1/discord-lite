//
//  DLTextParser.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/28/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLMessage.h"

@interface DLTextParser : NSObject

+(NSAttributedString *)attributedContentStringForMessage:(DLMessage *)m;

@end
