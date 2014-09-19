//
//  ContentModel.m
//  edge
//
//  Created by iPhone Developer on 6/30/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "ContentModel.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "Product.h"
#import "Procedure.h"
#import "Speciality.h"
#import "MyProfile.h"
#import "MyFavorite.h"
#import "MyEntitlement.h"
#import "PresentationMaster.h"
#import "RegistrationModel.h"
#import "DataSyncServiceHelper.h"
#import "ContentMapping.h"
#import "Content.h"
#import "SearchResultsVC.h"
#import "MedicalCategory.h"
#import "ContentSearch.h"
//from arcDev
#import "SpecialtyHotSpot.h"
//
#define APP_DELEGATE (AppDelegate*)[[UIApplication sharedApplication] delegate]

@interface ContentModel ()
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, assign) NSManagedObjectContext *managedObjectContext;
@end

@implementation ContentModel

+ (ContentModel*) sharedInstance
{
    static ContentModel *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[ContentModel alloc] init];
        // Do any other initialisation stuff here
        instance.appDelegate = [UIApplication sharedApplication].delegate;
        instance.managedObjectContext = instance.appDelegate.managedObjectContext;
        
        // dump specific core data objects/entity to console log
        //[instance dumpForDebugAssist];
        
        //from arcDev
        [instance createDummySpecialtyHotSpots];
        //


    });
    
    return instance;
    
}

- (NSString*) addAppDocumentsPathToPath:(NSString*)path
{
    NSString *basePath;
    
    basePath = [NSString stringWithFormat:@"%@/%@%@", NSHomeDirectory(), @"Documents", path];
    
    return basePath;
}


- (void) deleteAllFromEntityWithName:(NSString*)entityName
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            for (NSManagedObject *item in items)
            {
                [self.managedObjectContext deleteObject:item];
            }
            
            [self.appDelegate saveContext];
        }
    }
    
}

- (void) callClearMasterData:(BOOL)runInBackground
{
    if (!runInBackground)
    {
        [self clearMasterData];
    } else{
        [self performSelectorInBackground:@selector(clearMasterData) withObject:nil];
    }
}

- (void) clearMasterData
{
    // first turn off undo
    [[[self managedObjectContext] undoManager] disableUndoRegistration];
    
    //
    // Product Catalog entities
    //
    //nslog(@"Removing data from MedicalCategory");
    [self deleteAllFromEntityWithName:@"MedicalCategory"];
    
    //nslog(@"Removing data from ArcCategory");
    [self deleteAllFromEntityWithName:@"ArcCategory"];
    
    //nslog(@"Removing data from ProcedureStep");
    [self deleteAllFromEntityWithName:@"ProcedureStep"];
    
    //nslog(@"Removing data from SpecialityCategory");
    [self deleteAllFromEntityWithName:@"SpecialityCategory"];
    
    //nslog(@"Removing data from Content");
    [self deleteAllFromEntityWithName:@"Content"];
    
    //nslog(@"Removing data from ContentCategory");
    [self deleteAllFromEntityWithName:@"ContentCategory"];
    
    //nslog(@"Removing data from ContentMapping");
    [self deleteAllFromEntityWithName:@"ContentMapping"];
    
    //nslog(@"Removing data from Speciality");
    [self deleteAllFromEntityWithName:@"Speciality"];
    
    //nslog(@"Removing data from Procedure");
    [self deleteAllFromEntityWithName:@"Procedure"];
    
    //nslog(@"Removing data from Market");
    [self deleteAllFromEntityWithName:@"Market"];
    
    //nslog(@"Removing data from ProductCategory");
    [self deleteAllFromEntityWithName:@"ProductCategory"];
    
    //nslog(@"Removing data from Product");
    [self deleteAllFromEntityWithName:@"Product"];
    
    //nslog(@"Removing data from CompProduct");
    [self deleteAllFromEntityWithName:@"CompProduct"];
    
    //nslog(@"Removing data from FileContent");
    [self deleteAllFromEntityWithName:@"FileContent"];
    
    // re-enable undo
    [[[self managedObjectContext] undoManager] enableUndoRegistration];
    
}

- (void) clearUserData
{
    // first turn off undo
    [[[self managedObjectContext] undoManager] disableUndoRegistration];

    //
    // User entitites
    //
//     //nslog(@"Removing data from MyProfile");
//     [self deleteAllFromEntityWithName:@"MyProfile"];
//     
//     //nslog(@"Removing data from MyEntitlement");
//     [self deleteAllFromEntityWithName:@"MyEntitlement"];
    
     ////nslog(@"Removing data from MyFavorite");
     //[self deleteAllFromEntityWithName:@"MyFavorite"];
    
    ////nslog(@"Removing data from Surgeon");
    //[self deleteAllFromEntityWithName:@"Surgeon"];
    
//     //nslog(@"Removing data from MyForm");
//     [self deleteAllFromEntityWithName:@"MyForm"];
   // [self deleteAllFromEntityWithName:@"Tracking"];
    
    // re-enable undo
    [[[self managedObjectContext] undoManager] enableUndoRegistration];
    
}

