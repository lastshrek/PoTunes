//
//  PCWebViewController.m
//  PoTunes
//
//  Created by Purchas on 10/31/15.
//  Copyright © 2015 Purchas. All rights reserved.
//

#import "PCWebViewController.h"

@interface PCWebViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation PCWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    
    
    [self.activityIndicatorView setActivityIndicatorViewStyle: UIActivityIndicatorViewStyleWhite];
    
    NSString * string = [[NSBundle mainBundle] pathForResource:@"『秋凉，并未悲伤』『破车推荐2015年10月号』.webarchive" ofType:nil];
    
    [self loadWebPageWithString:string];
}

- (void)loadWebPageWithString:(NSString*)urlString {
    
    NSURL *url =[NSURL URLWithString:urlString];
    
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicatorView startAnimating] ;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    UIAlertView *alterview = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alterview show];
}
@end
