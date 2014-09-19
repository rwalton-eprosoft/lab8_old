//
//  StartNavigationController.m
//  edge
//
//  Created by iPhone Developer on 9/7/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "StartNavigationController.h"

@interface StartNavigationController ()

@end

@implementation StartNavigationController

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
    
    [self performSegueWithIdentifier:@"SplashSegue" sender:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