- (void) dumpForDebugAssist
{
    /*
    {
        NSFetchedResultsController *frc = [self frcWithEntityName:@"ArcCategory" sortKey:@"name" predicate:nil];
        //nslog(@"ArcCategory");
        for (NSManagedObject *mo in frc.fetchedObjects)
        {
            //nslog(@"%@", mo);
        }
    }
    
    {
        NSFetchedResultsController *frc = [self frcWithEntityName:@"ProcedureStep" sortKey:@"name" predicate:nil];
        //nslog(@"ArcCategory");
        for (NSManagedObject *mo in frc.fetchedObjects)
        {
            //nslog(@"%@", mo);
        }
    }
    
    //NSFetchRequest *fr = [self fetchRequestWithEntity:@"MedicalCategory"];
    //NSFetchRequest *fr = [self fetchRequestWithEntity:@"Market"];
      */
    
//    {
//        NSFetchedResultsController *frc = [self frcWithEntityName:@"Speciality" sortKey:@"name" predicate:nil];
//        //nslog(@"Speciality");
//        for (Speciality *speciality in frc.fetchedObjects)
//        {
//            //nslog(@"Speciality name: %@ splId:%d", speciality.name, [speciality.splId intValue]);
//        }
//    }
    
//    {
//        NSFetchedResultsController *frc = [self frcWithEntityName:@"MedicalCategory" sortKey:@"name" predicate:nil];
//        //nslog(@"MedicalCategory");
//        for (MedicalCategory *medicalCategory in frc.fetchedObjects)
//        {
//            //nslog(@"MedicalCategory name: %@ medCatId:%d", medicalCategory.name, [medicalCategory.medCatId intValue]);
//        }
//    }

    {
        NSFetchedResultsController *frc = [self frcWithEntityName:@"ContentMapping" sortKey:@"cntMapId" predicate:nil];
        //nslog(@"ContentMapping");
        for (ContentMapping *contentMapping in frc.fetchedObjects)
        {
            //nslog(@"ContentMapping cntMapId: %d medCatId:%d", [contentMapping.cntMapId intValue], [contentMapping.medCatId intValue]);
        }
    }

}


- (void) callDataSyncServiceWithUUID:(NSString*)uuid entitlements:(NSArray*)entitlements
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:uuid forKey:@"uuid"];
    
    NSMutableArray *array = [NSMutableArray array];
    for (MyEntitlement *myEntitlement in entitlements)
    {
        //nslog(@"myEntitlement name: %@ status: %d", myEntitlement.name, [myEntitlement.status intValue]);
        
        if ([myEntitlement.status intValue] == kEntitlementStatusEnabled)
        {
            [array addObject:myEntitlement.splId];
        }
    }
    [dict setObject:array forKey:@"splIds"];
    
//    for (NSString *key in dict.allKeys)
//    {
//        //nslog(@"key: %@ value: %@", key, [dict objectForKey:key]);
//    }
    
    DataSyncServiceHelper *dataSync = [[DataSyncServiceHelper alloc] init];
    [dataSync getSyncDataWithParams:dict];
}

- (void)loadMasterData
{
    // load master data content
    NSString *uuid = [[RegistrationModel sharedInstance] uuid];
    NSArray *myEntitlements = [[RegistrationModel sharedInstance].profile.myProfileToMyEntitlement allObjects];
    //nslog(@"callDataSyncServiceWithUUID: %@ myEntitlements: %@", uuid, myEntitlements);
    [self callDataSyncServiceWithUUID:uuid entitlements:myEntitlements];
    //nslog(@"complete callDataSyncServiceWithUUID.");
    
}

// used first sync after successful registration.
- (void) syncMasterDataInBackground
{
    //nslog(@"syncMasterDataInBackground.");
 
    @autoreleasepool {
        
        // first clear content
        //nslog(@"clearing master data first.");
        [self clearMasterData];
        
        [self loadMasterData];
        
    }
    
}

- (void) syncMasterData
{
    //nslog(@"syncMasterData.");
    
    [self performSelectorInBackground:@selector(syncMasterDataInBackground) withObject:nil];
}

// used first sync after successful registration.
- (void) syncDataInBackground
{
    //nslog(@"syncDataInBackground.");
    
    @autoreleasepool {
        
        [self loadMasterData];
    }
    
}

// used to sync content.
- (void) syncDataInBackgroundWithEntitlements : (NSArray*) myEntitlements
{
    //nslog(@"syncDataInBackgroundWithEntitlements.");
    // load master data content
    NSString *uuid = [[RegistrationModel sharedInstance] uuid];
    //nslog(@"callDataSyncServiceWithUUID: %@ myEntitlements: %@", uuid, myEntitlements);
    [self callDataSyncServiceWithUUID:uuid entitlements:myEntitlements];
    //nslog(@"complete callDataSyncServiceWithUUID.");
}

- (void) syncData
{
    [self performSelectorInBackground:@selector(syncDataInBackground) withObject:nil];
}

