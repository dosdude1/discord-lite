//
//  DLCaptchaWindowController.h
//  Discord Lite
//
//  Created by Collin Mistr on 1/12/22.
//  Copyright (c) 2022 dosdude1. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "DLController.h"

@protocol DLCaptchaWindowDelegate <NSObject>
@optional
-(void)didCompleteCaptchaSuccessfully:(BOOL)success;
@end

@interface DLCaptchaWindowController : NSWindowController {
    
    id<DLCaptchaWindowDelegate> delegate;
    IBOutlet WebView *captchaWebView;
    BOOL captchaSuccess;
}

-(void)setDelegate:(id<DLCaptchaWindowDelegate>)inDelegate;
-(void)loadHCaptchaWithSiteKey:(NSString *)siteKey;
-(void)loadRecaptchaWithSiteKey:(NSString *)siteKey;

@end
