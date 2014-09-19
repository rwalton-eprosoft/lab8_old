//
//  ContentSyncVerifier.h
//  edge
//
//  Created by Vijaykumar on 8/25/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DashboardVC.h"
#import "MBProgressHUD.h"

@interface ContentSyncVerifier : NSObject
{
    BOOL changeinvalue;
}
@property (nonatomic, strong) MBProgressHUD *hud;
@property (atomic, assign) BOOL changeinvalue;
+ (ContentSyncVerifier*) sharedInstance;

- (void) checkSpecialityStatus;

@property (nonatomic, strong) IBOutlet UIButton *hasNewContentBtn;
@property (atomic, strong) NSString* contentChangeReport;

- (void) enableBulbIcon;
- (void) disableBulbIcon;
- (void) callDataSyncServiceWithUUID:(NSString*)uuid entitlements:(NSArray*)entitlements;

@end