#pragma mark -
//
// web service response related
//
- (BOOL) parseRegistrationWithResponseDict:(NSDictionary*)dict params:(NSDictionary*)params
{
    //nslog(@"parseRegistrationWithResponseDict");
    
    BOOL validReg = NO;
    
    /*
     {
     "header" : {
     "statusCode" : 200,
     "status" : "success",
     "message" : "OK"
     },
     "body" : {
     "email" : "demo@example.com",
     "role" : "testRole",
     "market" : "USA",
     "reptype" : "testRepType",
     "splIds" : [ {
     "splId" : 1,
     "name" : "Bariatric Surgery"
     }, {
     "splId" : 2,
     "name" : "Cardiovascular Surgery"
     }, {
     "splId" : 3,
     "name" : "Gynecologic Surgery"
     } ]
     }
     }
     */
    
    NSDictionary *header = [dict objectForKey:@"header"];
    NSNumber *statusCode = [header objectForKey:@"statusCode"];
    
    if ([statusCode intValue] == 200)
    {
        validReg = YES;
        
        NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:[dict objectForKey:@"body"]];
        
        // add the first/last name to the response dictionary
        [body setObject:[params objectForKey:@"firstName"] forKey:@"firstName"];
        [body setObject:[params objectForKey:@"lastName"] forKey:@"lastName"];
        
        [[RegistrationModel sharedInstance] updateRegistration:body];
        
    } else{
        _registrationResponseHeader = header;
        
    }
    
    return validReg;
}

/*
 The registration web service is now available. The details are enlisted below:
 URL: http://eprodevbox.com/regapi/processregdata
 Method: POST
 Header Variables:
 1) Content-Type: application/json
 Body: It is Json format as follows:
 {
 "uuid":"1234567890",
 "email": "demo@example.com",
 "firstName": "firstName",
 "lastName": "lastName",
 "state" : "state",
 "department" : "department",
 "division" : "division"
 }
 Sample Response:
 {
 "header" : {
 "statusCode" : 200,
 "status" : "success",
 "message" : "OK"
 },
 "body" : {
 "email" : "demo@example.com",
 "role" : "testRole",
 "market" : "USA",
 "reptype" : "testRepType",
 "splIds" : {
 "0" : 1,
 "1" : 2,
 "2" : 3
 }
 }
 }
 
 Response on Error:
 {
 "header" : {
 "statusCode" : 4,
 "status" : "error",
 "message" : "Syntax error in JSON"
 }
 }
 
 Response on Success:
 {
 "header" : {
 "statusCode" : 200,
 "status" : "success",
 "message" : "OK"
 },
 "body" : {
 Actual data for the response
 }
 }
 */

- (void) registrationWithParams:(NSDictionary*)params
{
    /*
     NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
     [params setObject:@"1234567890" forKey:@"uuid"];
     [params setObject:@"demo@example.com" forKey:@"email"];
     [params setObject:@"firstName" forKey:@"firstName"];
     [params setObject:@"lastName" forKey:@"lastName"];
     [params setObject:@"state" forKey:@"state"];
     [params setObject:@"department" forKey:@"department"];
     [params setObject:@"division" forKey:@"division"];
     */
    
    NSString* serverBaseURL = WEB_SERVICE_BASE_SERVER;
    
//    NSString* defaultServerURL = [APP_DELEGATE settingsServerURL];
//    if (defaultServerURL != nil && defaultServerURL.length > 0)
//        serverBaseURL = defaultServerURL;
    
    NSString *wsUrlStr = [NSString stringWithFormat:@"%@%@", serverBaseURL,
                          POST_REGISTRATION_SERVICE];
    
    //nslog(@"registration url: %@", wsUrlStr);
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:serverBaseURL]];
    
    [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [httpClient setDefaultHeader:@"Accept" value:@"application/json"];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:POST_REGISTRATION_SERVICE parameters:params];
    
    //[request setTimeoutInterval:DEFAULT_WEB_SERVICE_TIMEOUT];
    
#warning user/pwd hard-coded values in HTTP headers
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[params objectForKey:@"email"] forHTTPHeaderField:@"USERNAME"];
    [request setValue:[params objectForKey:@"uuid"] forHTTPHeaderField:@"UUID"];
    
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"application/json"]];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/json"]];
    
    AFJSONRequestOperation *op = [AFJSONRequestOperation
                                  JSONRequestOperationWithRequest:request
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                      //nslog(@"%@ success response at: %@", wsUrlStr, [NSDate date]);
                                      ////nslog(@"response: %@", (NSString*)JSON);
                                      if (![ContentModel sharedInstance].isResetAll) {
                                          if ([self parseRegistrationWithResponseDict:JSON params:params])
                                          {
                                              //nslog(@"parseRegistrationWithResponseDict success.");
                                              
                                              NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
                                              
                                              [userDefaults setValue:[params objectForKey:@"firstName"] forKey:@"firstName"];
                                              [userDefaults setValue:[params objectForKey:@"lastName"] forKey:@"lastName"];
                                              [userDefaults setValue:[params objectForKey:@"email"] forKey:@"email"];
                                              [userDefaults setValue:@"" forKey:@"phone"];
                                              
                                              
                                              [self.appDelegate postApplicationEvent:APP_EVENT_REGISTRATION_SUCCESS];
                                          } else
                                          {
                                              //nslog(@"parseRegistrationWithResponseDict error response.");
                                              [self.appDelegate postApplicationEvent:APP_EVENT_REGISTRATION_ERROR_RESPONSE];
                                          }
                                      } else {
                                          [self.appDelegate postApplicationEvent:APP_EVENT_REGISTRATION_SUCCESS];
                                      }
                                  }
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                      //nslog(@"failure response %@  \n error %@ \n JSON %@", response, error, JSON);
                                      [self.appDelegate postApplicationEvent:APP_EVENT_REGISTRATION_FAILURE];
                                  }];
    
    //nslog(@"making %@ call at: %@", wsUrlStr, [NSDate date]);
    
    [httpClient enqueueHTTPRequestOperation:op];
}

