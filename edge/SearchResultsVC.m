//
//  SearchVC.m
//  edge
//
//  Created by iPhone Developer on 5/13/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "SearchResultsVC.h"
#import "AppDelegate.h"
#import "ContentModel.h"
#import "Content.h"
#import "Product.h"
#import "Procedure.h"
#import "Speciality.h"
#import "ContentCategory.h"
#import "ProductCategory.h"
#import "ProductSectionHeaderCell.h"
#import "SearchResultsGridCVCell.h"
#import "SearchResultsGridLayout.h"
#import "TabBarViewController.h"
#import "DashboardModel.h"
#import "ResourceViewerViewController.h"
#import "FavoritesModel.h"
#import "OrderedDictionary.h"
#import "ContentSearch.h"
#import "ContentSearchModel.h"

@interface SearchResultsVC ()
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, weak) NSFetchedResultsController *productsSearchResults;
//@property (nonatomic, strong) NSFetchedResultsController *proceduresSearchResults;
//@property (nonatomic, strong) NSFetchedResultsController *specialitiesSearchResults;
@property (nonatomic, weak) NSFetchedResultsController *contentsSearchResults;

// these represent sections in the collection view
@property (nonatomic, strong) OrderedDictionary *specialitySectionsDict;
@property (nonatomic, strong) OrderedDictionary *procedureSectionsDict;
@property (nonatomic, strong) OrderedDictionary *productCategorySectionsDict;
@property (nonatomic, strong) OrderedDictionary *categoryAllDict;
@property (nonatomic, weak) UIActionSheet *actionSheet;

// mapping from Product to Procedure(s) and a single ProductCategory
// Product ==> Procedure(s)
// Product ==> ProductCategory

// mapping from Content to Speciality, Procedure, Product
//
// Content ==> ContentMapping => Speciality
// Content ==> ContentMapping => Procedure
// Content ==> ContentMapping => Product

// how to process each Product and Content found for collection view presentation
//
// for each Product found, ...
//      for each related Procedure, add Product to a specific procedureSection
//      for Product's productCategory, add Product to specific productCategorySection

// for each Content found, ...
//      for each contentMapped Speciality, add Content to specific specialitySection
//      for each contentMapped Procedure, add Content to specific procedureSection
//      for each contentMapped Product's productCategory, add Content to specific productCategorySection


@property (nonatomic, strong) NSString *searchString;
@end

