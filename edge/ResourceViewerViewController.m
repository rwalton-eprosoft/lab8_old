//
//  ResourceViewerViewController.m
//  edgesync
//
//  Created by Vijaykumar on 6/29/13.
//  Copyright (c) 2013 eprosoft. All rights reserved.
//

#import "ResourceViewerViewController.h"
#import "MyMovieViewController.h"
#import "PDFScrollView.h"
#include "MoviePlayerViewController.h"
#include "TabBarViewController.h"

#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]



@interface ResourceViewerViewController ()


@end

@implementation ResourceViewerViewController
@synthesize appdelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadExternalurl
{
    _webView.hidden = NO;
    Isfullpath = YES;
    
    [self play];
   
}

- (void) play
{
    @autoreleasepool {
        
     NSLog(@"filePath: %@", _filePath);
    NSString* ext = [[_filePath pathExtension] lowercaseString];
    
  
    if ([ext isEqualToString:@"mp4"] ||
        [ext isEqualToString:@"m3u8"] ||
        [ext isEqualToString:@"m4v"]) {
        
        _webView.hidden = YES;
        _myMovieViewController = [[MyMovieViewController alloc] initWithNibName:@"PlayerView" bundle:nil];
        [_myMovieViewController playMovieFile:[NSURL fileURLWithPath:_filePath]];
        CGRect viewInsetRect = CGRectInset ([self.view bounds], 0, 20);
        [_myMovieViewController.view setFrame:viewInsetRect];
        [self.view addSubview:_myMovieViewController.view];

    } else if ([ext isEqualToString:@"pdf"]) {
        
            if(_document == nil) {
                NSString *path = _filePath;
                _document = [[YLDocument alloc] initWithFilePath:path];
                if(_document.isLocked) {
                    // unlock pdf document
                    [_document unlockWithPassword:@""];
                }
            }
        if (_document != nil && _document.pageCount != 0) {
            YLPDFViewController *v = [[YLPDFViewController alloc] initWithDocument:_document];
            [v setDocumentMode:YLDocumentModeSingle];
            
            [[UIBarButtonItem appearanceWhenContainedIn:[YLPDFViewController class], nil] setTintColor:[UIColor lightGrayColor]];
            [[UISegmentedControl appearanceWhenContainedIn:[YLPDFViewController class], nil] setTintColor:[UIColor lightGrayColor]];
            
            [v setPageCurlEnabled:NO];
            [v setHideDismissButton:YES];
            [v setAutoLayoutEnabled:YES];
            [v showToolbarsAnimated:NO];
            v.hideNavigationBar = NO;
            v.hideDismissButton = NO;
            
            [self addChildViewController:v];
            [v didMoveToParentViewController:self];
            v.view.frame = self.view.bounds;
            v.view.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:v.view];
        }
        if(_document.pageCount == 0)
        {
            UIAlertView *corruptedFile = [[UIAlertView alloc] initWithTitle:@"Information" message:@"This file is either corrupted or damaged" delegate:self cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
            [corruptedFile show];
        }

        
    }
   
     else if ([ext isEqualToString:@"jpg"] || [ext isEqualToString:@"png"]){
        NSRange rng = [ext rangeOfString:@"jpg"];
        if (rng.location != NSNotFound)
        {
            
            UIImageView * image = [[UIImageView alloc] initWithFrame:_webView.frame];
            [image setImage:[UIImage imageWithContentsOfFile:_filePath]];
            [self.view addSubview:image];
//            _webView.hidden = YES;
//            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:_filePath]];
//            [_webView loadRequest:request];
//            [self.view addSubview:_webView];
            
        } else {
            NSRange rng = [ext rangeOfString:@"png"];
            if (rng.location != NSNotFound)
            {
                UIImageView * image = [[UIImageView alloc] initWithFrame:_webView.frame];
                [image setImage:[UIImage imageWithContentsOfFile:_filePath]];
                [self.view addSubview:image];
//                _webView.hidden = YES;
//                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:_filePath]];
//                [_webView loadRequest:request];
//                [self.view addSubview:_webView];
                
            }
        }
    }
     else
     {
         if ([ext isEqualToString:@"html"])
         {
         }
         
        else
        {
            _filePath = [_filePath stringByAppendingString:@""];
 
        }
         _webView.hidden = NO;
//         [_webView setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
//         _webView.layer.borderColor = [UIColor darkGrayColor].CGColor;
//         _webView.layer.cornerRadius = 7;
//         _webView.layer.masksToBounds = YES;
//         _webView.layer.borderWidth = 1.0f;
         
         if (Isfullpath)
         {
             Isfullpath = NO;
             NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_filePath]];
            
             [_webView loadRequest:request];
             [self.view addSubview:_webView];
             [_webView bringSubviewToFront:_Spinner];
         }
         else
         {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:_filePath]];
            // NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_filePath]];
             [_webView loadRequest:request];
             [self.view addSubview:_webView];
             [_webView bringSubviewToFront:_Spinner];
         }
        
     }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    Isfullpath = NO;
    [_webView bringSubviewToFront:_Spinner];
    [_Spinner startAnimating];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
     _webView.delegate = self;
     _webView.scrollView.bounces = NO;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self.parentViewController viewWillAppear:YES];
    //[_webView reload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //YLDocument* document = [[YLDocument alloc] initWithFilePath:_filePath]; //Clear cache
    if (_document)
        [[YLCache sharedCache] clearCacheForDocument:_document];

    // Dispose of any resources that can be recreated.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self closeView:alertView];
}

