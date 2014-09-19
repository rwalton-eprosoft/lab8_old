//
//  SchedulerViewController.m
//  edge
//
//  Created by Vijaykumar on 8/22/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "SchedulerViewController.h"

@interface SchedulerViewController ()

@end

@implementation SchedulerViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) scheduleNotificationForDate: (NSDate*) date {
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = date;
    NSLog(@"Notification set for : %@", localNotification.fireDate);
    
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
//    localNotification.alertBody = [NSString stringWithFormat:@"Content updates Available"];
    localNotification.alertAction = NSLocalizedString(@"Content Sync", nil);
//    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 0;
    localNotification.repeatInterval = NSDayCalendarUnit;

    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
