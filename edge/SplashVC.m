//
//  SplashVC.m
//  edge
//
//  Created by iPhone Developer on 9/7/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "SplashVC.h"

@interface SplashVC ()

@end

@implementation SplashVC

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
    [self performSelector:@selector(dismissView) withObject:nil afterDelay:5.f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dismissView
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
