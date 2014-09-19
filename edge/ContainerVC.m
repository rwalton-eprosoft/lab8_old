//
//  ContainerVC.m
//  edge
//
//  Created by iPhone Developer on 6/10/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "ContainerVC.h"

@interface ContainerVC ()

@end

@implementation ContainerVC

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
    //[self performSegueWithIdentifier:@"ContainerToLogin" sender:nil];
    
    //[self performSelector:@selector(showRegistration) withObject:nil afterDelay:5.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showRegistration
{
    [self performSegueWithIdentifier:@"ContainerToRegistration" sender:nil];
}

@end
