//
//  MyProfile.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MyEntitlement;

@interface MyProfile : NSManagedObject

@property (nonatomic, retain) NSString * addrLine1;
@property (nonatomic, retain) NSString * addrLine2;
@property (nonatomic, retain) NSDate * contentUpdDt;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSDate * crtDt;
@property (nonatomic, retain) NSString * department;
@property (nonatomic, retain) NSString * division;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * market;
@property (nonatomic, retain) NSNumber * primaryPhone;
@property (nonatomic, retain) NSNumber * profId;
@property (nonatomic, retain) NSString * profilePhoto;
@property (nonatomic, retain) NSString * repType;
@property (nonatomic, retain) NSString * role;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSDate * uptDt;
@property (nonatomic, retain) NSString * zipcode;
@property (nonatomic, retain) NSSet *myProfileToMyEntitlement;
@end

@interface MyProfile (CoreDataGeneratedAccessors)

- (void)addMyProfileToMyEntitlementObject:(MyEntitlement *)value;
- (void)removeMyProfileToMyEntitlementObject:(MyEntitlement *)value;
- (void)addMyProfileToMyEntitlement:(NSSet *)values;
- (void)removeMyProfileToMyEntitlement:(NSSet *)values;

@end
