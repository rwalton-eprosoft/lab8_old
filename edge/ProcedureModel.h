//
//  ProcedureModel.h
//  edge
//
//  Created by Vijay on 10/04/13.
//  Copyright (c) 2013 eprosoft. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Procedure;

@interface ProcedureModel : NSObject

@property (atomic, strong) NSArray* arcSteps;

+ (ProcedureModel*) sharedInstance;

- (NSArray*) arcStepsForProcedure:(int) procId andForSpeciality: (int) spltId;
- (NSArray*) concernsForProcedure:(int) procId andForSpeciality: (int) spltId;
- (NSMutableArray*) productsForProcedure:(int) procId andForSpeciality: (int) spltId andForArcStepName: (NSString*) name;
- (NSMutableArray*) productsForProcedure:(int) procId andForSpeciality: (int) spltId andForArcStepName: (NSString*) name  andForProcStepID: (int) stepId;
- (NSMutableArray*) productsForConcerns:(int) procId andForSpeciality: (int) spltId andForArcStepName: (NSString*) name  andForConcernId: (int) concernId;
- (NSMutableArray*) metadataForContentId:(NSArray*) cntIds andForKey : (NSString*) key;
- (NSDictionary*) metadataDictForContentId:(NSArray*) cntIds andForKey : (NSString*) key;

- (NSArray*) getArcSteps;

- (Procedure*) procedureWithProcId:(int)procId;

- (void) dumpExtendedMetaData;

@end