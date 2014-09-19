//
//  DiagnosticsViewController.h
//  edge
//
//  Created by Dheeraj Raju on 10/03/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentSyncViewController.h"
#import "AppDelegate.h"
#import "TabBarViewController.h"
#import "MBProgressHUD.h"
#import "SyncViewController.h"


@interface DiagnosticsViewController : UIViewController

@property (strong, nonatomic) IBOutlet TabBarViewController *delegate;
@property (strong, nonatomic) IBOutlet UIView *diagnosticsPopupView;
@property (nonatomic, strong) ContentSyncViewController* contentSyncVC;
@property(atomic, retain) UIPopoverController* contentSyncPopup;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIView *hudView;
@property (weak, nonatomic) IBOutlet UIButton *reset_all_btn;
@property (weak, nonatomic) IBOutlet UIButton *diagnosticsBtn;
@property (nonatomic, strong) SyncViewController *sync;
@end
