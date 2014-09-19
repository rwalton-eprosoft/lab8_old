//
//  ProcedureModel.m
//  edge
//
//  Created by Vijay on 10/04/13.
//  Copyright (c) 2013 eprosoft. All rights reserved.
//

#import "ProcedureModel.h"
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
#import "Constants.h"
#import "ExtendedMetadata.h"

@interface ProcedureModel ()
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, assign) NSManagedObjectContext *managedObjectContext;
@end

@implementation ProcedureModel

/**
 */
+ (ProcedureModel*) sharedInstance
{
    static ProcedureModel *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[ProcedureModel alloc] init];
        instance.appDelegate = [UIApplication sharedApplication].delegate;
        instance.managedObjectContext = instance.appDelegate.managedObjectContext;
        [instance initArcSteps];
    });
    
    return instance;
    
}

- (void) initArcSteps {
    _arcSteps = [self getArcSteps];
}

/**
 */
- (NSFetchRequest*)fetchRequestWithEntity:(NSString*)entityName
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    return fetchRequest;
}

- (NSArray*) procedureForProcedureId :(int) procId andForSpecialityId : (int) spltId :(NSError*) error
{
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Procedure"];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"procId = %d and procedureToSpeciality.splId = %d", procId, spltId];
    [fetchRequest setPredicate:predicate];
    
    return [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}


/**
 */
- (NSArray*) arcStepsForProcedure:(int) procId andForSpeciality: (int) spltId
{
    
    NSMutableArray* procedureSteps = [[NSMutableArray alloc] init];
    
    NSError* error;
    NSArray* items = [self procedureForProcedureId :procId andForSpecialityId : spltId :error];
    if (!error)
    {
        if (items && items.count > 0)
        {
            for (NSManagedObject* mo in [[items objectAtIndex:0] valueForKey:@"procedureToProcedureStep"])
            {
                [procedureSteps addObject:mo];
            }
        }
    }
    return procedureSteps;
}

/**
 */

- (NSArray*) concernsForProcedure:(int) procId andForSpeciality: (int) spltId
{
    NSMutableArray* concerns = [[NSMutableArray alloc] init];
    NSError* error;
    NSArray* items = [self procedureForProcedureId :procId andForSpecialityId : spltId :error];
    if (!error)
    {
        if (items && items.count > 0)
        {
            for (NSManagedObject* mo in [[items objectAtIndex:0] valueForKey:@"procedureToProcedureStep"])
            {
                for (NSManagedObject* concern in [mo valueForKey:@"procedureStepToConcern"])
                {
                    [concerns addObject:concern];
                }
            }
        }
    }
    return concerns;
}

/**
 */
- (NSArray*) productsForProcedure:(int) procId andForSpeciality: (int) spltId andForArcStepName: (NSString*) name
{
    NSArray* products = [[NSArray alloc] init];
    int arcCatId = [self getArcCatIdForName:name];
    NSError* error;
    NSArray* items = [self procedureForProcedureId :procId andForSpecialityId : spltId :error];
    if (!error) {
        if (items && items.count > 0) {
            NSMutableArray* procSteps = [[NSMutableArray alloc] init];
            for (NSManagedObject* procedureStep in [[items objectAtIndex:0] valueForKey:@"procedureToProcedureStep"]) {
                if (procedureStep) {
                    if ([[procedureStep valueForKey:@"arcCatId"] intValue] == arcCatId) {
//                        for (NSManagedObject* product in [procedureStep valueForKey:@"procedureStepToProduct"]) {
//                            if (![products containsObject:product])
//                                [products addObject:product];
//                        }
                        [procSteps addObject:[procedureStep valueForKey:@"procStepId"]];
                    }
                }
            }
            if (procSteps && procSteps.count > 0)
                products = [self addProductsForStep : procSteps];
        }
    }
    return products;
}

- (NSArray*) addProductsForStep : (NSArray*) stepIds {

    NSArray* products;
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"ProcedureStepToProductNew"];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"procStepId in %@", stepIds];
    [fetchRequest setPredicate:predicate];
    
    NSError* error;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];

    NSArray* items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (items && items.count > 0) {
        NSMutableArray* productIds = [[NSMutableArray alloc] init];
        for (NSManagedObject* procedureStepToProductNew in items) {
            [productIds addObject:[procedureStepToProductNew valueForKey:@"prodId"]];
//            NSLog(@"Sort Order %@", [procedureStepToProductNew valueForKey:@"sortOrder"]);
//            NSLog(@"ID         %@", [procedureStepToProductNew valueForKey:@"procStepId"]);
//            NSLog(@"prodId         %@", [procedureStepToProductNew valueForKey:@"prodId"]);
//            NSLog(@"------------");
        }
        products = [self fetchProductsForStep : productIds];
//        for (NSManagedObject* product in products)
//            NSLog(@"%@) %@", [product valueForKey:@"prodId"], [product valueForKey:@"name"]);

    }
    return products;
}

