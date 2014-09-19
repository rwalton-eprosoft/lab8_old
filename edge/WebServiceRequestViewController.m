//
//  WebServiceRequestViewController.m
//  edgesync
//
//  Created by Vijaykumar on 5/30/13.
//  Copyright (c) 2013 eprosoft. All rights reserved.
//

#import "WebServiceRequestViewController.h"
#import "AFJSONRequestOperation.h"
#import "AppDelegate.h"
#import "DataSyncService.h"

#define APP_DELEGATE (AppDelegate*)[[UIApplication sharedApplication] delegate]
@interface WebServiceRequestViewController ()

@end

@implementation WebServiceRequestViewController

/**
 
 */
- (void) viewDidLoad {
    
}

/**
 
 */
- (IBAction) executeSyncData :(id)sender {
   
    DataSyncService* dataSyncService = [[DataSyncService alloc] init];
    NSString* json = @"{\"uuid\":\"1234567890\",\"splIds\":[1,2,3]}";
    NSError* error;
    id data =[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error];
    [dataSyncService syncData:@"http://eprodevbox.com/api/masterdata" withRequestData:data usingHttpMethod:@"POST"];

//    NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"AllDataFromApp" ofType:@"json"];
//    NSString *jsonData = [NSString stringWithContentsOfFile:dataPath encoding:NSISOLatin1StringEncoding error:nil];
//    NSError* erf;
//    NSDictionary* dataDict = [NSJSONSerialization JSONObjectWithData:[jsonData dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&erf];
//    [dataSyncService processJSONData : [(NSDictionary *) dataDict valueForKey:@"body"]];
}

/**
 */
- (IBAction) clearCoreData:(id)sender {
    DataSyncService* dataSyncService = [[DataSyncService alloc] init];

    [[[APP_DELEGATE managedObjectContext] undoManager] disableUndoRegistration];
    
    [dataSyncService  deleteAllFromEntityWithName:@"MedicalCategory"];
    [dataSyncService  deleteAllFromEntityWithName:@"ArcCategory"];
    [dataSyncService  deleteAllFromEntityWithName:@"ProcedureStep"];
    [dataSyncService  deleteAllFromEntityWithName:@"SpecialityCategory"];
    [dataSyncService  deleteAllFromEntityWithName:@"Content"];
    [dataSyncService  deleteAllFromEntityWithName:@"ContentCategory"];
    [dataSyncService  deleteAllFromEntityWithName:@"ContentMapping"];
    [dataSyncService  deleteAllFromEntityWithName:@"Speciality"];
    [dataSyncService  deleteAllFromEntityWithName:@"Procedure"];
    [dataSyncService  deleteAllFromEntityWithName:@"Market"];
    [dataSyncService  deleteAllFromEntityWithName:@"ProductCategory"];
    [dataSyncService  deleteAllFromEntityWithName:@"Product"];
    [dataSyncService  deleteAllFromEntityWithName:@"CompProduct"];
    [dataSyncService  deleteAllFromEntityWithName:@"FileContent"];
    
    [[[APP_DELEGATE managedObjectContext] undoManager] enableUndoRegistration];
}

@end