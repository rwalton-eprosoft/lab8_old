//
//  ProductPortfolioVC.m
//  edge
//
//  Created by iPhone Developer on 5/21/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "AppDelegate.h"
#import "ProductsVC.h"
#import "FilterCell.h"
#import "ProductGridCVCell.h"
#import "ProductListCVCell.h"
#import "Product.h"
#import "Procedure.h"
#import "Speciality.h"
#import "FilterModel.h"
#import "GradientView.h"
#import "ProductDetailVC.h"
#import "RegistrationModel.h"
#import "MyProfile.h"
#import "MyEntitlement.h"
#import "ProductCategory.h"
#import "Content.h"
#import "ProductSectionHeaderCell.h"
#import "ContentModel.h"
#import "FavoritesModel.h"
#import "CustomGridLayout.h"
#import "CustomListLayout.h"
#import "ProcedureModel.h"
#import "DashboardModel.h"
#import "TrackingModel.h"

@implementation ProductGroupSection
@end


@interface ProductsVC ()
@property (nonatomic, strong) NSMutableArray *specialities;
@property (nonatomic, strong) NSMutableArray *procedures;
@property (nonatomic, strong) NSArray *productCategories;
@property (nonatomic, strong) NSMutableDictionary *openSections;
@property (nonatomic, strong) NSMutableArray *products;
@property (nonatomic, strong) CustomListLayout *listLayout;
@property (nonatomic, strong) CustomGridLayout *tgridLayout;
///
// an array for each Speciality
// use same index as specialities item to get the corresponding item in the sorted array
//
//  example: specialities[0] <==> productsSortedByProductName[0] <==> productsSortedByProcedure[0])
//  example: specialities[1] <==> productsSortedByProductName[1] <==> productsSortedByProcedure[1])
//
// each item in the array is an array of products sorted as indicated by the name.
//

// Sort #1 - each item is an array of Products
//  Speciality #1
//      Product #1
//      Product #2
//  Speciality #2
//      Product #1
//      Product #3
@property (nonatomic, strong) NSMutableArray *specialityProductsSections;

// Sort #2 - each item is an array of Procedures
//  Speciality #1, Procedure #1
//          Product #1
//          Product #2
//  Speciality #1, Procedure #2
//          Product #1
//          Product #3
//  Speciality #1, Procedure #3
//      Procedure #1
//          Product #1
//          Product #2
//  Speciality #1, Procedure #4
//          Product #1
//          Product #3
@property (nonatomic, strong) NSMutableArray *specialityProceduresSections;

// Sort #3 - each item is an array of Products
//  Speciality #1, Product Category #1
//          Product #1
//          Product #2
//  Speciality #1, Product Category #2
//          Product #1
//          Product #3
//  Speciality #1, Product Category #3
//          Product #1
//          Product #3
@property (nonatomic, strong) NSMutableArray *specialityProductCategoriesSections;


@end

@implementation ProductsVC

{
    int selectedSection;
    int selectedRow;
    int selectedProductsSortType;
    
    int longPressItemSection;
    int longPressItemRow;
    BOOL isProductFavorite;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) initFilterControls
{
    // _tableView.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"split_view_sidepnl_bkg.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0]];
    
    _openSections = [[NSMutableDictionary alloc] init];
    
    FilterModel *filterModel = [FilterModel sharedInstance];
    [filterModel removeAllForFilterSection:kFilterSpecialty];
    [filterModel removeAllForFilterSection:kFilterProcedure];
    [filterModel removeAllForFilterSection:kFilterProductCategory];
    
    if (!_specialities)
    {
        _specialities = [NSMutableArray array];
    } else{
        [_specialities removeAllObjects];
    }
    
    if (!_procedures)
    {
        _procedures = [NSMutableArray array];
    } else
    {
        [_procedures removeAllObjects];
    }
    
    if (!_productCategories)
    {
        //_productCategories = [NSArray array];
        _productCategories = [[NSArray alloc]init];
    }
    
    //
    // MyEntitlement (Specialty) - only shows Entitlements that are enabled for content download.
    //
    BOOL enabled;
    NSArray *myEntitlements = [[[RegistrationModel sharedInstance].profile myProfileToMyEntitlement] allObjects];
    for (MyEntitlement *entitlement in myEntitlements)
    {
        enabled = [[RegistrationModel sharedInstance] isMyEntitlementEnabled:entitlement];
        
        if (enabled)
        {
            if (entitlement.myEntitlementToSpeciality)
            {
                
                
                Speciality *speciality = entitlement.myEntitlementToSpeciality;
                [_specialities addObject:speciality];
                
                // use the Speciality related to the enabled MyEntitlement object
                [filterModel setEnablementWithFilterSection:kFilterSpecialty filterObj:speciality filterId:entitlement.splId filterName:entitlement.name enabled:YES];
                
                //
                // Procedures - initially show all Procedures for related Speciality
                //
                NSSet *procedures = speciality.specialityToProcedure;
                for (Procedure *procedure in procedures.allObjects)
                {
                    [filterModel setEnablementWithFilterSection:kFilterProcedure filterObj:procedure filterId:procedure.procId  filterName:procedure.name enabled:YES];
                    [_procedures addObject:procedure];
                }
            }
        }
    }
    
    //
    // Product Categories - initially show all product categories
    //
    _productCategories = [ContentModel sharedInstance].productCategories.fetchedObjects;
    for (ProductCategory *productCategory in _productCategories)
    {
        [filterModel setEnablementWithFilterSection:kFilterProductCategory filterObj:productCategory filterId:productCategory.prodCatId filterName:productCategory.name enabled:YES];
    }
    
}

- (void) updateFilterControls
{
    FilterModel *filterModel = [FilterModel sharedInstance];
    
    [filterModel removeAllForFilterSection:kFilterProcedure];
    [_procedures removeAllObjects];
    
    for (Filterable *filterable in filterModel.specialtyEnablements.allValues)
    {
        if (filterable.enabled)
        {
            Speciality *specialty = (Speciality*)filterable.filterObj;
            [filterModel enableProceduresForSpeciality:specialty];
            for (Procedure *procedure in specialty.specialityToProcedure.allObjects)
            {
                [_procedures addObject:procedure];
            }
            
        }
    }
    
    [self.tableView reloadData];
    
}

