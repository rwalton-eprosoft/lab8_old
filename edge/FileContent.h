//
//  FileContent.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FileContent : NSManagedObject

@property (nonatomic, retain) NSNumber * cntId;
@property (nonatomic, retain) NSString * downloadStatus;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSNumber * splId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * type;

@end
