//
//  WebViewController.m
//  HyperExperimental
//
//  Created by Matt McMurry on 6/18/14.
//  Copyright (c) 2014 OC Tanner. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation WebViewController

- (id)initWithURL:(NSString *)url
{
    self = [super init];

    self.url = url;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:self.webView];
    
    
    [self.webView constrainHeightToView:self.view predicate:nil];
    [self.webView constrainWidthToView:self.view predicate:nil];
    [self.webView alignCenterWithView:self.view];
    
    
    self.title = self.url;
    
    NSURL *url = [NSURL URLWithString:self.url];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:req];
}

- (void)reloadWithURL:(NSString *)aurl; {
    self.url = aurl;
    NSURL *url = [NSURL URLWithString:self.url];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:req];
}

@end

