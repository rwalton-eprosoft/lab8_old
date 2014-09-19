//
//  SettingsVC.h
//  edge
//
//  Created by iPhone Developer on 5/13/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "BasePopoverVC.h"
#import "AppDelegate.h"

@protocol SettingsVCDelegate <NSObject>

- (void) dismissSettingsPopover;

@end

@interface SettingsVC : UIViewController

@property (nonatomic, assign) int defaultSpeciality;
@property (nonatomic, weak) id<SettingsVCDelegate> delegate;
@property (nonatomic, strong) UITableView * tableview;
@property (nonatomic, strong) IBOutlet UILabel * appversion;
@property (nonatomic, strong) AppDelegate * appDelegate;


- (IBAction) doneBtnTouched;
-(IBAction)profilebtnPressed:(id)sender;
-(IBAction)aboutbtnPressed:(id)sender;
-(IBAction)specialitybtnPressed:(id)sender;

@end