- (UIImage*) thumbnailImageForContentTitle:(NSString*)contentTitle
{
    UIImageView *thumbnailImageView;
    thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 112, 82)];
    UILabel * contenttitle;
    
    contenttitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 112, 82)];
    
    contenttitle.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
    contenttitle.text = contentTitle;
    contenttitle.numberOfLines = 0;
    contenttitle.font = [UIFont fontWithName:@"Arial" size:14];
    contenttitle.textAlignment = NSTextAlignmentCenter;
    [thumbnailImageView addSubview:contenttitle];
    UIGraphicsBeginImageContext(thumbnailImageView.bounds.size);
    [thumbnailImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *bitmap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return bitmap;
}

- (UIImage*) thumbnailImageForContentCatId:(NSNumber*)contentCatId
{
    UIImage *image;
    
    switch ([contentCatId intValue])
    {
        case kSpecialtyVideo:
        case kProcedureVideo:
        case kProductVideo:
        case kProductCompetitiveInfoVideos:
            image = [UIImage imageNamed:@"video"];
            break;
        case kSpecialtyMessage:
        case kProcedureMessage:
        case kProductMessage:
        case kProductClinicalMessage:
        case kProductNonClinicalMessage:
            image = [UIImage imageNamed:@"message"];
            break;
        case kSpecialtyArticle:
        case kProcedureArticle:
        case kProductArticle:
        case kProductClinicalArticles:
        case kProductClinicalArticlesCharts:
        case kProductClinicalArticlesOthers:
            image = [UIImage imageNamed:@"article"];
            break;
            
        default:
            image = [UIImage imageNamed:CONTENT_MISSING_IMAGE];
            break;
    }
    
    return image;
}

//
// Core data methods
//

- (NSFetchRequest*)fetchRequestWithEntity:(NSString*)entityName
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    return fetchRequest;
}

- (NSFetchedResultsController*) frcWithEntityName:(NSString*)entityName sortKey:(NSString*)sortKey predicate:(NSPredicate*)predicate
{
    // Set up the fetched results controller.

    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:entityName];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:40];
    
    // Edit the sort key as appropriate.
    if (sortKey)
    {
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:
                                    sortDescriptor1,
                                    nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
    }
    
    if (predicate)
    {
        [fetchRequest setPredicate:predicate];
    }
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSString *sectionNameKeyPath = nil;
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
                                                            initWithFetchRequest:fetchRequest
                                                            managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionNameKeyPath
                                                            cacheName:nil];
    
	NSError *error = nil;
	if (![fetchedResultsController performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	     */
	    //nslog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    //nslog(@"fetchedObjects.count: %d", fetchedResultsController.fetchedObjects.count);
    
    return fetchedResultsController;
    
}

- (NSFetchedResultsController*) products
{
    return [self frcWithEntityName:@"Product" sortKey:@"name" predicate:nil];
    
}

- (NSFetchedResultsController*) productsWithSpecialityIds:(NSArray*)splIds andProcedureIds:(NSArray*)procIds  andProductCategoryIds:(NSArray*)prodCatIds
{
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Product"];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:40];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:
                                sortDescriptor1,
                                nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"prodCatId IN %@ && ANY productToProcedure.procId IN %@ && ANY productToProcedure.procedureToSpeciality.splId IN %@", prodCatIds, procIds, splIds];
    //nslog(@"prodCatId IN %@ && ANY productToProcedure.procId IN %@ && ANY productToProcedure.procedureToSpeciality.splId IN %@", prodCatIds, procIds, splIds);
    [fetchRequest setPredicate:predicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSString *sectionNameKeyPath = nil;
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
                                                            initWithFetchRequest:fetchRequest
                                                            managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionNameKeyPath
                                                            cacheName:nil];
    
	NSError *error = nil;
	if (![fetchedResultsController performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	     */
	    //nslog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    //nslog(@"fetchedObjects.count: %d", fetchedResultsController.fetchedObjects.count);
    
    return fetchedResultsController;
    
}

- (ContentCategory*) contentCategoryWithContentCatId:(NSNumber*)contentCatId
{
    ContentCategory *contentCategory;
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Content"];

    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"contentCatId = %d", [contentCatId intValue]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            contentCategory = [items objectAtIndex:0];
        }
    }

    return contentCategory;
}

- (NSFetchedResultsController*) procedures
{
    return [self frcWithEntityName:@"Procedure" sortKey:@"name" predicate:nil];
    
}

- (NSFetchedResultsController*) specialities
{
    return [self frcWithEntityName:@"Speciality" sortKey:@"name" predicate:nil];
    
}

- (NSFetchedResultsController*) productCategories
{
    return [self frcWithEntityName:@"ProductCategory" sortKey:@"name" predicate:nil];
    
}

- (Procedure*) procedureWithProcId:(NSNumber*)procId
{
    Procedure *procedure;
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Procedure"];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"procId = %d", [procId intValue]];
    [fetchRequest setPredicate:predicate];

    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            procedure = [items objectAtIndex:0];
        }
    }
    
    return procedure;
    
}