- (NSArray*) fetchProductsForStep : (NSArray*) productIds {

    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Product"];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"prodId in %@", productIds]; //Not returning same order as input product id's
    [fetchRequest setPredicate:predicate];
    NSError* error;
    NSArray* products = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray* sortedProducts = [[NSMutableArray alloc] init];
    for (NSNumber* prodId in productIds) {
        for (Product* product in products) {
            if ([[product prodId] intValue] == [prodId intValue]) {
                if (![sortedProducts containsObject:product])
                    [sortedProducts addObject:product];
            }
        }
    }
    return sortedProducts;
}

- (NSMutableArray*) productsForProcedure:(int) procId andForSpeciality: (int) spltId andForArcStepName: (NSString*) name  andForProcStepID: (int) stepId
{
    NSMutableArray* products = [[NSMutableArray alloc] init];
    int arcCatId = [self getArcCatIdForName:name];
    NSError* error;
    NSArray* items = [self procedureForProcedureId :procId andForSpecialityId : spltId :error];
    
    if (!error)
    {
        if (items && items.count > 0)
        {
            NSSet* tempProducts = [[items objectAtIndex:0] valueForKey:@"procedureToProduct"];
            for (NSManagedObject* product in tempProducts)
            {
                for (NSManagedObject* procedureStep in [product valueForKey:@"productToProcedureStep"])
                {
                    if ([[procedureStep valueForKey:@"arcCatId"] intValue] == arcCatId &&
                        [[procedureStep valueForKey:@"procStepId"] intValue] == stepId)
                    {
                        if (![products containsObject:[product valueForKey:@"prodId"]])
                            [products addObject:[product valueForKey:@"prodId"]];
                    }
                }
            }
        }
    }
    return products;
}

- (NSArray *)fetchConcerns:(int)concernId
{
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Concern"];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"concernId = %d", concernId];
    [fetchRequest setPredicate:predicate];
    
    NSError* error;
    NSArray* concerns = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return concerns;
}

//- (NSMutableArray*) productsForProcedure:(int) procId andForSpeciality: (int) spltId andForArcStepName: (NSString*) name  andForConcernId: (int) concernId
//{
//    int arcCatId = [self getArcCatIdForName:name];
//    NSMutableArray* products = [[NSMutableArray alloc] init];
//
//    NSError* error;
//    NSArray* items = [self procedureForProcedureId :procId andForSpecialityId : spltId :error];
//
//    if (!error)
//    {
//        if (items && items.count > 0)
//        {
//            NSSet* tempProducts = [[items objectAtIndex:0] valueForKey:@"procedureToProduct"];
//            for (NSManagedObject* product in tempProducts)
//            {
//                for (NSManagedObject* procedureStep in [product valueForKey:@"productToProcedureStep"])
//                {
//                    if ([[procedureStep valueForKey:@"arcCatId"] intValue] == arcCatId)
//                    {
//                        for (NSManagedObject* concern in [procedureStep valueForKey:@"procedureStepToConcern"]) {
//                            if ([[concern valueForKey:@"concernId"] intValue] == concernId) {
//                                if (![products containsObject:[product valueForKey:@"prodId"]])
//                                    [products addObject:[product valueForKey:@"prodId"]];
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//    return products;
//}

- (NSMutableArray*) productsForConcerns : (int) procId andForSpeciality: (int) spltId andForArcStepName: (NSString*) name  andForConcernId: (int) concernId
{
    NSArray *concerns;
    concerns = [self fetchConcerns:concernId];
    
    NSMutableArray* products = [[NSMutableArray alloc] init];
    for (NSManagedObject* concern in concerns)
    {
        for (NSManagedObject* product in [concern valueForKey:@"concernToProduct"])
        {
            if (![products containsObject:[product valueForKey:@"prodId"]])
                [products addObject:[product valueForKey:@"prodId"]];
        }
    }
    return products;
}

/**
 
 */
