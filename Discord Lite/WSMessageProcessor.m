//
//  WSMessageProcessor.m
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

#import "WSMessageProcessor.h"

#import "WSFrame.h"
#import "WSMessage.h"


@implementation WSMessageProcessor 

-(NSUInteger)fragmentSize {
    return fragmentSize;
}

-(NSUInteger)bytesConstructed {
    return bytesConstructed;
}

-(void)setBytesConstructed:(NSUInteger)inBytesConstructed {
    bytesConstructed = inBytesConstructed;
}

-(void)setFragmentSize:(NSUInteger)inFragmentSize {
    fragmentSize = inFragmentSize;
}


#pragma mark - Object lifecycle


- (id)init {
    self = [super init];
    if (self) {
        messagesToSend = [[NSMutableArray alloc] init];
        framesToSend = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark - Helper methods


- (WSMessage *)messageWithStatusCode:(NSInteger)code text:(NSString *)text {
    WSMessage *message = [[WSMessage alloc] init];
    message.opcode = WSWebSocketOpcodeClose;
    message.statusCode = code;
    message.text = text;
    return [message autorelease];
}

- (WSMessage *)messageWithStatusCode:(NSInteger)code{
    return [self messageWithStatusCode:code text:nil];
}


#pragma mark - Public interface


- (WSMessage *)constructMessageFromData:(NSData *)data {
    if (!messageConstructed) {
        messageConstructed = [[WSMessage alloc] init];
        constructedData = [[NSMutableData alloc] init];
        isNewMessage = YES;
    }
    
    WSMessage *currentMessage;
    
    uint8_t *dataBytes = (uint8_t *)[data bytes];
    dataBytes += bytesConstructed;
    
    NSUInteger frameSize = 2;
    uint64_t payloadLength = 0;

    // Frame is not received fully
    if (frameSize > data.length - bytesConstructed) {
        return nil;
    }

    // Mask bit must be clear
    if (dataBytes[1] & 0x80) {
        return [self messageWithStatusCode:1002];
    }
    
    uint8_t opcode = dataBytes[0] & 0x7F;
    
    // Continuation frame received first
    if (isNewMessage && opcode == WSWebSocketOpcodeContinuation) {
        return [self messageWithStatusCode:1002];
    }
    
    // Opcode should not be a reserved code
    if (opcode != WSWebSocketOpcodeContinuation && opcode != WSWebSocketOpcodeText && opcode != WSWebSocketOpcodeBinary && opcode != WSWebSocketOpcodeClose && opcode != WSWebSocketOpcodePing && opcode != WSWebSocketOpcodePong ) {
        return [self messageWithStatusCode:1002];
    }
    
    // Determine message type
    if (opcode == WSWebSocketOpcodeText || opcode == WSWebSocketOpcodeBinary) {
        
        // Opcode should be continuation
        if (!isNewMessage) {
            return [self messageWithStatusCode:1002];
        }
        
        messageConstructed.opcode = opcode;
    }
    
    // Determine payload length
    if (dataBytes[1] < 126) {
        payloadLength = dataBytes[1];
    }
    else if (dataBytes[1] == 126) {
        frameSize += 2;
        
        // Frame is not received fully
        if (frameSize > data.length - bytesConstructed) {
            return nil;
        }

        uint16_t *payloadLength16 = (uint16_t *)(dataBytes + 2);
        payloadLength = CFSwapInt16BigToHost(*payloadLength16);
    }
    else {
        frameSize += 8;

        // Frame is not received fully
        if (frameSize > data.length - bytesConstructed) {
            return nil;
        }

        uint64_t *payloadLength64 = (uint64_t *)(dataBytes + 2);
        payloadLength = CFSwapInt64BigToHost(*payloadLength64);
    }
    
    // Frame is not received fully
    if (payloadLength + frameSize > data.length - bytesConstructed) {
        return nil;
    }
    
    uint8_t *payloadData = (uint8_t *)(dataBytes + frameSize);
    
    // Control frames
    if (opcode & 0x8) {
        
        currentMessage = [[WSMessage alloc] init];
        currentMessage.opcode = opcode;
        
        // Maximum payload length is 125
        if (payloadLength > 125) {
            return [self messageWithStatusCode:1002];
        }
        
        // Fin bit must be set
        if (~dataBytes[0] & 0x80) {
            return [self messageWithStatusCode:1002];
        }
        
        // Close frame
        if (opcode == WSWebSocketOpcodeClose) {
            uint16_t code = 0;
            
            if (payloadLength) {
                
                // Status code must be 2 byte long
                if (payloadLength == 1) {
                    code = 1002;
                }
                else {
                    uint16_t *code16 = (uint16_t *)payloadData;
                    code = CFSwapInt16BigToHost(*code16);
                    payloadData += 2;
                    currentMessage.text = [[NSString alloc] initWithBytes:payloadData length:payloadLength - 2 encoding:NSUTF8StringEncoding];
                    
                    // Invalid UTF8 message
                    if (!currentMessage.text && payloadLength > 2) {
                        code = 1007;
                    }
                }
            }
            currentMessage.statusCode = code;
        }
        
        // Ping frame
        if (opcode == WSWebSocketOpcodePing) {
            currentMessage.data = [NSData dataWithBytes:payloadData length:payloadLength];
        }
        
        // Pong frame
        if (opcode == WSWebSocketOpcodePong) {
            currentMessage.data = [NSData dataWithBytes:payloadData length:payloadLength];
        }
    }
    // Data frames
    else {
        
        // Get payload data
        [constructedData appendBytes:payloadData length:payloadLength];
        isNewMessage = NO;
        
        // In case it was the final fragment
        if (dataBytes[0] & 0x80) {
            
            // Text message
            if (messageConstructed.opcode == WSWebSocketOpcodeText) {
                messageConstructed.text = [[NSString alloc] initWithData:constructedData encoding:NSUTF8StringEncoding];
                
                // Invalid UTF8 message
                if (!messageConstructed.text && constructedData.length) {
                    return [self messageWithStatusCode:1007];
                }
            }
            // Binary message
            else if (messageConstructed.opcode == WSWebSocketOpcodeBinary) {
                messageConstructed.data = constructedData;
            }

            currentMessage = messageConstructed;
            messageConstructed = nil;
            constructedData = nil;
        }
    }
    
    bytesConstructed += (payloadLength + frameSize);
    
    return [currentMessage autorelease];
}

- (void)queueMessage:(WSMessage *)message {
    if (message.text) {
        message.data = [[message.text dataUsingEncoding:NSUTF8StringEncoding] retain];
        message.text = nil;
    }

    [messagesToSend addObject:message];
}


- (void)scheduleNextMessage {
    if (!messageProcessed && messagesToSend.count) {
        messageProcessed = [messagesToSend objectAtIndex:0];
        [messagesToSend removeObjectAtIndex:0];
    }
}

- (void)processMessage {
    // If no message to process then return
    if (!messageProcessed) {
        return;
    }
    
    uint8_t *dataBytes = (uint8_t *)[messageProcessed.data bytes];
    dataBytes += bytesProcessed;
    
    uint8_t opcode = messageProcessed.opcode;
    
    if (bytesProcessed) {
        opcode = WSWebSocketOpcodeContinuation;
    }
    
    NSData *data =[NSData dataWithBytesNoCopy:dataBytes length:messageProcessed.data.length - bytesProcessed freeWhenDone:NO];
    
    WSFrame *frame = [[WSFrame alloc] initWithOpcode:opcode data:data maxSize:fragmentSize];
    bytesProcessed += frame.payloadLength;
    [self queueFrame:frame];
    
    // All has been processed
    if (messageProcessed.data.length == bytesProcessed) {
        messageProcessed = nil;
        bytesProcessed = 0;
    }
}

- (void)queueFrame:(WSFrame *)frame {
    
    // Prioritize ping/pong frames
    if (frame.opcode == WSWebSocketOpcodePing || frame.opcode == WSWebSocketOpcodePong) {
        
        int index = 0;
        for (int i = (int)framesToSend.count - 1; i >= 0; i--) {
            WSFrame *aFrame = [framesToSend objectAtIndex:i];
            if (aFrame.opcode == frame.opcode) {
                index = i + 1;
                break;
            }
        }
        [framesToSend insertObject:frame atIndex:index];
    }
    else {
        [framesToSend addObject:frame];
    }
}

- (WSFrame *)nextFrame {
    if (framesToSend.count) {
        WSFrame *nextFrame = [framesToSend objectAtIndex:0];
        [framesToSend removeObjectAtIndex:0];
        return nextFrame;
    }
    
    return nil;
}

@end
