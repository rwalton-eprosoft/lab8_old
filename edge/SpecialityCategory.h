//
//  SpecialityCategory.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SpecialityCategory : NSManagedObject

@property (nonatomic, retain) NSNumber * crtBy;
@property (nonatomic, retain) NSDate * crtDt;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * splCatId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * uptBy;
@property (nonatomic, retain) NSDate * uptDt;

@end
