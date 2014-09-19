//
//  Procedure.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ProcedureStep, Product, Speciality;

@interface Procedure : NSManagedObject

@property (nonatomic, retain) NSNumber * crtBy;
@property (nonatomic, retain) NSDate * crtDt;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * procId;
@property (nonatomic, retain) NSNumber * splId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * uptBy;
@property (nonatomic, retain) NSDate * uptDt;
@property (nonatomic, retain) NSSet *procedureToProcedureStep;
@property (nonatomic, retain) NSSet *procedureToProduct;
@property (nonatomic, retain) Speciality *procedureToSpeciality;
@end

@interface Procedure (CoreDataGeneratedAccessors)

- (void)addProcedureToProcedureStepObject:(ProcedureStep *)value;
- (void)removeProcedureToProcedureStepObject:(ProcedureStep *)value;
- (void)addProcedureToProcedureStep:(NSSet *)values;
- (void)removeProcedureToProcedureStep:(NSSet *)values;

- (void)addProcedureToProductObject:(Product *)value;
- (void)removeProcedureToProductObject:(Product *)value;
- (void)addProcedureToProduct:(NSSet *)values;
- (void)removeProcedureToProduct:(NSSet *)values;

@end
