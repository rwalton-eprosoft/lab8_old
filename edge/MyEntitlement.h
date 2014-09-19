//
//  MyEntitlement.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MyProfile, Speciality;

@interface MyEntitlement : NSManagedObject

@property (nonatomic, retain) NSDate * contentUpdDt;
@property (nonatomic, retain) NSNumber * isDefault;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * splId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * totalFiles;
@property (nonatomic, retain) NSDecimalNumber * totalSize;
@property (nonatomic, retain) MyProfile *myEntitlementToMyProfile;
@property (nonatomic, retain) Speciality *myEntitlementToSpeciality;

@end