- (NSArray*)sortProductsByName:(NSArray*)array
{
    NSArray *sortedArray;
    sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(Product*)a name];
        NSString *second = [(Product*)b name];
        return [first compare:second];
    }];
    
    return sortedArray;
}

- (NSArray*) productsRelatedToSpeciality:(NSNumber*)splId
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (Product *product in _products)
    {
        for (Procedure *procedure in product.productToProcedure.allObjects)
        {
            if ([procedure.procedureToSpeciality.splId isEqualToNumber:splId])
            {
                [array addObject:product];
                break;
            }
        }
    }
    
    return [self sortProductsByName:array];
}

- (NSArray*) productsRelatedToProcedure:(NSNumber*)procId fromProducts:(NSArray*)products
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (Product *product in products)
    {
        for (Procedure *procedure in product.productToProcedure.allObjects)
        {
            if ([procedure.procId isEqualToNumber:procId])
            {
                [array addObject:product];
                break;
            }
        }
    }
    
    return [self sortProductsByName:array];
}

- (NSArray*) productsWithProductCategory:(NSNumber*)prodCatId  fromProducts:(NSArray*)products
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (Product *product in products)
    {
        if ([product.prodCatId isEqualToNumber:prodCatId])
        {
            [array addObject:product];
        }
    }
    
    return [self sortProductsByName:array];
}


- (void) queryProductsBasedOnAllFilters
{
    FilterModel *filterModel = [FilterModel sharedInstance];
    
    NSMutableArray *splIds = [NSMutableArray array];
    NSMutableArray  *procIds = [NSMutableArray array];
    NSMutableArray  *prodCatIds = [NSMutableArray array];
    
    Filterable *filterable;
    
    for (Speciality *speciality in _specialities)
    {
        filterable = [filterModel.specialtyEnablements objectForKey:[filterModel filterKeyWithFilterId:speciality.splId filterName:speciality.name]];
        if (filterable.enabled)
        {
            [splIds addObject:[NSNumber numberWithInt:[filterable.filterId intValue]]];
            
        }
    }
    
    for (Procedure *procedure in _procedures)
    {
        filterable = [filterModel.procedureEnablements objectForKey:[filterModel filterKeyWithFilterId:procedure.procId filterName:procedure.name]];
        if (filterable.enabled)
        {
            [procIds addObject:[NSNumber numberWithInt:[filterable.filterId intValue]]];
            
        }
    }
    
    for (ProductCategory *productCategory in _productCategories)
    {
        filterable = [filterModel.productCategoryEnablements objectForKey:[filterModel filterKeyWithFilterId:productCategory.prodCatId filterName:productCategory.name]];
        if (filterable.enabled)
        {
            [prodCatIds addObject:[NSNumber numberWithInt:[filterable.filterId intValue]]];
            
        }
    }
    
    // first clear all previously fetched Products
    if (!_products)
    {
        _products = [NSMutableArray array];
    } else{
        [_products removeAllObjects];
    }
    
    // fetch the products from local storage for the enabled filters
    [_products addObjectsFromArray:[[ContentModel sharedInstance] productsWithSpecialityIds:splIds andProcedureIds:procIds andProductCategoryIds:prodCatIds].fetchedObjects];
    
    // clear the sorted products arrays
    if (!_specialityProductsSections)
    {
        _specialityProductsSections = [NSMutableArray array];
    } else
    {
        [_specialityProductsSections removeAllObjects];
    }
    if (!_specialityProceduresSections)
    {
        _specialityProceduresSections = [NSMutableArray array];
    } else{
        [_specialityProceduresSections removeAllObjects];
    }
    
    if (!_specialityProductCategoriesSections)
    {
        _specialityProductCategoriesSections = [NSMutableArray array];
    } else{
        [_specialityProductCategoriesSections removeAllObjects];
    }
    
#warning FIX ME
    ProductGroupSection *pgs;
    for (Speciality *speciality in _specialities)
    {
        filterable = [filterModel.specialtyEnablements objectForKey:[filterModel filterKeyWithFilterId:speciality.splId filterName:speciality.name]];
        if (filterable.enabled)
        {
            NSArray *matchingProducts = [self productsRelatedToSpeciality:speciality.splId];
            
            if (!matchingProducts || !matchingProducts.count > 0)
                continue;
            
            pgs = [[ProductGroupSection alloc] init];
            pgs.speciality = speciality;
            pgs.products = matchingProducts;
            [_specialityProductsSections addObject:pgs];
            
            for (Procedure *procedure in _procedures)
            {
                if ([procedure.procedureToSpeciality.splId isEqualToNumber:speciality.splId])
                {
                    NSArray *tempProducts = [self productsRelatedToProcedure:procedure.procId fromProducts:matchingProducts];
                    if (tempProducts && tempProducts.count > 0)
                    {
                        pgs = [[ProductGroupSection alloc] init];
                        pgs.speciality = speciality;
                        pgs.sectionObj = procedure;
                        pgs.products = tempProducts;
                        [_specialityProceduresSections addObject:pgs];
                    }
                }
            }
            
            for (ProductCategory *productCategory in _productCategories)
            {
                NSArray *tempProducts = [self productsWithProductCategory:productCategory.prodCatId fromProducts:matchingProducts];
                if (tempProducts && tempProducts.count > 0)
                {
                    pgs = [[ProductGroupSection alloc] init];
                    pgs.speciality = speciality;
                    pgs.sectionObj = productCategory;
                    pgs.products = tempProducts;
                    [_specialityProductCategoriesSections addObject:pgs];
                }
            }
            
        }
    }
}

- (void) refreshProducts
{
    [self initFilterControls];
    [self toggleSectionExpansionFirstTime];
    
    [self queryProductsBasedOnAllFilters];
    [_tableView reloadData];
    [_collectionView reloadData];
}

- (void) reloadProducts
{
    [self queryProductsBasedOnAllFilters];
    
    [_collectionView reloadData];
}

- (NSString*) titleForFilterSection:(int)filterSection
{
    NSString *title_;
    /*
     switch (filterSection) {
     case kFilterSpecialty:
     title_ = @"Specialty";
     break;
     case kFilterProcedure:
     title_ = @"Procedure";
     break;
     case kFilterProductCategory:
     title_ = @"Product Category";
     break;
     
     default:
     title_ = @"unknown";
     break;
     }
     */
    title_ = @"Product Category";
    
    return title_;
}

