//
//  ContentSearch.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ContentSearch : NSManagedObject

@property (nonatomic, retain) NSNumber * catId;
@property (nonatomic, retain) NSString * catName;
@property (nonatomic, retain) NSNumber * cntId;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * keywords;
@property (nonatomic, retain) NSNumber * medCatId;
@property (nonatomic, retain) NSString * medCatName;
@property (nonatomic, retain) NSNumber * medId;
@property (nonatomic, retain) NSString * medName;
@property (nonatomic, retain) NSString * mime;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * prodCatName;
@property (nonatomic, retain) NSString * thumbnailImgPath;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * uptDt;

@end