- (NSFetchRequest*)contentMappingFetchRequestWithMedId:(NSNumber*)medId
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"ContentMapping"];

    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"medId = %d", [medId intValue]];
    [fetchRequest setPredicate:predicate];
    
    return fetchRequest;
}

- (NSFetchRequest*)contentFetchRequestWithContentMappings:(NSArray*)contentMappings
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Content"];

    NSMutableArray *args = [NSMutableArray array];
    for (ContentMapping *contentMapping in contentMappings)
    {
        [args addObject:contentMapping.cntId];
        ////nslog(@"contentMapping.cntId: %d", [contentMapping.cntId intValue]);
    }
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"cntId IN %@", args];
    [fetchRequest setPredicate:predicate];
    
    return fetchRequest;
}

- (Content*) contentWithId:(int)contentId
{
    Content *content;
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Content"];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"cntId = %d", contentId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            content = [items objectAtIndex:0];
        }
    }

    return content;
}

- (Content*) contentWithThumbPath:(NSString *)thumbPath
{
    Content *content;
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Content"];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"thumbnailImgPath = %@",thumbPath];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            content = [items objectAtIndex:0];
        }
    }
    
    return content;
}

- (Product*) productWithId:(int)productId
{
    Product *product;
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Product"];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"prodId = %d", productId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            product = [items objectAtIndex:0];
        }
    }
    
    return product;

}


- (ProductCategory*) productCategoryWithProdCatId:(NSNumber*)prodCatId
{
    
    ProductCategory *productCategory;
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"ProductCategory"];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"prodCatId = %d", [prodCatId intValue]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            productCategory = [items objectAtIndex:0];
        }
    }
    
    return productCategory;
}

- (NSArray*) productCategoryWithProdIds:(NSArray*) prodCatIds
{

    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"ProductCategory"];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"prodCatId in %@", prodCatIds];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            return items;
        }
    }
    
    return nil;
}

- (NSArray*) contentsForProduct:(Product*)product
{
    NSArray *contentMappings;
    NSArray *contents = [NSArray array];
    
    NSFetchRequest *fetchRequest = [self contentMappingFetchRequestWithMedId:product.prodId];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            contentMappings = items;
        }
    }
    
    if (contentMappings)
    {
        NSFetchRequest *fetchRequest = [self contentFetchRequestWithContentMappings:contentMappings];
        
        NSError *error;
        NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!error) {
            if (items && items.count > 0)
            {
                contents = items;
            }
        }
    }
    
    return contents;
    
}

//- (NSArray*) contentsForProduct:(Product*)product withContentCatId:(int)contentCatId
- (NSArray*) contentsForProduct:(Product*)product withContentCatIds:(NSArray*)contentCatIds;
{
    NSArray *contentMappings;
    NSArray *contents = [NSArray array];
    
    NSFetchRequest *fetchRequest = [self contentMappingFetchRequestWithMedId:product.prodId];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            contentMappings = items;
        }
    }
    
    if (contentMappings)
    {
        NSFetchRequest *fetchRequest = [self contentFetchRequestWithContentMappings:contentMappings];
        
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contentCatId = %d", contentCatId];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contentCatId IN %@", contentCatIds];
        
        // use the original predicate, and add a predicate to get only specific contentCatId
        [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, fetchRequest.predicate, nil]]];

        NSError *error;
        NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!error) {
            if (items && items.count > 0)
            {
                contents = items;
            }
        }
    }
    
    return contents;
    
}

//- (NSArray*) contentsForSpeciality:(Speciality*)speciality withContentCatId:(int)contentCatId
- (NSArray*) contentsForSpeciality:(Speciality*)speciality withContentCatIds:(NSArray*)contentCatIds;
{
    NSArray *contentMappings;
    NSArray *contents = [NSArray array];
    
    NSFetchRequest *fetchRequest = [self contentMappingFetchRequestWithMedId:speciality.splId];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            contentMappings = items;
        }
    }
    
    if (contentMappings)
    {
        NSFetchRequest *fetchRequest = [self contentFetchRequestWithContentMappings:contentMappings];
        
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contentCatId = %d", contentCatId];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contentCatId IN %@", contentCatIds];
        
        // use the original predicate, and add a predicate to get only specific contentCatId
        [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, fetchRequest.predicate, nil]]];
        
        NSError *error;
        NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!error) {
            if (items && items.count > 0)
            {
                contents = items;
            }
        }
    }
    
    return contents;
        
}

//- (NSArray*) contentsForProcedure:(Procedure*)procedure withContentCatId:(int)contentCatId
- (NSArray*) contentsForProcedure:(Procedure*)procedure withContentCatIds:(NSArray*)contentCatIds;
{
    NSArray *contentMappings;
    NSArray *contents = [NSArray array];
    
    NSFetchRequest *fetchRequest = [self contentMappingFetchRequestWithMedId:procedure.procId];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            contentMappings = items;
        }
    }
    
    if (contentMappings)
    {
        NSFetchRequest *fetchRequest = [self contentFetchRequestWithContentMappings:contentMappings];
        
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contentCatId = %d", contentCatId];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contentCatId IN %@", contentCatIds];
        
        // use the original predicate, and add a predicate to get only specific contentCatId
        [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, fetchRequest.predicate, nil]]];
        
        NSError *error;
        NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!error) {
            if (items && items.count > 0)
            {
                contents = items;
            }
        }
    }
    
    return contents;
        
}

