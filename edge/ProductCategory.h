//
//  ProductCategory.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

@interface ProductCategory : NSManagedObject

@property (nonatomic, retain) NSNumber * crtBy;
@property (nonatomic, retain) NSDate * crtDt;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * prodCatId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * uptBy;
@property (nonatomic, retain) NSDate * uptDt;
@property (nonatomic, retain) NSSet *prodCatToProduct;
@end

@interface ProductCategory (CoreDataGeneratedAccessors)

- (void)addProdCatToProductObject:(Product *)value;
- (void)removeProdCatToProductObject:(Product *)value;
- (void)addProdCatToProduct:(NSSet *)values;
- (void)removeProdCatToProduct:(NSSet *)values;

@end
