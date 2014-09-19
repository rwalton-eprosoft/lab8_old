//
//  ContentSyncReportViewController.m
//  edge
//
//  Created by Vijaykumar on 9/16/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "ContentSyncReportViewController.h"

@interface ContentSyncReportViewController ()

@end

@implementation ContentSyncReportViewController

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
    // Do any additional setup after loading the view from its nib.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneBtnClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
