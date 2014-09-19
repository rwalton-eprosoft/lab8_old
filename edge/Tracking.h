//
//  Tracking.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tracking : NSManagedObject

@property (nonatomic, retain) NSString * activityCode;
@property (nonatomic, retain) NSString * resources;
@property (nonatomic, retain) NSString * timestamp;
@property (nonatomic, retain) NSString * userName;

@end
