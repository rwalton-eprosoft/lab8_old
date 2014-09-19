//
//  ContentSyncSchedulerViewController.h
//  edge
//
//  Created by Vijaykumar on 8/23/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentSyncSchedulerViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *schedulerView;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, assign) BOOL autoUpdateOn;
@property (strong, nonatomic) IBOutlet UISwitch *autoUpdateSwitch;

- (void)saveScheduleData;

@end
