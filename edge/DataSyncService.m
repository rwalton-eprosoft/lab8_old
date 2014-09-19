//
//  DataSyncService.m
//  edgesync
//
//  Created by Vijaykumar on 5/30/13.
//  Copyright (c) 2013 eprosoft. All rights reserved.
//

#import "DataSyncService.h"
#import "AFJSONRequestOperation.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "RegistrationModel.h"
#import "DataValidator.h"
#import "DownloadManager.h"
#import "ContentSearchModel.h"
#import "FileContent.h"
#import "ContentModel.h"
#import "ContentMapping.h"
#import "MyEntitlement.h"
#import "MyProfile.h"
#import "ContentSyncVerifier.h"
#import "ContentSearch.h"
#import "SharedLink.h"

#define APP_DELEGATE (AppDelegate*)[[UIApplication sharedApplication] delegate]
@interface DataSyncService ()
@end

@implementation DataSyncService

int commonFiles = 0;

//Check if there are any updates for existing specialities
- (void)checkSpecialitySyncStatus : (NSString*) urlString withRequestData: (NSDictionary*) data usingHttpMethod:(NSString*) httpMethod
     withEmailId : (NSString*) emailId  withPassword : (NSString*) password
{
    [self invokeWebService :urlString usingHttpMethod:httpMethod withRequestData: data forEmailId:emailId forPassword:password checkSyncStatus:YES];
}


//Sync Server data with Core Data Locally
- (void)syncData : (NSString*) urlString withRequestData: (NSDictionary*) data usingHttpMethod:(NSString*) httpMethod
                    withEmailId : (NSString*) emailId  withPassword : (NSString*) password
{
    //        NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"edgeresponse" ofType:@"json"];
    //        NSString *jsonData = [NSString stringWithContentsOfFile:dataPath encoding:NSISOLatin1StringEncoding error:nil];
    //        NSError* erf;
    //        NSDictionary* dataDict = [NSJSONSerialization JSONObjectWithData:[jsonData dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&erf];
    //        NSDictionary *jsonDict = [(NSDictionary *) dataDict valueForKey:SERVER_RESPONSE_BODY];
    //    
    //        [self processJSONData :jsonDict];
    //        [APP_DELEGATE postApplicationEvent:APP_EVENT_SYNC_MASTER_DATA_SUCCESS];
    
    [self invokeWebService :urlString usingHttpMethod:httpMethod withRequestData: data forEmailId:emailId forPassword:password checkSyncStatus:NO];
}

//Sync Server data with Core Data Locally -- Deprecated Method
- (void)syncData : (NSString*) urlString withRequestData: (NSDictionary*) data usingHttpMethod:(NSString*) httpMethod
{
    
    [self invokeWebService :urlString usingHttpMethod:httpMethod withRequestData: data forEmailId:@"demo@example.com" forPassword:@"demo" checkSyncStatus:NO];
}

