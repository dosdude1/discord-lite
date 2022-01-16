//
//  DLCaptchaWindowController.m
//  Discord Lite
//
//  Created by Collin Mistr on 1/12/22.
//  Copyright (c) 2022 dosdude1. All rights reserved.
//

#import "DLCaptchaWindowController.h"

@interface DLCaptchaWindowController ()

@end

@implementation DLCaptchaWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    [captchaWebView setResourceLoadDelegate:self];
    captchaSuccess = NO;
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)setDelegate:(id<DLCaptchaWindowDelegate>)inDelegate {
    delegate = inDelegate;
}

-(void)loadHCaptchaWithSiteKey:(NSString *)siteKey {
    captchaSuccess = NO;
    NSMutableString *htmlContent = [[NSMutableString alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"captcha_hcaptcha.html"] encoding:NSUTF8StringEncoding error:nil];
    [htmlContent replaceCharactersInRange:[htmlContent rangeOfString:@"<SITE_KEY>"] withString:siteKey];
    [[captchaWebView mainFrame] loadHTMLString:htmlContent baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@.react-native.hcaptcha.com", siteKey]]];
}

-(void)loadRecaptchaWithSiteKey:(NSString *)siteKey {
    captchaSuccess = NO;
    NSMutableString *htmlContent = [[NSMutableString alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"captcha_recaptcha.html"] encoding:NSUTF8StringEncoding error:nil];
    [htmlContent replaceCharactersInRange:[htmlContent rangeOfString:@"<SITE_KEY>"] withString:siteKey];
    [[captchaWebView mainFrame] loadHTMLString:htmlContent baseURL:[NSURL URLWithString:@"https://cdn.discordapp.com/recaptcha/ios.html"]];
}

- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource {
    if ([[request.URL absoluteString] rangeOfString:@"captcha_key="].location != NSNotFound) {
        NSRange captchaKeyIDRange = [[request.URL absoluteString] rangeOfString:@"captcha_key="];
        NSString *captchaKey = [[request.URL absoluteString] substringFromIndex:captchaKeyIDRange.location+captchaKeyIDRange.length];
        [[DLController sharedInstance] setCaptchaKey:captchaKey];
        captchaSuccess = YES;
        [self.window close];
        return nil;
    }
    return request;
}

- (void)windowWillClose:(NSNotification *)notification {
    [delegate didCompleteCaptchaSuccessfully:captchaSuccess];
}

@end
