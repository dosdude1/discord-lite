//
//  WSFrame.m
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

#import "WSFrame.h"
#import <Security/Security.h>

static const NSUInteger WSMaskSize = 4;

@implementation WSFrame


- (BOOL)isControlFrame {
    if (opcode & 0x8) {
        return YES;
    }
    return NO;
}

-(void)setPayloadLength:(uint64_t)inPayloadLength {
    payloadLength = inPayloadLength;
}

-(void)setData:(NSMutableData *)d {
    [data release];
    [d retain];
    data = d;
}
-(void)setOpcode:(WSWebSocketOpcodeType)inOpcode {
    opcode = inOpcode;
}
-(WSWebSocketOpcodeType)opcode {
    return opcode;
}
-(NSMutableData *)data {
    return data;
}
-(uint64_t)payloadLength {
    return payloadLength;
}


#pragma mark - Frame construction


- (void)constructFrameWithOpcode:(WSWebSocketOpcodeType)anOpcode data:(NSData *)payloadData maxSize:(NSUInteger)maxSize {
    opcode = anOpcode;
    
    uint8_t maskBitAndPayloadLength;
    
    // Default size: sizeof(opcode) + sizeof(maskBitAndPayloadLength) + sizeof(mask)
    NSUInteger sizeWithoutPayload = 6;
    
    uint64_t totalLength = MIN((payloadData.length + sizeWithoutPayload), maxSize);
    
    // Calculate and set the frame size and payload length
    if (totalLength - sizeWithoutPayload < 126) {
        maskBitAndPayloadLength = totalLength - sizeWithoutPayload;
    }
    else {
        totalLength = MIN(totalLength + 2, maxSize);
        sizeWithoutPayload += 2;
        
        if (totalLength - sizeWithoutPayload < 65536) {
            maskBitAndPayloadLength = 126;
        }   
        else {
            totalLength = MIN(totalLength + 6, maxSize);
            maskBitAndPayloadLength = 127;
            sizeWithoutPayload += 6;
        }
    }
    
    payloadLength = totalLength - sizeWithoutPayload;
    
    // Set the opcode
    uint8_t finBitAndOpcode = anOpcode;
    
    // Set fin bit
    if (payloadLength == payloadData.length) {
        finBitAndOpcode |= 0x80;
    }
    
    // Create the frame data
    data = [[NSMutableData alloc] initWithLength:totalLength];
    uint8_t *frameBytes = (uint8_t *)(data.mutableBytes);
    
    // Store the opcode
    frameBytes[0] = finBitAndOpcode;
    
    // Set the mask bit
    maskBitAndPayloadLength |= 0x80;
    
    // Store mask bit and payload length
    frameBytes[1] = maskBitAndPayloadLength;
    
    if (payloadLength > 65535) {
        uint64_t *payloadLength64 = (uint64_t *)(frameBytes + 2);
        *payloadLength64 = CFSwapInt64HostToBig(payloadLength);
    }
    else if (payloadLength > 125) {
        uint16_t *payloadLength16 = (uint16_t *)(frameBytes + 2);
        *payloadLength16 = CFSwapInt16HostToBig(payloadLength);
    }
    
    // Generate a new mask
    uint8_t mask[WSMaskSize];
    for (int i=0; i<WSMaskSize; i++) {
        mask[i] = (uint8_t)arc4random();
    }
    //SecRandomCopyBytes(kSecRandomDefault, WSMaskSize, mask);
    
    // Store mask key
    uint8_t *mask8 = (uint8_t *)(frameBytes + sizeWithoutPayload - sizeof(mask));
    (void)memcpy(mask8, mask, sizeof(mask));
    
    // Store the payload data
    frameBytes += sizeWithoutPayload;
    (void)memcpy(frameBytes, payloadData.bytes, payloadLength);
    
    // Mask the payload data
    for (int i = 0; i < payloadLength; i++) {
        frameBytes[i] ^= mask[i % 4];
    }
}


#pragma mark - Public interface


- (id)initWithOpcode:(WSWebSocketOpcodeType)anOpcode data:(NSData *)aData maxSize:(NSUInteger)maxSize {
    self = [super init];
    if (self) {
        [self constructFrameWithOpcode:anOpcode data:aData maxSize:maxSize];
    }
    return self;
}

@end
