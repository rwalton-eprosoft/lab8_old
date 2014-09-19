//
//  DataSyncServiceHelper.m
//  edge
//
//  Created by iPhone Developer on 6/12/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "DataSyncServiceHelper.h"
#import "RegistrationModel.h"
#import "MyProfile.h"
#import "ContentModel.h"
#import "AppDelegate.h"
#define APP_DELEGATE (AppDelegate*)[[UIApplication sharedApplication] delegate]

@implementation DataSyncServiceHelper

- (void) getSyncDataWithParams:(NSDictionary*)params
{
    NSString *email = [[RegistrationModel sharedInstance].profile email];
    NSString *password = nil;
    
    DataSyncService *dataSyncService = [[DataSyncService alloc] init];
    
    NSString* serverBaseURL = WEB_SERVICE_BASE_SERVER;
//    NSString* defaultServerURL = [APP_DELEGATE settingsServerURL];
//    if (defaultServerURL != nil && defaultServerURL.length > 0)
//        serverBaseURL = defaultServerURL;

    NSString* newString = [NSString stringWithFormat:@"%@%@", serverBaseURL, URL_GET_MASTER_DATA];
    [dataSyncService syncData:newString withRequestData:params usingHttpMethod:@"POST" withEmailId:email withPassword:password];
}

- (void) checkSyncDataWithParams:(NSDictionary*)params
{
    NSString *email = [[RegistrationModel sharedInstance].profile email];
    NSString *password = nil;
    
    DataSyncService *dataSyncService = [[DataSyncService alloc] init];
    
    NSString* serverBaseURL = WEB_SERVICE_BASE_SERVER;
//    NSString* defaultServerURL = [APP_DELEGATE settingsServerURL];
//    if (defaultServerURL != nil && defaultServerURL.length > 0)
//        serverBaseURL = defaultServerURL;
    
    NSString* newString = [NSString stringWithFormat:@"%@%@", serverBaseURL, URL_GET_SYNC_CHANGE_DATA];
    [dataSyncService checkSpecialitySyncStatus:newString withRequestData:params usingHttpMethod:@"POST" withEmailId:email withPassword:password];
}

@end
