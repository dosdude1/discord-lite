//
//  WSMessage.h
//  WSWebSocket
//
//  Created by Andras Koczka on 3/22/12.
//  Copyright (c) 2012 Andras Koczka
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished
//  to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import "WSFrame.h"

/**
 Message for communicating with a WebSocket server.
 */
@interface WSMessage : NSObject {
    WSWebSocketOpcodeType opcode;
    NSData *data;
    NSString *text;
    NSInteger statusCode;
}

/**
 The type of the message.
 */
//@property (assign, nonatomic) WSWebSocketOpcodeType opcode;
-(WSWebSocketOpcodeType)opcode;
-(void)setOpcode:(WSWebSocketOpcodeType)inOpcode;
/**
 The message data.
 */
//@property (strong, nonatomic) NSData *data;
-(NSData *)data;
-(void)setData:(NSData *)inData;

/**
 The message text.
 */
//@property (strong, nonatomic) NSString *text;
-(NSString *)text;
-(void)setText:(NSString *)inText;

/**
 The status code.
 */
//@property (assign, nonatomic) NSInteger statusCode;
-(NSInteger)statusCode;
-(void)setStatusCode:(NSInteger)inStatusCode;

@end