@implementation SearchResultsVC
{
    BOOL hasProductsSearchResults;
    BOOL hasProceduresSearchResults;
    BOOL hasSpecialitiesSearchResults;
    BOOL hasContentsSearchResults;
    
    int filterType;
    int optionType;     // secondary sort
    int sortType;       // grouping (sections)
    
    int longPressItemSection;
    int longPressItemRow;
    NSString * searchText;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _searchTitle.font = [UIFont fontWithName:@"StagSans-Book" size:21];

	// Do any additional setup after loading the view.
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    [_activityView setHidden:NO];
    [_activityView startAnimating];
    //self.view.layer.cornerRadius = 10.0f;
    self.collectionView.layer.cornerRadius = 10.f;
    
    [self.appDelegate.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.appDelegate.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
//    _searchTitle.font = [UIFont fontWithName:@"StagSans-Book" size:21];
   [self setupCollectionView];
    
    filterType = kSearchResultsFilterTypeAll;
    optionType = kSearchResultsOptionTypeTitle;
    
    [self.sortSegCtl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    sortType = kSearchResultsSortTypeAll;
    
    [self.searchToolbar setBackgroundImage:[UIImage imageNamed:@"tool_bar_bkg"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    self.searchLbl.hidden = YES;
    self.noResultsFoundLbl.hidden = YES;
    self.sortSegCtl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor colorWithRed:204 green:204 blue:204 alpha:0.7], UITextAttributeTextColor,
                                nil];
    [self.sortSegCtl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    
    [self.sortSegCtl setTitleTextAttributes:highlightedAttributes forState:UIControlStateSelected];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    //    self.searchString = @"";
    if ([self.searchString length]== 0) {
        [self.alertLabel setHidden:NO];
        [_activityView setHidden:YES];
        [_activityView stopAnimating];
//        _alertImageView.hidden = NO;
    }
    else{
//        _alertImageView.hidden = NO;

        [self.alertLabel setHidden:YES];
        [self.collectionView setHidden:NO];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [_activityView setHidden:NO];
    [_activityView startAnimating];
    if ([self.noResultsFoundLbl isHidden] == NO || [self.searchString length]== 0) {
        [_activityView setHidden:YES];
        [_activityView stopAnimating];

               [self.alertLabel setHidden:NO];
//        _alertImageView.hidden = NO;
        [self.collectionView setHidden:YES];
        [self.noResultsFoundLbl setHidden:YES];
    }
    else{
                [self.alertLabel setHidden:YES];
//        _alertImageView.hidden = YES;
        [self.collectionView setHidden:NO];
    }
    [self.sortSegCtl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    sortType = kSearchResultsSortTypeAll;
    //[self refreshSearchResults];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) backgroundPerformSearch
{
    _productsSearchResults = _contentsSearchResults = nil;
    
    if ([self.searchString length] >0) {
//        if (filterType == kSearchResultsFilterTypeAll || filterType ==kSearchResultsFilterTypeProducts)
//        {
            // search the Products
            _productsSearchResults = [[ContentModel sharedInstance] searchProductsWithSearchString:self.searchString];
            //NSLog(@"_productsSearchResults:%@",_productsSearchResults);
//        }
        
        hasProductsSearchResults = _productsSearchResults && _productsSearchResults.fetchedObjects.count > 0;
        
//        if (filterType != kSearchResultsFilterTypeProducts) {
        // search the Contents
        
        
        _contentsSearchResults = [[ContentModel sharedInstance] searchContentsWithSearchString:self.searchString searchResultsSort:_sortSegCtl.selectedSegmentIndex filterType:kSearchResultsFilterTypeAll];
        
        hasContentsSearchResults = _contentsSearchResults && _contentsSearchResults.fetchedObjects.count > 0;
//        }
        [self reloadSortedSections];
    }
    //[self performSelectorOnMainThread:@selector(refreshSearchResults) withObject:nil waitUntilDone:NO];
    
    //dispatch_async(dispatch_get_main_queue(), ^{
    //    [self refreshSearchResults];
    //});
}


- (void) performSearch
{
//    //[self performSelectorInBackground:@selector(backgroundPerformSearch) withObject:nil];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
//                   ^{
//                       [self performSelector:@selector(backgroundPerformSearch)];
//                       dispatch_async(dispatch_get_main_queue(),
//                                      ^{
//                                          [self refreshSearchResults];
//                                      });
//                   });
    [self backgroundPerformSearch];
    [self refreshSearchResults];
}

- (void) refreshSearchResults
{
    [_activityView stopAnimating];
    [_activityView setHidden:YES];
    int totalcount = 0;
    if (sortType == kSearchResultsSortTypeAll){
        for (int i = 0; i < [self.categoryAllDict count]; i++) {
            totalcount = totalcount+ [[self.categoryAllDict objectAtIndex:i] count];
        }
    }
    if (totalcount>0)
    {
        [self.alertLabel setHidden:YES];
//        [self.alertImageView setHidden:YES];
        self.noResultsFoundLbl.hidden = YES;
        [self.collectionView setHidden:NO];
        self.searchLbl.hidden = NO;
        NSString * titlename = searchText;
        self.searchLbl.text = [NSString stringWithFormat:@"%@ - %d Items Found",searchText,totalcount];
//        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: self.searchLbl.attributedText];
//        int diff = self.searchLbl.text.length - titlename.length;
//        [text addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, 20)];
//        [text addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(20, self.searchString.length)];
//        [text addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(20+self.searchString.length, diff+1)];
//        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial" size:16] range:NSMakeRange(24+self.searchString.length, diff-3)];
//        [self.searchLbl setAttributedText: text];
    }
    else{
        if ([self.searchString length] >0) {
//            [self.alertImageView setHidden:YES];
            [self.alertLabel setHidden:YES];
            self.noResultsFoundLbl.hidden = YES;
            [self.collectionView setHidden:NO];
            self.searchLbl.text = [NSString stringWithFormat:@"Search results for '%@'", self.searchString];
//            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: self.searchLbl.attributedText];
//            [text addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, 20)];
//            [text addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(20, self.searchString.length)];
//            [text addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(20+self.searchString.length, 1)];
//            [self.searchLbl setAttributedText: text];
        }
        else{
            [self.searchLbl setHidden:YES];
        }
    }
    [self show];
    [_collectionView reloadData];
    
}

#pragma mark -
#pragma mark handle actions

- (IBAction) filterBtnTouched
{
    BOOL display = NO;
    NSString *titleString = @"Filters";
    if (self.actionSheet)
    {
        if (self.actionSheet.tag == kSearchResultsActionSheetTagFilters) {
            display = YES;
        }
        [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:YES];
        self.actionSheet = nil;
    }
    if (!display) {
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: titleString
                                                              delegate: self
                                                     cancelButtonTitle: @"cancel"
                                                destructiveButtonTitle: nil
                                                     otherButtonTitles: @"All", @"Videos", @"Articles",@"Products", nil];
    
    
    actionSheet.tag = kSearchResultsActionSheetTagFilters;
    self.actionSheet = actionSheet;
    [self.actionSheet showFromBarButtonItem:_filterButton animated:YES];
    }
}

- (IBAction) optionsBtnTouched
{
    BOOL display = NO;
    
    NSString *titleString = @"Options";
    if (self.actionSheet)
    {
        if (self.actionSheet.tag == kSearchResultsActionSheetTagOptions) {
            display = YES;
        }
        [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:YES];
        self.actionSheet = nil;
    }
    if (!display) {
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: titleString
                                                              delegate: self
                                                     cancelButtonTitle: @"cancel"
                                                destructiveButtonTitle: nil
                                                     otherButtonTitles: @"Title", @"Type", @"Date", nil];
    
    
    actionSheet.tag = kSearchResultsActionSheetTagOptions;
    self.actionSheet = actionSheet;
    [self.actionSheet showFromBarButtonItem:_sortButton animated:YES];
    }
    
}

- (IBAction) searchResultsSortChanged
{
    //NSLog(@"INDEX:%d",self.sortSegCtl.selectedSegmentIndex);
    if (sortType == self.sortSegCtl.selectedSegmentIndex) {
        [self.sortSegCtl setSelectedSegmentIndex:UISegmentedControlNoSegment];
        sortType = kSearchResultsSortTypeAll;
    }
    else{
        sortType = self.sortSegCtl.selectedSegmentIndex;
    }
    [self refreshSearchResults];
    [self.collectionView reloadData];
}

- (IBAction) closeBtnTouched
{
    //Vijay -- Moved SearchResults to Tabbar which should always be visible.
    //[self hide];
}

- (void) reloadSortedSections
{
    @autoreleasepool {
        
        // clear the sorted products arrays
        if (!self.specialitySectionsDict)
        {
            self.specialitySectionsDict = [[OrderedDictionary alloc] init];
        } else
        {
            [self.specialitySectionsDict removeAllObjects];
        }
        if (!self.procedureSectionsDict)
        {
            self.procedureSectionsDict = [[OrderedDictionary alloc] init];
        } else
        {
            [self.procedureSectionsDict removeAllObjects];
        }
        if (!self.productCategorySectionsDict)
        {
            self.productCategorySectionsDict = [[OrderedDictionary alloc] init];
        } else
        {
            [self.productCategorySectionsDict removeAllObjects];
        }
        if (!self.categoryAllDict)
        {
            self.categoryAllDict = [[OrderedDictionary alloc] init];
        } else
        {
            [self.categoryAllDict removeAllObjects];
        }
        NSMutableArray *array;
        UIImage *productImage;
        // for each Product found, ...
        //      for each related Procedure, add Product to a specific procedureSection
        //          for each Procedure, get the mapped Speciality, add Product to specific specialitySection
        //      for Product's productCategory, add Product to specific productCategorySection
        
        if (self.productsSearchResults && self.productsSearchResults.fetchedObjects ) {
            //NSLog(@"Products found: %d", self.productsSearchResults.fetchedObjects.count);
            
            NSMutableArray* prodCatIds = [[NSMutableArray alloc] init];
            for (Product *product in self.productsSearchResults.fetchedObjects) {
                productImage = [self thumbnailImageForProduct:product];
                if (productImage != NULL) {
                    [prodCatIds addObject:product.prodCatId];
                }
            }
            
            NSArray* productCategories = [[ContentModel sharedInstance] productCategoryWithProdIds:prodCatIds];
            for (Product *product in self.productsSearchResults.fetchedObjects)
            {
                productImage = [self thumbnailImageForProduct:product];
                if (productImage != NULL) {
                    for (Procedure *procedure in product.productToProcedure.allObjects)
                    {
                        array = [self.procedureSectionsDict objectForKey:procedure.name];
                        if (!array) {
                            array = [NSMutableArray arrayWithObject:product];
                            [self.procedureSectionsDict setObject:array forKey:procedure.name];
                            [self.categoryAllDict setObject:array forKey:procedure.name];
                        } else{
                            if (![array containsObject:product])
                                [array addObject:product];
                        }
                        
                        Speciality *speciality = procedure.procedureToSpeciality;
                        if (speciality)
                        {
                            array = [self.specialitySectionsDict objectForKey:speciality.name];
                            if (!array) {
                                array = [NSMutableArray arrayWithObject:product];
                                [self.specialitySectionsDict setObject:array forKey:speciality.name];
                                [self.categoryAllDict setObject:array forKey:speciality.name];
                            } else{
                                if (![array containsObject:product])
                                    [array addObject:product];
                            }
                        }
                    }
                }
//#warning relationship product.productToProdCat NOT being set!
                //ProductCategory *productCategory = product.productToProdCat;
                
                ProductCategory *productCategory = [self getProductCategory:product.prodCatId fromProductCatArray:productCategories];//[[ContentModel sharedInstance] productCategoryWithProdCatId:product.prodCatId];
                if (productCategory)
                {
                    if (productImage != NULL) {
                        array = [self.productCategorySectionsDict objectForKey:productCategory.name];
                        if (!array) {
                            array = [NSMutableArray arrayWithObject:product];
                            [self.productCategorySectionsDict setObject:array forKey:productCategory.name];
                            [self.categoryAllDict setObject:array forKey:productCategory.name];
                        } else{
                            if (![array containsObject:product])
                                [array addObject:product];
                        }
                        
                    }
                }
                
            }
        }
        
        // for each Content found, ...
        //      for each contentMapped Speciality, add Content to specific specialitySection
        //      for each contentMapped Procedure, add Content to specific procedureSection
        //      for each contentMapped Product's productCategory, add Content to specific productCategorySection
        if (self.contentsSearchResults && self.contentsSearchResults.fetchedObjects ) {
//            NSLog(@"Contents found: %@", self.contentsSearchResults.fetchedObjects);
            if (filterType != kSearchResultsFilterTypeProducts) {
                for (ContentSearch *content in self.contentsSearchResults.fetchedObjects)
                {
                    //NSLog(@"content %@",content.medCatName);
                    //NSLog(@"content %@",content.cntId);
                    if ([[content.medCatName lowercaseString] isEqualToString:@"speciality"] || [[content.medCatName lowercaseString] isEqualToString:@"specialty"])
                    {
//                        NSLog(@"content %@",content.catName);
//                        if (![content.catName isEqualToString:@"SpecialtyImage"]) {
                        array = [self.specialitySectionsDict objectForKey:content.medName];
                        if (!array) {
                            array = [NSMutableArray arrayWithObject:content];
                            [self.specialitySectionsDict setObject:array forKey:content.medName];
                            [self.categoryAllDict setObject:array forKey:content.medName];
                        } else {
                            if (![array containsObject:content] && ![self pathExists:content.path withArray:array])
                                [array addObject:content];
                        }
//                        }
                        //NSLog(@"For Speciality .. Title ... %@", content.path);
                    }
                    
                    if ([content.medCatName isEqualToString:@"Procedure"])
                    {
//                        NSLog(@"content %@",content.catName);
//                        if (![content.catName isEqualToString:@"ProcedureImage"]) {
                        array = [self.procedureSectionsDict objectForKey:content.medName];
                        if (!array) {
                            array = [NSMutableArray arrayWithObject:content];
                            [self.procedureSectionsDict setObject:array forKey:content.medName];
                            [self.categoryAllDict setObject:array forKey:content.medName];
                        } else{
                            if (![array containsObject:content] && ![self pathExists:content.path withArray:array])
                                [array addObject:content];
                        }
                       // }
                        //NSLog(@"For Procedure .. Title ... %@", content.path);
                    }
                    
                    if ([content.medCatName isEqualToString:@"Product"])
                    {
//                        if (![content.catName isEqualToString:@"ProductImage"]|| ![content.catName isEqualToString:@"ProductClinicalMessage"]||![content.catName isEqualToString:@"ProductNonClinicalMessage"]) {
                        array = [self.productCategorySectionsDict objectForKey:content.prodCatName];
                        if (!array) {
                            array = [NSMutableArray arrayWithObject:content];
                            if ([content.prodCatName length]>0) {
                                [self.productCategorySectionsDict setObject:array forKey:content.prodCatName];
                                [self.categoryAllDict setObject:array forKey:content.prodCatName];
                            }
                        } else {
                            if (![array containsObject:content] && ![self pathExists:content.path withArray:array])
                                [array addObject:content];
                        }
//                        }
                        //NSLog(@"For Product .. Title ... %@", content.path);
                    }
                }
            }
        }
    //Make unique list removing duplicates
        NSMutableArray *itemsArray = [[NSMutableArray alloc]init];
        for (int i = 0; i< [self.categoryAllDict count]; i++) {
            NSArray * tempArray = [self.categoryAllDict objectAtIndex:i];
            for (int j = 0 ; j< [tempArray count]; j++) {
                if (![itemsArray containsObject:[tempArray objectAtIndex:j]]) {
                    if ([[tempArray objectAtIndex:j] isKindOfClass:[ContentSearch class]]) {
                        ContentSearch * content =  (ContentSearch *) [tempArray objectAtIndex:j];
                        if (![self contentExists:content.cntId withArray:itemsArray] && ![self titleExists:content.title withArray:itemsArray]) {
                            [itemsArray addObject:[tempArray objectAtIndex:j]];
                        }
                    }
                    else {
                    [itemsArray addObject:[tempArray objectAtIndex:j]];
                  }
                }
            }
        }
        
        [self.categoryAllDict removeAllObjects];
        [self.categoryAllDict setObject:itemsArray forKey:@"all"];
        [self filterSearchResultItems];
        [self sortSearchResultItems];
        //NSLog(@"productCategorySections : %@", self.productCategorySectionsDict);
        //NSLog(@"procedureSections : %@", self.procedureSectionsDict);
        //NSLog(@"specialitySections : %@", self.specialitySectionsDict);
        NSLog(@"categoryAllDict : %@", self.categoryAllDict);
    }
}

- (BOOL) pathExists:(NSString*) path withArray:(NSArray*) array {
    
    for (id cnt in array) {
        if ([cnt isKindOfClass:ContentSearch.class]) {
            ContentSearch* cntSearch = (ContentSearch*) cnt;
            if ([cntSearch.path isEqualToString:path]) {
//                NSLog(@"duplicate path %@", path);
                return YES;
            }
            else if ([path length] == 0){
                return YES;
            }

        }
    }
    return NO;
}

- (BOOL) contentExists:(NSNumber*) cntId withArray:(NSArray*) array {
    
    for (id cnt in array) {
        if ([cnt isKindOfClass:ContentSearch.class]) {
            ContentSearch* cntSearch = (ContentSearch*) cnt;
            if ([cntSearch.cntId isEqualToNumber:cntId]) {
//                NSLog(@"duplicate content %@", cntId);
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL) titleExists:(NSString*) cntTitle withArray:(NSArray*) array {
    
    for (id cnt in array) {
        if ([cnt isKindOfClass:ContentSearch.class]) {
            ContentSearch* cntSearch = (ContentSearch*) cnt;
            if ([cntSearch.title isEqualToString:cntTitle]) {
                //      NSLog(@"duplicate title %@", cntTitle);
                return YES;
            }
            else if ([cntTitle length] == 0){
                return YES;
            }
            
        }
    }
    return NO;
}

/**
 */
- (ProductCategory*) getProductCategory: (NSNumber*) prodCatId fromProductCatArray: (NSArray*) productCategories {
    
    for (ProductCategory* prodCat in productCategories) {
        if ([[prodCat prodCatId] intValue] == [prodCatId intValue]) {
            return prodCat;
        }
    }
    return nil;
}

- (void) filterSearchResultItems
{
    NSArray *allowedTypes;
    switch (filterType) {
        case kSearchResultsFilterTypeVideos:
        {
            allowedTypes = [NSArray arrayWithObjects:
                            [NSNumber numberWithInt:kSpecialtyVideo],
                            [NSNumber numberWithInt:kProcedureVideo],
                            [NSNumber numberWithInt:kProductVideo],
                            [NSNumber numberWithInt:kProductCompetitiveInfoVideos],
                            nil];
        }
            break;
        case kSearchResultsFilterTypeArticles:
            allowedTypes = [NSArray arrayWithObjects:
                            [NSNumber numberWithInt:kSpecialtyArticle],
                            [NSNumber numberWithInt:kProcedureArticle],
                            [NSNumber numberWithInt:kProductArticle],
                            [NSNumber numberWithInt:kProductClinicalArticles],
                            [NSNumber numberWithInt:kProductClinicalArticlesOthers],
                            nil];
            break;
        case kSearchResultsFilterTypeProducts:
            allowedTypes = [NSArray arrayWithObjects:[NSNumber numberWithInt:0],nil];
            break;
        case kSearchResultsFilterTypeAll:
        default:
            allowedTypes = nil;
            break;
    }
    
    if ([allowedTypes count]>1)
    {
         NSMutableArray *itemsArray = [[NSMutableArray alloc]init];
        for (int i =0 ; i < [self.categoryAllDict count]; i++) {
             NSArray *tempArray = [self.categoryAllDict objectAtIndex:i];
            for (int j = 0 ; j< [tempArray count]; j++) {
            if ([[tempArray objectAtIndex:j] isKindOfClass:[ContentSearch class]]) {
                ContentSearch * content =  (ContentSearch *) [tempArray objectAtIndex:j];
                if ([self catergoryExists:content.catId withArray:allowedTypes]
                    ) {
                    [itemsArray addObject:[tempArray objectAtIndex:j]];
                }
            }
          }
        }
        [self.categoryAllDict removeAllObjects];
        [self.categoryAllDict setObject:itemsArray forKey:@"all"];
    }
    else if ([[allowedTypes objectAtIndex:0] isEqualToNumber:[NSNumber numberWithInt:0]]){
        NSMutableArray *itemsArray = [[NSMutableArray alloc]init];
        for (int i =0 ; i < [self.categoryAllDict count]; i++) {
             NSArray *tempArray  = [self.categoryAllDict objectAtIndex:i];
            for (int j = 0 ; j< [tempArray count]; j++) {
                if ([[tempArray objectAtIndex:j] isKindOfClass:[Product class]]) {
                [itemsArray addObject:[tempArray objectAtIndex:j]];
                }
            }
        }
        [self.categoryAllDict removeAllObjects];
        [self.categoryAllDict setObject:itemsArray forKey:@"all"];
    }

}

- (BOOL) catergoryExists:(NSNumber*) catId withArray:(NSArray*) array {
    
    for (NSNumber *cat in array) {
            if ([cat isEqualToNumber:catId]) {
                return YES;
            }
        }
    return NO;
}

- (void) sortSearchResultItems
{
    [self applyOptionTypeSortToDict:self.productCategorySectionsDict];
    [self applyOptionTypeSortToDict:self.procedureSectionsDict];
    [self applyOptionTypeSortToDict:self.specialitySectionsDict];
    [self applyOptionTypeSortToDict:self.categoryAllDict];
}

- (void) applyOptionTypeSortToDict:(OrderedDictionary*)dict
{
    NSArray *array;
    for (NSString *key in dict.allKeys)
    {
        switch (optionType) {
            case kSearchResultsOptionTypeTitle:
                array = [self sortSearchResultItemsByTitle:[dict objectForKey:key]];
                break;
            case kSearchResultsOptionTypeDate:
                array = [self sortSearchResultItemsByDate:[dict objectForKey:key]];
                break;
            case kSearchResultsOptionTypeType:
                array = [self sortSearchResultItemsByType:[dict objectForKey:key]];
                break;
                
            default:
                break;
        }
        if (array != nil) {
        [dict setObject:array forKey:key];
        }
    }
    
}

- (NSArray*)sortSearchResultItemsByTitle:(NSArray*)array
{
    NSArray *sortedArray;
    sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [a isKindOfClass:[Product class]] ? [(Product*)a name] : [(ContentSearch*)a title];
        NSString *second = [b isKindOfClass:[Product class]] ? [(Product*)b name] : [(ContentSearch*)b title];
        return [first compare:second];
    }];
    if (sortedArray != nil) {
    return sortedArray;
    }
        else{
            return nil;
        }
}

- (NSArray*)sortSearchResultItemsByDate:(NSArray*)array
{
    NSArray *sortedArray;
    sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        // "a" and "b" are instances of Product or Content objects
        NSDate *first = [a isKindOfClass:[Product class]] ? [(Product*)a uptDt] : [(ContentSearch*)a uptDt];
        NSDate *second = [b isKindOfClass:[Product class]] ? [(Product*)b uptDt] : [(ContentSearch*)b uptDt];
        return [first compare:second];
    }];
    
    if (sortedArray != nil) {
        return sortedArray;
    }
    else{
        return nil;
    }
}

- (NSNumber*)sortNbrForContent:(ContentSearch*)content
{
    NSNumber *sortNbr;
    
    // sort order Videos, Messages, Articles
    // any not matching those types, sort to last
    switch ([content.catId intValue])
    {
            // video
        case kSpecialtyVideo:
        case kProcedureVideo:
        case kProductVideo:
        case kProductCompetitiveInfoVideos:
            //
            // ... video logic here
            sortNbr = [NSNumber numberWithInt:2];
            //
            break;
            
            // article
        case kSpecialtyArticle:
        case kProcedureArticle:
        case kProductClinicalArticles:
        case kProductClinicalArticlesCharts:
        case kProductClinicalArticlesOthers:
            //
            // ... article logic here
            sortNbr = [NSNumber numberWithInt:4];
            //
            break;
            
            // message
        case kSpecialtyMessage:
        case kProcedureMessage:
        case kProductClinicalMessage:
        case kProductNonClinicalMessage:
            //
            // ... message logic here
            sortNbr = [NSNumber numberWithInt:3];
            //
            break;
            
        default:
            //
            // ... default logic here
            sortNbr = [NSNumber numberWithInt:99];
            //
            break;
    }
    
    return sortNbr;
    
}

- (NSArray*)sortSearchResultItemsByType:(NSArray*)array
{
    NSArray *sortedArray;
    sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        
        NSNumber *first, *second;
        
        if ([a isKindOfClass:[Product class]])
        {
            // Product appear first in sort
            first = [NSNumber numberWithInt:1];
        } else if ([a isKindOfClass:[ContentSearch class]])
        {
            // get the sort order for the Content object
            first = [self sortNbrForContent:(ContentSearch*)a];
        }
        
        if ([b isKindOfClass:[Product class]])
        {
            // Product appear first in sort
            second = [NSNumber numberWithInt:1];
        } else if ([b isKindOfClass:[ContentSearch class]])
        {
            // get the sort order for the Content object
            second = [self sortNbrForContent:(ContentSearch*)b];
        }
        return [first compare:second];
    }];
    
    if (sortedArray != nil) {
        return sortedArray;
    }
    else{
        return nil;
    }
}

#pragma mark -
#pragma mark UIActionSheetDelegate


- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    //#warning iOS7 test bed
    //actionSheet.backgroundColor = [UIColor grayColor];
    
    //Gets an array af all of the subviews of our actionSheet
    NSArray *subviews = [actionSheet subviews];
    
    for (UIView *v in subviews)
    {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *b = (UIButton*)v;
            [b setTitleColor:[UIColor colorWithRed:130.0f/255.0f green:130.0f/255.0f blue:130.0f/255.0f alpha:1] forState:UIControlStateNormal];
            [b setTitleColor:[UIColor colorWithRed:243.0f/255.0f green:6.0f/255.0f blue:23.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
            b.titleLabel.font = [UIFont fontWithName:@"Arial" size:18];
            //[b setBackgroundImage:[UIImage imageNamed:@"backActionSheetHighlighted.png"] forState:UIControlStateHighlighted];
            //[b setBackgroundImage:[UIImage imageNamed:@"backActionSheet.png"] forState:UIControlStateNormal];
        }
    }
    //
    
    if (actionSheet.tag == kSearchResultsActionSheetTagFilters || actionSheet.tag == kSearchResultsActionSheetTagOptions)
    {
        for (UIView *_currentView in actionSheet.subviews) {
            if ([_currentView isKindOfClass:[UILabel class]])
            {
                CGRect frame = ((UILabel *)_currentView).frame;
                frame.origin.y = 20;
                frame.size.height = 40;
                ((UILabel *)_currentView).frame = frame;
                [((UILabel *)_currentView) setFont:[UIFont fontWithName:@"Arial" size:20]];
                [((UILabel *)_currentView) setTextColor:[UIColor colorWithRed:243.0f/255.0f green:6.0f/255.0f blue:23.0f/255.0f alpha:1.0f]];
                
            }
            
        }
    }
}


// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int buttonsCount = actionSheet.numberOfButtons;
    switch (actionSheet.tag) {
            // filters
        case kSearchResultsActionSheetTagFilters:
            if (buttonIndex < buttonsCount -1) {
                [self updateFilter:buttonIndex];
            }
            break;
            // options
        case kSearchResultsActionSheetTagOptions:
            if (buttonIndex < buttonsCount -1) {
                [self updateOption:buttonIndex];
            }
            break;
            // long press
        case kSearchResultsActionSheetTagLongPress:
        {
            if (buttonIndex >= 0) {
                [self handleLongPressMenuSelection:buttonIndex];
//                NSLog(@"button index:%d",buttonIndex);
            }
            break;
        }
        case kSearchResultsLongPressItemFavoriteTagCancelandSharable:
            if (buttonIndex == 0) {
                [self handleLongPressMenuSelection:1];
            }
            break;
            
        default:
            break;
    }
}