- (BOOL) isFilterSectionOpen:(int)filterSection
{
    BOOL open = NO;
    
    NSString *sectionTitle = [self titleForFilterSection:filterSection];
    
    if (sectionTitle)
    {
        open = [self.openSections objectForKey:sectionTitle] != nil;
        
    }
    
    return open;
}

- (void) updateFilterSection:(int)filterSection open:(BOOL)open
{
    NSString *sectionTitle = [self titleForFilterSection:filterSection];
    
    if (sectionTitle)
    {
        NSString *openSection = [self.openSections objectForKey:sectionTitle];
        if (openSection)
        {
            // section found in the dictionary
            
            if (!open)
                // remove the section from the dictionary
                [self.openSections removeObjectForKey:sectionTitle];
        }
        else
        {
            // section not found in the dictionary
            
            if (open)
                // add the section to the dictionary
                [self.openSections setObject:[[NSObject alloc] init] forKey:sectionTitle];
        }
    }
}

- (void) checkForNavigateToProduct
{
    //nslog(@"ProductsVC checkForNavigateToProduct");
    if ([[DashboardModel sharedInstance] currentProductProductsFlow])
    {
        [self performSegueWithIdentifier:@"ProductDetailSegue" sender:nil];
    }
    
}

- (void)viewDidLoad
{
    @autoreleasepool {
        
        
        [super viewDidLoad];
        // Do any additional setup after loading the view.
        _titleLabel.font = [UIFont fontWithName:@"StagSans-Book" size:21];
        [self initGestures];
        
        filtersVisible = YES;
        [self initFilterControls];
        _tableView.layer.cornerRadius = 10.f;
        _tableView.layer.borderColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f].CGColor;
        _tableView.layer.borderWidth = 1.f;
        
        _productAreaView.layer.cornerRadius = 10.f;
        _productAreaView.layer.borderColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f].CGColor;
        _productAreaView.layer.borderWidth = 1.f;
        _productAreaView.clipsToBounds = YES;
        
        showList = NO;
        [self setupCollectionView];
        
        // start with no sort
        [self sortByCategoryBtnTouched];
        [self toggleSectionExpansionFirstTime];
        
        
        appcopyImageView = [[UILabel alloc] initWithFrame:CGRectMake(500, 270, 400, 200)];
        [appcopyImageView setText:@"Please select a product category filter to view a product."];
        [appcopyImageView setFont:[UIFont fontWithName:@"Arial" size:15]];
        [appcopyImageView setTextColor:[UIColor colorWithRed:110.0/255 green:110.0/255 blue:110.0/255 alpha:1.0]];
        appcopyImageView.hidden = YES;
        [self.view addSubview:appcopyImageView];
        
        appcopyNew = [[UILabel alloc] initWithFrame:CGRectMake(535, 270, 400, 200)];
        appcopyNew.textColor = appcopyImageView.textColor;
        appcopyNew.font = appcopyImageView.font;
        [appcopyNew setText:@"No products found in selected categories."];
        appcopyNew.hidden = YES;
        [self.view addSubview:appcopyNew];
        
        uncheckedCount = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshProducts)
                                                     name:@"refreshProducts" object:nil];

    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.appDelegate.isproductClicked) {
        self.appDelegate.isproductClicked = NO;
        [self checkForNavigateToProduct];
    }
    [self refreshProducts];
}

- (void) viewDidAppear:(BOOL)animated
{
    // be sure to call base class
    [super viewDidAppear:animated];
    [[TrackingModel sharedInstance] createTrackingDataWithResource:@"ProductsVC" activityCode:TRACKING_ACTIVITY_VIEWED_PAGE];
    appcopyImageView.hidden = YES;
    appcopyNew.hidden = YES;    
}

- (void) viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshProducts" object:nil];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self updateCollectionViewSize];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark init gesture recognizers

- (void) initGestures
{
    // grab view, tap to hide/show
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideFilters)];
    [self.grabView addGestureRecognizer:tapGes];
    
    // grab view, swipe left
    UISwipeGestureRecognizer *swipeGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showHideFilters)];
    swipeGes.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.grabView addGestureRecognizer:swipeGes];
    
    // grab view, swipe right
    swipeGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showHideFilters)];
    swipeGes.direction = UISwipeGestureRecognizerDirectionRight;
    [self.grabView addGestureRecognizer:swipeGes];
    
    // table view, swipe left
    swipeGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showHideFilters)];
    swipeGes.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.tableView addGestureRecognizer:swipeGes];
    
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
	// only when gesture was recognized, not when ended
	if (gesture.state == UIGestureRecognizerStateBegan)
	{
        //
        // NOTE: get the correct index path first, and set the longPress vars.
        //
        // get affected cell
        UICollectionViewCell *cell = (UICollectionViewCell *)[gesture view];
        
        // get indexPath of cell
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        
        longPressItemSection = indexPath.section;
        longPressItemRow = indexPath.row;
        
        NSArray *products;
        Product *product;
        
        switch (selectedProductsSortType)
        {
            case kProductSortNone:
            {
                //products = [[_specialityProductsSections objectAtIndex:longPressItemSection] products];
                product = [_products objectAtIndex:longPressItemRow];
                
            }
                break;
            case kProductSortByProcedure:
            {
                //products = [[_specialityProceduresSections objectAtIndex:longPressItemSection] products];
                product = [_products objectAtIndex:longPressItemRow];
            }
                break;
            case kProductSortByCategory:
            {
                //products = [[_specialityProductCategoriesSections objectAtIndex:longPressItemSection] products];
                product = [_products objectAtIndex:longPressItemRow];
                
                
            }
                break;
                
            default:
                return;
                break;
        }
        //nslog(@"product.name: %@", product.name);
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
        {
            // iOS 8 logic
            self.view.window.tintColor = [UIColor grayColor];
        }
        
        BOOL isFavorite = [[FavoritesModel sharedInstance] isProductAFavorite:product];
        
        if (isFavorite == YES)
        {
            //nslog(@"Im a Favorite");
            isProductFavorite = YES;
            
            UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: @"Already a Favorite"
                                                                      delegate: self
                                                             cancelButtonTitle: nil
                                                        destructiveButtonTitle: nil
                                                             otherButtonTitles: @"OK", nil];
            
            [actionSheet showFromRect: cell.frame inView: cell.superview animated: YES];
        }
        else
        {
            //nslog(@"Im NOT Favorite");
            isProductFavorite = NO;
            
            UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                                      delegate: self
                                                             cancelButtonTitle: nil
                                                        destructiveButtonTitle: nil
                                                             otherButtonTitles: @"Add to Favorites", nil];
            
            [actionSheet showFromRect: cell.frame inView: cell.superview animated: YES];
            
        }
        //        [self.collectionView reloadData];
        cell = nil;
        product = nil;
        products = nil;
    }
}

