//
//  Product.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CompProduct, Concern, Market, Procedure, ProcedureStep, ProductCategory;

@interface Product : NSManagedObject

@property (nonatomic, retain) NSNumber * arcId;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSNumber * crtBy;
@property (nonatomic, retain) NSDate * crtDt;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * mktId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * prodCatId;
@property (nonatomic, retain) NSNumber * prodId;
@property (nonatomic, retain) NSString * sku;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * uptBy;
@property (nonatomic, retain) NSDate * uptDt;
@property (nonatomic, retain) NSSet *productToCompProduct;
@property (nonatomic, retain) NSSet *productToConcern;
@property (nonatomic, retain) Market *productToMarket;
@property (nonatomic, retain) NSSet *productToProcedure;
@property (nonatomic, retain) NSSet *productToProcedureStep;
@property (nonatomic, retain) ProductCategory *productToProdCat;
@end

@interface Product (CoreDataGeneratedAccessors)

- (void)addProductToCompProductObject:(CompProduct *)value;
- (void)removeProductToCompProductObject:(CompProduct *)value;
- (void)addProductToCompProduct:(NSSet *)values;
- (void)removeProductToCompProduct:(NSSet *)values;

- (void)addProductToConcernObject:(Concern *)value;
- (void)removeProductToConcernObject:(Concern *)value;
- (void)addProductToConcern:(NSSet *)values;
- (void)removeProductToConcern:(NSSet *)values;

- (void)addProductToProcedureObject:(Procedure *)value;
- (void)removeProductToProcedureObject:(Procedure *)value;
- (void)addProductToProcedure:(NSSet *)values;
- (void)removeProductToProcedure:(NSSet *)values;

- (void)addProductToProcedureStepObject:(ProcedureStep *)value;
- (void)removeProductToProcedureStepObject:(ProcedureStep *)value;
- (void)addProductToProcedureStep:(NSSet *)values;
- (void)removeProductToProcedureStep:(NSSet *)values;

@end
