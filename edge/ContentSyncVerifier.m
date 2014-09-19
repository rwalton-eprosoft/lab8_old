//
//  ContentSyncVerifier.m
//  edge
//
//  Created by Vijaykumar on 8/25/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "ContentSyncVerifier.h"
#import "AppDelegate.h"
#import "MyEntitlement.h"
#import "RegistrationModel.h"
#import "MyProfile.h"
#import "ContentModel.h"
#import "TabBarViewController.h"
#import "Constants.h"
#import "DataSyncServiceHelper.h"

@implementation ContentSyncVerifier
@synthesize changeinvalue;

+ (ContentSyncVerifier*) sharedInstance
{
    static ContentSyncVerifier *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[ContentSyncVerifier alloc] init];
    });
    return instance;
}

- (id) init {
    
    if (super.init) {
    }
    return self;
}

- (void) checkSpecialityStatus {
    
    [self registerForEvents];
    NSString *uuid = [[RegistrationModel sharedInstance] uuid];
    NSArray *myEntitlements = [[RegistrationModel sharedInstance].profile.myProfileToMyEntitlement allObjects];
    [self callDataSyncServiceWithUUID:uuid entitlements:myEntitlements];
}

- (void) registerForEvents
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSyncMasterDataSuccess:) name:APP_EVENT_VERIFY_SYNC_DATA_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSyncMasterDataFailure:) name:APP_EVENT_VERIFY_SYNC_DATA_FAILURE object:nil];
}

- (void) unregisterForEvents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_VERIFY_SYNC_DATA_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_VERIFY_SYNC_DATA_FAILURE object:nil];
}

- (void) handleSyncMasterDataSuccess: (NSNotification *)notification
{
    if ([[UpdateNotify SharedManager] titlearray].count && [[UpdateNotify SharedManager] lastArray].count)
    {
        [self enableBulbIcon];
    }
   
    [_hud hide:YES];
    ////nslog(@"UserInfo .... %@",[notification userInfo]);
    _contentChangeReport = [[notification userInfo] valueForKey:@"message"];
    
    [self unregisterForEvents];
}

- (void) handleSyncMasterDataFailure : (NSNotification *)notification
{
    [_hud hide:YES];
    ////nslog(@"UserInfo .... %@",[notification userInfo]);
    _contentChangeReport = [[notification userInfo] valueForKey:@"message"];

    [self unregisterForEvents];
}

- (void) callDataSyncServiceWithUUID:(NSString*)uuid entitlements:(NSArray*)entitlements
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:uuid forKey:@"uuid"];
    
    NSMutableArray *array = [NSMutableArray array];
    for (MyEntitlement *myEntitlement in entitlements)
    {
        if ([myEntitlement.status intValue] == kEntitlementStatusEnabled)
        {
            [array addObject:myEntitlement.splId];
        }
    }
        [dict setObject:array forKey:@"splIds"];
    
    DataSyncServiceHelper *dataSync = [[DataSyncServiceHelper alloc] init];
    [dataSync checkSyncDataWithParams:dict];
}

- (void) enableBulbIcon {
    [self.hasNewContentBtn setImage:[UIImage imageNamed:@"bulp_active.png"] forState:UIControlStateNormal];
    _hasNewContentBtn.enabled = YES;
     changeinvalue = YES;
    

}

- (void) disableBulbIcon {
    [self.hasNewContentBtn setImage:[UIImage imageNamed:@"bulp_inactive.png"] forState:UIControlStateNormal];
    _hasNewContentBtn.enabled = NO;
    changeinvalue = NO;
}

@end