#pragma mark -
#pragma mark UIActionSheetDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex && isProductFavorite == NO)
    {
        [self addFavOnProduct];
        isProductFavorite = NO;
    }
}
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    //#warning iOS7 test bed
    
    //Gets an array af all of the subviews of our actionSheet
    NSArray *subviews = [actionSheet subviews];
    
    for (UIView *v in subviews)
    {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *b = (UIButton*)v;
            [b setTitleColor:[UIColor colorWithRed:110.0f/255.0f green:110.0f/255.0f blue:110.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [b setTitleColor:[UIColor colorWithRed:243.0f/255.0f green:6.0f/255.0f blue:23.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
            
        }
    }
}

- (void)addFavOnProduct
{
    NSArray *products;
    Product *product;
    
    switch (selectedProductsSortType)
    {
        case kProductSortNone:
        {
            //products = [[_specialityProductsSections objectAtIndex:longPressItemSection] products];
            product = [_products objectAtIndex:longPressItemRow];
        }
            break;
        case kProductSortByProcedure:
        {
            products = [[_specialityProceduresSections objectAtIndex:longPressItemSection] products];
            product = [products objectAtIndex:longPressItemRow];
        }
            break;
        case kProductSortByCategory:
        {
            products = [[_specialityProductCategoriesSections objectAtIndex:longPressItemSection] products];
            product = [products objectAtIndex:longPressItemRow];
        }
            break;
            
        default:
            return;
            break;
    }
    
    [[FavoritesModel sharedInstance] addFavoriteWithProduct:product];
    
}

#pragma mark -
#pragma mark UITableViewDataSource

// Default is 1 if not implemented
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return 3;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int nRows = 0;
    
    BOOL isOpen = [self isFilterSectionOpen:section];
    /*
     switch (section) {
     case kFilterSpecialty:
     if (isOpen)
     {
     nRows = _specialities.count;
     }
     break;
     case kFilterProcedure:
     if (isOpen)
     {
     nRows = _procedures.count;
     }
     break;
     case kFilterProductCategory:
     if (isOpen)
     {
     nRows = _productCategories.count;
     }
     break;
     
     default:
     break;
     }
     */
    if (isOpen)
    {
        nRows = _productCategories.count;
    }
    
    return nRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36.0f;
}

// custom view for header. will be adjusted to default or specified header height
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    section = kFilterProductCategory;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 260.0f, 36.0f)];
    UIImageView *bckImg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"split_view_sidepnl_red_strip_bkg.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0]];
    bckImg.frame = CGRectMake(0.f, 0.f, view.frame.size.width, view.frame.size.height);
    bckImg.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [view addSubview:bckImg];
    
    NSString *title = [self titleForFilterSection:section];
    BOOL isOpen = [self isFilterSectionOpen:section];
    
    CGRect frame;
    
    // create the toggle button
    UIButton *tog = [UIButton buttonWithType:UIButtonTypeCustom];
    tog.tag = section;
    [tog setImage:[UIImage imageNamed:isOpen ? DOWN_ARROW : RIGHT_ARROW] forState:UIControlStateNormal];
    [tog sizeToFit];
    frame = tog.frame;
    //frame.origin.x = 10.0f;
    //frame.origin.y = 7.0f;
    frame.origin.x = view.frame.size.width - (frame.size.width + 10.0f);
    frame.origin.y = 7.0f;
    tog.frame = frame;
    [view addSubview:tog];
    
    // create the title label
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 7.0f, 200.0f, 22.0f)];
    //lbl.font = [UIFont boldSystemFontOfSize:18.0f];
    lbl.textColor = [UIColor whiteColor];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textAlignment = NSTextAlignmentLeft;
    lbl.text = title;
    lbl.layer.shadowOffset = CGSizeMake(1.f, 1.f);
    lbl.layer.shadowColor = [UIColor colorWithRed:33/255.f green:33/255.f blue:33/255.f alpha:1.f].CGColor;
    lbl.font = [UIFont fontWithName:@"Arial" size:18.f];
    [view addSubview:lbl];
    
    FilterBtn *filterBtn;
    
#warning Recheck after testing
    //force checkbox always
    //if (isOpen)
    {
        BOOL allEnabled = [[FilterModel sharedInstance] areAllEnabledForFilterSection:section];
        
        // create the select all button
        filterBtn = [FilterBtn buttonWithType:UIButtonTypeCustom];
        filterBtn.tag = section;
        
        filterBtn.checked = allEnabled;
        [self setImageForSectionFilterBtn:filterBtn];
        [filterBtn addTarget:self action:@selector(toggleSectionFilters:) forControlEvents:UIControlEventTouchDown];
        [filterBtn sizeToFit];
        frame = filterBtn.frame;
        //frame.origin.x = view.frame.size.width - (frame.size.width + 10.0f);
        //frame.origin.y = 7.0f;
        frame.origin.x = 10.0f;
        frame.origin.y = 7.0f;
        filterBtn.frame = frame;
        [view addSubview:filterBtn];
    }
    
    // create the section expand/collapse button
    frame = filterBtn.frame;
    ////nslog(@"view.frame.size.width: %f frame.origin.x: %f frame.size.width: %f", view.frame.size.width, frame.origin.x, frame.size.width);
    CGFloat width = view.frame.size.width - (frame.origin.x + frame.size.width);
    //if (isOpen)
    //width -= 40.0f;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = section;
    [btn addTarget:self action:@selector(toggleSectionExpansion:) forControlEvents:UIControlEventTouchDown];
    //btn.frame = CGRectMake(0.0f, 0.0f, width, view.frame.size.height);
    btn.frame = CGRectMake(frame.origin.x + frame.size.width + 10.f, 0.0f, width, view.frame.size.height);
    [view addSubview:btn];
    bckImg = nil;
    return view;
}

