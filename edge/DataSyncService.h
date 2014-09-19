//
//  DataSyncService.h
//  edgesync
//
//  Created by Vijaykumar on 5/30/13.
//  Copyright (c) 2013 eprosoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPClient.h"
#import "UpdateNotify.h"
#import "SyncedData.h"

@interface DataSyncService : NSObject

{
    NSMutableArray *contentArray,*contentArray2,*entitlmntArray;
    NSMutableArray *masterlookups;
    NSMutableArray *finalArray;
    NSMutableArray *newEntitlements;
    NSMutableArray *myEntitlements;
}

@property (nonatomic,strong) AFHTTPClient* httpClient;
@property (nonatomic, assign) BOOL isInitialSync;

- (void)syncData : (NSString*) urlString withRequestData: (NSDictionary*) data usingHttpMethod:(NSString*) httpMethod DEPRECATED_ATTRIBUTE;

- (void)syncData : (NSString*) urlString withRequestData: (NSDictionary*) data usingHttpMethod:(NSString*) httpMethod
     withEmailId : (NSString*) emailId  withPassword : (NSString*) password;

- (void) deleteAllFromEntityWithName:(NSString*)entityName;

- (BOOL) deleteSpecialityById : (NSNumber*) splId
      withManagedObjectContext:(NSManagedObjectContext* ) context;

- (void)checkSpecialitySyncStatus : (NSString*) urlString withRequestData: (NSDictionary*) data usingHttpMethod:(NSString*) httpMethod
                      withEmailId : (NSString*) emailId  withPassword : (NSString*) password;

@end


/*
 UUID: U56789A0
 email: account2@example.com
 password: account2
 */