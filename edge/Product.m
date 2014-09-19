//
//  Product.m
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import "Product.h"
#import "CompProduct.h"
#import "Concern.h"
#import "Market.h"
#import "Procedure.h"
#import "ProcedureStep.h"
#import "ProductCategory.h"


@implementation Product

@dynamic arcId;
@dynamic code;
@dynamic crtBy;
@dynamic crtDt;
@dynamic desc;
@dynamic mktId;
@dynamic name;
@dynamic prodCatId;
@dynamic prodId;
@dynamic sku;
@dynamic status;
@dynamic uptBy;
@dynamic uptDt;
@dynamic productToCompProduct;
@dynamic productToConcern;
@dynamic productToMarket;
@dynamic productToProcedure;
@dynamic productToProcedureStep;
@dynamic productToProdCat;

@end
