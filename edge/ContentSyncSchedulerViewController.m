//
//  ContentSyncSchedulerViewController.m
//  edge
//
//  Created by Vijaykumar on 8/23/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "ContentSyncSchedulerViewController.h"
#import "SchedulerViewController.h"
@interface ContentSyncSchedulerViewController ()

@end

@implementation ContentSyncSchedulerViewController

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
    
    
    
    self.schedulerView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.schedulerView.layer.cornerRadius = 10;
    self.schedulerView.layer.masksToBounds = YES;
    self.schedulerView.layer.borderWidth = 1.0f;
    
    self.datePicker.layer.borderColor = [UIColor whiteColor].CGColor;
    self.datePicker.layer.cornerRadius = 10;
    self.datePicker.layer.masksToBounds = YES;
    self.datePicker.layer.borderWidth = 1.0f;
    
    [self setImageForNavigationBackButton];
    self.navigationItem.title = @"    Frequency";
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:243/255.0f green:243/255.0f blue:243/255.0f alpha:1.0f];
        self.navigationController.navigationBar.translucent = NO;
    }else{
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:243/255.0f green:243/255.0f blue:243/255.0f alpha:1.0f];
    }
    
   
    //self.title = @"Content Sync";
    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont fontWithName:@"Arial" size:18];
    //titleView.font = [UIFont boldSystemFontOfSize:22.0];
    titleView.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    titleView.shadowOffset = CGSizeMake(0.0f, 1.0f);
    titleView.textColor = [UIColor colorWithRed:243.0f/255.0f green:6.0f/255.0f blue:23.0f/255.0f alpha:1.0f];
    titleView.text = @"    Frequency";
    self.navigationItem.titleView = titleView;
    [titleView sizeToFit];
    
    _datePicker.timeZone = [NSTimeZone systemTimeZone];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)saveScheduleData {
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL autoUpdate = _autoUpdateSwitch.on;
    NSMutableDictionary * syncSchedule = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          _datePicker.date, @"datePicker",
                                          [NSNumber numberWithBool:autoUpdate], @"autoUpdates",  nil];
    
    [defaults setObject:syncSchedule forKey:@"syncSchedule"];
    SchedulerViewController* schedulerViewController = [[SchedulerViewController alloc] init];
    [schedulerViewController scheduleNotificationForDate:_datePicker.date];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) retrieveScheduleData {
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * syncSchedule = [defaults objectForKey:@"syncSchedule"];
    NSDate* date = [syncSchedule objectForKey:@"datePicker"];
    BOOL autoUpdate = [[syncSchedule objectForKey:@"autoUpdates"] boolValue];
    _autoUpdateSwitch.on = autoUpdate;
    if (date != nil)
        _datePicker.date = [syncSchedule objectForKey:@"datePicker"];
}

- (void) didMoveToParentViewController:(UIViewController *)parent {
    
    if (parent == nil) { // This means we are moving back to Root View Controller, so save to defaults.
        [self saveScheduleData];
    } else {
        [self retrieveScheduleData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setImageForNavigationBackButton
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 41)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back_btn.png"] forState:UIControlStateNormal];
    UIBarButtonItem *barBackButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [backButton addTarget:self action:@selector(popCurrentViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = barBackButtonItem;
    self.navigationItem.hidesBackButton = YES;
}

- (void)popCurrentViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cntUpdateValueChanged:(id)sender
{
    UISwitch* update = (UISwitch*)sender;
    _autoUpdateOn = update.on;
}

@end
