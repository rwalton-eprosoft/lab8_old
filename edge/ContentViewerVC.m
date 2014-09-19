//
//  ContentViewerVC.m
//  edge
//
//  Created by iPhone Developer on 6/21/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "ContentViewerVC.h"
#import "AppDelegate.h"
#import "Content.h"
#import "ContentModel.h"

@interface ContentViewerVC ()
@property (nonatomic, weak) AppDelegate *appDelegate;
@end

@implementation ContentViewerVC

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
	// Do any additional setup after loading the view.
    _appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    [self loadContent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) doneBtnTouched
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void) loadContent
{
    NSString *path = [[ContentModel sharedInstance] addAppDocumentsPathToPath:_content.path];
    NSLog(@"path: [%@]", path);

    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:path];
    NSLog(@"fileURL: [%@]", fileURL);
    
    [_webView loadRequest:[NSURLRequest requestWithURL:fileURL]];
}

@end