-(IBAction)closeView:(id)sender
{
    [_myMovieViewController closeView];
    _myMovieViewController = nil;
    
    [self unLoadDrawTool];
    
    [_webView loadHTMLString:@"" baseURL:nil];
    [_webView stopLoading];
    _webView.delegate = nil;
    [_webView removeFromSuperview];
    
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

/*
 -(IBAction)closeView:(id)sender {
 
 [_myMovieViewController closeView];
 _webView = nil;
 // [_webView loadHTMLString:@"<html><head></head><body></body></html>" baseURL:nil];
 [self unLoadDrawTool];
 [self dismissViewControllerAnimated:NO completion:nil];
 }
 */

-(IBAction)drawToolButtonClicked:(id)sender {
    [self loadDrawTool];
    //[self showTransparentDrawTool];
    
}

-(void)loadrefernce
{
    NSURL *url = [[NSURL alloc] initWithString:[_filePath stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:requestObj];
    [self.view addSubview:_webView];
    [_webView bringSubviewToFront:_Spinner];
    
}

- (void) loadDrawTool {
    if (_drawView) {
        [_drawView removeFromSuperView];
        _drawView = nil;
    } else {
        _drawView = [[DrawVC alloc]initWithNibName:@"DrawView" bundle:nil] ;
        _drawView.view.backgroundColor = [UIColor clearColor];
        
//        CGRect viewFrame = self.view.frame;
//        float height = (viewFrame.size.height - 49 - 250 - 50);
//        CGSize newSize = CGSizeMake(viewFrame.size.width, height);
//        viewFrame.origin.y = 50;
//        viewFrame.size = newSize;
//        
//        _drawView.view.frame = viewFrame;
        _drawView.view.frame = CGRectMake(0, 40, 1024, 730);
        [self.view addSubview:_drawView.view];
        [self.view bringSubviewToFront:_drawView.view];
    }
}

- (void) unLoadDrawTool {
    if (_drawView) {
        [_drawView removeFromSuperView];
        _drawView = nil;
    }
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_Spinner stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        
        
        
        
        //[self.view addSubview:refernceView];
        //   //nslog(@"checking---file:///Users/epromacmini/Library/Application%20Support/iPhone%20Simulator/7.0/Applications/B7B7346C-0410-4569-8CA6-C4B998D8414E/Documents/assets/content/videos/product/642_01_sfx_310_12_sfx_product_overview_animation_ca.mp4");
    
        NSString * urlstring;
        //nslog(@"after delete %@",[[[request URL] absoluteString] substringFromIndex: 7]);
        NSString * filePath2 = [NSString stringWithFormat:@"%@%@",DocumentsDirectory,[[[request URL] absoluteString] substringFromIndex:7]];
        //nslog(@"original url -- %@%@",DocumentsDirectory,[[[request URL] absoluteString] substringFromIndex: 7]);
        // NSString* ext = [[filePath pathExtension] lowercaseString];
        //nslog(@"---%@",filePath);
        //nslog(@"extension -- %@",ext);
        NSString * realpath = [[request URL] absoluteString];
        NSString* ext1 = [[realpath pathExtension] lowercaseString];
        NSString * ExternalLink =[realpath substringToIndex:4];
        if ([ExternalLink isEqualToString:@"http"])
        {
            ResourceViewerViewController* rviewer = [[ResourceViewerViewController alloc] initWithNibName:@"ResourceView" bundle:nil];
           
            rviewer.filePath = realpath;
            [self presentViewController:rviewer animated:NO completion:nil];
            [rviewer.webView setScalesPageToFit:YES];
            [rviewer loadExternalurl];
            return YES;
            
        }
        
        if ([ext1 isEqualToString:@"mp4"] ||
            [ext1 isEqualToString:@"m3u8"] ||
            [ext1 isEqualToString:@"m4v"] || ([ext1 isEqualToString:@"pdf"]) || [ext1 isEqualToString:@"jpg"] || [ext1 isEqualToString:@"png"] || [ext1 isEqualToString:@"html"])
        {
            
            
            urlstring = filePath2;
            
//            NSString * ExternalLink2 =[realpath substringToIndex:4];
//            if ([ExternalLink2 isEqualToString:@"file"])
//            {
//                
//                NSString * realpath2 = [[request URL] absoluteString];
//                urlstring = realpath2;
//            }
        }
        else
        {
            
            NSArray *substrings = [[[request URL] absoluteString] componentsSeparatedByString:@"#"];
            NSString *code;
            if (substrings.count)
            {
                code =  [substrings objectAtIndex:((substrings.count) -1)];
            }
            else
                code = @"1";
            
            code = [code stringByReplacingOccurrencesOfString:@"." withString:@"_"];
//            NSString *code = [[[request URL] absoluteString] substringFromIndex: [[[request URL] absoluteString] length] - 2];
//            //nslog(@"--before-%@",code);
//            if([code hasPrefix:@"#"])
//            {
//                code = [[[request URL] absoluteString] substringFromIndex: [[[request URL] absoluteString] length] - 1];
//                //nslog(@"---%@",code);
//            }
            
//            NSString * strippedNumber = [code stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@""];
            //nslog(@"--- %@",strippedNumber);
            urlstring = [NSString stringWithFormat:@"%@%@?current=%@",DocumentsDirectory,[appdelegate getAppContentPath:@"references"],code];
            ResourceViewerViewController* rviewer = [[ResourceViewerViewController alloc] initWithNibName:@"ResourceView" bundle:nil];
           
            rviewer.filePath = urlstring;
           // [rviewer setModalPresentationStyle:UIModalPresentationPageSheet];
            [self presentViewController:rviewer animated:YES completion:nil];
           // [rviewer.view.superview setAutoresizingMask:(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth)];

            [rviewer.webView setScalesPageToFit:YES];
            [rviewer loadrefernce];
            return YES;
            
            
            
            //urlstring = [NSString stringWithFormat:@"%@/assets/content/applications/885_references/index.html?current=%@&list=%@",DocumentsDirectory, code,contentStringList];
            //nslog(@" in class");
            
           //  NSURL *url = [[NSURL alloc] initWithString:[urlstring stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        }
        
        ResourceViewerViewController* rviewer = [[ResourceViewerViewController alloc] initWithNibName:@"ResourceView" bundle:nil];
        //NSString* targetPath = [[ContentModel sharedInstance] addAppDocumentsPathToPath:content.path];
        rviewer.filePath = urlstring;
        [self presentViewController:rviewer animated:NO completion:nil];
        [rviewer.webView setScalesPageToFit:YES];
        [rviewer play];
        
        //        NSURL *url = [[NSURL alloc] initWithString:[urlstring stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        //        //nslog(@"----1234--%@",url);
        //        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        //
        //        [self.RefernceWebview loadRequest:requestObj];
    }
    return YES;
}

@end