- (void) toggleSectionExpansion:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    int filterSection = btn.tag;
    BOOL isOpen = [self isFilterSectionOpen:filterSection];
    isOpen = !isOpen;   // toggle is open
    [self updateFilterSection:filterSection open:isOpen];
    [self.tableView reloadData];
    
}

- (void) toggleSectionExpansionFirstTime
{
    int filterSection = 0;
    BOOL isOpen = [self isFilterSectionOpen:filterSection];
    isOpen = !isOpen;   // toggle is open
    [self updateFilterSection:filterSection open:isOpen];
    
    filterSection = 1;
    isOpen = [self isFilterSectionOpen:filterSection];
    isOpen = !isOpen;   // toggle is open
    [self updateFilterSection:filterSection open:isOpen];
    
    filterSection = 2;
    isOpen = [self isFilterSectionOpen:filterSection];
    isOpen = !isOpen;   // toggle is open
    [self updateFilterSection:filterSection open:isOpen];
    [self.tableView reloadData];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static FilterCell *cell;
    //static Speciality *speciality;
    //static Procedure *procedure;
    static ProductCategory *productCategory;
    static Filterable *filterable;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"FilterCell"];
    cell.toggleBtn.indexPath = indexPath;
    cell.toggleBtn.tag = indexPath.section;
    
    FilterModel *filterModel = [FilterModel sharedInstance];
    /*
     switch (indexPath.section)
     {
     case kFilterSpecialty:
     {
     speciality = [_specialities objectAtIndex:indexPath.row];
     cell.tag = indexPath.section;
     cell.titleLbl.text = speciality.name;
     filterable = [filterModel.specialtyEnablements objectForKey:[filterModel filterKeyWithFilterId:speciality.splId filterName:speciality.name]];
     cell.toggleBtn.checked = filterable.enabled;
     [self setImageForFilterBtn:cell.toggleBtn];
     }
     break;
     case kFilterProcedure:
     {
     procedure = [_procedures objectAtIndex:indexPath.row];
     cell.tag = indexPath.section;
     cell.titleLbl.text = procedure.name;
     filterable = [filterModel.procedureEnablements objectForKey:[filterModel filterKeyWithFilterId:procedure.procId filterName:procedure.name]];
     cell.toggleBtn.checked = filterable.enabled;
     [self setImageForFilterBtn:cell.toggleBtn];
     }
     break;
     case kFilterProductCategory:
     {
     productCategory = [_productCategories objectAtIndex:indexPath.row];
     cell.tag = indexPath.section;
     cell.titleLbl.text = productCategory.name;
     filterable = [filterModel.productCategoryEnablements objectForKey:[filterModel filterKeyWithFilterId:productCategory.prodCatId filterName:productCategory.name]];
     cell.toggleBtn.checked = filterable.enabled;
     [self setImageForFilterBtn:cell.toggleBtn];
     }
     break;
     
     default:
     break;
     }
     */
    productCategory = [_productCategories objectAtIndex:indexPath.row];
    cell.tag = indexPath.section;
    cell.titleLbl.text = productCategory.name;
    filterable = [filterModel.productCategoryEnablements objectForKey:[filterModel filterKeyWithFilterId:productCategory.prodCatId filterName:productCategory.name]];
    cell.toggleBtn.checked = filterable.enabled;
    [self setImageForFilterBtn:cell.toggleBtn];
    
    return cell;
}

#pragma mark -
#pragma mark Collection view

