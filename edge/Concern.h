//
//  Concern.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ProcedureStep, Product;

@interface Concern : NSManagedObject

@property (nonatomic, retain) NSNumber * arcCatId;
@property (nonatomic, retain) NSNumber * concernId;
@property (nonatomic, retain) NSNumber * crtBy;
@property (nonatomic, retain) NSDate * crtDt;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * uptBy;
@property (nonatomic, retain) NSDate * uptDt;
@property (nonatomic, retain) NSSet *concernToProcedureStep;
@property (nonatomic, retain) NSSet *concernToProduct;
@end

@interface Concern (CoreDataGeneratedAccessors)

- (void)addConcernToProcedureStepObject:(ProcedureStep *)value;
- (void)removeConcernToProcedureStepObject:(ProcedureStep *)value;
- (void)addConcernToProcedureStep:(NSSet *)values;
- (void)removeConcernToProcedureStep:(NSSet *)values;

- (void)addConcernToProductObject:(Product *)value;
- (void)removeConcernToProductObject:(Product *)value;
- (void)addConcernToProduct:(NSSet *)values;
- (void)removeConcernToProduct:(NSSet *)values;

@end
