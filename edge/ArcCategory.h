//
//  ArcCategory.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ArcCategory : NSManagedObject

@property (nonatomic, retain) NSNumber * arcCatId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * status;

@end
