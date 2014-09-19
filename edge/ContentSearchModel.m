//
//  ContentSearchModel.m
//  edge
//
//  Created by Vijay on 11/04/13.
//  Copyright (c) 2013 eprosoft. All rights reserved.
//

#import "ContentSearchModel.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "ContentModel.h"
#define APP_DELEGATE (AppDelegate*)[[UIApplication sharedApplication] delegate]

@interface ContentSearchModel ()
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, assign) NSManagedObjectContext *managedObjectContext;
@end

@implementation ContentSearchModel

/**
 */
+ (ContentSearchModel*) sharedInstance
{
    static ContentSearchModel *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[ContentSearchModel alloc] init];
        instance.appDelegate = [UIApplication sharedApplication].delegate;
        instance.managedObjectContext = instance.appDelegate.managedObjectContext;
    });
    return instance;
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

- (NSArray*) fetchContent
{
    NSError* error;
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Content"];
    
    return [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (Content*) fetchContentById : (int) id
{
    NSError* error;
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Content"];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"cntId = %d", id];
    [fetchRequest setPredicate:predicate];

    NSArray* items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return (items.count > 0 ? [items objectAtIndex:0] : nil);
}

- (NSArray*) fetchContentCategory
{
    NSError* error;
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"ContentCategory"];
    
    return [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (NSArray*) fetchMedicalCategory
{
    NSError* error;
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"MedicalCategory"];
    
    return [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

/**
 */
- (NSArray*) fetchContentMappingWithCntIds : (NSArray*) cntIds
{
    NSError* error;
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"ContentMapping"];
    
    return [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

/**
 */
- (void) loadContentSearch {
    
    @autoreleasepool {
    //Indexing into ContentSearch
    NSArray* contents = [self fetchContent];
    NSArray* cntIds = [self fetchContentIds:contents];
    
    NSArray* contentCategories = [self fetchContentCategory];
    NSArray* medicalCategories = [self fetchMedicalCategory];
    NSArray* contentMappings   = [self fetchContentMappingWithCntIds: cntIds];
    
    NSArray* medIds = [[NSArray alloc] init];//[self fetchMedIdsIdsFor:kMedCatIdSpeciality :contentMappings];
    NSArray* specialities      = [self fetchSpecialitiesForMedIds: medIds];
    
    //medIds = [self fetchMedIdsIdsFor:kMedCatIdProcedure :contentMappings];
    NSArray* procedures      = [self fetchProceduresForMedIds: medIds];

    //
    NSArray* productCategories = [self fetchProductCategories];
    NSArray* products          = [self fetchProducts];
    
    NSManagedObjectContext* context = [APP_DELEGATE managedObjectContext];
    for (NSManagedObject* contentMapping in contentMappings) {

        NSManagedObject *managedObject = nil;
        NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
        [data setValue:[contentMapping valueForKey:@"cntMapId"] forKey:@"id"];

        NSArray *array = [self fetchManagedObjectByPrimaryKey:data withManagedObjectContext:context forEntityName:@"ContentSearch"];
        BOOL isRecordExist = (array.count > 0);
        if (isRecordExist)
            managedObject = [array objectAtIndex:0];
        else {
            managedObject = [NSEntityDescription
                            insertNewObjectForEntityForName:@"ContentSearch"
                            inManagedObjectContext:context];
        }
        
        NSNumber* medId = [contentMapping valueForKey:@"medId"];
        [managedObject setValue:medId forKey:@"medId"];

        NSNumber* cntId = [contentMapping valueForKey:@"cntId"];
        [self setContentData:cntId  :managedObject :contents];
        [managedObject setValue:[contentMapping valueForKey:@"cntMapId"] forKey:@"id"];

        //Set Content Category
        NSNumber* cntCatId = [managedObject valueForKey:@"catId"];
        NSString* cntCatName = [self getContentCategoryName:cntCatId :contentCategories];
        [managedObject setValue:cntCatName forKey:@"catName"];

        //Set Medical Category
        NSNumber* medCatId = [contentMapping valueForKey:@"medCatId"];
        [managedObject setValue:medCatId forKey:@"medCatId"];
        NSString* medCatName = [self getMedicalCategoryName :medCatId :medicalCategories];
        [managedObject setValue:medCatName forKey:@"medCatName"];
        
        //
        if ([[contentMapping valueForKey:@"medCatId"] intValue] == kMedCatIdSpeciality)
            [managedObject setValue:[self getSpecialityName :medId :specialities] forKey:@"medName"];
        
        if ([[contentMapping valueForKey:@"medCatId"] intValue] == kMedCatIdProcedure)
            [managedObject setValue:[self getProcedureName  :medId :procedures] forKey:@"medName"];

        if ([[contentMapping valueForKey:@"medCatId"] intValue] == kMedCatIdProduct)
            [managedObject setValue:[self getProductCategoryName :medId :products :productCategories] forKey:@"prodCatName"];

    }

    NSError* error;
    if (![context save:&error])
    {
        
    }//nslog(@"Couldn't save: %@", [error localizedDescription]);
    }
}

/**
 */
- (void) setContentData:(NSNumber*) cntId :(NSManagedObject*) managedObject :(NSArray*) contents {
    
    for (NSManagedObject* content in contents) {
        if ([[content valueForKey:@"cntId"] intValue] == [cntId intValue]) {
            [managedObject setValue:cntId forKey:@"cntId"];
            [managedObject setValue:[content valueForKey:@"title"] forKey:@"title"];
            [managedObject setValue:[content valueForKey:@"keywords"] forKey:@"keywords"];
            [managedObject setValue:[content valueForKey:@"thumbnailImgPath"] forKey:@"thumbnailImgPath"];
            [managedObject setValue:[content valueForKey:@"path"] forKey:@"path"];
            [managedObject setValue:[content valueForKey:@"uptDt"] forKey:@"uptDt"];
            [managedObject setValue:[content valueForKey:@"contentCatId"] forKey:@"catId"];
            [managedObject setValue:[content valueForKey:@"mime"] forKey:@"mime"];
        }
    }
}

/**
 */
- (NSArray*) fetchSpecialitiesForMedIds : (NSArray*) medIds
{
    NSError* error;
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Speciality"];
    
//    NSPredicate *predicate;
//    predicate = [NSPredicate predicateWithFormat:@"medCatId in %@", medIds];
//    [fetchRequest setPredicate:predicate];

    return [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

/**
 */
- (NSArray*) fetchProceduresForMedIds : (NSArray*) medIds
{
    NSError* error;
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Procedure"];
    
    //    NSPredicate *predicate;
    //    predicate = [NSPredicate predicateWithFormat:@"medCatId in %@", medIds];
    //    [fetchRequest setPredicate:predicate];
    
    return [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

/**
 */
- (NSArray*) fetchProductCategories
{
    NSError* error;
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"ProductCategory"];
    
    //    NSPredicate *predicate;
    //    predicate = [NSPredicate predicateWithFormat:@"medCatId in %@", medIds];
    //    [fetchRequest setPredicate:predicate];
    
    return [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

/**
 */
- (NSArray*) fetchProducts
{
    NSError* error;
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Product"];
    
    //    NSPredicate *predicate;
    //    predicate = [NSPredicate predicateWithFormat:@"medCatId in %@", medIds];
    //    [fetchRequest setPredicate:predicate];
    
    return [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

/**
 */
- (NSArray*) fetchMedIdsIdsFor: (int) medCatId :(NSArray*) contentMappings  {
    
    NSMutableArray* medCatIds = [[NSMutableArray alloc] init];
    for (NSManagedObject* contentMapping in contentMappings) {
        if ([[contentMapping valueForKey:@"medCatId"] intValue] == medCatId) {
            [medCatIds addObject:[contentMapping valueForKey:@"medId"]];
        }
    }
    return medCatIds;
}

/**
 */
- (NSString*) getContentCategoryName : (NSNumber*) contentCatId : (NSArray*) contentCategories {
    
    for (NSManagedObject* contentCategory in contentCategories) {
        if ([[contentCategory valueForKey:@"contentCatId"] intValue] == [contentCatId intValue]) {
            return [contentCategory valueForKey:@"name"];
        }
    }
    return @"";
}

/**
 */
- (NSString*) getProductCategoryName : (NSNumber*) medId : (NSArray*) products : (NSArray*) productCategories{
    
    for (NSManagedObject* product in products) {
        if ([[product valueForKey:@"prodId"] intValue] == [medId intValue]) {
            return [self fetchProductCategory :[product valueForKey:@"prodCatId"] : productCategories];
        }
    }
    return @"";
}

/**
 */
- (NSString*) fetchProductCategory : (NSNumber*) prodCatId : (NSArray*) productCategories {
    
    for (NSManagedObject* productCategory in productCategories) {
        if ([[productCategory valueForKey:@"prodCatId"] intValue] == [prodCatId intValue]) {
            return [productCategory valueForKey:@"name"];
        }
    }
    return @"";
}

/**
 */
- (NSString*) getSpecialityName : (NSNumber*) medId : (NSArray*) specialities {
    
    for (NSManagedObject* speciality in specialities) {
        if ([[speciality valueForKey:@"splId"] intValue] == [medId intValue]) {
            return [speciality valueForKey:@"name"];
        }
    }
    return @"";
}

/**
 */
- (NSString*) getProcedureName : (NSNumber*) medId : (NSArray*) procedures {
    
    for (NSManagedObject* procedure in procedures) {
        if ([[procedure valueForKey:@"procId"] intValue] == [medId intValue]) {
            return [procedure valueForKey:@"name"];
        }
    }
    return @"";
}

/**
 */
- (NSString*) getMedicalCategoryName : (NSNumber*) medCatId : (NSArray*) medicalCategories {
    
    for (NSManagedObject* medicalCategory in medicalCategories) {
        if ([[medicalCategory valueForKey:@"medCatId"] intValue] == [medCatId intValue]) {
            return [medicalCategory valueForKey:@"name"];
        }
    }
    return @"";
}

/**
 */
- (NSArray*) fetchContentIds: (NSArray*) contents {
    NSMutableArray* cntIds = [[NSMutableArray alloc] init];
    for (NSManagedObject* content in contents) {
        [cntIds addObject: [content valueForKey:@"cntId"]];
    }
    return cntIds;
}

/**
 * Duplication of method from DataSyncService, need to move to a Utility class
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
    else if ([entity isEqualToString:@"ContentSearch"])
        return @"id";
    else if ([entity isEqualToString:@"FileContent"])
        return @"path";
    return nil;
}

@end
