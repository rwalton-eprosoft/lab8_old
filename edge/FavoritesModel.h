//
//  FavoritesModel.h
//  edge
//
//  Created by Ryan G Walton on 6/27/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MyFavorite, ContentCategory, Content, Product;

#define MAX_FAVORITES_ON_DASHBOARD          10
#define CONTENT_CAT_ID_FAV_ON_PRODUCT       999999

enum FavoritesSort
{
    //kFavoritesSortType = 0,
    kFavoritesSortABC = 0,
    kFavoritesSortDate
};

enum FavoritesFilter
{
    kFavoritesFilterArticles = 0,
    kFavoritesFilterMessages,
    kFavoritesFilterVideo,
    kFavoritesFilterProduct,
    kFavoritesFilterAll = 99
};

@interface FavoritesModel : NSObject

+ (FavoritesModel*) sharedInstance;

- (void) addFavoriteWithCntId:(NSNumber *)cntId contentCatId:(NSNumber *)contentCatId;
- (void) addFavoriteWithContent:(Content *)content;
- (void) deleteFavorite:(MyFavorite *)fav;
- (NSFetchedResultsController *) favoritesWithFavoritesSort: (int) favoritesSort onDashboard:(BOOL)onDashboard filterType:(int)filterType;
- (void) dumpContents;
- (BOOL) canAddtoDashboard;
- (BOOL) isContentAFavorite:(Content *)content;
- (void) addFavoriteWithProduct:(Product *)product;
- (void) addtoDashboard:(MyFavorite *)fav;
- (BOOL) isProductAFavorite:(Product *)product;

- (ContentCategory *) contentCategoryWithId:(NSNumber*)contentCatId;

@end
