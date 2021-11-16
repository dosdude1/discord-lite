//
//  WSMessageProcessor.h
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

@class WSFrame;
@class WSMessage;

/**
 This class is responsible for constructing/processing messages.
 */
@interface WSMessageProcessor : NSObject {
    NSUInteger fragmentSize;
    NSUInteger bytesConstructed;
    
    NSMutableArray *messagesToSend;
    NSMutableArray *framesToSend;
    
    WSMessage *messageConstructed;
    WSMessage *messageProcessed;
    NSMutableData *constructedData;
    
    NSUInteger bytesProcessed;
    BOOL isNewMessage;
}


/**
 Specifies the maximum fragment size to use.
 */
//@property (assign, nonatomic) NSUInteger fragmentSize;
-(NSUInteger)fragmentSize;
-(void)setFragmentSize:(NSUInteger)inFragmentSize;

/**
 Number of bytes constructed.
 */
//@property (assign, nonatomic) NSUInteger bytesConstructed;
-(NSUInteger)bytesConstructed;
-(void)setBytesConstructed:(NSUInteger)inBytesConstructed;

/**
 Constructs a message from the received data.
 @param data The data to process
 */
- (WSMessage *)constructMessageFromData:(NSData *)data;

/**
 Queues a message to send.
 @param message The message to send
 */
- (void)queueMessage:(WSMessage *)message;

/**
 Schedules the next message.
 */
- (void)scheduleNextMessage;

/**
 Processes the current message;
 */
- (void)processMessage;

/**
 Queues a frame to send.
 @param frame The frame to send
 */
- (void)queueFrame:(WSFrame *)frame;

/**
 Returns the next frame to send.
 */
- (WSFrame *)nextFrame;

@end
