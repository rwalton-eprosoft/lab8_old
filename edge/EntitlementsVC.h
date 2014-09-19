//
//  EntitlementsVC.h
//  edge
//
//  Created by iPhone Developer on 6/10/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#define TAG_SPECIALITY_DEFAULT_TABLE_VIEW           90
#define TAG_SPECIALITY_ENABLEMENTS_TABLE_VIEW       91

#define TAG_FILTER_CELL_DEFAULT                     900
#define TAG_FILTER_CELL_ENABLEMENT                  901

#define TAG_ALERT_VIEW_CONFIRM_CONTENT_DOWNLOAD     902
#define TAG_ALERT_MASTER_SYNC_FAILED                903


@interface EntitlementsVC : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *defaultTableView;
@property (nonatomic, strong) IBOutlet UITableView *enablementsTableView;
@property (nonatomic, strong) IBOutlet UILabel *totalContentDownloadSizeLbl;
@property (nonatomic, strong) IBOutlet UILabel *totalFreeStorageSpaceLbl;
@property (nonatomic, strong) MBProgressHUD *hud;

- (IBAction) downloadContentBtnTouched;

@end