-(void)setupCollectionView
{
    if (!_tgridLayout)
    {
        _tgridLayout = [[CustomGridLayout alloc]init];
    }
    if (!_listLayout)
    {
        _listLayout = [[CustomListLayout alloc]init];
    }
    
    [_collectionView setCollectionViewLayout:showList ? _listLayout : _tgridLayout];
    
    [_collectionView setPagingEnabled:NO];
    
    //self.collectionView.backgroundColor = [UIColor colorWithWhite:0.25f alpha:1.0f];
    
    // NOTE: this is for programmatic, not compatible with using cell identifiers in IB (apple doc says the call is needed, but will break the UI)
    
    //[_collectionView registerClass:[ProductGridCVCell class] forCellWithReuseIdentifier:@"ProductGridCVCell"];
    //[_collectionView registerClass:[ProductListCVCell class] forCellWithReuseIdentifier:@"ProductListCVCell"];
    
    //[_collectionView registerClass:[ProductSectionHeaderCell class]
    //        forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
    //               withReuseIdentifier:@"ProductSectionHeaderCell"];
    
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    int nSections = 1;
    /*
     #warning FIX ME
     switch (selectedProductsSortType)
     {
     case kProductSortNone:
     //nSections = _specialityProductsSections.count;
     nSections = 1;
     
     break;
     case kProductSortByProcedure:
     nSections = _specialityProceduresSections.count;
     break;
     case kProductSortByCategory:
     nSections = _specialityProductCategoriesSections.count;
     break;
     
     default:
     break;
     }
     */
    //NSLog(@"nSections: %d", nSections);
    
    return nSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    int nItems = 0;
    
#warning FIX ME
    switch (selectedProductsSortType)
    {
        case kProductSortNone:
            //nItems = [[[_specialityProductsSections objectAtIndex:section] products] count];
            nItems = _products.count;
            break;
        case kProductSortByProcedure:
            nItems = [[[_specialityProceduresSections objectAtIndex:section] products] count];
            break;
        case kProductSortByCategory:
            nItems = [[[_specialityProductCategoriesSections objectAtIndex:section] products] count];
            break;
            
        default:
            break;
    }
    if (filterClicked)
    {
        if (nItems == 0)
        {
            appcopyNew.hidden = NO;
        }
        else
        {
            appcopyNew.hidden = YES;
        }
        if (_productCategories.count == uncheckedCount)
        {
            appcopyNew.hidden = YES;
        }
        filterClicked = NO;
    }
    //NSLog(@"nItems: %d", nItems);
    
    return nItems;
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static Product *product;
    static NSArray *products;
    static UICollectionViewCell *cell;
    static ProductGridCVCell *gridCell;
    static ProductListCVCell *listCell;
    
    //UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    //NSIndexPath *tempIndexPath;
    //tempIndexPath = itemAttributes.indexPath;
    //NSLog(@"cellForItem indexPath %@",indexPath);
    //NSLog(@"layout indexPath %@",tempIndexPath);
    
    switch (selectedProductsSortType)
    {
        case kProductSortNone:
        {
            //products = [[_specialityProductsSections objectAtIndex:indexPath.section] products];
            //NSLog(@"_products = %lu", (unsigned long)[_products count]);
            product = [_products objectAtIndex:indexPath.row];
            
            ////nslog(@"\n\nProd Id : %@", product.prodId);
            ////nslog(@"\n\nName    : %@", product.name);
            //NSArray *array = [product.productToProcedure allObjects];
            //for (Procedure* proc in array) {
            ////nslog(@"Proc Id   : %@", proc.procId);
            ////nslog(@"Proc Name : %@", proc.name);
            ////nslog(@"Splt Id   : %@", proc.procedureToSpeciality.splId);
            //}
            ////nslog(@"*********************");
        }
            break;
        case kProductSortByProcedure:
        {
            products = [[_specialityProceduresSections objectAtIndex:indexPath.section] products];
            
            product = [products objectAtIndex:indexPath.row];
            ////nslog(@"\n\nProd Id : %@", product.prodId);
            ////nslog(@"\n\nName    : %@", product.name);
            //NSArray *array = [product.productToProcedure allObjects];
            //for (Procedure* proc in array) {
            ////nslog(@"Proc Id   : %@", proc.name);
            ////nslog(@"Proc Name : %@", proc.procId);
            ////nslog(@"Splt Id   : %@", proc.procedureToSpeciality.splId);
            //}
            ////nslog(@"*********************");
            
        }
            break;
        case kProductSortByCategory:
        {
            products = [[_specialityProductCategoriesSections objectAtIndex:indexPath.section] products];
            //NSLog(@"Products count Cat = %lu", (unsigned long)[products count]);
            
            product = [products objectAtIndex:indexPath.row];
            ////nslog(@"\n\nProd Id : %@", product.prodId);
            ////nslog(@"\n\nName    : %@", product.name);
            //NSArray *array = [product.productToProcedure allObjects];
            //for (Procedure* proc in array) {
            //    //nslog(@"Proc Id   : %@", proc.name);
            //    //nslog(@"Proc Name : %@", proc.procId);
            //    //nslog(@"Splt Id   : %@", proc.procedureToSpeciality.splId);
            //}
            // //nslog(@"*********************");
            
        }
            break;
            
        default:
            break;
    }
    
    ////nslog(@"product.name: %@", product.name);
    NSArray *contents = [[ContentModel sharedInstance] contentsForProduct:product withContentCatIds:[NSArray arrayWithObject:[NSNumber numberWithInt:kProductImage]]];
    
    //    for (Content *content in contents)
    //    {
    //        //nslog(@"content.cntId: %d content.path: %@", [content.cntId intValue], content.path);
    //    }
    
    UIImageView *productThumbnailImage;
    if (showList)
    {
        productThumbnailImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 157)];
    }
    else
    {
        productThumbnailImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 112, 84)];
        
    }
    
    for (Content *content in contents)
    {
        ////nslog(@"content.path: %@", content.path);
        if (content.thumbnailImgPath)
        {
            if (showList)
            {
                productThumbnailImage.image = [self.appDelegate loadImage:content.path];
                break;
            }
            else
            {
                productThumbnailImage.image = [self.appDelegate loadImage:content.thumbnailImgPath];
                break;
            }
        }
    }
    if (!productThumbnailImage.image)
    {
        ////nslog(@">>>>> thumnbnail not set or found. using placeholder image!!!!!");
        // productThumbnailImage.image = [UIImage imageNamed:PRODUCT_THUMBNAIL_IMAGE_NOT_FOUND];200 157
        UILabel * producttitle;
        if (showList)
        {
            producttitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 157)];
            
        }
        else
        {
            producttitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 112, 84)];
            
        }
        producttitle.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        producttitle.text = product.name;
        producttitle.numberOfLines = 0;
        producttitle.font = [UIFont fontWithName:@"Arial" size:14];
        producttitle.textAlignment = NSTextAlignmentCenter;
        [productThumbnailImage addSubview:producttitle];
        UIGraphicsBeginImageContext(productThumbnailImage.bounds.size);
        [productThumbnailImage.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *bitmap = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        productThumbnailImage.image = bitmap;
        
    }
    
    
    if (showList)
    {
        listCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProductListCVCell" forIndexPath:indexPath];
        //NSLog(@"Index path = %@", indexPath);
        
        //         if (!productThumbnailImage)
        //         {
        //             listCell.imageView.hidden = YES;
        //             listCell.imageLbl.text = product.name;
        //         }
        //         else
        {
            listCell.imageView.image = productThumbnailImage.image;
            listCell.imageLbl.hidden = YES;
        }
        
        listCell.titleLbl.text = product.name;
        listCell.descrLbl.text = product.desc;
        
        listCell.imageBorderView.layer.borderWidth = 1.f;
        listCell.imageBorderView.layer.borderColor = [UIColor colorWithRed:243.0f/255.0f green:243.0f/255.0f blue:243.0f/255.0f alpha:1.0f].CGColor;
        
        cell = listCell;
        
    }
    else
    {
        gridCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProductGridCVCell" forIndexPath:indexPath];
        //        if (!productThumbnailImage)
        //        {
        //            gridCell.imageView.hidden = YES;
        //            gridCell.imageLbl.text = product.name;
        //        }
        //        else
        {
            gridCell.imageView.image = productThumbnailImage.image;
            gridCell.imageLbl.hidden = YES;
        }
        gridCell.titleLbl.text = product.name;
        
        gridCell.imageBorderView.layer.borderWidth = 1.f;
        gridCell.imageBorderView.layer.borderColor = [UIColor colorWithRed:243.0f/255.0f green:243.0f/255.0f blue:243.0f/255.0f alpha:1.0f].CGColor;
        
        cell = gridCell;
    }
    
    // set up long-press for Products
    UILongPressGestureRecognizer *longPressGesture =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    [cell addGestureRecognizer:longPressGesture];
    
    //contents = nil;
    //productThumbnailImage = nil;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CGSizeMake(0, 0);
    }else {
        return CGSizeMake(self.collectionView.bounds.size.width, 135);
    }
}
/*
 - (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 UICollectionReusableView *reusableview = nil;
 if (kind == UICollectionElementKindSectionHeader)
 {
 #warning FIX ME
 ProductSectionHeaderCell *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProductSectionHeaderCell" forIndexPath:indexPath];
 headerView.titleLbl.text = nil;
 headerView.layer.cornerRadius = 11.0f;
 headerView.titleLbl.font = [UIFont fontWithName:@"StagSans-Light" size:26];
 //headerView.backgroundColor = [UIColor greenColor];
 ////nslog(@"Headerview label x :%f y :%f", headerView.titleLbl.frame.origin.x, headerView.titleLbl.frame.origin.y);
 //headerView.titleLbl.backgroundColor = [UIColor redColor];
 
 //
 if (!showList)
 {
 CGRect frame = headerView.frame;
 frame.size.width = 100.0f;
 frame.size.height = 100.0f;
 headerView.frame = frame;
 }
 //
 
 switch (selectedProductsSortType)
 {
 case kProductSortNone:
 {
 ProductGroupSection *pgs = [_specialityProductsSections objectAtIndex:indexPath.section];
 headerView.titleLbl.text = [NSString stringWithFormat:@"Products - %@", pgs.speciality.name];
 }
 break;
 case kProductSortByProcedure:
 {
 ProductGroupSection *pgs = [_specialityProceduresSections objectAtIndex:indexPath.section];
 // secondary sort is Procedure name
 headerView.titleLbl.text = [NSString stringWithFormat:@"Products - %@, %@", pgs.speciality.name, [(Procedure*)pgs.sectionObj name]];
 }
 break;
 case kProductSortByCategory:
 {
 ProductGroupSection *pgs = [_specialityProductCategoriesSections objectAtIndex:indexPath.section];
 // secondary sort is ProductCategory name
 headerView.titleLbl.text = [NSString stringWithFormat:@"Products - %@, %@", pgs.speciality.name, [(ProductCategory*)pgs.sectionObj name]];
 }
 break;
 
 default:
 break;
 }
 //nslog(@"header title text %@", headerView.titleLbl.text);
 reusableview = headerView;
 
 } else if (kind == UICollectionElementKindSectionFooter)
 {
 ProductSectionHeaderCell *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProductSectionHeaderCell" forIndexPath:indexPath];
 //nslog(@"footer header view %@", headerView.titleLbl.text);
 headerView.titleLbl.text = nil;
 reusableview = headerView;
 }
 
 return reusableview;
 }
 */
