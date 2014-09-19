
//
//  FavoritesModel.m
//  edge
//
//  Created by Ryan G Walton on 6/27/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "FavoritesModel.h"
#import "MyFavorite.h"
#import "AppDelegate.h"
#import "Content.h"
#import "ContentModel.h"
#import "TrackingModel.h"
#import "Product.h"

@interface FavoritesModel ()
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, assign) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSArray *favorites;
@end

@implementation FavoritesModel

+ (FavoritesModel*) sharedInstance
{
    static FavoritesModel *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[FavoritesModel alloc] init];
        // Do any other initialisation stuff here
        [instance initModel];

    });
    
    return instance;
    
}
- (void) initModel
{
    // init favorites
    _appDelegate = [UIApplication sharedApplication].delegate;
    _managedObjectContext = _appDelegate.managedObjectContext;
    
}

- (Content *) contentWithContentId:(NSNumber *)contentId
{
    Content *content;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"cntId = %d", [contentId intValue]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            content = [items objectAtIndex:0];
        }
    }
    
    return content;
}

- (void) addFavoriteWithProduct:(Product *)product
{
    // Create a new instance of the entity
    MyFavorite *fav = [NSEntityDescription insertNewObjectForEntityForName:@"MyFavorite"
                                                    inManagedObjectContext:_appDelegate.managedObjectContext];
    
    fav.cntId = product.prodId;
    fav.crtDt = [NSDate date];
    fav.contentCatId = [NSNumber numberWithInt:CONTENT_CAT_ID_FAV_ON_PRODUCT];

    fav.isProduct = [NSNumber numberWithBool:YES];
    fav.title = product.name;
    
    //TrackingModel will be called for analytics
    NSString *tempStr = [NSString stringWithFormat:@"%@:%@", product.prodId, product.name];
    //NSString *resourceString = [NSString stringWithFormat:@"%@", product.name];
    [[TrackingModel sharedInstance] createTrackingDataWithResource:tempStr activityCode:TRACKING_ACTIVITY_ADDED_FAVORITE_ON_PRODUCT];
    
    [_appDelegate saveContext];
}


- (void) addFavoriteWithContent:(Content *)content
{
    [self addFavoriteWithCntId:content.cntId contentCatId:content.contentCatId];
}

- (void) addFavoriteWithCntId:(NSNumber *)cntId contentCatId:(NSNumber *)contentCatId
{
    // Create a new instance of the entity
    MyFavorite *fav = [NSEntityDescription insertNewObjectForEntityForName:@"MyFavorite"
                                                  inManagedObjectContext:_appDelegate.managedObjectContext];
    
    fav.cntId = cntId;
    fav.crtDt = [NSDate date];
    fav.contentCatId = contentCatId;
    fav.favoriteToContent = [self contentWithContentId:cntId];
    fav.title = fav.favoriteToContent.title;
    fav.isProduct = [NSNumber numberWithBool:NO];


    //TrackingModel will be called for analytics
    //NSString *resourceString = [NSString stringWithFormat:@"%@",fav.favoriteToContent.title];
    NSString *tempStr = [NSString stringWithFormat:@"%@:%@", fav.cntId, fav.favoriteToContent.title];

    [[TrackingModel sharedInstance] createTrackingDataWithResource:tempStr activityCode:TRACKING_ACTIVITY_ADDED_FAVORITE];
    
    [_appDelegate saveContext];
}

- (void) deleteFavorite:(MyFavorite *)fav
{
    [_appDelegate.managedObjectContext deleteObject:fav];
    
    [_appDelegate saveContext];
}

