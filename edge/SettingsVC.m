//
//  SettingsVC.m
//  edge
//
//  Created by iPhone Developer on 5/13/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "SettingsVC.h"
#import "ProfileVC.h"
#import "TrackingModel.h"


@interface SettingsVC ()

@end

@implementation SettingsVC
@synthesize tableview;


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
    
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
        self.navigationController.navigationBar.translucent = NO;
    }else{
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    }
    
    self.view.layer.borderColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0f].CGColor;
    self.view.layer.cornerRadius = 7;
    self.view.layer.masksToBounds = YES;
    self.view.layer.borderWidth = 1.0f;
        UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
     titleView.font = [UIFont fontWithName:@"Arial" size:18];
        //titleView.font = [UIFont boldSystemFontOfSize:22.0];
        titleView.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        titleView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        titleView.textColor = [UIColor colorWithRed:243.0f/255.0f green:6.0f/255.0f blue:23.0f/255.0f alpha:1.0f];
        titleView.text = @"Settings";
        self.navigationItem.titleView = titleView;
        [titleView sizeToFit];
    
    
    
    //    UIImage *navBkg = [[UIImage imageNamed:@"nav_bar_bkg"]
    //                       resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    //
    //    // Set the background image for *all* UINavigationBars
    //    [[UINavigationBar appearance] setBackgroundImage:navBkg
    //                                       forBarMetrics:UIBarMetricsDefault];
    
    
    UIButton *myButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [myButton1 setImage:[UIImage imageNamed:@"done_btn@2x.png"] forState:UIControlStateNormal];
    myButton1.showsTouchWhenHighlighted = YES;
    myButton1.frame = CGRectMake(0.0, 3.0, 50,30);
    
    [myButton1 addTarget:self action:@selector(doneBtnTouched) forControlEvents:UIControlEventTouchUpInside];
    
   // UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:myButton1];
    self.navigationItem.rightBarButtonItem = nil;
    //nslog(@"version string--%@",[self.appDelegate appVersionString]);
    self.appversion.text = [self.appDelegate appVersionString];
	// Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) doneBtnTouched
{
    if (self.delegate)
    {
        [self.delegate dismissSettingsPopover];
        
        
        //        UIImage *navBkg = [[UIImage imageNamed:@"nav_bar_bkg"]
        //                           resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        //
        //        // Set the background image for *all* UINavigationBars
        //        [[UINavigationBar appearance] setBackgroundImage:navBkg
        //                                           forBarMetrics:UIBarMetricsDefault];
    }
}

-(IBAction)profilebtnPressed:(id)sender
{
    ProfileVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileVCont"];
    vc.Viewname = @"1";
    
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)aboutbtnPressed:(id)sender
{
    ProfileVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileVCont"];
    vc.Viewname = @"2";
    
    [self.navigationController pushViewController:vc animated:YES];
}
-(IBAction)specialitybtnPressed:(id)sender
{
    ProfileVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileVCont"];
    vc.Viewname = @"3";
    
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (IBAction)sendTrackingButtonPressed:(id)sender
{
    [[TrackingModel sharedInstance] callTracking];
}

@end
