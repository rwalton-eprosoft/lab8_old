//
//  ProcedureStep.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Concern, Procedure, Product;

@interface ProcedureStep : NSManagedObject

@property (nonatomic, retain) NSNumber * arcCatId;
@property (nonatomic, retain) NSNumber * crtBy;
@property (nonatomic, retain) NSDate * crtDt;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * procStepId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * uptBy;
@property (nonatomic, retain) NSDate * uptDt;
@property (nonatomic, retain) NSSet *procedureStepToConcern;
@property (nonatomic, retain) NSSet *procedureStepToProcedure;
@property (nonatomic, retain) NSSet *procedureStepToProduct;
@end

@interface ProcedureStep (CoreDataGeneratedAccessors)

- (void)addProcedureStepToConcernObject:(Concern *)value;
- (void)removeProcedureStepToConcernObject:(Concern *)value;
- (void)addProcedureStepToConcern:(NSSet *)values;
- (void)removeProcedureStepToConcern:(NSSet *)values;

- (void)addProcedureStepToProcedureObject:(Procedure *)value;
- (void)removeProcedureStepToProcedureObject:(Procedure *)value;
- (void)addProcedureStepToProcedure:(NSSet *)values;
- (void)removeProcedureStepToProcedure:(NSSet *)values;

- (void)addProcedureStepToProductObject:(Product *)value;
- (void)removeProcedureStepToProductObject:(Product *)value;
- (void)addProcedureStepToProduct:(NSSet *)values;
- (void)removeProcedureStepToProduct:(NSSet *)values;

@end
