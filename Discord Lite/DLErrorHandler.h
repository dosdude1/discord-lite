//
//  DLErrorHandler.h
//  Discord Lite
//
//  Created by Collin Mistr on 10/27/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DLError.h"

@interface DLErrorHandler : NSObject

+(void)displayErrorAsModal:(DLError *)e;
+(void)displayError:(DLError *)e onWindow:(NSWindow *)window;

@end
