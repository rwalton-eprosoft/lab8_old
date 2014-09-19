//
//  DashboardModel.h
//  edge
//
//  Created by iPhone Developer on 6/5/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MyEntitlement;
@class Content;
@class Product;
@class Speciality;
@class Procedure;

typedef enum dashboardItemType {
    kDashboardItemTypeStakeHolder = 0,
    kDashboardItemTypeSpeciality,
    kDashboardItemTypeMyFavorites,
    kDashboardItemTypeMyRecentlyViewed,
} DashboardItemType;

typedef enum dcustomerType {
    //kCustomerTypeDefault = 0,
    kCustomerTypeClinical = 1,
    kCustomerTypeNonClinical
} CustomerType;

#define kCustomerTypeDefault    kCustomerTypeClinical

// any of the items on the dashboard (home)
@interface DashboardItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *imageNameSelected;
@property (nonatomic, assign) DashboardItemType itemType;
@property (nonatomic, assign) CustomerType customerType;
@property (nonatomic, assign) BOOL currentSelection;
@property (nonatomic, assign) BOOL defaultSelection;
@property (nonatomic, assign) BOOL isProduct;
@property (nonatomic, weak) UIButton *itemBtn;
@property (nonatomic, assign) int itemId;
@property (nonatomic, weak) id managedObject;   // core data object

- (id) initWithTitle:(NSString*)title itemType:(int)itemType itemId:(int)itemId selected:(BOOL)selected defaultSelection:(BOOL)defaultSelection;
- (id) initWithTitle:(NSString*)title itemType:(int)itemType itemId:(int)itemId selected:(BOOL)selected defaultSelection:(BOOL)defaultSelection isProduct:(BOOL)isProduct;

@end


@interface DashboardModel : NSObject

@property (nonatomic, assign) CustomerType currentCustomerType;
@property (nonatomic, assign) int currentSpecialityId;
@property (nonatomic, assign) int currentSpecId;

@property (nonatomic, weak) MyEntitlement *currentEntitlement;

// used to identify the current selected Speciality, Procedure, Product or Content object
@property (nonatomic, strong) Content *currentContent;
@property (nonatomic, strong) Product *currentProduct;                  // selected Product on Product view flow
@property (nonatomic, strong) Speciality *currentSpeciality;
@property (nonatomic, strong) Procedure *currentProcedure;

// selected Product for specific tab views, that call up "shared" ProductDetail view
@property (nonatomic, strong) Product *currentProductProcedureFlow;     // selected Product on Procedure view flow
@property (nonatomic, strong) Product *currentProductProductsFlow;     // selected Product on Products view flow
@property (nonatomic, strong) Product *currentProductSearchFlow;        // selected Product on Search view flow

+ (DashboardModel*) sharedInstance;
- (void) initModel;
- (void) refreshDashboard;

- (NSArray*) specialities;
- (NSString*) imageNameForDashboardItemType:(int)itemType;
- (NSArray*) itemsWithDashboardItemType:(int)itemType;
- (void) dashboardItemSelected:(DashboardItem*)item;

// recently viewed
- (void) addRecentlyViewedForContent:(Content*)content;
- (void) addRecentlyViewedForProduct:(Product*)product;
- (NSArray*) recentlyViewed;
- (void) clearSelectionWithDashboardItems:(NSArray*)items;

@end
