//
//  ContentDataMgr.m
//  edge
//
//  Created by iPhone Developer on 5/18/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "ContentDataMgr.h"
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

@interface ContentDataMgr ()
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, assign) NSManagedObjectContext *managedObjectContext;
@end

@implementation ContentDataMgr

+ (ContentDataMgr*) sharedInstance
{
    static ContentDataMgr *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[ContentDataMgr alloc] init];
        // Do any other initialisation stuff here
        instance.appDelegate = [UIApplication sharedApplication].delegate;
        instance.managedObjectContext = instance.appDelegate.managedObjectContext;
    });
    
    return instance;

}

- (NSString*) addAppDocumentsPathToPath:(NSString*)path
{
    NSString *basePath;
    
    basePath = [NSString stringWithFormat:@"%@/%@%@/", NSHomeDirectory(), @"Documents", path];
    
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
    NSLog(@"Removing data from MedicalCategory");
    [self deleteAllFromEntityWithName:@"MedicalCategory"];
    
    NSLog(@"Removing data from ArcCategory");
    [self deleteAllFromEntityWithName:@"ArcCategory"];
    
    NSLog(@"Removing data from ProcedureStep");
    [self deleteAllFromEntityWithName:@"ProcedureStep"];
    
    NSLog(@"Removing data from SpecialityCategory");
    [self deleteAllFromEntityWithName:@"SpecialityCategory"];
    
    NSLog(@"Removing data from Content");
    [self deleteAllFromEntityWithName:@"Content"];
    
    NSLog(@"Removing data from ContentCategory");
    [self deleteAllFromEntityWithName:@"ContentCategory"];
    
    NSLog(@"Removing data from ContentMapping");
    [self deleteAllFromEntityWithName:@"ContentMapping"];
    
    NSLog(@"Removing data from Speciality");
    [self deleteAllFromEntityWithName:@"Speciality"];
    
    NSLog(@"Removing data from Procedure");
    [self deleteAllFromEntityWithName:@"Procedure"];
    
    NSLog(@"Removing data from Market");
    [self deleteAllFromEntityWithName:@"Market"];
    
    NSLog(@"Removing data from ProductCategory");
    [self deleteAllFromEntityWithName:@"ProductCategory"];
    
    NSLog(@"Removing data from Product");
    [self deleteAllFromEntityWithName:@"Product"];
    
    NSLog(@"Removing data from CompProduct");
    [self deleteAllFromEntityWithName:@"CompProduct"];

    //
    // User entitites
    //
    /*
    NSLog(@"Removing data from MyProfile");
    [self deleteAllFromEntityWithName:@"MyProfile"];
    
    NSLog(@"Removing data from MyEntitlement");
    [self deleteAllFromEntityWithName:@"MyEntitlement"];
    
    NSLog(@"Removing data from MyFavorite");
    [self deleteAllFromEntityWithName:@"MyFavorite"];
    
    NSLog(@"Removing data from MyForm");
    [self deleteAllFromEntityWithName:@"MyForm"];
     */
    
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
    
     NSLog(@"Removing data from MyProfile");
     [self deleteAllFromEntityWithName:@"MyProfile"];
     
     NSLog(@"Removing data from MyEntitlement");
     [self deleteAllFromEntityWithName:@"MyEntitlement"];
     
     NSLog(@"Removing data from MyFavorite");
     [self deleteAllFromEntityWithName:@"MyFavorite"];
     
     NSLog(@"Removing data from MyForm");
     [self deleteAllFromEntityWithName:@"MyForm"];
     
    
    // re-enable undo
    [[[self managedObjectContext] undoManager] enableUndoRegistration];
    
}


- (void) callDataSyncServiceWithUUID:(NSString*)uuid entitlements:(NSArray*)entitlements
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:uuid forKey:@"uuid"];
    
    NSMutableArray *array = [NSMutableArray array];
    for (MyEntitlement *myEntitlement in entitlements)
    {
        NSLog(@"myEntitlement name: %@ status: %d", myEntitlement.name, [myEntitlement.status intValue]);

        if ([myEntitlement.status intValue] == kEntitlementStatusEnabled)
        {
            [array addObject:myEntitlement.splId];
        }
    }
    [dict setObject:array forKey:@"splIds"];
    
    for (NSString *key in dict.allKeys)
    {
        NSLog(@"key: %@ value: %@", key, [dict objectForKey:key]);
    }

    DataSyncServiceHelper *dataSync = [[DataSyncServiceHelper alloc] init];
    [dataSync getSyncDataWithParams:dict];
}

