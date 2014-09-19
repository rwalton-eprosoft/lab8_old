//
//  SpecialtyHotSpot.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SpecialtyHotSpot : NSManagedObject

@property (nonatomic, retain) NSNumber * cntId;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * procId;
@property (nonatomic, retain) NSNumber * splId;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;

@end