#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedSection = indexPath.section;
    selectedRow = indexPath.row;
    
    [self updateCurrentProduct];
    
    [self performSegueWithIdentifier:@"ProductDetailSegue" sender:nil];
    
}

- (void) updateCurrentProduct
{
    Product *product;
    
    switch (selectedProductsSortType)
    {
        case kProductSortNone:
        {
            //ProductGroupSection *pgs = [_specialityProductsSections objectAtIndex:selectedSection];
            //product = [pgs.products objectAtIndex:selectedRow];
            product = [_products objectAtIndex:selectedRow];
        }
            break;
        case kProductSortByProcedure:
        {
            ProductGroupSection *pgs = [_specialityProceduresSections objectAtIndex:selectedSection];
            product = [pgs.products objectAtIndex:selectedRow];
        }
            break;
        case kProductSortByCategory:
        {
            ProductGroupSection *pgs = [_specialityProductCategoriesSections objectAtIndex:selectedSection];
            product = [pgs.products objectAtIndex:selectedRow];
        }
            break;
            
        default:
            break;
    }
    
    [[DashboardModel sharedInstance] setCurrentProductProductsFlow:product];
}

#pragma mark -
#pragma mark prepare segue

//- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"ProductDetailSegue"])
//    {
//        ProductDetailVC *vc = (ProductDetailVC*)segue.destinationViewController;
//        //vc.product = self.appDelegate.currentProduct;
//        vc.product = [[DashboardModel sharedInstance] currentProduct];
//
//    }
//
//}

- (void) setImageForFilterBtn:(FilterBtn*)filterBtn
{
    [filterBtn setImage:filterBtn.checked ? [UIImage imageNamed:CHECKBOX_CHECKED_IMAGE_GREY] : [UIImage imageNamed:CHECKBOX_UNCHECKED_IMAGE_GREY] forState:UIControlStateNormal];
    
}

- (void) setImageForSectionFilterBtn:(FilterBtn*)filterBtn
{
    [filterBtn setImage:filterBtn.checked ? [UIImage imageNamed:CHECKBOX_CHECKED_IMAGE_WHITE] : [UIImage imageNamed:CHECKBOX_UNCHECKED_IMAGE_WHITE] forState:UIControlStateNormal];
    
}

#pragma mark -
#pragma mark handle our actions

- (IBAction) toggleSectionFilters:(id)sender
{
    NSLog(@"toggleSectionFilters");
    FilterBtn *btn = (FilterBtn*)sender;
    
    btn.checked = !btn.checked;
    [self setImageForFilterBtn:btn];
    int filterSection = btn.tag;
    filterSection = kFilterProductCategory;
    NSLog(@"Button tag = %ld", (long)btn.tag);
    
    btn.checked ? [[FilterModel sharedInstance] enableAllForFilterSection:filterSection] : [[FilterModel sharedInstance] enableNoneForFilterSection:filterSection];
    
    [self.tableView reloadData];
    if (filterSection == kFilterSpecialty)
    {
        // if Speciality filter changed, reload Procedures
        [self updateFilterControls];
        [self.tableView reloadData];
    }
    if (filterSection == kFilterProcedure)
    {
        if (!btn.checked)
        {
            appcopyImageView.hidden = NO;
            appcopyImageView.userInteractionEnabled = NO;
            uncheckedCount = _procedures.count;
        }
        else
        {
            appcopyImageView.hidden = YES;
            appcopyImageView.userInteractionEnabled = YES;
            uncheckedCount = 0;
        }
        
    }
    if (filterSection == kFilterProductCategory)
    {
        appcopyNew.hidden = YES;
        if (!btn.checked)
        {
            appcopyImageView.hidden = NO;
            appcopyImageView.userInteractionEnabled = NO;
            uncheckedCount = _productCategories.count;
        }
        else
        {
            appcopyImageView.hidden = YES;
            appcopyImageView.userInteractionEnabled = YES;
            uncheckedCount = 0;
        }
        // NSLog(@"unchecked count = %i", uncheckedCount);
        // NSLog(@"productCategories = %i", _productCategories.count);
        
    }
    
    [self reloadProducts];
    
}

