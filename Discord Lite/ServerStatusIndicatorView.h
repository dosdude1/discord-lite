//
//  ServerStatusIndicatorView.h
//  Discord Lite
//
//  Created by Collin Mistr on 10/4/22.
//  Copyright (c) 2022 dosdude1. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
    ServerStatusIndicatorNone = 0,
    ServerStatusIndicatorUnread = 1,
    ServerStatusIndicatorHover = 2,
    ServerStatusIndicatorSelected = 3
} ServerStatusIndicator;

@interface ServerStatusIndicatorView : NSView {
    ServerStatusIndicator indicatorToDraw;
}

-(void)setDrawnIndicator:(ServerStatusIndicator)ind;

@end
