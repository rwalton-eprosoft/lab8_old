//
//  InteractiveViewerModel.m
//  edge
//
//  Created by Vijaykumar on 11/13/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "InteractiveViewerModel.h"
#import "PresentationModel.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "ContentModel.h"
#import "ContentSearchModel.h"

#define APP_DELEGATE (AppDelegate*)[[UIApplication sharedApplication] delegate]

@interface InteractiveViewerModel ()
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, assign) NSManagedObjectContext *managedObjectContext;
@end

@implementation InteractiveViewerModel

/**
 */
+ (InteractiveViewerModel*) sharedInstance
{
    static InteractiveViewerModel *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[InteractiveViewerModel alloc] init];
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

/**
 */
- (NSArray*) fetchContent
{
    NSError* error;
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Content"];
    
    return [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (NSArray*) fetchContentMapping : (NSNumber*) medId : (NSNumber*) medCatId {
    
    NSError* error;
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"ContentMapping"];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"medId == %d and medCatId == %d", [medId intValue], [medCatId intValue]];
    [fetchRequest setPredicate:predicate];
    
    return [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

/**
 */
- (NSArray*) fetchPaths:(NSNumber *)medId targetAudience:(NSNumber *)targetAudience medCatId:(NSNumber*) medCatId : (NSNumber*) contentCatId withRelevantProcs : (NSNumber*) relevantProcedure {
    
    //Fetch records matching spltId from ContentMapping
    NSMutableArray* paths = [[NSMutableArray alloc] init];
    NSArray* contentMappings = [self fetchContentMapping:medId :medCatId];
    NSMutableArray* cntIds = [[NSMutableArray alloc] init];
    for (NSManagedObject* mo in contentMappings) {
        [cntIds addObject:[mo valueForKey:@"cntId"]];
    }
    
    if (cntIds != nil && cntIds.count > 0) {
        NSError* error;
        NSFetchRequest* fetchRequest = [self fetchRequestWithEntity:@"ExtendedMetadata"];
        NSPredicate *predicate;
        predicate = [NSPredicate predicateWithFormat:@"fieldName == 'TARGETAUDIENCE' and fieldValue CONTAINS[cd] %@ and cntId in %@", targetAudience, cntIds];
        [fetchRequest setPredicate:predicate];
        
        NSArray* metadata = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        [cntIds removeAllObjects];
        for (NSManagedObject* mo in metadata) {
            [cntIds addObject:[mo valueForKey:@"cntId"]];
        }
        
        if (relevantProcedure != nil) {
            
            predicate = [NSPredicate predicateWithFormat:@"fieldName == 'RELEVANTPROCEDURES' and fieldValue CONTAINS[cd] %@ and cntId in %@", relevantProcedure, cntIds];
            [fetchRequest setPredicate:predicate];
            
            NSArray* metadata = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            [cntIds removeAllObjects];
            for (NSManagedObject* mo in metadata) {
                NSArray * list = [[mo valueForKey:@"fieldValue"] componentsSeparatedByString:@","];
                for (NSString* val in list) {
                    if ([val isEqualToString:[relevantProcedure stringValue]])
                        [cntIds addObject:[mo valueForKey:@"cntId"]];
                }
            }
        }
        
        fetchRequest = [self fetchRequestWithEntity:@"Content"];
        NSPredicate *predicate1;
        predicate1 = [NSPredicate predicateWithFormat:@"cntId in %@ and contentCatId == %@", cntIds, contentCatId];
        [fetchRequest setPredicate:predicate1];
        NSArray* contents = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        for (NSManagedObject* mo in contents) {
            [paths addObject:[mo valueForKey:@"path"]];
        }
    }
    return paths;
}

- (NSNumber*) fetchMedCatIdForName : (NSString*) medCatName {
    NSArray* medicalCategory = [[ContentSearchModel sharedInstance] fetchMedicalCategory];
    for (NSManagedObject* mo in medicalCategory) {
        if ([[[mo valueForKey:@"name"] lowercaseString] isEqualToString:[medCatName lowercaseString]]) {
            return [mo valueForKey:@"medCatId"];
        }
    }
    return nil;
}

/**
 */
- (NSArray*) fetchSpecialtyIV : (NSNumber*) spltId withTarget: (NSNumber*) targetAudience {
    
    NSArray* spltIV = [self fetchPaths:spltId targetAudience:targetAudience medCatId:[self fetchMedCatIdForName:@"Specialty"] :[NSNumber numberWithInt:56] withRelevantProcs:[NSNumber numberWithInt:0]];
    
    if (spltIV == nil || spltIV.count <= 0) { //if there are no Speciality IV, use default target audience
        spltIV = [self fetchPaths:spltId targetAudience:[NSNumber numberWithInt:0] medCatId:[self fetchMedCatIdForName:@"Specialty"] :[NSNumber numberWithInt:56] withRelevantProcs:nil];
    }
    //NSLog(@"SpecialtyIV Paths  %@", spltIV);
    return spltIV;
}

/**
 */
- (NSArray*) fetchProcedureIV : (NSNumber*) procID withTarget : (NSNumber*) targetAudience {
    
    NSArray* procIV = [self fetchPaths:procID targetAudience:targetAudience medCatId:[self fetchMedCatIdForName:@"Procedure"] :[NSNumber numberWithInt:57] withRelevantProcs:[NSNumber numberWithInt:0]];
    
    if (procIV == nil || procIV.count <= 0) { //Default Audience
        procIV = [self fetchPaths:procID targetAudience:[NSNumber numberWithInt:0] medCatId:[self fetchMedCatIdForName:@"Procedure"] :[NSNumber numberWithInt:57] withRelevantProcs:nil];
    }
    //NSLog(@"ProcedureIV Paths  %@", procIV);
    return procIV;
}

/**
 */
- (NSArray*) fetchProductIV   : (NSNumber*) prodID withTarget : (NSNumber*) targetAudience : (NSNumber*) relavantProcId {
    
    NSArray* paths = [self fetchPaths:prodID targetAudience:targetAudience medCatId:[self fetchMedCatIdForName:@"Product"] :[NSNumber numberWithInt:58] withRelevantProcs:relavantProcId]; //Selected Audience and Selected procedure
    
    if (paths == nil || paths.count <= 0) {
        paths = [self fetchPaths:prodID targetAudience:targetAudience medCatId:[self fetchMedCatIdForName:@"Product"] :[NSNumber numberWithInt:58] withRelevantProcs:[NSNumber numberWithInt:0]]; //Selected Audience and Default Procedure
        
        if (paths == nil || paths.count <= 0) {
            paths = [self fetchPaths:prodID targetAudience:[NSNumber numberWithInt:0] medCatId:[self fetchMedCatIdForName:@"Product"] :[NSNumber numberWithInt:58] withRelevantProcs:relavantProcId]; //Default Audience and Selected Procedure
            
            if (paths == nil || paths.count <= 0) {
                paths = [self fetchPaths:prodID targetAudience:[NSNumber numberWithInt:0] medCatId:[self fetchMedCatIdForName:@"Product"] :[NSNumber numberWithInt:58] withRelevantProcs:[NSNumber numberWithInt:0]]; //Default Audience and Default procedure
            }
        }
    }
    return paths;
}

/**
 */
- (NSArray*) fetchProductClinicalMsg   : (NSNumber*) prodID withTarget : (NSNumber*) targetAudience withRelevantProcedure : (NSNumber*) relavantProcId {
    
    NSArray* clinicalMsg = [self fetchPaths:prodID targetAudience:targetAudience medCatId:[self fetchMedCatIdForName:@"Product"] :[NSNumber numberWithInt:kProductClinicalMessage] withRelevantProcs:relavantProcId];
    
    if (clinicalMsg == nil || clinicalMsg.count <= 0) {
        clinicalMsg =  [self fetchPaths:prodID targetAudience:targetAudience medCatId:[self fetchMedCatIdForName:@"Product"] :[NSNumber numberWithInt:kProductClinicalMessage] withRelevantProcs:[NSNumber numberWithInt:0]];
        if (clinicalMsg == nil || clinicalMsg.count <= 0) {
            clinicalMsg =  [self fetchPaths:prodID targetAudience:[NSNumber numberWithInt:0] medCatId:[self fetchMedCatIdForName:@"Product"] :[NSNumber numberWithInt:kProductClinicalMessage] withRelevantProcs:relavantProcId];
            if (clinicalMsg == nil || clinicalMsg.count <= 0) {
                clinicalMsg =  [self fetchPaths:prodID targetAudience:[NSNumber numberWithInt:0] medCatId:[self fetchMedCatIdForName:@"Product"] :[NSNumber numberWithInt:kProductClinicalMessage] withRelevantProcs:[NSNumber numberWithInt:0]];
            }
        }
    }
    
    return clinicalMsg;
}

/**
 */
- (NSArray*) fetchProductNonClinicalMsg   : (NSNumber*) prodID withTarget : (NSNumber*) targetAudience withRelevantProcedure : (NSNumber*) relavantProcId {
    
    NSArray* nonClinicalMsg = [self fetchPaths:prodID targetAudience:targetAudience medCatId:[self fetchMedCatIdForName:@"Product"] :[NSNumber numberWithInt:kProductNonClinicalMessage] withRelevantProcs:relavantProcId];
    
    if (nonClinicalMsg == nil || nonClinicalMsg.count <= 0) {
        nonClinicalMsg = [self fetchPaths:prodID targetAudience:targetAudience medCatId:[self fetchMedCatIdForName:@"Product"] :[NSNumber numberWithInt:kProductNonClinicalMessage] withRelevantProcs:[NSNumber numberWithInt:0]];
        if (nonClinicalMsg == nil || nonClinicalMsg.count <= 0) {
            nonClinicalMsg = [self fetchPaths:prodID targetAudience:[NSNumber numberWithInt:0] medCatId:[self fetchMedCatIdForName:@"Product"] :[NSNumber numberWithInt:kProductNonClinicalMessage] withRelevantProcs:relavantProcId];
            if (nonClinicalMsg == nil || nonClinicalMsg.count <= 0) {
                nonClinicalMsg = [self fetchPaths:prodID targetAudience:[NSNumber numberWithInt:0] medCatId:[self fetchMedCatIdForName:@"Product"] :[NSNumber numberWithInt:kProductNonClinicalMessage] withRelevantProcs:[NSNumber numberWithInt:0]];
            }
        }
    }
    
    return nonClinicalMsg;
}

@end
