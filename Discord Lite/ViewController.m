//
//  ViewController.m
//  Discord Lite
//
//  Created by Collin Mistr on 10/31/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

-(id)init {
    self = [super init];
    return self;
}

-(id)initWithNibNamed:(NSString *)inNibName bundle:(NSBundle *)bundle {
    self = [self init];
    NSNib *nib = [[[NSNib alloc] initWithNibNamed:inNibName bundle:bundle] autorelease];
    NSArray *topLevelObjects;
    if (! [nib instantiateNibWithOwner:self topLevelObjects:&topLevelObjects]) {// error
        
        view = nil;
    }
    /*NSEnumerator *e = [topLevelObjects objectEnumerator];
    id topLevelObject;
    while (topLevelObject = [e nextObject]) {
        //[topLevelObject isKindOfClass:[view class]]
        if (topLevelObject == view) {
            //view = topLevelObject;
            break;
        }
    }*/
    return self;
}
-(NSView *)view {
    return view;
}

-(id)representedObject {
    return nil;
}

-(void)dealloc {
    //[view setDelegate:nil];
    [super dealloc];
}

@end
