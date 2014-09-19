//
//  ProcedureStepToProductNew.h
//  edge
//
//  Created by Ryan G Walton on 9/17/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ProcedureStepToProductNew : NSManagedObject

@property (nonatomic, retain) NSNumber * arcCatId;
@property (nonatomic, retain) NSNumber * crtBy;
@property (nonatomic, retain) NSDate * crtDt;
@property (nonatomic, retain) NSNumber * procStepId;
@property (nonatomic, retain) NSNumber * prodId;
@property (nonatomic, retain) NSNumber * prodProcStepId;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * uptBy;
@property (nonatomic, retain) NSDate * uptDt;

@end