- (NSFetchedResultsController*) searchContentsWithSearchString:(NSString*)searchStr searchResultsSort:(int)searchResultsSort filterType:(int)filterType
{
    // cache the fetched result controller, expensive to create
    static NSFetchedResultsController *fetchedResultsController = nil;

    if (!fetchedResultsController)
    {
        NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"ContentSearch"];
        
        // Set the batch size to a suitable number. 
        [fetchRequest setFetchBatchSize:40];
        
        // Edit the sort key as appropriate.
        NSString *sortKey = @"title";
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:
                                    sortDescriptor1,
                                    nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        fetchedResultsController = [[NSFetchedResultsController alloc]
                                    initWithFetchRequest:fetchRequest
                                    managedObjectContext:self.managedObjectContext
                                    sectionNameKeyPath:nil
                                    cacheName:nil];
    }
    
    NSPredicate *searchPredicate;
    NSPredicate * p1 = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@",searchStr];
    NSPredicate * p2 = [NSPredicate predicateWithFormat:@"keywords CONTAINS[cd] %@",searchStr];
   NSPredicate * p3 = [NSPredicate predicateWithFormat:@"NOT (catName CONTAINS[cd] %@)",searchStr];
//    searchPredicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@ OR keywords CONTAINS[cd] %@ ", searchStr, searchStr];
    NSPredicate *p4 = [NSCompoundPredicate orPredicateWithSubpredicates:@[p1,p2]];
    searchPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[p3,p4]];
    [fetchedResultsController.fetchRequest setPredicate:searchPredicate];
    
    NSArray *allowedTypes;
    NSArray *excludeTypes = [NSArray arrayWithObjects:
                             [NSNumber numberWithInt:kSpecialtyMessage],
                             [NSNumber numberWithInt:kProcedureMessage],
                             [NSNumber numberWithInt:kProductClinicalMessage],
                             [NSNumber numberWithInt:kProductNonClinicalMessage],
                             [NSNumber numberWithInt:kProductImage],
                             [NSNumber numberWithInt:kProcedureImage],
                             [NSNumber numberWithInt:kSpecialtyImage],
                             [NSNumber numberWithInt:kSpecialtyDashBoardIcon],
                             nil];
    switch (filterType) {
        case kSearchResultsFilterTypeVideos:
        {
            allowedTypes = [NSArray arrayWithObjects:
                            [NSNumber numberWithInt:kSpecialtyVideo],
                            [NSNumber numberWithInt:kProcedureVideo],
                            [NSNumber numberWithInt:kProductVideo],
                            [NSNumber numberWithInt:kProductCompetitiveInfoVideos],
                            nil];
        }
            break;
        case kSearchResultsFilterTypeArticles:
            allowedTypes = [NSArray arrayWithObjects:
                            [NSNumber numberWithInt:kSpecialtyArticle],
                            [NSNumber numberWithInt:kProcedureArticle],
                            [NSNumber numberWithInt:kProductArticle],
                            [NSNumber numberWithInt:kProductClinicalArticles],
                            [NSNumber numberWithInt:kProductClinicalArticlesOthers],
                            nil];
            break;

        case kSearchResultsFilterTypeAll:
        default:
            allowedTypes = nil;
            break;
    }
    
    if (allowedTypes)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"catId IN %@", allowedTypes];
        NSCompoundPredicate *compPred = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:[NSArray arrayWithObjects:fetchedResultsController.fetchRequest.predicate, predicate,nil]];
        [fetchedResultsController.fetchRequest setPredicate:compPred];
    }
    else{
        NSPredicate *excludePredicate = [NSPredicate predicateWithFormat:@"NOT (catId IN %@)",excludeTypes];
        NSCompoundPredicate *compPred = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:[NSArray arrayWithObjects:fetchedResultsController.fetchRequest.predicate,excludePredicate,nil]];
        [fetchedResultsController.fetchRequest setPredicate:compPred];

    }
    
	NSError *error = nil;
	if (![fetchedResultsController performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	     */
	    //nslog(@"Unresolved error %@, %@", error, [error userInfo]);
	    //abort();
	} else{
        //nslog(@"fetchedObjects.count: %d", fetchedResultsController.fetchedObjects.count);
    }
    
    return fetchedResultsController;    
}

