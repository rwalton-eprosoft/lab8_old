//
//  SearchVC.h
//  edge
//
//  Created by iPhone Developer on 5/13/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "CustomSegmentControl.h"
@class TabBarViewController;

enum SearchResultsActionSheetTags {
    kSearchResultsActionSheetTagFilters = 99,
    kSearchResultsActionSheetTagOptions,
    kSearchResultsActionSheetTagLongPress,
    kSearchResultsLongPressItemFavoriteTagCancel,
    kSearchResultsLongPressItemFavoriteTagCancelandSharable
    };

enum SearchResultsFilterTypes {
    kSearchResultsFilterTypeAll = 0,
    kSearchResultsFilterTypeVideos,
    kSearchResultsFilterTypeArticles,
    kSearchResultsFilterTypeProducts
    };

enum SearchResultsOptionTypes {
    kSearchResultsOptionTypeTitle = 0,
    kSearchResultsOptionTypeType,
    kSearchResultsOptionTypeDate
    };

enum SearchResultsLongPressItems {
    kSearchResultsLongPressItemAddToFavorites = 0,
    kSearchResultsLongPressItemShare,
};

enum  SearchResultsSortType {
    kSearchResultsSortTypeProducts = 0,
    kSearchResultsSortTypeProcedures,
    kSearchResultsSortTypeSpecialties,
    kSearchResultsSortTypeAll
    };

@interface SearchResultsVC : BaseVC <UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UILabel *searchLbl;
@property (nonatomic, weak) IBOutlet CustomSegmentControl *sortSegCtl;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) TabBarViewController *tabs;
@property (nonatomic, weak) IBOutlet UIButton *filterBtn;
@property (nonatomic, weak) IBOutlet UIButton *optionsBtn;
@property (nonatomic, weak) IBOutlet UILabel *noResultsFoundLbl;
@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIToolbar *searchToolbar;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (weak, nonatomic) IBOutlet UILabel *searchTitle;
//@property (weak, nonatomic) IBOutlet UIImageView *alertImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

- (IBAction) filterBtnTouched;
- (IBAction) optionsBtnTouched;
- (IBAction) searchResultsSortChanged;
- (IBAction) closeBtnTouched;

- (void) show;
- (void) hide;

- (void) performSearchWithSearchstring:(NSString*)searchStr;

@end
