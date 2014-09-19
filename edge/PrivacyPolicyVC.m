//
//  PrivacyPolicyVC.m
//  edge
//
//  Created by Ryan G Walton on 9/11/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "PrivacyPolicyVC.h"
#import "StaticTextModel.h"
#import "AppDelegate.h"
#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]


#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]

@interface PrivacyPolicyVC ()

@end

@implementation PrivacyPolicyVC
@synthesize istypeof;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    StaticTextModel *st = [StaticTextModel sharedInstance];
    _privacyPolicyTextView.text = st.privacyPolicyText;
	// Do any additional setup after loading the view.
    NSString *urlstring;
    
    indicatrView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatrView.center = CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height/2);
    indicatrView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);

    [self.view addSubview:indicatrView];
    
    if ([istypeof isEqualToString:@"MIR"])
    {
        
        urlstring = [NSString stringWithFormat:@"%@%@",DocumentsDirectory,[self.appDelegate getAppContentPath:@"mir_privacy"]];
        
        NSLog(@"Path is %@",urlstring);
        
    }
    else if([istypeof isEqualToString:@"SPLIV"])
    {
        
        urlstring = @"http://m.eprodevbox.com/spl_iv/index.html";
    }
    
    else
    {
        urlstring=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Registration.html"];
       // urlstring = [NSString stringWithFormat:@"%@/assets/content/applications/883_rep_tool_intranet_privacy_policy_aug_2013/index.html",DocumentsDirectory];
        //nslog(@"Path is %@",urlstring);

    }
  
    NSURL *urlpath = [[NSURL alloc] initWithString:[urlstring stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:urlpath];
    //nslog(@"url request is %@",urlpath);
    [_webVw loadRequest:urlReq];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeOnToolbarTouched:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [indicatrView startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [indicatrView stopAnimating];

}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Please Try Again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    [indicatrView stopAnimating];
}

@end