- (IBAction) toggleFilter:(id)sender
{
    filterClicked = YES;
    
    FilterBtn *btn = (FilterBtn*)sender;
    
    btn.checked = !btn.checked;
    [self setImageForFilterBtn:btn];
    
    int filterSection = btn.tag;
    
    int row = btn.indexPath.row;
    NSNumber *filterId;
    NSString *filterName;
    id anyObj;
    /*
     switch (filterSection) {
     case kFilterSpecialty:
     {
     Speciality *speciality = [_specialities objectAtIndex:row];
     filterId = speciality.splId;
     filterName = speciality.name;
     anyObj = speciality;
     }
     break;
     case kFilterProcedure:
     {
     Procedure *procedure = [_procedures objectAtIndex:row];
     filterId = procedure.procId;
     filterName = procedure.name;
     anyObj = procedure;
     }
     break;
     case kFilterProductCategory:
     {
     ProductCategory *productCategory = [_productCategories objectAtIndex:row];
     filterId = productCategory.prodCatId;
     filterName = productCategory.name;
     anyObj = productCategory;
     }
     break;
     
     default:
     break;
     }
     */
    filterSection = kFilterProductCategory;
    ProductCategory *productCategory = [_productCategories objectAtIndex:row];
    filterId = productCategory.prodCatId;
    filterName = productCategory.name;
    anyObj = productCategory;
    
    
    [[FilterModel sharedInstance] setEnablementWithFilterSection:filterSection filterObj:anyObj filterId:filterId filterName:filterName enabled:btn.checked];
    
    if (filterSection == kFilterSpecialty)
    {
        // if Speciality filter changed, reload Procedures
        [self updateFilterControls];
        [self.tableView reloadData];
    }
    if (filterSection == kFilterProcedure)
    {
        if (btn.checked)
        {
            appcopyImageView.hidden = YES;
            appcopyImageView.userInteractionEnabled = YES;
            uncheckedCount--;
        }
        if (!btn.checked)
        {
            uncheckedCount++;
        }
        if (_procedures.count == uncheckedCount)
        {
            appcopyImageView.hidden = NO;
            appcopyImageView.userInteractionEnabled = NO;
        }
        
        [self.tableView reloadData];
    }
    
    if (filterSection == kFilterProductCategory)
    {
        if (btn.checked)
        {
            appcopyImageView.hidden = YES;
            appcopyImageView.userInteractionEnabled = YES;
            uncheckedCount--;
        }
        if (!btn.checked)
        {
            uncheckedCount++;
        }
        
        // NSLog(@"unchecked count = %i", uncheckedCount);
        // NSLog(@"productCategories = %i", _productCategories.count);
        
        if (uncheckedCount == _productCategories.count)
        {
            appcopyImageView.hidden = NO;
            appcopyImageView.userInteractionEnabled = NO;
        }
        
        
        [self.tableView reloadData];
    }
    [self reloadProducts];
    
}

- (IBAction) toggleCollectionLayoutStyle
{
    showList = !showList;
    [self.collectionLayoutToggleBtn setImage:[UIImage imageNamed:showList ? IMAGE_VIEW_GRID_ICON : IMAGE_VIEW_LIST_ICON] forState:UIControlStateNormal];
    //[self setupCollectionView];
    [self updateCollectionView];
    [self updateCollectionViewSize];
    [self.collectionView reloadData];
    [self.collectionView scrollRectToVisible:CGRectMake(0.f, 0.f, 1.f, 1.f) animated:YES];
}

-(void) updateCollectionView
{
    [_collectionView setCollectionViewLayout:showList ? _listLayout : _tgridLayout];
}

- (IBAction) showHideFilters
{
    ////nslog(@"showHideFilters");
    if (filtersVisible)
    {
        [self moveFiltersOffScreen];
    } else {
        [self moveFiltersOnScreen];
    }
}

- (IBAction) sortByProcedureBtnTouched
{
    _sortByProcedureBtn.selected = YES;
    _sortByCategoryBtn.selected = NO;
    _sortNoneBtn.selected = NO;
    
    selectedProductsSortType = kProductSortByProcedure;
    [self reloadProducts];
}

- (IBAction) sortByCategoryBtnTouched
{
    _sortByProcedureBtn.selected = NO;
    _sortByCategoryBtn.selected = NO;
    _sortNoneBtn.selected = YES;
    
    selectedProductsSortType = kProductSortNone;
    [self reloadProducts];
}

- (IBAction) sortNoneBtnTouched
{
    _sortByProcedureBtn.selected = NO;
    _sortByCategoryBtn.selected = NO;
    _sortNoneBtn.selected = YES;
    
    selectedProductsSortType = kProductSortNone;
    [self reloadProducts];
}

- (void) updateCollectionViewSize
{
    if (showList)
    {
        _productAreaViewWidthConstraint.constant = 768.0f;
    }
    else
    {
        _productAreaViewWidthConstraint.constant = 982.0f;
    }
    
}

#pragma mark -

- (void) moveFiltersOffScreen
{
    filtersVisible = NO;
    
    [UIView animateWithDuration:0.75f animations:^{
        _filtersDistanceFromLeftConstraint.constant = -280.f;
        //_grabViewDistanceFromLeftConstraint.constant = 0.f;
        _grabView.hidden = NO;
        _productAreaViewDistanceFromLeftConstraint.constant = 42.f;
        [self.view layoutIfNeeded];
    }
                     completion:^(BOOL finished){
                         //[self updateCollectionViewSize];
                         [self.view layoutIfNeeded];
                     }
     ];
}

- (void) moveFiltersOnScreen
{
    filtersVisible = YES;
    
    [UIView animateWithDuration:0.75f animations:^{
        _filtersDistanceFromLeftConstraint.constant = 20.f;
        //_grabViewDistanceFromLeftConstraint.constant = -42.f;
        _grabView.hidden = YES;
        _productAreaViewDistanceFromLeftConstraint.constant = 320.f;
        [self.view layoutIfNeeded];
    }
                     completion:^(BOOL finished){
                         //[self updateCollectionViewSize];
                         [self.view layoutIfNeeded];
                     }
     ];
}

@end
