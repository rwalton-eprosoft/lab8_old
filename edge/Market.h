//
//  Market.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

@interface Market : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * mktId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSSet *marketToProduct;
@end

@interface Market (CoreDataGeneratedAccessors)

- (void)addMarketToProductObject:(Product *)value;
- (void)removeMarketToProductObject:(Product *)value;
- (void)addMarketToProduct:(NSSet *)values;
- (void)removeMarketToProduct:(NSSet *)values;

@end
