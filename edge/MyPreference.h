//
//  MyPreference.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MyPreference : NSManagedObject

@property (nonatomic, retain) NSDate * crtDt;
@property (nonatomic, retain) NSNumber * prefId;
@property (nonatomic, retain) NSString * prefKey;
@property (nonatomic, retain) NSString * prefValue;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSDate * uptDt;

@end
