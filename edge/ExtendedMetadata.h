//
//  ExtendedMetadata.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ExtendedMetadata : NSManagedObject

@property (nonatomic, retain) NSNumber * cntExtFieldId;
@property (nonatomic, retain) NSNumber * cntId;
@property (nonatomic, retain) NSString * fieldName;
@property (nonatomic, retain) NSString * fieldValue;
@property (nonatomic, retain) NSNumber * status;

@end