- (void) syncMasterDataInBackground
{
    // first clear content
    [self clearMasterData];
    
    // load master data content
    NSString *uuid = [[RegistrationModel sharedInstance] uuid];
    NSArray *myEntitlements = [[RegistrationModel sharedInstance].profile.myProfileToMyEntitlement allObjects];
    NSLog(@"callDataSyncServiceWithUUID: %@ myEntitlements: %@", uuid, myEntitlements);
    [self callDataSyncServiceWithUUID:uuid entitlements:myEntitlements];
    NSLog(@"complete callDataSyncServiceWithUUID.");
    
}

- (void) syncMasterData
{
    [self performSelectorInBackground:@selector(syncMasterDataInBackground) withObject:nil];
}

- (BOOL) parseRegistrationWithResponseDict:(NSDictionary*)dict params:(NSDictionary*)params
{
    NSLog(@"parseRegistrationWithResponseDict");
    
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
    NSString *wsUrlStr = [NSString stringWithFormat:@"%@%@", WEB_SERVICE_BASE_SERVER,
                          POST_REGISTRATION_SERVICE];
    
    NSLog(@"registration url: %@", wsUrlStr);
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:WEB_SERVICE_BASE_SERVER]];
    
    [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [httpClient setDefaultHeader:@"Accept" value:@"application/json"];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:POST_REGISTRATION_SERVICE parameters:params];
    
    //[request setTimeoutInterval:DEFAULT_WEB_SERVICE_TIMEOUT];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"demo@example.com" forHTTPHeaderField:@"X_ASCCPE_USERNAME"];
    [request setValue:@"demo" forHTTPHeaderField:@"X_ASCCPE_PASSWORD"];
    
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"application/json"]];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/json"]];
    
    AFJSONRequestOperation *op = [AFJSONRequestOperation
                                  JSONRequestOperationWithRequest:request
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                      NSLog(@"%@ success response at: %@", wsUrlStr, [NSDate date]);
                                      NSLog(@"response: %@", (NSString*)JSON);
                                      if ([self parseRegistrationWithResponseDict:JSON params:params])
                                       {
                                           NSLog(@"parseRegistrationWithResponseDict success.");
                                           [self.appDelegate postApplicationEvent:APP_EVENT_REGISTRATION_SUCCESS];
                                       } else
                                       {
                                           NSLog(@"parseRegistrationWithResponseDict error response.");
                                           [self.appDelegate postApplicationEvent:APP_EVENT_REGISTRATION_ERROR_RESPONSE];
                                       }
                                  }
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                      NSLog(@"failure response %@  \n error %@ \n JSON %@", response, error, JSON);
                                      [self.appDelegate postApplicationEvent:APP_EVENT_REGISTRATION_FAILURE];
                                  }];
    
    NSLog(@"making %@ call at: %@", wsUrlStr, [NSDate date]);
    
    [httpClient enqueueHTTPRequestOperation:op];    
}


//
// Core data methods
//

- (NSFetchedResultsController*) frcWithEntityName:(NSString*)entityName sortKey:(NSString*)sortKey predicate:(NSPredicate*)predicate
{
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
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
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    NSLog(@"fetchedObjects.count: %d", fetchedResultsController.fetchedObjects.count);
    
    return fetchedResultsController;
    
}

- (NSFetchedResultsController*) products
{
    return [self frcWithEntityName:@"Product" sortKey:@"name" predicate:nil];
    
}

