//
//  DLError.h
//  Discord Lite
//
//  Created by Collin Mistr on 10/27/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ErrorTypeConnection = 0,
    ErrorTypeRequest = 1
} ErrorType;

@class DLError;

@interface DLError : NSObject {
    ErrorType type;
    NSString *messageText;
    NSString *infoText;
}

+(DLError *)requestErrorWithMessage:(NSString *)message;
+(DLError *)generalConnectionError;

-(id)init;
-(void)setType:(ErrorType)t;
-(void)setMessageText:(NSString *)text;
-(void)setInfoText:(NSString *)text;

-(NSString *)messageText;
-(NSString *)infoText;

@end
