//
//  Speciality.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MyEntitlement, Procedure;

@interface Speciality : NSManagedObject

@property (nonatomic, retain) NSNumber * crtBy;
@property (nonatomic, retain) NSDate * crtDt;
@property (nonatomic, retain) NSDate * lastSyncDt;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * splCatId;
@property (nonatomic, retain) NSNumber * splId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * uptBy;
@property (nonatomic, retain) NSDate * uptDt;
@property (nonatomic, retain) MyEntitlement *specialityToMyEntitlement;
@property (nonatomic, retain) NSSet *specialityToProcedure;
@end

@interface Speciality (CoreDataGeneratedAccessors)

- (void)addSpecialityToProcedureObject:(Procedure *)value;
- (void)removeSpecialityToProcedureObject:(Procedure *)value;
- (void)addSpecialityToProcedure:(NSSet *)values;
- (void)removeSpecialityToProcedure:(NSSet *)values;

@end
