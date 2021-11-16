//
//  WSFrame.h
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

typedef enum {
    WSWebSocketOpcodeContinuation = 0,
    WSWebSocketOpcodeText = 1,
    WSWebSocketOpcodeBinary = 2,
    WSWebSocketOpcodeClose = 8,
    WSWebSocketOpcodePing = 9,
    WSWebSocketOpcodePong = 10
}WSWebSocketOpcodeType;


/**
 WebSocket frame to be send to a server.
 */
@interface WSFrame : NSObject {
    WSWebSocketOpcodeType opcode;
    NSMutableData *data;
    uint64_t payloadLength;
    BOOL isControlFrame;
}

/**
 The type of the frame.
 */
//@property (assign, nonatomic, readonly) WSWebSocketOpcodeType opcode;
-(WSWebSocketOpcodeType)opcode;
-(void)setOpcode:(WSWebSocketOpcodeType)inOpcode;

/**
 The frame data.
 */
//@property (strong, nonatomic, readonly) NSMutableData *data;
-(NSMutableData *)data;
-(void)setData:(NSMutableData *)d;

/**
 The length of the payload.
 */
//@property (assign, nonatomic, readonly) uint64_t payloadLength;
-(uint64_t)payloadLength;
-(void)setPayloadLength:(uint64_t)inPayloadLength;

/**
 Yes if the frame is a control frame.
 */
//@property (assign, nonatomic, readonly) BOOL isControlFrame;
-(BOOL)isControlFrame;
//-(void)setIsControlFrame:(BOOL)inIsControlFrame;

/**
 Designated initializer. Creates a new frame with the given type and data.
 @param opcode The opcode of the message
 @param data The payload data to be processed
 @param maxSize The maximum size of the frame
 */
- (id)initWithOpcode:(WSWebSocketOpcodeType)opcode data:(NSData *)data maxSize:(NSUInteger)maxSize;

@end
