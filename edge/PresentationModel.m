//
//  PresentationModel.m
//  edge
//
//  Created by Vijay on 10/06/13.
//  Copyright (c) 2013 eprosoft. All rights reserved.
//

#import "PresentationModel.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "ContentModel.h"

@interface PresentationModel ()
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, assign) NSManagedObjectContext *managedObjectContext;
@end

@implementation PresentationModel

/**
 */
+ (PresentationModel*) sharedInstance
{
    static PresentationModel *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[PresentationModel alloc] init];
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

- (int) contentCatIdsForContentCatName : (NSString*) name
{
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"ContentCategory"];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error)
    {
        if (items && items.count > 0)
        {
            return [[[items objectAtIndex:0] valueForKey:@"contentCatId"] intValue];
        }
    }
    return 0;
}

/**
 */
- (NSArray*) contentForContentCatId : (int) cntCatId
{
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Content"];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"contentCatId = %d", cntCatId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error)
    {
        if (items && items.count > 0)
        {
            return items;
        }
    }
    
    return nil;
}

/**
 */
- (NSArray*) contentForContentIds : (NSString*) cntIds
{
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Content"];
    
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"cntId IN %@", [cntIds componentsSeparatedByString:@","]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error)
    {
        if (items && items.count > 0)
        {
            return items;
        }
    }
    
    return nil;
}

/**
 */
- (NSMutableArray *)getCntIds
{
    NSMutableArray *cntIds = [NSMutableArray array];
    NSArray* contents = [self contentForContentCatId: kSpecialtyPresentations];
    for (NSManagedObject *mo in contents)
    {
        [cntIds addObject:[mo valueForKey:@"cntId"]];
    }
    
    return cntIds;
}

- (NSMutableDictionary *)preparePresentationsJSON:(NSArray *)contents mo:(NSManagedObject *)mo
{
    NSMutableDictionary *contentDictionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableArray *array = [NSMutableArray array];
    if ([contentDictionary objectForKey:@"prstId"] == nil) {
        [contentDictionary setObject:[self presentationTitle:[[mo valueForKey:@"cntId"] intValue] :contents] forKey:@"prstId"];
        [contentDictionary setObject:[self presentationId:[[mo valueForKey:@"cntId"] intValue] :contents] forKey:@"Id"];
        [contentDictionary setObject:[self presentationPath:[[mo valueForKey:@"cntId"] intValue] :contents] forKey:@"path"];

    }
    
    //NSArray *array1 = [self processPath:[mo valueForKey:@"fieldValue"]];
   //[contentDictionary setObject:array1 forKey:@"cntId"];
    
    [array addObject:contentDictionary];
    [dict setObject:array forKey:@"SpecialtyPresentations"];
    return dict;
}

/**
 */
- (NSMutableArray*) pathsForPresentations
{
    NSMutableArray* presentations = [[NSMutableArray alloc] init];
    
    NSArray* contents = [self contentForContentCatId: kSpecialtyPresentations];
    //NSArray *items = [self metadataContentIds : contents];
    //if (items && items.count > 0)
    //{
        for (NSManagedObject* mo in contents) {
            NSMutableDictionary *dict;
            dict = [self preparePresentationsJSON:contents mo:mo];
            [presentations addObject:dict];
        }
        return presentations;
   // }
    //return nil;
}

- (NSMutableArray*) pathsForMetadataPresentations
{
    NSMutableArray* presentations = [[NSMutableArray alloc] init];
    
    NSArray* contents = [self contentForContentCatId: kSpecialtyPresentations];
    NSArray *items = [self metadataContentIds : contents];
    if (items && items.count > 0)
    {
    for (NSManagedObject* mo in items) {
        NSMutableDictionary *dict;
        dict = [self prepareMetaPresentationsJSON:contents mo:mo];
        [presentations addObject:dict];
    }
    return presentations;
     }
    return nil;
}

- (NSMutableDictionary *)prepareMetaPresentationsJSON:(NSArray *)contents mo:(NSManagedObject *)mo
{
    NSMutableDictionary *contentDictionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableArray *array = [NSMutableArray array];
    if ([contentDictionary objectForKey:@"prstId"] == nil) {
        [contentDictionary setObject:[self presentationTitle:[[mo valueForKey:@"cntId"] intValue] :contents] forKey:@"prstId"];
        [contentDictionary setObject:[self presentationId:[[mo valueForKey:@"cntId"] intValue] :contents] forKey:@"Id"];
        [contentDictionary setObject:[self presentationPath:[[mo valueForKey:@"cntId"] intValue] :contents] forKey:@"path"];
        
    }
    
    NSArray *array1 = [self processPath:[mo valueForKey:@"fieldValue"]];
    [contentDictionary setObject:array1 forKey:@"cntId"];
    
    [array addObject:contentDictionary];
    [dict setObject:array forKey:@"SpecialtyPresentations"];
    return dict;
}

/**
 */
- (NSArray*) presentationContent
{
    NSMutableArray* prContents = [[NSMutableArray alloc] init];
    NSArray* contents = [self contentForContentCatId: kSpecialtyPresentations];
    NSArray *items = [self metadataContentIds : contents];
    
    if (items != nil && items.count > 0) {
        
        for (NSManagedObject* mo in items) {
            NSArray* values = [self contentForContentIds:[mo valueForKey:@"fieldValue"]];
            for (NSManagedObject* value in values) {
                [prContents addObject:value];
            }
        }
    }
    return prContents;
}
- (NSArray*) presentationPathContent
{
    NSMutableArray* prContents = [[NSMutableArray alloc] init];
    NSArray* contents = [self contentForContentCatId: [self contentCatIdsForContentCatName:@"SpecialtyPresentations"]];
    for (NSManagedObject* value in contents) {
        [prContents addObject:value];
    }
    return prContents;
}
/**
 
 */
- (NSArray*) metadataContentIds : (NSArray*) contents {
    
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"ExtendedMetadata"];
    NSPredicate *predicate;
    NSMutableArray *cntIds;
    cntIds = [NSMutableArray array];

    for (NSManagedObject *mo in contents)
    {
        [cntIds addObject:[mo valueForKey:@"cntId"]];
    }
    
    predicate = [NSPredicate predicateWithFormat:@"cntId IN %@", cntIds];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return items;
}

/**
 */
- (NSArray*) processPath : (NSString*) cntIds
{
    NSMutableArray* paths = [[NSMutableArray alloc] init];
    if (cntIds != nil)
    {
        NSArray* contents = [self contentForContentIds:cntIds];
        for (NSManagedObject* mo in contents)
        {
           [paths addObject: [mo valueForKey:@"path"]];
        }
    }
    return paths;
}

- (NSString*) presentationTitle : (int) cntId :(NSArray*) contents
{
    for (NSManagedObject* mo in contents)
    {
        if ([[mo valueForKey:@"cntId"] intValue] == cntId)
        {
            return [mo valueForKey:@"title"];
        }
    }
    return nil;
}

- (NSString*) presentationId : (int) cntId :(NSArray*) contents
{
    for (NSManagedObject* mo in contents)
    {
        if ([[mo valueForKey:@"cntId"] intValue] == cntId)
        {
            return [mo valueForKey:@"cntId"];
        }
    }
    return nil;
}

- (NSString*) presentationPath : (int) cntId :(NSArray*) contents
{
    for (NSManagedObject* mo in contents)
    {
        if ([[mo valueForKey:@"cntId"] intValue] == cntId)
        {
            return [mo valueForKey:@"path"];
        }
    }
    return nil;
}

@end