- (NSFetchedResultsController *) favoritesWithFavoritesSort: (int) favoritesSort onDashboard:(BOOL) onDashboard filterType:(int)filterType
{
    NSFetchRequest *fetchRequest = [self favoritesFetchRequest];
    
    NSString *sectionNameKeyPath;
    
    switch (favoritesSort)
    {
        /*
        case kFavoritesSortType:
        {
            sectionNameKeyPath = @"contentCatId";
        }
            break;
         */
        case kFavoritesSortABC:
        {
            sectionNameKeyPath = @"title";
        }
            break;
        case kFavoritesSortDate:
        {
            sectionNameKeyPath = @"crtDt";

        }
            break;
        default:
        {
            sectionNameKeyPath = @"title";
        }
            break;
            
    }
    
    NSMutableArray *predicates = [NSMutableArray array];
    
    ////nslog(@"sectionNKP %@", sectionNameKeyPath);
    
    if (onDashboard)
    {
        // add the predicate for searching
        NSPredicate *predicate;
        predicate = [NSPredicate predicateWithFormat:@"isOnDashboard = %d", 1];
        [predicates addObject:predicate];
        
        sectionNameKeyPath = nil;
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:
                                    sortDescriptor1,
                                    nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        
    }
    else
    {
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:sectionNameKeyPath ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:
                                    sortDescriptor1,
                                    nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
    }
    
    if (filterType != kFavoritesFilterAll)
    {
        switch (filterType)
        {
            case kFavoritesFilterArticles:
            {
                // add the predicate for searching
                NSMutableArray *args = [NSMutableArray array];
                [args addObject:[NSNumber numberWithInt:kSpecialtyArticle]];
                [args addObject:[NSNumber numberWithInt:kProcedureArticle]];
                [args addObject:[NSNumber numberWithInt:kProductClinicalArticles]];
                [args addObject:[NSNumber numberWithInt:kProductClinicalArticlesCharts]];
                [args addObject:[NSNumber numberWithInt:kProductClinicalArticlesOthers]];
                NSPredicate *predicate;
                predicate = [NSPredicate predicateWithFormat:@"contentCatId IN %@", args];
                ////nslog(@"Predicate is contentCatId = %d", filterType);
                [predicates addObject:predicate];
            }
                break;
            case kFavoritesFilterMessages:
            {
                // add the predicate for searching
                NSMutableArray *args = [NSMutableArray array];
                [args addObject:[NSNumber numberWithInt:kSpecialtyMessage]];
                [args addObject:[NSNumber numberWithInt:kProcedureMessage]];
                [args addObject:[NSNumber numberWithInt:kProductClinicalMessage]];
                [args addObject:[NSNumber numberWithInt:kProductNonClinicalMessage]];

                NSPredicate *predicate;
                predicate = [NSPredicate predicateWithFormat:@"contentCatId IN %@", args];
                ////nslog(@"Predicate is contentCatId = %d", filterType);
                [predicates addObject:predicate];
            }
                break;
            case kFavoritesFilterVideo:
            {
                // add the predicate for searching
                NSMutableArray *args = [NSMutableArray array];
                [args addObject:[NSNumber numberWithInt:kSpecialtyVideo]];
                [args addObject:[NSNumber numberWithInt:kProcedureVideo]];
                [args addObject:[NSNumber numberWithInt:kProductVideo]];
                [args addObject:[NSNumber numberWithInt:kProductCompetitiveInfoVideos]];
                
                NSPredicate *predicate;
                predicate = [NSPredicate predicateWithFormat:@"contentCatId IN %@", args];
                ////nslog(@"Predicate is contentCatId = %d", filterType);
                [predicates addObject:predicate];
            }
                break;
            case kFavoritesFilterProduct:
            {
                // add the predicate for searching
                NSPredicate *predicate;
                predicate = [NSPredicate predicateWithFormat:@"contentCatId = %d", CONTENT_CAT_ID_FAV_ON_PRODUCT];
                ////nslog(@"Predicate is contentCatId = %d", filterType);
                [predicates addObject:predicate];
            }
                break;

             default:
            {
                // add the predicate for searching
                NSPredicate *predicate;
                predicate = [NSPredicate predicateWithFormat:@"contentCatId = %d", filterType];
                ////nslog(@"Predicate is contentCatId = %d", filterType);
                [predicates addObject:predicate];

            }
                 break;
        }     
              
        
    }
    
    switch (predicates.count)
    {
        case 1:
            [fetchRequest setPredicate:[predicates objectAtIndex:0]];
            break;
        case 2:
            [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]];
            break;
            
        default:
            break;
    }    
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
                                                            initWithFetchRequest:fetchRequest
                                                            managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionNameKeyPath
                                                            cacheName:nil];
    NSError *error = nil;
	if (![fetchedResultsController performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	     */
	    //nslog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    ////nslog(@"fetchedObjects.count: %d", fetchedResultsController.fetchedObjects.count);
       
    return fetchedResultsController;
}

#pragma mark -
#pragma Private Methods

- (NSFetchRequest*)favoritesFetchRequest
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyFavorite" inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    return fetchRequest;
}

- (ContentCategory *) contentCategoryWithId:(NSNumber*)contentCatId
{
    ContentCategory *cntCat = nil;
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ContentCategory" inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // add the predicate for searching
        NSPredicate *predicate;
        predicate = [NSPredicate predicateWithFormat:@"contentCatId = %d", [contentCatId intValue]];
        [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            cntCat = [items objectAtIndex:0];
        }
    }
    
    return cntCat;
}

- (void) dumpContents
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            for (Content *content in items)
            {
                ////nslog(@"\nContent %d", [[content cntId] intValue]);
            }
        }
    }
    
}

- (int) numberofItemsOnDashboard
{
    int count = 0;
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyFavorite" inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"isOnDashboard = %d", 1];
    [fetchRequest setPredicate:predicate];
    
    
    NSError *error;
    
    int countForFetch;
    countForFetch = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    
    if (!error)
    {
        ////nslog(@"\nFavs %d", countForFetch);
        count = countForFetch;
        
    }
    
    return count;
}

- (void) addtoDashboard:(MyFavorite *)fav
{
    fav.sortOrder = [NSNumber numberWithInt:[self numberofItemsOnDashboard]+1];
    fav.isOnDashboard = [NSNumber numberWithBool:YES];

    [_appDelegate saveContext];
}

- (BOOL) canAddtoDashboard
{
    BOOL canAdd = YES;
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyFavorite" inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"isOnDashboard = %d", 1];
    [fetchRequest setPredicate:predicate];

    NSError *error;
    
    int countForFetch;
    countForFetch = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];

    if (!error)
    {
        ////nslog(@"\nFavs %d", countForFetch);
        canAdd = (countForFetch < MAX_FAVORITES_ON_DASHBOARD);
        
    }
    
    return canAdd;
}

- (BOOL) isContentAFavorite:(Content *)content
{
    BOOL isFavorite = NO;
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyFavorite" inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"cntId = %d", [content.cntId intValue]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            isFavorite = YES;
        }
    }
    
        
    return isFavorite;

}

- (BOOL) isProductAFavorite:(Product *)product
{
    BOOL isFavorite = NO;
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyFavorite" inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"cntId = %d && contentCatId = %d", [product.prodId intValue], CONTENT_CAT_ID_FAV_ON_PRODUCT];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            isFavorite = YES;
        }
    }
    
    
    return isFavorite;
    
}

@end