- (NSFetchedResultsController*) productsWithSpecialityIds:(NSArray*)splIds andProcedureIds:(NSArray*)procIds  andProductCategoryIds:(NSArray*)prodCatIds sectionNameKeyPath:(NSString*)sectionNameKeyPath
{
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Product" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
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
    NSLog(@"prodCatId IN %@ && ANY productToProcedure.procId IN %@ && ANY productToProcedure.procedureToSpeciality.splId IN %@", prodCatIds, procIds, splIds);
    [fetchRequest setPredicate:predicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    //NSString *sectionNameKeyPath = nil;
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
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    NSLog(@"fetchedObjects.count: %d", fetchedResultsController.fetchedObjects.count);
    
    return fetchedResultsController;
        
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

- (NSFetchRequest*)procedureFetchRequestWithProcId:(NSNumber*)procId
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Procedure" inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"procId = %d", [procId intValue]];
    [fetchRequest setPredicate:predicate];
    
    return fetchRequest;
}

- (Procedure*) procedureWithProcId:(NSNumber*)procId
{
    Procedure *procedure;
    
    NSFetchRequest *fetchRequest = [self procedureFetchRequestWithProcId:procId];
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

- (NSFetchRequest*)contentMappingFetchRequestWithProduct:(Product*)product
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ContentMapping" inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"medId = %d", [product.prodId intValue]];
    [fetchRequest setPredicate:predicate];
    
    return fetchRequest;
}

- (NSFetchRequest*)contentFetchRequestWithContentMappings:(NSArray*)contentMappings
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSMutableArray *args = [NSMutableArray array];
    for (ContentMapping *contentMapping in contentMappings)
    {
        [args addObject:contentMapping.cntId];
    }
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"cntId IN %@", args];
    [fetchRequest setPredicate:predicate];
    
    return fetchRequest;
}

- (NSArray*) contentsForProduct:(Product*)product
{
    NSArray *contentMappings;
    NSArray *contents = [NSArray array];
    
    NSFetchRequest *fetchRequest = [self contentMappingFetchRequestWithProduct:product];

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

- (NSArray*) contentsForProduct:(Product*)product withContentCatId:(int)contentCatId
{
    NSArray *contentMappings;
    NSArray *contents = [NSArray array];
    
    NSFetchRequest *fetchRequest = [self contentMappingFetchRequestWithProduct:product];
    
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
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contentCatId == %d", contentCatId];
        [fetchRequest setPredicate:predicate];
        
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

- (void) createMyFavoriteWithDict:(NSDictionary*)dict
{
    // Create a new instance of the entity
    MyFavorite *fav = [NSEntityDescription insertNewObjectForEntityForName:@"Favorite"
                                            inManagedObjectContext:self.managedObjectContext];
    
    /*
     @property (nonatomic, retain) NSNumber * cntId;
     @property (nonatomic, retain) NSDate * crtDt;
     @property (nonatomic, retain) NSNumber * favId;
     @property (nonatomic, retain) NSString * sortOrder;
     @property (nonatomic, retain) NSNumber * status;
     @property (nonatomic, retain) NSDate * uptDt;
     */
    fav.cntId = [dict objectForKey:@"cntId"];
    fav.crtDt = [NSDate date];
    fav.sortOrder = [NSNumber numberWithInt:0];
    fav.status = [NSNumber numberWithInt:STATUS_DEFAULT];
    
    [self.appDelegate saveContext];
    
}

- (void) createPresentationWithDict:(NSDictionary*)dict
{
    // Create a new instance of the entity
    PresentationMaster *pres = [NSEntityDescription insertNewObjectForEntityForName:@"PresentationMaster"
                                                    inManagedObjectContext:self.managedObjectContext];
    
    /*
     @property (nonatomic, retain) NSDate * crtDt;
     @property (nonatomic, retain) NSString * footer;
     @property (nonatomic, retain) NSString * header;
     @property (nonatomic, retain) NSString * name;
     @property (nonatomic, retain) NSNumber * presMasId;
     @property (nonatomic, retain) NSNumber * status;
     @property (nonatomic, retain) NSString * subTitle1;
     @property (nonatomic, retain) NSString * subTitle2;
     @property (nonatomic, retain) NSString * subTitle3;
     @property (nonatomic, retain) NSString * title;
     @property (nonatomic, retain) NSDate * uptDt;
     @property (nonatomic, retain) NSSet *PresentationMasterToPresentationDetail;
     */
    pres.crtDt = [NSDate date];
    pres.name = [dict objectForKey:@"name"];
    pres.status = [NSNumber numberWithInt:STATUS_DEFAULT];
    
    [self.appDelegate saveContext];
    
}


@end
