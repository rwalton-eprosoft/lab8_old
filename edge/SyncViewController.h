//
//  SyncViewController.h
//  edge
//
//  Created by Vijaykumar on 8/7/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentSyncViewController.h"
#import "AppDelegate.h"
#import "TabBarViewController.h"
#import "MBProgressHUD.h"

@interface SyncViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

{
    NSArray *tempArray;
    NSMutableArray *muttempArray;
}

@property (nonatomic, assign) AppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UIView *syncPopupView;
@property (strong, nonatomic) IBOutlet UITableView *specialityListTable;
@property (strong, nonatomic) IBOutlet TabBarViewController *delegate;
@property (strong, nonatomic) NSMutableDictionary *selectedRows;

@property (nonatomic, strong) ContentSyncViewController* contentSyncVC;
@property(atomic, retain) UIPopoverController* contentSyncPopup;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIView *hudView;

@property (nonatomic, assign) int syncvalue;
@property (nonatomic, assign) int syncvalue1;

@property (nonatomic, assign) BOOL syncFromScheduler;

- (IBAction)syncBtnClicked:(id)sender;

- (void) registerForEvents;
- (void) unregisterForEvents;


@end