- (NSFetchedResultsController*) searchProductsWithSearchString:(NSString*)searchStr
{
    // cache the fetched result controller, expensive to create
    static NSFetchedResultsController *fetchedResultsController = nil;
    
    if (!fetchedResultsController)
    {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Product"];
        
        // Set the batch size to a suitable number.
        [fetchRequest setFetchBatchSize:40];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:
                                    sortDescriptor1,
                                    nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        fetchedResultsController = [[NSFetchedResultsController alloc]
                                                                initWithFetchRequest:fetchRequest
                                                                managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil
                                                                cacheName:nil];
    }
    
    NSPredicate *searchPredicate;
    searchPredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@ OR desc CONTAINS[cd] %@ OR code  CONTAINS[cd] %@ OR sku CONTAINS[cd] %@", searchStr, searchStr, searchStr, searchStr];
    [fetchedResultsController.fetchRequest setPredicate:searchPredicate];

	NSError *error = nil;
	if (![fetchedResultsController performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	     */
	    //nslog(@"Unresolved error %@, %@", error, [error userInfo]);
	    //abort();
	} else{
        //nslog(@"fetchedObjects.count: %d", fetchedResultsController.fetchedObjects.count);
    }
    
    return fetchedResultsController;
}

- (void) addWordsToDict:(NSMutableDictionary*)dict fromString:(NSString*)string withSearchString:(NSString*)searchStr
{
    NSArray *allWords = [string componentsSeparatedByString:@" "];

    NSRange rng;
    for (NSString *word in allWords)
    {
        NSArray *wordsArray = [word componentsSeparatedByString:@","];
        for (NSString *searchWord in wordsArray)
        {
            if (![dict objectForKey:searchWord])
            {
                rng = [searchWord rangeOfString:searchStr options:NSCaseInsensitiveSearch];
                if (rng.location != NSNotFound)
                {
                    NSCharacterSet *validChars = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"];
                    validChars = [validChars invertedSet];
                    NSRange r = [searchWord rangeOfCharacterFromSet:validChars];
                    if (r.location == NSNotFound) {
                        if (![dict objectForKey:[searchWord lowercaseString]])
                            [dict setObject:searchWord forKey:[searchWord lowercaseString]]; //for unique words (case insensitive)
                    }
                }
            }
        }
    }
}

// search for suggestions with search string
- (NSArray*) suggestionsSearchWithSearchString:(NSString*)searchStr
{
    // cache the words dictionary
    static NSMutableDictionary *words = nil;
    
    if (!words)
    {
        words = [[NSMutableDictionary alloc] init];
    }
    else
    {
        [words removeAllObjects];
    }
    
    NSArray *founds = [self searchProductsWithSearchString:searchStr].fetchedObjects;
    
    if (founds && founds.count > 0)
    {
        for (Product *product in founds)
        {
            [self addWordsToDict:words fromString:product.name withSearchString:searchStr];
            [self addWordsToDict:words fromString:product.desc withSearchString:searchStr];
        }
    }
    
    founds = [self searchContentsWithSearchString:searchStr searchResultsSort:kSearchResultsSortABCD filterType:kSearchResultsFilterTypeAll].fetchedObjects;
    
    if (founds && founds.count > 0)
    {
        for (ContentSearch *content in founds)
        {
            [self addWordsToDict:words fromString:content.title withSearchString:searchStr];
           //a [self addWordsToDict:words fromString:content.desc withSearchString:searchStr];
            [self addWordsToDict:words fromString:content.keywords withSearchString:searchStr];
        }
    }
    
    return [words allValues];
    
}

// get objects reverse mapped to ContentMappings for a given Content and MedCatId
- (NSArray*) reverseMappedContentForContent:(Content*)content withMedCatId:(NSNumber*)medCatId
{
    NSArray *targetObjects;
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"ContentMapping"];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"cntId = %d AND medCatId = %d", [content.cntId intValue], [medCatId intValue]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *contentMappings;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            contentMappings = items;
        }
    }

    if (contentMappings)
    {
        NSMutableArray *keys = [NSMutableArray array];
        for (ContentMapping *contentMapping in contentMappings)
        {
            [keys addObject:contentMapping.medId];
        }
        
        switch ([medCatId intValue]) {
            case kMedCatIdSpeciality:
                fetchRequest = [self fetchRequestWithEntity:@"Speciality"];
                predicate = [NSPredicate predicateWithFormat:@"splId IN %@", keys];
                break;
            case kMedCatIdProcedure:
                fetchRequest = [self fetchRequestWithEntity:@"Procedure"];
                predicate = [NSPredicate predicateWithFormat:@"procId IN %@", keys];
                break;
            case kMedCatIdProduct:
                fetchRequest = [self fetchRequestWithEntity:@"Product"];
                predicate = [NSPredicate predicateWithFormat:@"prodId IN %@", keys];
                break;
                
            default:
                break;
        }
        
        // add the predicate for searching
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!error) {
            if (items && items.count > 0)
            {
                targetObjects = items;
            }
        }

    }
    
    return targetObjects;
}

- (void) dumpContentMappingsWithCntId:(NSNumber*)cntId withMedCatId:(NSNumber*)medCatId
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"ContentMapping"];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"cntId = %d AND medCatId = %d", [cntId intValue], [medCatId intValue]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            //nslog(@"contentMappings: %d", items.count);
            for (ContentMapping *cm in items)
            {
                //nslog(@"cntMapId: %d cntId: %d medCatId: %d", [cm.cntMapId intValue], [cm.cntId intValue], [cm.medCatId intValue]);
            }
        }
    }

}

//from arcDev
- (void) loadhotSpots
{
    
}

- (NSArray*)hotSpotsForSpecialty:(Speciality*)specialty
{
    NSArray *hots = [NSArray array];
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"SpecialtyHotSpot"];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"splId = %d", [specialty.splId intValue]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            hots = items;
        }
    }
    
    return hots;
}

- (void) deleteSpecialtyHotSpots
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"SpecialtyHotSpot"];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            for (NSManagedObject *mo in items)
            {
                [_appDelegate.managedObjectContext deleteObject:mo];
            }
        }
    }
    
    [_appDelegate saveContext];
    
}