- (NSMutableArray*) metadataForContentId:(NSArray*) cntIds andForKey : (NSString*) key
{
    NSMutableArray* contents = [[NSMutableArray alloc] init];
    NSError* error;
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"ExtendedMetadata"];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"cntId IN %@ and fieldName == %@", cntIds, key];
    [fetchRequest setPredicate:predicate];
    
    NSArray* items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error)
    {
        if (items && items.count > 0)
        {
            for (NSManagedObject* mo in items)
            {
                NSString* value = [mo valueForKey:@"fieldValue"];
                if (value != nil)
                {
                    NSArray* values = [value componentsSeparatedByString:@","];
                    for (NSString* val in values)
                    {
                        if (![contents containsObject:val])
                            [contents addObject:val];
                    }
                }
            }
        }
    }
    return contents;
}

/**
 
 */
- (NSDictionary*) metadataDictForContentId:(NSArray*) cntIds andForKey : (NSString*) key
{
    ////nslog(@"- (NSDictionary*) metadataDictForContentId:(NSArray*) cntIds andForKey : (NSString*) key");
    NSError* error;
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"ExtendedMetadata"];
    NSPredicate *predicate;
    ////nslog(@"predicate: cntId IN %@ and fieldName == %@", cntIds, key);
    predicate = [NSPredicate predicateWithFormat:@"cntId IN %@ and fieldName == %@", cntIds, key];
    [fetchRequest setPredicate:predicate];
    NSMutableDictionary* contentIdSet = [[NSMutableDictionary alloc] init];
    
    NSArray* items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error)
    {
        if (items && items.count > 0)
        {
            //for (NSManagedObject* mo in items)
            for (ExtendedMetadata *ex in items)
            {
                //NSString* value = [mo valueForKey:@"fieldValue"];
                NSString* value = ex.fieldValue;
                if (value != nil)
                {
                    NSMutableDictionary *valsDict = [[NSMutableDictionary alloc] init];
                    NSArray* values = [value componentsSeparatedByString:@","];
                    for (NSString* val in values)
                    {
                        //                        if (![contents containsObject:val])
                        //                            [contents addObject:val];
                        if (![valsDict objectForKey:val])
                        {
                            [valsDict setObject:[NSNumber numberWithInt:[val intValue]] forKey:val];
                        }
                    }
                    //vijay, original code
                    //[contentIdSet setObject:[mo valueForKey:@"cntId"] forKey:contents];
                    // jerry, change to make contentId the key
                    //[contentIdSet setObject:valsDict.allKeys forKey:[[mo valueForKey:@"cntId"] stringValue]];
                    [contentIdSet setObject:valsDict.allKeys forKey:[ex.cntId stringValue]];
                }
            }
        }
    }
    return contentIdSet;
}

/**
 */
- (NSString*) getArcNameForId : (int) arcId {
    
    for (NSManagedObject* mo in _arcSteps) {
        if ([[mo valueForKey:@"arcCatId"] intValue] == arcId) {
            return [mo valueForKey:@"name"];
        }
    }
    return @"";
}

/**
 */
- (int) getArcCatIdForName : (NSString*) name {
    
    for (NSManagedObject* mo in _arcSteps) {
        if ([[mo valueForKey:@"name"] isEqualToString:name]) {
            return [[mo valueForKey:@"arcCatId"] intValue];
        }
    }
    return 0;
}

/**
 */
- (NSArray*) getArcSteps {
    
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"ArcCategory"];
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return items;
}

- (Procedure*) procedureWithProcId:(int)procId
{
    Procedure *procedure;
    
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Procedure"];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"procId = %d", procId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error)
    {
        if (items && items.count > 0)
        {
            procedure = [items objectAtIndex:0];
        }
    }
    
    return procedure;
}

- (void) dumpExtendedMetaData
{
    NSError* error;
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"ExtendedMetadata"];
    
    //nslog(@"dumping ExtendedMetaData");
    NSArray* items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error)
    {
        if (items && items.count > 0)
        {
            for (ExtendedMetadata *ex in items)
            {
                /*
                 @property (nonatomic, retain) NSNumber * cntExtFieldId;
                 @property (nonatomic, retain) NSNumber * cntId;
                 @property (nonatomic, retain) NSString * fieldName;
                 @property (nonatomic, retain) NSString * fieldValue;
                 @property (nonatomic, retain) NSNumber * status;
                 */
                //nslog(@"cntExtFieldId: %d cntId: %d fieldName: %@ fieldValue: %@ status: %d", [ex.cntExtFieldId intValue], [ex.cntId intValue], ex.fieldName, ex.fieldValue, [ex.status intValue]);
            }
        }
    }
}

@end
