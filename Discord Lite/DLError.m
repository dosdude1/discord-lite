//
//  DLError.m
//  Discord Lite
//
//  Created by Collin Mistr on 10/27/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "DLError.h"

@implementation DLError

+(DLError *)requestErrorWithMessage:(NSString *)message {
    DLError *e = [[DLError alloc] init];
    [e setType:ErrorTypeRequest];
    [e setInfoText:message];
    return [e autorelease];
}
+(DLError *)generalConnectionError {
    DLError *e = [[DLError alloc] init];
    [e setType:ErrorTypeConnection];
    return [e autorelease];
}

-(id)init {
    self = [super init];
    messageText = @"Error";
    infoText = @"An error occurred.";
    return self;
}


-(void)setType:(ErrorType)t {
    if (t == ErrorTypeConnection) {
        messageText = @"Could not connect to the Discord server. Please check your Internet connection and try again.";
    }
    type = t;
}
-(void)setMessageText:(NSString *)text {
    messageText = text;
}
-(void)setInfoText:(NSString *)text {
    infoText = text;
}
-(NSString *)messageText {
    return messageText;
}
-(NSString *)infoText {
    return infoText;
}

@end