- (void) createDummySpecialtyHotSpots
{
    // first, delete existing specialty hot spots
    [self deleteSpecialtyHotSpots];
    
    //     specialty name: Hernia splId: 1 cntId: 864
    //
    //     procedure name: Laparoscopic Ventral procId: 2
    //
    [self createSpecialtyHotSpotWithSpecialtyId:[NSNumber numberWithInt:1]
                                         procId:[NSNumber numberWithInt:2]
                                          cntId:[NSNumber numberWithInt:864]
                                          width:[NSNumber numberWithInt:50]
                                         height:[NSNumber numberWithInt:50]
                                              x:[NSNumber numberWithInt:100]
                                              y:[NSNumber numberWithInt:100]
     ];
    
    //
    //     specialty name: Bariatric splId: 2 cntId: 135
    //
    //     procedure name: LAP Sleeve procId: 7
    //
    [self createSpecialtyHotSpotWithSpecialtyId:[NSNumber numberWithInt:2]
                                         procId:[NSNumber numberWithInt:7]
                                          cntId:[NSNumber numberWithInt:135]
                                          width:[NSNumber numberWithInt:50]
                                         height:[NSNumber numberWithInt:50]
                                              x:[NSNumber numberWithInt:150]
                                              y:[NSNumber numberWithInt:150]
     ];
    
    //
    //     specialty name: Gynecologic splId: 6 cntId: 863
    //
    //     procedure name: Hysterectomy - Total Laparoscopic procId: 17
    [self createSpecialtyHotSpotWithSpecialtyId:[NSNumber numberWithInt:6]
                                         procId:[NSNumber numberWithInt:17]
                                          cntId:[NSNumber numberWithInt:863]
                                          width:[NSNumber numberWithInt:50]
                                         height:[NSNumber numberWithInt:50]
                                              x:[NSNumber numberWithInt:50]
                                              y:[NSNumber numberWithInt:50]
     ];
    //     procedure name: Hysterectomy - Total Abdominal procId: 15
    [self createSpecialtyHotSpotWithSpecialtyId:[NSNumber numberWithInt:6]
                                         procId:[NSNumber numberWithInt:15]
                                          cntId:[NSNumber numberWithInt:863]
                                          width:[NSNumber numberWithInt:50]
                                         height:[NSNumber numberWithInt:50]
                                              x:[NSNumber numberWithInt:101]
                                              y:[NSNumber numberWithInt:101]
     ];
    //     procedure name: Cesarean Section procId: 13
    [self createSpecialtyHotSpotWithSpecialtyId:[NSNumber numberWithInt:6]
                                         procId:[NSNumber numberWithInt:13]
                                          cntId:[NSNumber numberWithInt:863]
                                          width:[NSNumber numberWithInt:50]
                                         height:[NSNumber numberWithInt:50]
                                              x:[NSNumber numberWithInt:151]
                                              y:[NSNumber numberWithInt:151]
     ];
    //     procedure name: Hysterectomy - Laparoscopic Supracervical procId: 14
    [self createSpecialtyHotSpotWithSpecialtyId:[NSNumber numberWithInt:6]
                                         procId:[NSNumber numberWithInt:14]
                                          cntId:[NSNumber numberWithInt:863]
                                          width:[NSNumber numberWithInt:50]
                                         height:[NSNumber numberWithInt:50]
                                              x:[NSNumber numberWithInt:201]
                                              y:[NSNumber numberWithInt:201]
     ];
    //     procedure name: Hysterectomy - Total Vaginal procId: 16
    [self createSpecialtyHotSpotWithSpecialtyId:[NSNumber numberWithInt:6]
                                         procId:[NSNumber numberWithInt:16]
                                          cntId:[NSNumber numberWithInt:863]
                                          width:[NSNumber numberWithInt:50]
                                         height:[NSNumber numberWithInt:50]
                                              x:[NSNumber numberWithInt:251]
                                              y:[NSNumber numberWithInt:251]
     ];
    
    
}

- (void) createSpecialtyHotSpotWithSpecialtyId:(NSNumber *)splId procId:(NSNumber *)procId cntId:(NSNumber *)cntId width:(NSNumber *)width height:(NSNumber *)height x:(NSNumber *)x y:(NSNumber *)y
{
    /*
     @property (nonatomic, retain) NSNumber * cntId;
     @property (nonatomic, retain) NSNumber * height;
     @property (nonatomic, retain) NSNumber * procId;
     @property (nonatomic, retain) NSNumber * splId;
     @property (nonatomic, retain) NSNumber * width;
     @property (nonatomic, retain) NSNumber * x;
     @property (nonatomic, retain) NSNumber * y;
     */
    
    // Create a new instance of the entity
    SpecialtyHotSpot *hot = [NSEntityDescription insertNewObjectForEntityForName:@"SpecialtyHotSpot"
                                                          inManagedObjectContext:_appDelegate.managedObjectContext];
    
    [hot setCntId:cntId];
    [hot setHeight:height];
    [hot setProcId:procId];
    [hot setSplId:splId];
    [hot setWidth:width];
    [hot setX:x];
    [hot setY:y];
    
    [_appDelegate saveContext];
    
}

//

@end
