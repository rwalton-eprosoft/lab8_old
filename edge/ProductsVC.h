//
//  ProductPortfolioVC.h
//  edge
//
//  Created by iPhone Developer on 5/21/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "BaseVC.h"
@class Product;
@class Speciality;

#define NAVIGATE_TO_PRODUCT                 999

#define CHECKBOX_CHECKED_IMAGE_WHITE        @"checkbox_select_white"
#define CHECKBOX_UNCHECKED_IMAGE_WHITE      @"checkbox_white"

#define CHECKBOX_CHECKED_IMAGE_GREY         @"checkbox_select_grey"
#define CHECKBOX_UNCHECKED_IMAGE_GREY       @"checkbox_grey"

#define DOWN_ARROW                          @"downarrow"
#define RIGHT_ARROW                         @"rightarrow"

enum ProductsSortType {
    kProductSortByProcedure = 0,
    kProductSortByCategory,
    kProductSortNone
};

enum CollectionLayoutType {
    CollectionLayoutGrid = 0,
    CollectionLayoutList
    };

@interface ProductGroupSection : NSObject

@property (nonatomic, weak) Speciality *speciality;
@property (nonatomic, weak) id sectionObj;      // either Procedure or ProductCategory obj
@property (nonatomic, strong) NSArray *products;

@end

@interface ProductsVC : BaseVC <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    BOOL showList;
    BOOL filtersVisible;
    UILabel *appcopyImageView,*appcopyNew;
    int uncheckedCount;
    BOOL filterClicked;
}


@property (nonatomic, strong) IBOutlet UILabel * titleLabel;
@property (nonatomic, strong) IBOutlet UIView *grabView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *productAreaView;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UIButton *sortByProcedureBtn;
@property (nonatomic, strong) IBOutlet UIButton *sortByCategoryBtn;
@property (nonatomic, strong) IBOutlet UIButton *sortNoneBtn;
@property (nonatomic, strong) IBOutlet UIButton *collectionLayoutToggleBtn;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *filtersDistanceFromLeftConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *grabViewDistanceFromLeftConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *productAreaViewDistanceFromLeftConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *productAreaViewWidthConstraint;

- (IBAction) toggleFilter:(id)sender;
- (IBAction) toggleCollectionLayoutStyle;
- (IBAction) showHideFilters;
- (IBAction) sortByProcedureBtnTouched;
- (IBAction) sortByCategoryBtnTouched;
- (IBAction) sortNoneBtnTouched;
- (void) reloadProducts;
- (void) refreshProducts;

@end
