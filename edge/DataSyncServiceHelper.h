//
//  DataSyncServiceHelper.h
//  edge
//
//  Created by iPhone Developer on 6/12/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "DataSyncService.h"
#import "Constants.h"

//#define URL_GET_MASTER_DATA             @"http://eprodevbox.com/api/masterdata"
#define URL_GET_MASTER_DATA             @"/contentapi/contentsync"  //@"http://eprodevbox.com/contentapi/contentsync"
#define URL_GET_SYNC_CHANGE_DATA        @"/notifyapi/notifyupdate" //@"http://eprodevbox.com/notifyapi/notifyupdate"


//#define URL_GET_MASTER_DATA             @"http://192.168.1.108/contentapi/contentsync"
//#define URL_GET_SYNC_CHANGE_DATA        @"http://192.168.1.108/notifyapi/notifyupdate"

@interface DataSyncServiceHelper : DataSyncService

- (void) getSyncDataWithParams:(NSDictionary*)params;
- (void) checkSyncDataWithParams:(NSDictionary*)params;

@end