//Save data to Core Data, notify if any failures
- (void)processServerData:(NSHTTPURLResponse *)response JSON:(id)JSON checkSyncStatus : (BOOL) checkSyncStatus
{
    ////nslog(@"the output is %@",[JSON class]);
    ////nslog(@"count of body json is %d",[JSON count]);
    
    ////nslog(@"the output is %@",[JSON objectForKey:@"body"]);
    ////nslog(@"the output in each %@",[[JSON objectForKey:@"body"] objectForKey:@"masterLookups"] );
    ////nslog(@"the output in each %d",[[[JSON objectForKey:@"body"] objectForKey:@"masterLookups"] count]);
    
    ////nslog(@"the output in Specialities %@",[[JSON objectForKey:@"body"] objectForKey:@"Specialities"] );
    if (checkSyncStatus == YES)
    {
        [self checkSyncStatusJSON:JSON];
    }
    NSDictionary *jsonHeader = [(NSDictionary *) JSON valueForKey:SERVER_RESPONSE_HEADER];
    if (response.statusCode != 200 || (jsonHeader != nil &&
                                       [[jsonHeader valueForKey:@"statusCode"] intValue] != [[NSNumber numberWithInt:kSuccessContent] intValue])) {
        if (!checkSyncStatus) {
            [[NSNotificationCenter defaultCenter] postNotificationName:APP_EVENT_SYNC_MASTER_DATA_FAILURE object:nil userInfo:jsonHeader];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:APP_EVENT_VERIFY_SYNC_DATA_FAILURE object:nil userInfo:jsonHeader];
        }
        return;
    }
    
    if (!checkSyncStatus) {
        NSDictionary *jsonDict = [(NSDictionary *) JSON valueForKey:SERVER_RESPONSE_BODY];
        [self processJSONData :jsonDict];
        [APP_DELEGATE postApplicationEvent:APP_EVENT_SYNC_MASTER_DATA_SUCCESS];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:APP_EVENT_VERIFY_SYNC_DATA_SUCCESS object:nil userInfo:jsonHeader];
    }
}
- (void) checkSyncStatusJSON:(id)JSON
{
    contentArray = [[NSMutableArray alloc] initWithCapacity:0];
    contentArray2 = [[NSMutableArray alloc] initWithCapacity:0];
    
    entitlmntArray = [[NSMutableArray alloc] initWithCapacity:0];

    
    finalArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    masterlookups = [[NSMutableArray alloc] initWithCapacity:0];
    
    newEntitlements = [[NSMutableArray alloc] initWithCapacity:0];
    
    myEntitlements = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL isNewSpecialitiesAdded = NO;
    
    if ([[[JSON objectForKey:@"body"] objectForKey:@"NewEntitlements"] count] !=0 )
    {
        NSMutableDictionary *dictnry = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dictnry setObject:[[JSON objectForKey:@"body"] objectForKey:@"NewEntitlements"] forKey:@"newEntitlements"];
        [newEntitlements addObject:dictnry];
        
        NSNumber *splId;
        MyEntitlement *myEntitlement;
        MyProfile *profile;
        
        NSString *email = [[RegistrationModel sharedInstance].profile email];
        
        NSFetchRequest *fetchRequest1 = [self profileFetchRequestWithEmail:email];
        
        NSError *error1;
        BOOL found1 = NO;
        NSArray *items1 = [[APP_DELEGATE managedObjectContext] executeFetchRequest:fetchRequest1 error:&error1];
        if (!error1) {
            if (items1 && items1.count > 0)
            {
                profile = [items1 objectAtIndex:0];
                found1 = YES;
            }
        }
        
        if (!found1)
        {
            // Create a new instance of the entity
            profile = [NSEntityDescription insertNewObjectForEntityForName:@"MyProfile"
                                                    inManagedObjectContext:[APP_DELEGATE managedObjectContext]];
            profile.email = email;
            profile.crtDt = [NSDate date];
        }
        
        for (int b= 0; b < [[[newEntitlements objectAtIndex:0] objectForKey:@"newEntitlements"] count]; b++)
        {
            [dictnry setObject:[[[newEntitlements objectAtIndex:0] objectForKey:@"newEntitlements"] objectAtIndex:b ] forKey:@"newEntitlementsName"];
            
            [entitlmntArray addObject:[dictnry objectForKey:@"newEntitlementsName"]];
            
            splId = [[entitlmntArray objectAtIndex:b] objectForKey:@"splId"];
            
            // Create the fetch request for MyEntitlement
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            // Edit the entity name as appropriate.
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyEntitlement" inManagedObjectContext:[APP_DELEGATE managedObjectContext]];
            [fetchRequest setEntity:entity];
            
            // add the predicate for searching
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"splId = %d", [splId intValue]];
            [fetchRequest setPredicate:predicate];
            
            NSError *error;
            BOOL found = NO;
            NSArray *items = [[APP_DELEGATE managedObjectContext] executeFetchRequest:fetchRequest error:&error];
            if (!error) {
                if (items && items.count > 0)
                {
                    myEntitlement = [items objectAtIndex:0];
                    found = YES;
                }
            }
            
            
            if (!found)
            {
                // Create a new instance of the entity
                myEntitlement = [NSEntityDescription insertNewObjectForEntityForName:@"MyEntitlement"
                                                              inManagedObjectContext:[APP_DELEGATE managedObjectContext]];
                myEntitlement.splId = splId;
                myEntitlement.status = [NSNumber numberWithInt:kEntitlementStatusDisabled];
                
                
                myEntitlement.totalFiles = [[entitlmntArray objectAtIndex:b] objectForKey:@"totalFiles"];
                myEntitlement.name = [[entitlmntArray objectAtIndex:b] objectForKey:@"name"];
                myEntitlement.totalSize = [[entitlmntArray objectAtIndex:b] objectForKey:@"totalSize"];
                
                // relate myEntitlement to MyProfile
                myEntitlement.myEntitlementToMyProfile = profile;
                [APP_DELEGATE saveContext];
                
                [myEntitlements addObject:myEntitlement];
                isNewSpecialitiesAdded = YES;

            }
        }
    }
    if (isNewSpecialitiesAdded)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ForNewEnt" object:nil];
    }
    if (!isNewSpecialitiesAdded)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NoNewSpecialities" object:nil];

    }
    
    if ([[[JSON objectForKey:@"body"] objectForKey:@"masterLookups"] count] !=0 )
    {
        NSMutableDictionary *dictnry = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dictnry setObject:[[JSON objectForKey:@"body"] objectForKey:@"masterLookups"] forKey:@"masterLookups"];
        [masterlookups addObject:dictnry];
        
        int a;
        
        for (a = 0; a < [[[[masterlookups objectAtIndex:0] objectForKey:@"masterLookups"] objectForKey:@"Applications"] count]; a++)
        {
            [dictnry setObject:[[[[[masterlookups objectAtIndex:0] objectForKey:@"masterLookups"] objectForKey:@"Applications"] objectAtIndex:a ]objectForKey:@"name"] forKey:@"ApplicationsName"];
            [contentArray2 addObject:[dictnry objectForKey:@"ApplicationsName"]];
        }
        
        for (a = 0; a < [[[[masterlookups objectAtIndex:0] objectForKey:@"masterLookups"] objectForKey:@"ArcCategory"] count]; a++)
        {
            [dictnry setObject:[[[[[masterlookups objectAtIndex:0] objectForKey:@"masterLookups"] objectForKey:@"ArcCategory"] objectAtIndex:a ]objectForKey:@"name"] forKey:@"ArcCategoryName"];
            [contentArray2 addObject:[dictnry objectForKey:@"ArcCategoryName"]];
        }
        
        for (a = 0; a < [[[[masterlookups objectAtIndex:0] objectForKey:@"masterLookups"] objectForKey:@"ContentCategory"] count]; a++)
        {
            [dictnry setObject:[[[[[masterlookups objectAtIndex:0] objectForKey:@"masterLookups"] objectForKey:@"ContentCategory"] objectAtIndex:a ]objectForKey:@"name"] forKey:@"ContentCategoryName"];
            [contentArray2 addObject:[dictnry objectForKey:@"ContentCategoryName"]];
        }
        for (a = 0; a < [[[[masterlookups objectAtIndex:0] objectForKey:@"masterLookups"] objectForKey:@"MedicalCategory"] count]; a++)
        {
            [dictnry setObject:[[[[[masterlookups objectAtIndex:0] objectForKey:@"masterLookups"] objectForKey:@"MedicalCategory"] objectAtIndex:a ]objectForKey:@"name"] forKey:@"MedicalCategoryName"];
            [contentArray2 addObject:[dictnry objectForKey:@"MedicalCategoryName"]];
        }
        for (a = 0; a < [[[[masterlookups objectAtIndex:0] objectForKey:@"masterLookups"] objectForKey:@"ProductCategory"] count]; a++)
        {
            [dictnry setObject:[[[[[masterlookups objectAtIndex:0] objectForKey:@"masterLookups" ]objectForKey:@"ProductCategory"] objectAtIndex:a ]objectForKey:@"name"] forKey:@"ProductCategoryName"];
            [contentArray2 addObject:[dictnry objectForKey:@"ProductCategoryName"]];
        }
        for (a = 0; a < [[[[masterlookups objectAtIndex:0] objectForKey:@"masterLookups"] objectForKey:@"SpecialityCategory"] count]; a++)
        {
            [dictnry setObject:[[[[[masterlookups objectAtIndex:0] objectForKey:@"masterLookups"] objectForKey:@"SpecialityCategory"] objectAtIndex:a ]objectForKey:@"name"] forKey:@"SpecialityCategoryName"];
            [contentArray2 addObject:[dictnry objectForKey:@"SpecialityCategoryName"]];
        }
    }
    
    
    for (int j = 0; j < [[[JSON objectForKey:@"body"] objectForKey:@"Specialities"] count]; j++)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dict setObject:[[JSON objectForKey:@"body"] objectForKey:@"Specialities"]  forKey:@"name"];
        [contentArray addObject:dict];
        
        SyncedData *tot = [[SyncedData alloc] init];
        tot.contents = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *dictnry = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dictnry setObject:[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"name"] forKey:@"name"];
        
        if ([[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] count] != 0)
        {
            if ([[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] != 0)
            {
                tot.names = [dictnry objectForKey:@"name"];
            }
            
            NSString *specialityname = [[NSString alloc]init];
            NSString *ProcedureName = [[NSString alloc] init];
            
            for (int x = 0 ; x < [[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"Market"] count]; x++)
            {
                
                [dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"Market"] objectAtIndex:x] objectForKey:@"name"] forKey:@"marketname"];
                [tot.contents addObject:[dictnry objectForKey:@"marketname"]];
                
            }
            
            for (int x = 0 ; x < [[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"Procedure"] count]; x++)
            {
                
                [dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"Procedure"] objectAtIndex:x] objectForKey:@"name"] forKey:@"Procedurename"];
                [tot.contents addObject:[dictnry objectForKey:@"Procedurename"]];
                
            }
            
            for (int x = 0 ; x < [[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"Product"] count]; x++)
            {
                
                [dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"Product"] objectAtIndex:x] objectForKey:@"name"] forKey:@"Productname"];
                [tot.contents addObject:[dictnry objectForKey:@"Productname"]];
                
            }
            
            for (int x = 0 ; x < [[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"CompProduct"] count]; x++)
            {
                
                [dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"CompProduct"] objectAtIndex:x] objectForKey:@"name"] forKey:@"CompProductname"];
                [tot.contents addObject:[dictnry objectForKey:@"CompProductname"]];
                
            }
            
            for (int x = 0 ; x < [[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProcedureStep"] count]; x++)
            {
                
                
                [dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProcedureStep"] objectAtIndex:x] objectForKey:@"name"] forKey:@"ProcedureStepname"];
                [tot.contents addObject:[dictnry objectForKey:@"ProcedureStepname"]];
                
            }
            
            
            
            for (int x = 0 ; x < [[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"Content"] count]; x++)
            {
                [dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"Content"] objectAtIndex:x] objectForKey:@"title"] forKey:@"title"];
                [tot.contents addObject:[dictnry objectForKey:@"title"]];
                
            }
            
            for (int x = 0 ; x < [[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ContentMapping"] count]; x++)
            {
                //[dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ContentMapping"] objectAtIndex:x] objectForKey:@"ContentTitle"] forKey:@"ContentTitle"];
                //[dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ContentMapping"] objectAtIndex:x] objectForKey:@"ContentType"] forKey:@"ContentType"];
                specialityname = [[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ContentMapping"] objectAtIndex:x] objectForKey:@"ContentTitle"];
                ProcedureName = [[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ContentMapping"] objectAtIndex:x] objectForKey:@"ContentType"];
                
                //[tot.contents addObject:[dictnry objectForKey:@"title"]];
                [tot.contents addObject:[NSString stringWithFormat:@"%@ to %@",specialityname,ProcedureName]];
            }
            for (int x = 0 ; x < [[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"SpecialityToProcedure"] count]; x++)
            {
                
                //[dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"SpecialityToProcedure"] objectAtIndex:x] objectForKey:@"SpecialityName"] forKey:@"stpSpecialityName"];
                
                //[dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"SpecialityToProcedure"] objectAtIndex:x] objectForKey:@"ProcedureName"] forKey:@"stpProcedureName"];
                
                specialityname = [[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"SpecialityToProcedure"] objectAtIndex:x] objectForKey:@"SpecialityName"];
                ProcedureName =[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"SpecialityToProcedure"] objectAtIndex:x] objectForKey:@"ProcedureName"];
                
                // [tot.contents addObject:[dictnry objectForKey:@"stpProcedureName"]];
                [tot.contents addObject:[NSString stringWithFormat:@"%@ to %@",specialityname,ProcedureName]];
                
            }
            
            for (int x = 0 ; x < [[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProcedureToProduct"] count]; x++)
            {
                //[dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProcedureToProduct"] objectAtIndex:x] objectForKey:@"ProcedureName"] forKey:@"ptpProcedureName"];
                // [dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProcedureToProduct"] objectAtIndex:x] objectForKey:@"ProductName"] forKey:@"ptpProductName"];
                
                specialityname = [[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProcedureToProduct"] objectAtIndex:x] objectForKey:@"ProcedureName"];
                ProcedureName = [[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProcedureToProduct"] objectAtIndex:x] objectForKey:@"ProductName"];
                
                //[tot.contents addObject:[dictnry objectForKey:@"ptpProductName"]];
                [tot.contents addObject:[NSString stringWithFormat:@"%@ to %@",specialityname,ProcedureName]];
            }
            
            for (int x = 0 ; x < [[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProcedurestepToProcedure"] count]; x++)
            {
                
                // [dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProcedurestepToProcedure"] objectAtIndex:x] objectForKey:@"ProcStepName"] forKey:@"ProcStepName"];
                // [dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProcedurestepToProcedure"] objectAtIndex:x] objectForKey:@"ProcedureName"] forKey:@"ProcProcedureName"];
                specialityname = [[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProcedurestepToProcedure"] objectAtIndex:x] objectForKey:@"ProcStepName"];
                ProcedureName = [[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProcedurestepToProcedure"] objectAtIndex:x] objectForKey:@"ProcedureName"];
                
                //[tot.contents addObject:[dictnry objectForKey:@"ProcStepName"]];
                [tot.contents addObject:[NSString stringWithFormat:@"%@ to %@",specialityname,ProcedureName]];
            }
            
            for (int x = 0 ; x < [[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProductToCompProduct"] count]; x++)
            {
                
                //[dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProductToCompProduct"] objectAtIndex:x] objectForKey:@"ProductName"] forKey:@"ptcpProductName"];
                // [dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProductToCompProduct"] objectAtIndex:x] objectForKey:@"CompProductName"] forKey:@"ptcpCompProductName"];
                
                specialityname = [[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProductToCompProduct"] objectAtIndex:x] objectForKey:@"ProductName"];
                ProcedureName = [[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProductToCompProduct"] objectAtIndex:x] objectForKey:@"CompProductName"];
                
                //[tot.contents addObject:[dictnry objectForKey:@"ptcpCompProductName"]];
                [tot.contents addObject:[NSString stringWithFormat:@"%@ to %@",specialityname,ProcedureName]];
            }
            
            for (int x = 0 ; x < [[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProductToMarket"] count]; x++)
            {
                
                //[dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProductToMarket"] objectAtIndex:x] objectForKey:@"ProductName"] forKey:@"ptmProductName"];
                //[dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProductToMarket"] objectAtIndex:x] objectForKey:@"MarketName"] forKey:@"ptmMarketName"];
                
                specialityname = [[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProductToMarket"] objectAtIndex:x] objectForKey:@"ProductName"];
                ProcedureName = [[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProductToMarket"] objectAtIndex:x] objectForKey:@"MarketName"];
                
                //[tot.contents addObject:[dictnry objectForKey:@"ptmMarketName"]];
                [tot.contents addObject:[NSString stringWithFormat:@"%@ to %@",specialityname,ProcedureName]];
            }
            
            for (int x = 0 ; x < [[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProductToProcedurestep"] count]; x++)
            {
                
                //[dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProductToProcedurestep"] objectAtIndex:x] objectForKey:@"ProductName"] forKey:@"ptpProductName"];
                //[dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProductToProcedurestep"] objectAtIndex:x] objectForKey:@"ProcStepName"] forKey:@"ptpProcStepName"];
                
                specialityname = [[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProductToProcedurestep"] objectAtIndex:x] objectForKey:@"ProductName"];
                ProcedureName = [[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProductToProcedurestep"] objectAtIndex:x] objectForKey:@"ProcStepName"];
                
                //[tot.contents addObject:[dictnry objectForKey:@"ptpProcStepName"]];
                [tot.contents addObject:[NSString stringWithFormat:@"%@ to %@",specialityname,ProcedureName]];
            }
            for (int x = 0 ; x < [[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ExtendedMetadata"] count]; x++)
            {
                
                [dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ExtendedMetadata"] objectAtIndex:x] objectForKey:@"fieldName"] forKey:@"fieldName"];
                [tot.contents addObject:[dictnry objectForKey:@"fieldName"]];
                
                
            }
            for (int x = 0 ; x < [[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"Concern"] count]; x++)
            {
                
                [dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"Concern"] objectAtIndex:x] objectForKey:@"name"] forKey:@"ConcernName"];
                [tot.contents addObject:[dictnry objectForKey:@"ConcernName"]];
                
                
            }
            for (int x = 0 ; x < [[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ConcernToProduct"] count]; x++)
            {
                
                //[dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ConcernToProduct"] objectAtIndex:x] objectForKey:@"ConcernName"] forKey:@"ConcernConcernName"];
                //[dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ConcernToProduct"] objectAtIndex:x] objectForKey:@"ProductName"] forKey:@"ConcernProductName"];
                
                specialityname = [[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ConcernToProduct"] objectAtIndex:x] objectForKey:@"ConcernName"];
                ProcedureName = [[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ConcernToProduct"] objectAtIndex:x] objectForKey:@"ProductName"];
                
                //[tot.contents addObject:[dictnry objectForKey:@"ConcernProductName"]];
                [tot.contents addObject:[NSString stringWithFormat:@"%@ to %@",specialityname,ProcedureName]];
                
            }
            for (int x = 0 ; x < [[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProcedureStepToConcern"] count]; x++)
            {
                
                //[dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProcedureStepToConcern"] objectAtIndex:x] objectForKey:@"ConcernName"] forKey:@"pstcConcernName"];
                //[dictnry setObject:[[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProcedureStepToConcern"] objectAtIndex:x] objectForKey:@"ProcStepName"] forKey:@"pstcProcStepName"];
                
                specialityname = [[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProcedureStepToConcern"] objectAtIndex:x] objectForKey:@"ConcernName"];
                ProcedureName = [[[[[[[contentArray objectAtIndex:0] objectForKey:@"name"] objectAtIndex:j] objectForKey:@"updates"] objectForKey:@"ProcedureStepToConcern"] objectAtIndex:x] objectForKey:@"ProcStepName"];
                
                // [tot.contents addObject:[dictnry objectForKey:@"pstcProcStepName"]];
                [tot.contents addObject:[NSString stringWithFormat:@"%@ to %@",specialityname,ProcedureName]];
            }
            [finalArray addObject:tot];
            
        }
        
    }
    [[UpdateNotify SharedManager] setNewentitlementsArray:entitlmntArray];
    [[UpdateNotify SharedManager] setTitlearray:contentArray2];
    [[UpdateNotify SharedManager] setLastArray:finalArray];
    
    
}

- (NSFetchRequest*)profileFetchRequestWithEmail:(NSString*)email
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyProfile" inManagedObjectContext:[APP_DELEGATE managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"email = %@", email];
    [fetchRequest setPredicate:predicate];
    
    return fetchRequest;
}

/**
 Invokes a web service call
 */
- (void) invokeWebService : (NSString*) urlString usingHttpMethod:(NSString*) httpMethod withRequestData: (NSDictionary*) data
forEmailId : (NSString*) emailId  forPassword : (NSString*) password checkSyncStatus: (BOOL) status
{
    
    NSURL *url = [NSURL URLWithString:urlString];
    _httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [_httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [_httpClient setDefaultHeader:HTTP_HEADER_ACCEPT value:HTTP_APPLICATION_JSON];
    _httpClient.parameterEncoding = AFJSONParameterEncoding;
    _isInitialSync = NO;
    
    NSLog(@"Accessing URL : %@", urlString);
    NSString *filepath = [url path];
    NSMutableURLRequest *request = [_httpClient requestWithMethod:httpMethod path:filepath parameters:data];
    [request setValue:emailId forHTTPHeaderField:HTTP_X_ASCCPE_USERNAME];
    [request setValue:[[RegistrationModel sharedInstance] uuid] forHTTPHeaderField:@"UUID"];
    [request setTimeoutInterval:3600];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:HTTP_APPLICATION_JSON, nil]];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
        {
           // NSLog(@"%@", JSON);
//            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:JSON options:0 error:nil];
//            NSString* jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
//            NSLog(@"Json String: %@", jsonString);
            
            [self processServerData:response JSON:JSON checkSyncStatus:status];
        }
        failure:^(NSURLRequest *request,
                  NSHTTPURLResponse *response, NSError *error, id JSON) {
            //NSLog(@"Request Failure Because %@",[error userInfo]);
            [APP_DELEGATE postApplicationEvent:APP_REQUEST_FAILURE];
        }
     ];
    [_httpClient enqueueHTTPRequestOperation:operation];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 903) {
        exit(0);
    }
}

//Populate data for each Entity in Core Data and build Relations
- (void) processJSONData :(NSDictionary*) jsonDict
{
     @autoreleasepool {
    _isInitialSync = NO;
    if (![[RegistrationModel sharedInstance] isRegistered]) {
        _isInitialSync = YES;
        NSArray* jsonArray = [jsonDict objectForKey:@"FileContent"];
        if (jsonArray && jsonArray.count > 5) { // Check if there are atleast 5 items
            [[RegistrationModel sharedInstance] setRegistrationComplete];
        } else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Download Data Failure" message:@"There seems to be an issue downloading the content,\t\ntap cancel button and restart application\t\nContact help desk if problem persists." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            alert.tag = 903;
            [alert show];
            return; //Invalid data, do not register
        }
    } else {
        if ([[ContentModel sharedInstance] isResetAll])
            _isInitialSync = YES;
    }
        
    //nslog(@"Generating data for MedicalCategory");
    [self populateCoreDataForEntity:@"MedicalCategory" forJSONResponse:jsonDict];
    
    //nslog(@"Generating data for ArcCategory");
    [self populateCoreDataForEntity:@"ArcCategory" forJSONResponse:jsonDict];
    
    //nslog(@"Generating data for ProcedureStep");
    [self populateCoreDataForEntity:@"ProcedureStep" forJSONResponse:jsonDict];
    
    //nslog(@"Generating data for SpecialityCategory");
    
    [self populateCoreDataForEntity:@"SpecialityCategory" forJSONResponse:jsonDict];
    
    //nslog(@"Generating data for ContentCategory");
    [self populateCoreDataForEntity:@"ContentCategory" forJSONResponse:jsonDict];
    
    //nslog(@"Generating data for ContentMapping");
    [self populateCoreDataForEntity:@"ContentMapping" forJSONResponse:jsonDict];
    
    //nslog(@"Generating data for Speciality");
    [self populateCoreDataForEntity:@"Speciality" forJSONResponse:jsonDict];
    
    //nslog(@"Generating data for Procedure");
    [self populateCoreDataForEntity:@"Procedure" forJSONResponse:jsonDict];
    
    //nslog(@"Generating data for Market");
    [self populateCoreDataForEntity:@"Market" forJSONResponse:jsonDict];
    
    //nslog(@"Generating data for ProductCategory");
    [self populateCoreDataForEntity:@"ProductCategory" forJSONResponse:jsonDict];
    
    //nslog(@"Generating data for Product");
    [self populateCoreDataForEntity:@"Product" forJSONResponse:jsonDict];
    
    //nslog(@"Generating data for CompProduct");
    [self populateCoreDataForEntity:@"CompProduct" forJSONResponse:jsonDict];
    
    //nslog(@"Generating data for FileContent");
    [self populateCoreDataForEntity:@"FileContent" forJSONResponse:jsonDict];
    
    //nslog(@"Generating data for Content");
    [self populateCoreDataForEntity:@"Content" forJSONResponse:jsonDict];
    
    //nslog(@"Generating data for Applications");
    [self populateCoreDataForEntity:@"Applications" forJSONResponse:jsonDict];
    
    //nslog(@"Generating data for ExtendedMetadata");
    [self populateCoreDataForEntity:@"ExtendedMetadata" forJSONResponse:jsonDict];
        
    //nslog(@"Generating data for Concern");
    [self populateCoreDataForEntity:@"Concern" forJSONResponse:jsonDict];
    
    //ProcedureStepToProductNew
    [self populateCoreDataForEntity:@"ProcedureStepToProductNew" forJSONResponse:jsonDict];
    
    //nslog(@"Generating data for Relations");
    [self populateCoreDataForEntity:@"Relations" forJSONResponse:jsonDict];
    
    //nslog(@"Generating Relation for Entitlements To Specialities");
    [[RegistrationModel sharedInstance] relateEntitlementsToSpecialities];

//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MedicalCategory"
//                                              inManagedObjectContext:[APP_DELEGATE managedObjectContext]];
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    [request setEntity:entity];
    
    //[self deleteAllFromEntityWithName:@"ContentSearch"];

    [[ContentSearchModel sharedInstance] loadContentSearch];
    
    //** Start **
    //This is to list total number of duplicate files across specialities...
    //    DownloadManager* downloadManager = [DownloadManager sharedManager];
    //    downloadManager.commonFiles = [NSNumber numberWithInt: commonFiles];
    //** End **
    
    
    DataValidator* dq = [[DataValidator alloc] init];
    [dq getContentByContentCategory];
    
    [[ContentSyncVerifier sharedInstance] disableBulbIcon];
    //nslog(@"%@...", [dq report]);
     }
}



/**
 Populates data for each single entity in Core Data.
 */
- (void) populateCoreDataForEntity :(NSString*) entityName forJSONResponse:(NSDictionary*) dataDict
{
    @autoreleasepool {
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    NSArray* jsonArray = [dataDict objectForKey:entityName];
    if ([entityName isEqualToString:@"Relations"]) {
        [self processRelations :jsonArray :context];
        return;
    }
    
    int cnt = 0;
    for (NSDictionary* data in jsonArray) {
        
        if (![self isNewInsert:data forEntity:entityName withManagedObjectContext:context]) continue; //If the status is "1" (Insert) and if Persistance store already has a record, ignore...
        
        //For delete, no need for insertNewObjectForEntityForName
        if (([[data objectForKey:ATTR_STATUS] intValue] == [[NSNumber numberWithInt:3] intValue])
            && ![entityName isEqualToString:ENT_FILECONTENT]) { //Ignore FileContent for delete, let download logic remove file+record
            [self executeCoreDataAction :data forManagedObjectContext:context forEntityName:entityName];
            continue;
        }
        
        //@TODO - This needs to moved to a common logic
        if ([[data objectForKey:ATTR_STATUS] intValue] == [[NSNumber numberWithInt:2] intValue]) { //For update, if record exists update and continue,
            NSArray* array = [self fetchManagedObjectByPrimaryKey : data
                                          withManagedObjectContext: context
                                                     forEntityName: entityName];
            if (array != nil && array.count > 0) {
                [self executeCoreDataAction :data forManagedObjectContext:context forEntityName:entityName];
                if ([entityName  isEqual: @"Speciality"])
                {
                    NSFetchRequest *entfetchRequest = [self fetchRequestWithEntity:@"MyEntitlement"];
                    NSNumber *splId = [data objectForKey:@"splId"];
                    NSPredicate *entpredicate;
                    entpredicate = [NSPredicate predicateWithFormat:@"splId = %d", [splId intValue]];
                    [entfetchRequest setPredicate:entpredicate];
                    NSArray* entArray = [[APP_DELEGATE managedObjectContext] executeFetchRequest:entfetchRequest error:nil];
                    MyEntitlement *myent;
                    if (entArray.count > 0)
                    {
                        myent = [entArray objectAtIndex:0];
                        myent.name = [data objectForKey:@"name"];
                        [APP_DELEGATE saveContext];
                    }
                }
                continue;
            }
        } //If the status is 2 and record doesn't exists add it.
        
        NSManagedObject *managedObject = [NSEntityDescription
                                          insertNewObjectForEntityForName:entityName
                                          inManagedObjectContext:context];
        
        NSDictionary *attributes = [[managedObject entity] attributesByName];
        for (NSString *attribute in attributes) {
            id value = [data objectForKey:attribute];
            if ([entityName isEqualToString:@"FileContent"] && _isInitialSync) {
                if ([attribute isEqualToString:@"initialSync"])
                   value = [NSNumber numberWithBool:YES];
            }

            if (value == nil || [value isKindOfClass:[NSNull class]]) {
                continue;
            }
            [self convertValueToProperType:attribute attributes:attributes forValue:&value];
            [managedObject setValue:value forKey:attribute];
        }
        
        [self executeCoreDataAction :managedObject forManagedObjectContext:context forEntityName:entityName];
        cnt++;
        //NSLog(@"%@", data);
    }
    NSLog(@"populateCoreDataForEntity :%@, cnt: %d", entityName, cnt);
    }
}

/**
 Check if a record already exists.
 */
- (BOOL) isNewInsert : (NSDictionary*) data forEntity : (NSString*) entityName withManagedObjectContext: (NSManagedObjectContext*) context
{
    NSArray *array = [self fetchManagedObjectByPrimaryKey:data withManagedObjectContext:context forEntityName:entityName];
    
    BOOL status = ([[data objectForKey:ATTR_STATUS] intValue] == [[NSNumber numberWithInt:1] intValue]);
    BOOL newRecord = ((array.count > 0 && status)? NO : YES);
    
    return newRecord;
}

/**
 Helper method
 */
- (NSString*)convertFirstLetterToLowerCase:(NSString *)relation
{
    return [relation stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[relation substringToIndex:1] lowercaseString]];
}

/**
 Processes each relation as per the relations sent by server in json array
 */
- (void) processRelations :(NSArray*) jsonArray :(NSManagedObjectContext* ) context
{
    NSError* error;
    for (NSDictionary* relations in jsonArray) {
        for (NSString* relation in [relations keyEnumerator]) {
            NSArray* relationEntities = [relation componentsSeparatedByString: @"To"];
            NSString* fromEntity = [relationEntities objectAtIndex:0];
            NSString* toEntity = [relationEntities objectAtIndex:1];
            //nslog(@"Executing relation for : %@", relation);
            if ([relation isEqualToString:@"ProductToProcedure"]) {
                //nslog(@"ProductToProcedure......./");
            }
            if (![self isValidRelation :relation]) continue;
            NSArray* values = [relations objectForKey:relation];
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            for (NSDictionary* subrelation in values) {
                
                NSArray* childObjects;
                NSArray* parentObject;
                for (NSString* relationAttribute in [subrelation keyEnumerator]) {  //This is for child objects
                    if ([[subrelation objectForKey:relationAttribute] isKindOfClass:[NSArray class]]) {
                        NSEntityDescription *entity = [NSEntityDescription entityForName:toEntity inManagedObjectContext:[APP_DELEGATE managedObjectContext]];
                        [fetchRequest setEntity:entity];
                        NSString* predicateString = [self buildPredicateWithFieldName :relationAttribute values:[subrelation objectForKey:relationAttribute]];
                        
                        if (predicateString == nil) continue;
                        
                        predicateString = [predicateString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        //nslog(@"predicateString ..... Child %@", predicateString);
                        NSPredicate *predicate;
                        predicate = [NSPredicate predicateWithFormat:predicateString];
                        [fetchRequest setPredicate:predicate];
                        childObjects = [[APP_DELEGATE managedObjectContext] executeFetchRequest:fetchRequest error:&error];
                    } else {                                                        //This is the parent object
                        NSEntityDescription *entity = [NSEntityDescription entityForName:fromEntity inManagedObjectContext:[APP_DELEGATE managedObjectContext]];
                        [fetchRequest setEntity:entity];
                        NSMutableArray* tempArray = [[NSMutableArray alloc] init];
                        [tempArray addObject:[subrelation objectForKey:relationAttribute]];
                        NSString* predicateString = [self buildPredicateWithFieldName :relationAttribute values:tempArray];
                        NSPredicate *predicate;
                        predicateString = [predicateString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        //nslog(@"predicateString ..... Parent %@", predicateString);
                        predicate = [NSPredicate predicateWithFormat:predicateString];
                        [fetchRequest setPredicate:predicate];
                        parentObject = [[APP_DELEGATE managedObjectContext] executeFetchRequest:fetchRequest error:&error];
                    }
                }
                @try {
                    if (parentObject && childObjects) {
                        
                        NSSet *tempSet = [NSSet setWithArray:childObjects];
                        NSSet *currentSet = [[parentObject objectAtIndex:0] valueForKey:[self convertFirstLetterToLowerCase:relation]];
                        
                        [[parentObject objectAtIndex:0] setValue: (currentSet != nil)? [currentSet setByAddingObjectsFromSet:tempSet]: tempSet forKey:[self convertFirstLetterToLowerCase:relation]];
                        
                        //nslog(@"ParentObject : %@, ChildSet : %@, RelationName : %@", parentObject, childObjects , [self convertFirstLetterToLowerCase:relation]);
                        
                       // if (![context save:&error]) //nslog(@"Couldn't save: %@", [error localizedDescription]);
                    }
                }
                @catch (NSException *exception) {
                    //nslog(@"Exception.... for Relation : %@, Exception : %@", [self convertFirstLetterToLowerCase:relation], exception);
                }
                @finally {
                    
                }
            }
        }
    }
}

/**
 *
 */
- (NSString*) buildPredicateWithFieldName : (NSString*) fieldName values :(NSArray*) values
{
    
    BOOL predicateWithSingleQuote = [self isFieldNameRequiresValueInSingleQuote:fieldName]; //Some string values require single quotes
    NSString* predicateString;
    if (values != nil && values.count > 0) {
        if (!predicateWithSingleQuote) {
            predicateString = [NSString stringWithFormat:@"(%@ == %@)", fieldName, values[0]];
            for (int i = 1; i < values.count; i++) {
                predicateString = [predicateString stringByAppendingString:[NSString stringWithFormat:@" OR (%@ == %@)", fieldName, values[i]]];
            }
        } else {
            predicateString = [NSString stringWithFormat:@"(%@ == '%@')", fieldName, values[0]];
            for (int i = 1; i < values.count; i++) {
                predicateString = [predicateString stringByAppendingString:[NSString stringWithFormat:@" OR (%@ == '%@')", fieldName, values[i]]];
            }
        }
    } else {
        //nslog(@"Values for Field Name %@ is nil", fieldName);
    }
    return predicateString;
}

- (BOOL) isFieldNameRequiresValueInSingleQuote : (NSString*) fieldName
{
    
    if ([fieldName isEqualToString:ATTR_PATH]) {
        return TRUE;
    }
    return FALSE;
}

- (NSFetchRequest*)fetchRequestWithEntity:(NSString*)entityName
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[APP_DELEGATE managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    return fetchRequest;
}

- (FileContent*) fetchFileContentByCntId : (NSString*) path withLike:(BOOL) likeValues
{
    NSError* error;
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"FileContent"];
    NSPredicate *predicate;
    
    if (likeValues)
        predicate = [NSPredicate predicateWithFormat:@"path BEGINSWITH[cd] %@", path];
    else
        predicate = [NSPredicate predicateWithFormat:@"path = %@", path];

    [fetchRequest setPredicate:predicate];
    
    NSArray* items = [[APP_DELEGATE managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    return (items.count > 0 ? [items objectAtIndex:0] : nil);
}

- (NSArray*) fetchFileContentByCntId : (NSNumber*) cntId
{
    NSError* error;
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"FileContent"];
    
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"cntId = %@", cntId];
    [fetchRequest setPredicate:predicate];
    
    NSArray* items = [[APP_DELEGATE managedObjectContext] executeFetchRequest:fetchRequest error:&error];

    return items;
}


- (void)deleteFiles:(Content *)content entityName:(NSString *)entityName :(BOOL) contentDelete {
    
    if ([[entityName lowercaseString] isEqualToString:@"content"]) {
        if (contentDelete) {
           [self deleteContent : content];
           return;
        }
        
        NSArray* fileContents = [self fetchFileContentByCntId:content.cntId];
        for (FileContent* fileContent in fileContents) {
            if (fileContent != nil && [fileContent.path rangeOfString:@"thumb"].location == NSNotFound) {
                [self deleteContent : content];
            }
        }
    }
}

/**
 */
- (void) deleteContent :(Content*) content {

    //Delete a folder (ex: set of files in html page location)
    if ([[content.path pathExtension] isEqual: @""]) {
        //nslog(@"...Deleting.........%@", content.path);
        //Check if mime type is application/zip, if yes, delete complete folder.
        if ([[content.mime lowercaseString] isEqualToString:@"application/zip"]) {
            [[DownloadManager sharedManager] removeFileAtPath:content.path];
            if([content.thumbnailImgPath isEqualToString:@""]){}
            else
            {
                [[DownloadManager sharedManager] removeFileAtPath:content.thumbnailImgPath];
            }
                
                
        }
    } else {
        //Delete only file
        //nslog(@"...Deleting.........%@", content.path);
        [[DownloadManager sharedManager] removeFileAtPath:content.path];
        if([content.thumbnailImgPath isEqualToString:@""]){}
        else
        {
            [[DownloadManager sharedManager] removeFileAtPath:content.thumbnailImgPath];
        }
    }
}

/**
 *
 */
- (void) executeCoreDataAction :(id) managedObject  forManagedObjectContext:(NSManagedObjectContext* ) context
                  forEntityName:(NSString*) entityName
{
    
    NSError *error;
    if ([[managedObject valueForKey:ATTR_STATUS] intValue] == 1) {        //Save
        if (![context save:&error])
        {
            NSLog(@"Couldn't save: %@", [error localizedDescription]);
        }
    } else if ([[managedObject valueForKey:ATTR_STATUS] intValue] == 2) { //Update
        
        NSArray* array = [self fetchManagedObjectByPrimaryKey : managedObject
                                      withManagedObjectContext: context
                                                 forEntityName: entityName];
        
        if (array != nil && array.count > 0)
            [self deleteFiles:array[0] entityName:entityName :NO]; //Since this is update, we must check the files in FileContent
        
        if (array != nil && array.count > 0) {
            [self updateEntityFrom:managedObject forEntityName:entityName toManagedObject:[array objectAtIndex:0]];
            if (![context save:&error]) NSLog(@"Couldn't save: %@", [error localizedDescription]);
        }
        else {
            NSLog(@"Record doesnt exist for update, so add it..");
            if (![context save:&error]) NSLog(@"Couldn't save: %@", [error localizedDescription]);
        }
        
    } else if ([[managedObject valueForKey:ATTR_STATUS] intValue] == 3) {  //Delete
        
        if ([entityName isEqualToString:ENT_FILECONTENT]) {
            //nslog(@"entityName .... entityName ");
            if (![context save:&error]) NSLog(@"Couldn't save: %@", [error localizedDescription]); //Do not process delete for FileContent as we process within downloads.
            return;
        }
        
        NSArray* array = [self fetchManagedObjectByPrimaryKey : managedObject
                                      withManagedObjectContext: context
                                                 forEntityName: entityName];
        
        if (array != nil && array.count > 0) //Delete files if entityname is content
            [self deleteFiles:array[0] entityName:entityName :YES]; //Since this is delete, delete the file if it exists in Content

        if ([[entityName lowercaseString] isEqualToString:@"product"]) {
            NSArray* cntMappings = [self fetchContentMappingWithMedId : [managedObject valueForKey:@"prodId"]];
            if (cntMappings != nil && cntMappings.count > 0) {
                for (ContentMapping* cntMap in cntMappings) {
                    [context deleteObject:cntMap]; //should return only one object
                }
            } else {
                //nslog(@"Invalid Data from Server, %@ ", managedObject);
            }
        }
         if ([[entityName lowercaseString] isEqualToString:@"content"])
         {
             
         //// ---- removing in contentsearch
        NSError* error;
        NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"ContentSearch"];
        
        NSPredicate *predicate;
        predicate = [NSPredicate predicateWithFormat:@"cntId = %d", [[managedObject valueForKey:@"cntId"] intValue]];
        [fetchRequest setPredicate:predicate];
        
            NSArray* cntSearchArray = [[APP_DELEGATE managedObjectContext] executeFetchRequest:fetchRequest error:&error];
             if (cntSearchArray != nil && cntSearchArray.count > 0) {
                 for (ContentSearch* cntSea in cntSearchArray) {
                     [context deleteObject:cntSea]; //should return only one object
                 }
             } else {
                 //nslog(@"Invalid Data from Server, %@ ", managedObject);
             }
             
             
             
             //// ---- removing in share
             
             NSFetchRequest *fetchRequest2 = [self fetchRequestWithEntity:@"SharedLink"];
             
             NSPredicate *predicate2;
             predicate2 = [NSPredicate predicateWithFormat:@"cntId = %d", [[managedObject valueForKey:@"cntId"] intValue]];
             [fetchRequest2 setPredicate:predicate2];
             
             NSArray* shareArray = [[APP_DELEGATE managedObjectContext] executeFetchRequest:fetchRequest2 error:&error];
             if (shareArray != nil && shareArray.count > 0) {
                 for (SharedLink* seaObj in shareArray) {
                     [context deleteObject:seaObj]; //should return only one object
                 }
             } else {
                 //nslog(@"Invalid Data from Server, %@ ", managedObject);
             }
             
             
             
    }
        if (array != nil && array.count > 0) {
            [context deleteObject:[array objectAtIndex:0]]; //should return only one object
            if (![context save:&error]) NSLog(@"Couldn't save: %@", [error localizedDescription]);
        }
    }
}

/**
 */
- (NSArray*) fetchContentMappingWithMedId : (NSNumber*) medId
{
    NSError* error;
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"ContentMapping"];
    
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"medId = %d", [medId intValue]];
    [fetchRequest setPredicate:predicate];

    return [[APP_DELEGATE managedObjectContext] executeFetchRequest:fetchRequest error:&error];
}


/**
 *
 */
- (NSArray*) fetchManagedObjectByPrimaryKey :(id) managedObject
                    withManagedObjectContext:(NSManagedObjectContext* ) context
                               forEntityName:(NSString*) entityName {
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    fetch.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSString* predicateString;
    if ([[self getPrimaryKeyAttribute :entityName] isEqualToString:ATTR_PATH]) //Handle special case for path (String)
        predicateString = [NSString stringWithFormat:@"%@ == '%@'", [self getPrimaryKeyAttribute :entityName], [managedObject valueForKey:[self getPrimaryKeyAttribute :entityName]]];
    else
        predicateString = [NSString stringWithFormat:@"%@ == %@", [self getPrimaryKeyAttribute :entityName], [managedObject valueForKey:[self getPrimaryKeyAttribute :entityName]]];
    
    predicateString = [predicateString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    fetch.predicate = [NSPredicate predicateWithFormat:predicateString];
    NSArray *array = [context executeFetchRequest:fetch error:nil];
    return array;
}

/**
 
 */
- (void) updateEntityFrom :(id) from forEntityName:(NSString*) entityName toManagedObject:(NSManagedObject*) to {
    
    NSDictionary *attributes = [[to entity] attributesByName];
    for (NSString *attribute in attributes) {
        id value = [from valueForKey:attribute];
        if (value == nil) {
            continue;
        }
        [self convertValueToProperType:attribute attributes:attributes forValue:&value];
        [to setValue:value forKey:attribute];
    }
}

/**
 
 */
- (void)convertValueToProperType:(NSString *)attribute attributes:(NSDictionary *)attributes forValue:(id *)value
{
    NSAttributeType attributeType = [[attributes objectForKey:attribute] attributeType];
    if ((attributeType == NSStringAttributeType) && ([*value isKindOfClass:[NSNumber class]])) {
        *value = [*value stringValue];
    } else if (((attributeType == NSInteger16AttributeType) || (attributeType == NSInteger32AttributeType) || (attributeType == NSInteger64AttributeType) || (attributeType == NSBooleanAttributeType)) && ([*value isKindOfClass:[NSString class]])) {
        *value = [NSNumber numberWithInteger:[*value  integerValue]];
    } else if ((attributeType == NSFloatAttributeType) && ([*value isKindOfClass:[NSString class]])) {
        *value = [NSNumber numberWithDouble:[*value doubleValue]];
    } else if ((attributeType == NSDateAttributeType) && ([*value isKindOfClass:[NSString class]])) {
        *value = [*value stringByReplacingOccurrencesOfString:@"\"<null>\"" withString:@""];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        NSDate* dateFromString = [dateFormatter dateFromString:*value];
        *value = dateFromString;
    }
}

/**
 
 */
- (NSString*) getPrimaryKeyAttribute : (NSString*) entity {
    
    if ([entity isEqualToString:@"Product"])
        return @"prodId";
    else if ([entity isEqualToString:@"Procedure"])
        return @"procId";
    else if ([entity isEqualToString:@"ProcedureStep"])
        return @"procStepId";
    else if ([entity isEqualToString:@"ContentCategory"])
        return @"contentCatId";
    else if ([entity isEqualToString:@"ArcCategory"])
        return @"arcCatId";
    else if ([entity isEqualToString:@"Speciality"])
        return @"splId";
    else if ([entity isEqualToString:@"Content"])
        return @"cntId";
    else if ([entity isEqualToString:@"MedicalCategory"])
        return @"medCatId";
    else if ([entity isEqualToString:@"ContentMapping"])
        return @"cntMapId";
    else if ([entity isEqualToString:@"CompProduct"])
        return @"compProdId";
    else if ([entity isEqualToString:@"Market"])
        return @"mktId";
    else if ([entity isEqualToString:@"SpecialityCategory"])
        return @"splCatId";
    else if ([entity isEqualToString:@"ProductCategory"])
        return @"prodCatId";
    else if ([entity isEqualToString:@"Concern"])
        return @"concernId";
    else if ([entity isEqualToString:@"ExtendedMetadata"])
        return @"cntExtFieldId";
    else if ([entity isEqualToString:@"FileContent"])
        return @"path";
    else if ([entity isEqualToString:@"ProcedureStepToProductNew"])
        return @"prodProcStepId";
    else if ([entity isEqualToString:@"Applications"])
        return @"appId";
    return nil;
}

/**
 */
- (void) deleteAllFromEntityWithName:(NSString*)entityName
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[APP_DELEGATE managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [[APP_DELEGATE managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            for (NSManagedObject *item in items)
            {
                [[APP_DELEGATE managedObjectContext] deleteObject:item];
            }
            [APP_DELEGATE saveContext];
        }
    }
}

/**
 *
 */
- (BOOL) deleteSpecialityById : (NSNumber*) splId
      withManagedObjectContext:(NSManagedObjectContext* ) context {
    
    //Speciality
    NSMutableArray* values = [[NSMutableArray alloc] init];
    [values addObject:[NSNumber numberWithInt:[splId intValue]]];
    NSArray *specialities = [self fetchManagedObjectByPrimaryKeys :values withManagedObjectContext:context forEntityName:ENT_SPECIALITY];
    if (specialities != nil && specialities.count > 0) {
        
        //Procedure
        NSMutableArray* specialityIds = [self prepareValuesArrayFromManagedObjects :specialities :@"Procedure" :@"splId"];
        NSArray* procedures = [self fetchByForeignKey:ATTR_SPLID :@"Procedure" :context :specialityIds];
        if (procedures != nil && procedures.count > 0) {
            
            //Product
            NSMutableArray* procedureIds = [self prepareValuesArrayFromManagedObjects :procedures :@"Product" :@"procId"];
            NSArray* products = [self fetchByForeignKey:ATTR_SPLID :@"Product" :context :procedureIds];
            for (NSManagedObject* product in products)
                [context deleteObject:product];
        }
        for (NSManagedObject* speciality in specialities)
            [context deleteObject:speciality];
        
        NSError* error;
        if (![context save:&error]) {
            //nslog(@"Couldn't save: %@", [error localizedDescription]);
            return false;
        }
    }
    
    //Delete data from Content Mapping and Content Entities
    //Delete physical files
    return true; // All Good
}

- (NSArray*) fetchByForeignKey :(NSString*) foreignKey :(NSString*) entityName :(NSManagedObjectContext* ) context :(NSArray*) values {
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    fetch.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSString* predicateString;
    NSString* predicate = [self buildPredicateWithFieldName:foreignKey values:values];
    predicateString = [predicate stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    fetch.predicate = [NSPredicate predicateWithFormat:predicateString];
    NSArray *array2 = [context executeFetchRequest:fetch error:nil];
    return array2;
}

- (NSMutableArray*) prepareValuesArrayFromManagedObjects :(NSArray*) managedObjects :(NSString*) entityName  : (NSString*) key {
    NSMutableArray* values = [[NSMutableArray alloc] init];
    for (id entity in managedObjects) {
        NSNumber* value = [entity valueForKey:key];
        [values addObject:value];
    }
    return values;
}

/**
 */
- (NSArray*) fetchManagedObjectByPrimaryKeys :(NSArray*) values
                     withManagedObjectContext:(NSManagedObjectContext*) context
                                forEntityName:(NSString*) entityName
{
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    fetch.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSString* predicateString;
    
    NSString* predicate = [self buildPredicateWithFieldName:[self getPrimaryKeyAttribute :entityName] values:values];
    
    predicateString = [predicate stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    fetch.predicate = [NSPredicate predicateWithFormat:predicate];
    NSArray *array = [context executeFetchRequest:fetch error:nil];
    return array;
}

/**
 */
- (BOOL) isValidRelation : (NSString*) relationName {
    
    if ([relationName isEqualToString:REL_SPECIALITYTOPROCEDURE] ||
        [relationName isEqualToString:REL_PRODUCTTOPROCEDURE] ||
        [relationName isEqualToString:REL_PROCEDURETOPRODUCT] ||
        [relationName isEqualToString:REL_MARKETTOPRODUCT] ||
        [relationName isEqualToString:REL_PROCEDURETOPROCEDURESTEP] ||
        [relationName isEqualToString:REL_PROCEDURESTEPTOPRODUCT] ||
        [relationName isEqualToString:REL_PRODUCTTOPROCEDURESTEP] ||
        [relationName isEqualToString:REL_PROCEDURESTEPTOCONCERN] ||
        [relationName isEqualToString:REL_CONCERNTOPROCEDURESTEP] ||
        [relationName isEqualToString:REL_CONCERNTOPRODUCT] ||
        [relationName isEqualToString:REL_PRODUCTTOCONCERN] ||
        [relationName isEqualToString:REL_PROCEDURESTEPTOPROCEDURE] ||
        [relationName isEqualToString:@"productToProdCat"]
        /*|| [relationName isEqualToString:@"ProductToCompProduct"]*/
        )
    {
        return TRUE;
    }
    return FALSE;
}

@end