- (void) updateFilter:(int)buttonIndex
{
    switch (buttonIndex) {
        case kSearchResultsFilterTypeAll:
            [self.filterBtn setImage:[UIImage imageNamed:@"filter_all"] forState:UIControlStateNormal];
            break;
        case kSearchResultsFilterTypeVideos:
            [self.filterBtn setImage:[UIImage imageNamed:@"filter_videos"] forState:UIControlStateNormal];
            break;
        case kSearchResultsFilterTypeArticles:
            [self.filterBtn setImage:[UIImage imageNamed:@"filter_articles"] forState:UIControlStateNormal];
            break;
        case kSearchResultsFilterTypeProducts:
            [self.filterBtn setImage:[UIImage imageNamed:@"filter_products"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    if (buttonIndex >= 0) {
        filterType = buttonIndex;
    }
    [self reloadSortedSections];
    [self refreshSearchResults];
//    [self performSearch];
}

- (void) updateOption:(int)buttonIndex
{
    switch (buttonIndex) {
        case kSearchResultsOptionTypeTitle:
            [self.optionsBtn setImage:[UIImage imageNamed:@"title"] forState:UIControlStateNormal];
            break;
        case kSearchResultsOptionTypeDate:
            [self.optionsBtn setImage:[UIImage imageNamed:@"date"] forState:UIControlStateNormal];
            break;
        case kSearchResultsOptionTypeType:
            [self.optionsBtn setImage:[UIImage imageNamed:@"type"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    if (buttonIndex >= 0) {
        optionType = buttonIndex;
    }
//    [self performSearch];
    [self reloadSortedSections];
    [self refreshSearchResults];
}

- (void) handleLongPressMenuSelection:(int)buttonIndex
{
    NSObject *dataObj;
    switch (sortType) {
        case kSearchResultsSortTypeProducts:
            dataObj = [[self.productCategorySectionsDict objectAtIndex:longPressItemSection] objectAtIndex:longPressItemRow];
            break;
        case kSearchResultsSortTypeProcedures:
            dataObj = [[self.procedureSectionsDict objectAtIndex:longPressItemSection] objectAtIndex:longPressItemRow];
            break;
        case kSearchResultsSortTypeSpecialties:
            dataObj = [[self.specialitySectionsDict objectAtIndex:longPressItemSection] objectAtIndex:longPressItemRow];
            break;
        case kSearchResultsSortTypeAll:
            if ([self.categoryAllDict count]>longPressItemSection) {
            dataObj = [[self.categoryAllDict objectAtIndex:longPressItemSection]objectAtIndex:longPressItemRow];
            }
            break;
        default:
            break;
    }
    
    if (dataObj)
    {
        if ([dataObj isKindOfClass:[Product class]])
        {
            Product *product = (Product*)dataObj;
            [[FavoritesModel sharedInstance] addFavoriteWithProduct:product];
            //        // Product was longPress
            //        Product *product = [_productsSearchResults.fetchedObjects objectAtIndex:longPressItemRow];
            //        //NSLog(@"product.name: %@ product.code: %@", product.name, product.code);
            //        [self.appDelegate navigateToProductDetailWithProduct:product];
            //        [self closeBtnTouched];
        }
        else if ([dataObj isKindOfClass:[ContentSearch class]])
        {
            ContentSearch* cs = (ContentSearch*)dataObj;
            Content *content = [[ContentSearchModel sharedInstance] fetchContentById:[[cs cntId] intValue]];
            //            [self closeBtnTouched];
            //            if (content)
            //                [self openContentInContentViewer:content];
            
            if (content)
            {
                switch (buttonIndex) {
                    case kSearchResultsLongPressItemAddToFavorites:
                        [self handleAddToFavoritesWithContent:content];
                        break;
                    case kSearchResultsLongPressItemShare:
                        [self handleShareWithContent:content];
                        break;
                    default:
                        break;
                }
            }
        }
    }
    
}

- (void)handleAddToFavoritesWithContent:(Content*)content
{
    [[FavoritesModel sharedInstance] addFavoriteWithCntId:content.cntId contentCatId:content.contentCatId];
}

- (void)handleShareWithContent:(Content*)content
{
    //[self closeBtnTouched];
    [self.tabs invokeEmailQueueOverlayVCWithContent:content];
    
}

#pragma mark -
#pragma mark public

- (void) show
{
    if (self.view.hidden)
    {
        self.view.hidden = NO;
    }
}

- (void) hide
{
    if (!self.view.hidden)
    {
        self.view.hidden = YES;
    }
}

- (void) performSearchWithSearchstring:(NSString*)searchStr
{
    [self.alertLabel setHidden:YES];
//    _alertImageView.hidden = YES;
    [self.collectionView setHidden:NO];
    self.searchString = searchStr;
    self.searchLbl.text = [NSString stringWithFormat:@"Search results for '%@'", searchStr];
    searchText = self.searchLbl.text;
    //    self.searchLbl.hidden = NO;
    [self performSearch];
}

#pragma mark -
#pragma mark UICollectionViewDataSource

-(void)setupCollectionView
{
    [_collectionView setCollectionViewLayout:[[SearchResultsGridLayout alloc] init]];
    
    [_collectionView setPagingEnabled:NO];
    //[_collectionView registerClass:[ProductSectionHeaderCell class]
    //    forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
    //          withReuseIdentifier:@"ProductSectionHeaderCell"];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    int nSections = 0;
    
    switch (sortType) {
        case kSearchResultsSortTypeProducts:
            nSections = self.productCategorySectionsDict.count;
            break;
        case kSearchResultsSortTypeProcedures:
            nSections = self.procedureSectionsDict.count;
            break;
        case kSearchResultsSortTypeSpecialties:
            nSections = self.specialitySectionsDict.count;
            break;
        case kSearchResultsSortTypeAll:
            nSections = 1;
            break;
        default:
            break;
    }
    
//    NSLog(@"nSections: %d", nSections);
    
    if ([self.alertLabel isHidden]) {
        self.noResultsFoundLbl.hidden = nSections > 0;
    }
    
    if ([self.noResultsFoundLbl isHidden] == NO) {
        self.searchLbl.hidden = YES;
    }
    
    return nSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    int nItems = 0;
    
    switch (sortType) {
        case kSearchResultsSortTypeProducts:
            nItems = [[self.productCategorySectionsDict objectAtIndex:section] count];
            break;
        case kSearchResultsSortTypeProcedures:
            nItems = [[self.procedureSectionsDict objectAtIndex:section] count];
            break;
        case kSearchResultsSortTypeSpecialties:
            nItems = [[self.specialitySectionsDict objectAtIndex:section] count];
            break;
        case kSearchResultsSortTypeAll:
             if ([self.categoryAllDict count]>section) {
            nItems = [[self.categoryAllDict objectAtIndex:section] count];
             }
            break;
        default:
            break;
    }
    
    //NSLog(@"nItems: %d", nItems);
    self.noResultsFoundLbl.hidden = nItems >0;
    self.searchLbl.hidden = nItems == 0;
    if ([self.noResultsFoundLbl isHidden] == NO || [self.searchLbl isHidden] == NO) {
        [self.alertLabel setHidden:YES];
    }
    return nItems;
}

- (UIImage*) thumbnailImageForProduct:(Product*)product
{
    UIImage *productThumbnailImage;
    
    NSArray *contents = [[ContentModel sharedInstance] contentsForProduct:product withContentCatIds:[NSArray arrayWithObject:[NSNumber numberWithInt:kProductImage]]];
    
    for (Content *content in contents)
    {
        if (content.thumbnailImgPath)
        {
            productThumbnailImage = [self.appDelegate loadImage:content.thumbnailImgPath];
            break;
        }
        
    }
    
    //    if (!productThumbnailImage)
    //    {
    //        productThumbnailImage = [UIImage imageNamed:PRODUCT_MISSING_IMAGE];
    //    }
    
    return productThumbnailImage;
    
}

- (NSString*) imageNameForContentCatId:(NSString*)mime
{
    NSString *imageName;
    
    if ([[mime lowercaseString] isEqualToString:@"application/zip"])
    {
        imageName = @"html_large_btn";
    }
    else if ([[mime lowercaseString] isEqualToString:@"application/pdf"])
    {
        imageName = @"article_large_btn";
    }
    else if ([[mime lowercaseString] isEqualToString:@"video/quicktime"])
    {
        imageName = @"video_large_btn";
    }
    else if ([[mime lowercaseString] isEqualToString:[NSString stringWithFormat:@"%d" ,CONTENT_CAT_ID_FAV_ON_PRODUCT]])
    {
        imageName = @"product_large_btn";
    }
    return imageName;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static UICollectionViewCell *cell;
    
#warning FIX ME
    SearchResultsGridCVCell *gridCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SearchResultsGridCVCell" forIndexPath:indexPath];
    
    gridCell.imageBorderView.layer.cornerRadius = 0.0f;
    gridCell.imageBorderView.layer.borderColor = [UIColor colorWithRed:243.0f/255.0f green:243.0f/255.0f blue:243.0f/255.0f alpha:1.0f].CGColor;
    gridCell.imageBorderView.layer.borderWidth = 1.f;
    
    UIImage *productThumbnailImage;
    
    NSObject *dataObj;
    switch (sortType) {
        case kSearchResultsSortTypeProducts:
            dataObj = [[self.productCategorySectionsDict objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            break;
        case kSearchResultsSortTypeProcedures:
            dataObj = [[self.procedureSectionsDict objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            break;
        case kSearchResultsSortTypeSpecialties:
            dataObj = [[self.specialitySectionsDict objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            break;
        case kSearchResultsSortTypeAll:
             if ([self.categoryAllDict count]>indexPath.section) {
            dataObj = [[self.categoryAllDict objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
             }
            break;
        default:
            break;
    }
    
    if (dataObj)
    {
        if ([dataObj isKindOfClass:[Product class]])
        {
            Product *product = (Product*)dataObj;
            productThumbnailImage = [self thumbnailImageForProduct:product];
            
            gridCell.imageView.image = productThumbnailImage;
            gridCell.titleLbl.text = product.name;
            gridCell.dateLbl.text = [self.appDelegate.dateFormatter stringFromDate:product.uptDt];
            gridCell.overlayImageView.image = [UIImage imageNamed:[self imageNameForContentCatId:[NSString stringWithFormat:@"%d" ,CONTENT_CAT_ID_FAV_ON_PRODUCT]]];

#warning LONG-PRESS NOT SUPPORTED FOR PRODUCTS
            // NOTE: long-press not enabled for Products
            ///
            // so remove long-press gesture if exists, since cells are re-used!
            //            for (UIGestureRecognizer *ges in gridCell.gestureRecognizers)
            //            {
            //                if ([ges isKindOfClass:[UILongPressGestureRecognizer class]])
            //                {
            //                    [gridCell removeGestureRecognizer:ges];
            //                }
            //            }
            //NSLog(@"Product Title : %@", product.name);
        }
        else if ([dataObj isKindOfClass:[ContentSearch class]])
        {
            ContentSearch *content = (ContentSearch*)dataObj;
//             NSLog(@"content %@",content.cntId);
            productThumbnailImage = [self.appDelegate loadImage:content.thumbnailImgPath];
            if (!productThumbnailImage)
            {
//                productThumbnailImage = [[ContentModel sharedInstance] thumbnailImageForContentCatId:content.catId];
                productThumbnailImage = [[ContentModel sharedInstance] thumbnailImageForContentTitle:content.title];
            }
            gridCell.imageView.image = productThumbnailImage;
            gridCell.titleLbl.text = content.title;
            gridCell.dateLbl.text = [self.appDelegate.dateFormatter stringFromDate:content.uptDt];
            gridCell.overlayImageView.image = [UIImage imageNamed:[self imageNameForContentCatId:content.mime]];
            // set up long-press for Content types
            //            UILongPressGestureRecognizer *longPressGesture =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
            //            [gridCell addGestureRecognizer:longPressGesture];
            //NSLog(@"Content Title : %@", content.title);
            //NSLog(@"Content Path  : %@", content.path);
        }
    }
    
    cell = gridCell;
    UILongPressGestureRecognizer *longPressGesture =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    [cell addGestureRecognizer:longPressGesture];
    
    return cell;
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        
#warning FIX ME
        ProductSectionHeaderCell *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProductSectionHeaderCell" forIndexPath:indexPath];
        
        headerView.titleLbl.text = @"";
        headerView.layer.cornerRadius = 11.0f;
        headerView.titleLbl.font = [UIFont fontWithName:@"StagSans-Light" size:20];
        NSString *sectionTitle;
        int items = 0 ;
        switch (sortType) {
            case kSearchResultsSortTypeProducts:
                sectionTitle = [self.productCategorySectionsDict keyAtIndex:indexPath.section];
                items = [[self.productCategorySectionsDict objectAtIndex:indexPath.section ] count];
                break;
            case kSearchResultsSortTypeProcedures:
                sectionTitle = [self.procedureSectionsDict keyAtIndex:indexPath.section];
                items = [[self.procedureSectionsDict objectAtIndex:indexPath.section ] count];
                break;
            case kSearchResultsSortTypeSpecialties:
                sectionTitle = [self.specialitySectionsDict keyAtIndex:indexPath.section];
                items = [[self.specialitySectionsDict objectAtIndex:indexPath.section ] count];
                
                break;
            case kSearchResultsSortTypeAll:
                //                sectionTitle = [self.categoryAllDict keyAtIndex:indexPath.section];
                //                items = [[self.categoryAllDict objectAtIndex:indexPath.section]count];
                sectionTitle = @"";
                items = 0;
                break;
            default:
                break;
        }
        headerView.titleLbl.text = [NSString stringWithFormat:@"%@", sectionTitle];
        if (items >0)
        {
            headerView.titleLbl.text = [NSString stringWithFormat:@"%@   ( %d )",sectionTitle,items];
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: headerView.titleLbl.attributedText];
            int diff = headerView.titleLbl.text.length - sectionTitle.length;
            [text addAttribute: NSForegroundColorAttributeName value:[UIColor darkGrayColor] range: NSMakeRange(sectionTitle.length+3, diff-3)];
            [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"StagSans-Light" size:14] range:NSMakeRange(sectionTitle.length+3, diff-3)];
            [headerView.titleLbl setAttributedText: text];
        }
        reusableview = headerView;
        
    } else if (kind == UICollectionElementKindSectionFooter) {
        ProductSectionHeaderCell *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProductSectionHeaderCell" forIndexPath:indexPath];
        headerView.titleLbl.text = @"";
        reusableview = headerView;
    }
    
    return reusableview;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSObject *dataObj;
    switch (sortType) {
        case kSearchResultsSortTypeProducts:
            dataObj = [[self.productCategorySectionsDict objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            break;
        case kSearchResultsSortTypeProcedures:
            dataObj = [[self.procedureSectionsDict objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            break;
        case kSearchResultsSortTypeSpecialties:
            dataObj = [[self.specialitySectionsDict objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            break;
        case kSearchResultsSortTypeAll:
             if ([self.categoryAllDict count]>indexPath.section) {
            dataObj = [[self.categoryAllDict objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
             }
            break;
        default:
            break;
    }
    
    if (dataObj)
    {
        if ([dataObj isKindOfClass:[Product class]])
        {
            // Product was selected
            Product *product = (Product*)dataObj;
            //NSLog(@"product.name: %@ product.code: %@", product.name, product.code);
            
            [self closeBtnTouched];
            [self.appDelegate navigateToProductDetailWithProduct:product];
            
        }
        else if ([dataObj isKindOfClass:[ContentSearch class]])
        {
            ContentSearch* cs = (ContentSearch*)dataObj;
            NSLog(@"duplicate content %@", [cs title]);
            Content *content = [[ContentSearchModel sharedInstance] fetchContentById:[[cs cntId] intValue]];
            [self closeBtnTouched];
            if (content){
                NSString* targetPath = [[ContentModel sharedInstance] addAppDocumentsPathToPath:content.path];
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:targetPath];
                if (fileExists) {
                    [self openContentInContentViewer:content];
                }
                else
                {
                    SearchResultsGridCVCell *cell = (SearchResultsGridCVCell *)[collectionView cellForItemAtIndexPath:indexPath];
                    
                    UIImageView *showMsg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 120, 50)];
                    [showMsg convertRect:cell.contentView.frame fromView:showMsg];
                    showMsg.image = [UIImage imageNamed:@"search_popup.png"];
                    [cell.contentView addSubview:showMsg];
                    showMsg.alpha = 1.0f;
                    [UIView animateWithDuration:5.0 delay:0.5 options:0 animations:^{
                        showMsg.alpha = 0.0f;
                    } completion:^(BOOL finished) {
                        [showMsg removeFromSuperview];
                    }];
                }
            }
            //=======
            //            Content *content = (Content*)dataObj;
            //
            //            //[self closeBtnTouched];
            //            [self openContentInContentViewer:content];
            //>>>>>>> 14b32e97ce9d8c7df57495cad1c7f6c4b4d6caf0
        }
    }
    
}

#pragma mark -
#pragma mark UIGestureRecognizer Methods

- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
    {
        // iOS 8 logic
        self.view.window.tintColor = [UIColor grayColor];
    }
    
	// only when gesture was recognized, not when ended
	if (gesture.state == UIGestureRecognizerStateBegan)
	{
		// get affected cell
		SearchResultsGridCVCell *cell = (SearchResultsGridCVCell *)[gesture view];

		// get indexPath of cell
		NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        
        longPressItemSection = indexPath.section;
        longPressItemRow = indexPath.row;
        
        
        NSObject *dataObj;
        BOOL isFavorite;
        NSString *str;
        switch (sortType) {
            case kSearchResultsSortTypeProducts:
                dataObj = [[self.productCategorySectionsDict objectAtIndex:longPressItemSection] objectAtIndex:longPressItemRow];
                break;
            case kSearchResultsSortTypeProcedures:
                dataObj = [[self.procedureSectionsDict objectAtIndex:longPressItemSection] objectAtIndex:longPressItemRow];
                break;
            case kSearchResultsSortTypeSpecialties:
                dataObj = [[self.specialitySectionsDict objectAtIndex:longPressItemSection] objectAtIndex:longPressItemRow];
                break;
            case kSearchResultsSortTypeAll:
                 if ([self.categoryAllDict count]>longPressItemSection) {
                dataObj = [[self.categoryAllDict objectAtIndex:longPressItemSection] objectAtIndex:longPressItemRow];
                 }
                break;
            default:
                break;
        }
        
        if (dataObj)
        {
            if ([dataObj isKindOfClass:[Product class]])
            {
                Product *product = (Product*)dataObj;
                isFavorite = [[FavoritesModel sharedInstance] isProductAFavorite:product];
                
                if (isFavorite == YES)
                {
//                    NSLog(@"Im a Favorite");
                    
                    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: @"Already a Favorite"
                                                                              delegate: self
                                                                     cancelButtonTitle: nil
                                                                destructiveButtonTitle: nil
                                                                     otherButtonTitles: @"OK", nil];
                    
                    [actionSheet showFromRect: cell.frame inView: cell.superview animated: YES];
                    actionSheet.tag = kSearchResultsLongPressItemFavoriteTagCancel;
                }
                else
                {
//                    NSLog(@"Im NOT Favorite");
                    
                    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                                              delegate: self
                                                                     cancelButtonTitle: nil
                                                                destructiveButtonTitle: nil
                                                                     otherButtonTitles: @"Add to Favorites", nil];
                    
                    [actionSheet showFromRect: cell.frame inView: cell.superview animated: YES];
                    actionSheet.tag = kSearchResultsActionSheetTagLongPress;
                    
                }
                
            }
            else if ([dataObj isKindOfClass:[ContentSearch class]])
            {
                ContentSearch* cs = (ContentSearch*)dataObj;
                Content *content = [[ContentSearchModel sharedInstance] fetchContentById:[[cs cntId] intValue]];
                
                if ([cs.catName isEqualToString:@"SpecialtyPresentations"] || [cs.catName isEqualToString:@"SpecialtyIV"] || [cs.catName isEqualToString:@"ProcedurePresentations"] || [cs.catName isEqualToString:@"ProcedureIV"] || [cs.catName isEqualToString:@"ProductIV"])
                {
                    [content setIsSharable:[NSNumber numberWithInt:0]];
                }
                
                isFavorite = [[FavoritesModel sharedInstance] isContentAFavorite:content];
                
                if (isFavorite)
                {
                    str = @"Already a Favorite";
                    
                    if (content.isSharable == [NSNumber numberWithInt:0])
                    {
//                        NSLog(@"Favorite and NOT sharable");
                        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: str
                                                                                  delegate: self
                                                                         cancelButtonTitle: nil
                                                                    destructiveButtonTitle: nil
                                                                         otherButtonTitles: @"OK",nil];
                        
                        actionSheet.tag = kSearchResultsLongPressItemFavoriteTagCancel;
                        
                        
                        [actionSheet showFromRect: cell.frame inView: cell.superview animated: YES];
                        
                    }
                    else if (content.isSharable == [NSNumber numberWithInt:1])
                    {
                        //NSLog(@"Favorite and sharable");
                        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: str
                                                                                  delegate: self
                                                                         cancelButtonTitle: nil
                                                                    destructiveButtonTitle: nil
                                                                         otherButtonTitles: @"Share",nil];
                        
                        actionSheet.tag = kSearchResultsLongPressItemFavoriteTagCancelandSharable;
                        
                        [actionSheet showFromRect: cell.frame inView: cell.superview animated: YES];
                    }
                }
                else
                {
                    str = @"Add to Favorites";
                    
                    if (content.isSharable == [NSNumber numberWithInt:0])
                    {
                        //NSLog(@"Not Favorite and NOT sharable");
                        
                        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                                                  delegate: self
                                                                         cancelButtonTitle: nil
                                                                    destructiveButtonTitle: nil
                                                                         otherButtonTitles: str, nil];
                        
                        actionSheet.tag = kSearchResultsActionSheetTagLongPress;
                        
                        [actionSheet showFromRect: cell.frame inView: cell.superview animated: YES];
                        
                        
                        
                    }
                    else if (content.isSharable == [NSNumber numberWithInt:1])
                    {
                        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                                                  delegate: self
                                                                         cancelButtonTitle: nil
                                                                    destructiveButtonTitle: nil
                                                                         otherButtonTitles: str, @"Share", nil];
                        
                        actionSheet.tag = kSearchResultsActionSheetTagLongPress;
                        
                        [actionSheet showFromRect: cell.frame inView: cell.superview animated: YES];
                        
                        
                    }
                }
            }
        }
    }
}

- (void) openContentInContentViewer:(Content*)content
{
    // add MyRecentlyViewed
    [[DashboardModel sharedInstance] addRecentlyViewedForContent:content];
    
    ResourceViewerViewController* rviewer = [[ResourceViewerViewController alloc] initWithNibName:@"ResourceView" bundle:nil];
    NSString* targetPath = [[ContentModel sharedInstance] addAppDocumentsPathToPath:content.path];
    rviewer.filePath = targetPath;
    [self presentViewController:rviewer animated:NO completion:nil];
    [rviewer.webView setScalesPageToFit:YES];
    [rviewer play];
}


#pragma mark -

@end
