//
//  ViewController.h
//  Discord Lite
//
//  Created by Collin Mistr on 10/31/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSView+BGColor.h"

@interface ViewController : NSObject {
    IBOutlet NSView_BGColor *view;
}

-(id)init;
-(id)initWithNibNamed:(NSString *)inNibName bundle:(NSBundle *)bundle;
-(NSView *)view;
-(id)representedObject;

@end
