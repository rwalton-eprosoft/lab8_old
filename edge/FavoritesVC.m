//
//  FavoritesVC.m
//  edge
//
//  Created by iPhone Developer on 5/31/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "FavoritesVC.h"
#import "FavoritesGridCVCell.h"
#import "FavoritesCollectionHeaderView.h"
#import "FavoritesCollectionViewLayout.h"
#import "FavoritesModel.h"
#import "MyFavorite.h"
#import "ContentCategory.h"
#import "Content.h"
#import "AppDelegate.h"
#import "ContentModel.h"
#import "ResourceViewerViewController.h"
#import "LXReorderableCollectionViewFlowLayout.h"
#import "FavLXReorderableCVLayout.h"
#import "TabBarViewController.h"
#import "DashboardModel.h"
#import "EmailQueueOverlayViewController.h"
#import "TrackingModel.h"
#import "Product.h"

#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]


@interface FavoritesVC ()

@property (nonatomic, strong) NSFetchedResultsController *favoritesFRC;
@property (nonatomic, strong) NSMutableArray *dashboardItems;
@property (nonatomic, strong) FavoritesCollectionViewLayout *favcollectionViewLayout;
@property (nonatomic, strong) LXReorderableCollectionViewFlowLayout *lxReorderableFlowLayout;

- (void)didChangeSegmentControl:(UISegmentedControl *)control;

@end

@implementation FavoritesVC
{
    BOOL all;
    BOOL isEditing;
    int filterType;
    BOOL isActionSheetShowing;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark View Lifecyle

-(void)viewWillAppear:(BOOL)animated
{
    // be sure to call base class
    [super viewWillAppear:animated];
    isActionSheetShowing = NO;
    [self reloadFavorites];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _titlelabel.font = [UIFont fontWithName:@"StagSans-Book" size:21];
    //[self deleteOldFavs];
    
    [self.appDelegate.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"edge_bg"]];
    
    [self resetFilter];
    
    all = YES;
    isEditing = NO;
    
    self.sortSegmentedControl.selectedSegmentIndex = 0;
    self.sortSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    
    [self.sortSegmentedControl addTarget:self action:@selector(didChangeSegmentControl:) forControlEvents:UIControlEventValueChanged];
    
    [self toggleBarButton:NO];
    self.editingModeDeleteButton.hidden = YES;
    
    //set initial collectionview
    self.collectionView = self.favCollectionView;
    self.lxCollectionView.tag = TAG_LX;
    self.favCollectionView.tag = TAG_FAVS;
    [self.favoritesToolbar setBackgroundImage:[UIImage imageNamed:@"tool_bar_bkg"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [self reloadFavorites];
    [self checkForFavorites];
//    appCopyView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 88, 1024, 620)];
//    appCopyView.image = [UIImage imageNamed:@"favoites_edit_dashboard"];
//    [self.view addSubview:appCopyView];
    _appCopyView.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (isEditing)
    {
        [self toggleEditMode];
    }
    [super viewWillDisappear:YES];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self editBUtton];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)deleteOldFavs
{
    [[ContentModel sharedInstance] clearUserData];
}

-(void)showFavs
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyFavorite" inManagedObjectContext:self.appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [self.appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            ////nslog(@"items %d ", [items count]);
            for (MyFavorite *fav in items)
            {
                // //nslog(@"\nFavorites %@ %@", [self.appDelegate.dateFormatter stringFromDate:fav.crtDt], fav.contentCatId);
            }
        }
    }
}

-(void)reloadFavorites
{
    _favoritesFRC = [[FavoritesModel sharedInstance] favoritesWithFavoritesSort:self.sortSegmentedControl.selectedSegmentIndex onDashboard:!all filterType:filterType];
    _sortImageView.image = [UIImage imageNamed:@"segment_atoz"];

    if ([_favoritesFRC.sections count] == 0)
    {
       // _alertLabel.text = @"No Favorites added are available as of now.";
        _alertLabel.hidden = NO;
//        _alertImageView.hidden = NO;
        
    }
    else
    {
        _alertLabel.hidden = YES;
//        _alertLabel.text = @"";
//        _alertImageView.hidden = YES;
        
    }
    [self.collectionView reloadData];
}

-(void)checkForFavorites
{
    if ([_favoritesFRC.sections count] == 0) {
        
        //UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Items Exist" message:@"Please add items to favorites" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
       // [av show];
        //_alertLabel.text = @"No Favorites added are available as of now.";
        _alertLabel.hidden = NO;
//        _alertImageView.hidden = NO;
        _appCopyView.hidden = YES;
    }
    else
    {
        _alertLabel.hidden = YES;
       // _alertLabel.text = @"";
//        _alertImageView.hidden =YES;
    }
}

-(void)checkForDashboardFavorites
{
    [self reloadFavorites];
    if ([_favoritesFRC.fetchedObjects count] == 0)
    {
        //UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Home Screen Items Exist" message:@"Please add favorites to Home Screen" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
     //   [av show];
        [self.editDashboardBarButton setEnabled:NO];
       // _alertLabel.text = @"No Favorites added are available as of now.";
        _alertLabel.hidden = YES;
//        _alertImageView.hidden = NO;
        _appCopyView.hidden = NO;
    }
    else
    {
        [self checkForFavorites];
        [self.editDashboardBarButton setEnabled:YES];
        _alertLabel.hidden = YES;
       // _alertLabel.text = @"";
        //nslog(@"in else");
//        _alertImageView.hidden = YES;
    }
}

- (NSString*) imageNameForContentCatId:(NSString*)mime type:(FavCellImageType)imageType
    {
        NSString *imageName;
        if ([[mime lowercaseString] isEqualToString:@"application/zip"])
        {
            if (imageType == kFavCellImageTypeIcon)
            {
                imageName = @"articles";
            }
            else if (imageType == kFavCellImageTypeOverlay)
            {
                imageName = @"html_large_btn";
            }
        }
        else if ([[mime lowercaseString] isEqualToString:@"application/pdf"])
        {
            if (imageType == kFavCellImageTypeIcon)
            {
                imageName = @"articles";
            }
            else if (imageType == kFavCellImageTypeOverlay)
            {
                imageName = @"article_large_btn";
            }
        }
        else if ([[mime lowercaseString] isEqualToString:@"video/quicktime"])
        {
            if (imageType == kFavCellImageTypeIcon)
            {
                imageName = @"video";
            }
            else if (imageType == kFavCellImageTypeOverlay)
            {
                imageName = @"video_large_btn";
            }
        }
        else
        {
            if (imageType == kFavCellImageTypeIcon)
            {
                imageName = @"articles";
            }
            else if (imageType == kFavCellImageTypeOverlay)
            {
                imageName = @"product_large_btn";
            }
        }
    /*switch (contentCatId.intValue)
    {
            // video
        case kSpecialtyVideo:
        case kProcedureVideo:
        case kProductVideo:
        case kProductCompetitiveInfoVideos:
            if (imageType == kFavCellImageTypeIcon)
            {
                imageName = @"video";
            }
            else if (imageType == kFavCellImageTypeOverlay)
            {
                imageName = @"video_large_btn";
            }
            break;
            
            // article
        case kSpecialtyArticle:
        case kProcedureArticle:
        case kProductClinicalArticles:
        case kProductClinicalArticlesCharts:
        case kProductClinicalArticlesOthers:
            if (imageType == kFavCellImageTypeIcon)
            {
                imageName = @"articles";
            }
            else if (imageType == kFavCellImageTypeOverlay)
            {
                imageName = @"article_large_btn";
            }
            break;
            
            // message
        case kSpecialtyMessage:
        case kProcedureMessage:
        case kProductClinicalMessage:
        case kProductNonClinicalMessage:
        case kProductCompetitiveInfo:
            if (imageType == kFavCellImageTypeIcon)
            {
                imageName = @"chat";
            }
            else if (imageType == kFavCellImageTypeOverlay)
            {
                imageName = @"html_large_btn";
            }
            break;
            
            // product
        case CONTENT_CAT_ID_FAV_ON_PRODUCT:
            if (imageType == kFavCellImageTypeIcon)
            {
                imageName = @"video";
            }
            else if (imageType == kFavCellImageTypeOverlay)
            {
                imageName = @"product_large_btn";
            }
            break;
            
        default:
            if (imageType == kFavCellImageTypeIcon)
            {
                imageName = @"video";
            }
            else if (imageType == kFavCellImageTypeOverlay)
            {
                imageName = @"product_large_btn";
            }
            break;
    }*/
    return imageName;
}


#pragma mark -
#pragma mark UICollectionView Data Source Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[_favoritesFRC fetchedObjects] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"FavCollectionCell";
    MyFavorite *fav;
    
    fav = [_favoritesFRC.fetchedObjects objectAtIndex:indexPath.row];
    
    Product *product;
    
    if ([fav.isProduct boolValue])
    {
        product = [[ContentModel sharedInstance] productWithId:[fav.cntId intValue]];

    }
    
    FavoritesGridCVCell *cell = (FavoritesGridCVCell*)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    cell.dataTypeLabel.textAlignment = NSTextAlignmentCenter;
    
    NSString *str;
    
    int favCatId = [fav.contentCatId intValue];
    
    switch (favCatId)
    {
        case kFavoritesFilterArticles:
            str = @"Article";
            break;
        case kFavoritesFilterMessages:
            
            str = @"Message";
            
            break;
        case kFavoritesFilterVideo:
            
            str = @"Video";
            
            break;
                    
        case CONTENT_CAT_ID_FAV_ON_PRODUCT:
            
            str = product.name;
            
            break;

            
        default:

            str = fav.favoriteToContent.title;
        
            break;
    }
    
    cell.dataTypeLabel.text = str;
    cell.dateLabel.textAlignment = NSTextAlignmentCenter;
    cell.dateLabel.text = [self.appDelegate.dateFormatter stringFromDate:fav.crtDt];
    
    if (self.collectionView == self.favCollectionView)
    {
        cell.editingModeDeleteButton.hidden = YES;
        cell.editingModeDeleteImageView.hidden = YES;
        cell.editingModeDeleteButton.tag = indexPath.row;
        
        UILongPressGestureRecognizer *longPressGesture =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        cell.favCellLongPress = longPressGesture;
        
        [cell addGestureRecognizer:longPressGesture];
    }
    
    else
    {
        //editing mode
        if (cell.favCellLongPress)
        {
            [cell removeGestureRecognizer:cell.favCellLongPress];
            cell.favCellLongPress = nil;
        }
        cell.editingModeDeleteButton.tag = indexPath.row;
        fav.sortOrder = [NSNumber numberWithInt:indexPath.row];
        ////nslog(@"Sort order is %d", [fav.sortOrder intValue]);
    }
    
    NSString *iconImageName;
    NSString *overlayImageName;
    NSString *thumbnailImagePath;
    
    UIImageView *productThumbnailImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 112, 82)];
    UILabel * producttitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 112, 82)];


    //nslog(@"fav.contentCatId: %d CONTENT_CAT_ID_FAV_ON_PRODUCT: %d", [fav.contentCatId intValue], CONTENT_CAT_ID_FAV_ON_PRODUCT);
    if ([fav.contentCatId intValue] == CONTENT_CAT_ID_FAV_ON_PRODUCT)
    {
        _appCopyView.hidden = YES;
        //nslog(@"Fav is on Product");
        // favorite is on Product
        NSArray *contents = [[ContentModel sharedInstance] contentsForProduct:product withContentCatIds:[NSArray arrayWithObject:[NSNumber numberWithInt:kProductImage]]];
        
        
        
        for (Content *content in contents)
        {
            ////nslog(@"content.path: %@", content.path);
            if (content.thumbnailImgPath)
            {
                NSString* targetPath = [DocumentsDirectory stringByAppendingString:content.thumbnailImgPath];
                BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:targetPath];
                producttitle.text = content.title;
                
                if (!success)
                {
                    break;
                }
                ////nslog(@"content.thumbnailImgPath: %@", content.thumbnailImgPath);
                else
                {
                    productThumbnailImage.image = [self.appDelegate loadImage:content.thumbnailImgPath];
                    
                    overlayImageName = [self imageNameForContentCatId:content.mime type:kFavCellImageTypeOverlay];
                    break;
                }
            }
            
        }
        if (!productThumbnailImage.image)
        {
            
            producttitle.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
            
            producttitle.numberOfLines = 0;
            producttitle.font = [UIFont fontWithName:@"Arial" size:11];
            producttitle.textAlignment = NSTextAlignmentCenter;
            [productThumbnailImage addSubview:producttitle];
            UIGraphicsBeginImageContext(productThumbnailImage.bounds.size);
            [productThumbnailImage.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *bitmap = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            productThumbnailImage.image = bitmap;
        }
        cell.favCellImageView.image = productThumbnailImage.image;
        cell.centerImageView.image = [UIImage imageNamed:overlayImageName];
    }
    else
    {
        thumbnailImagePath = fav.favoriteToContent.thumbnailImgPath;
        NSString* targetPath = [DocumentsDirectory stringByAppendingString:thumbnailImagePath];
        BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:targetPath];
        if (!success || [thumbnailImagePath isEqualToString:@""])
        {
            //nslog(@"thumbnailImagePath is nil");
            producttitle.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
            producttitle.text = str;
            producttitle.numberOfLines = 0;
            producttitle.font = [UIFont fontWithName:@"Arial" size:11];
            producttitle.textAlignment = NSTextAlignmentCenter;
            [productThumbnailImage addSubview:producttitle];
            UIGraphicsBeginImageContext(productThumbnailImage.bounds.size);
            [productThumbnailImage.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *bitmap = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            productThumbnailImage.image = bitmap;
            cell.favCellImageView.image = productThumbnailImage.image;
        }
        else
        {
            cell.favCellImageView.image = [self.appDelegate loadImage:thumbnailImagePath];
            
        }
        
        overlayImageName = [self imageNameForContentCatId:fav.favoriteToContent.mime type:kFavCellImageTypeOverlay];
        cell.centerImageView.image = [UIImage imageNamed:overlayImageName];
        
    }
    
    cell.dashboardIconImageView.hidden = ![fav.isOnDashboard boolValue];
    
    return cell;
}

#pragma mark -
#pragma mark UICollectionView delegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isEditing) {
        MyFavorite *fav;
        fav = [_favoritesFRC.fetchedObjects objectAtIndex:indexPath.row];
        
        ///get path and setup resource viewer
        NSString* targetPath = [[ContentModel sharedInstance] addAppDocumentsPathToPath:fav.favoriteToContent.path];        
        //targetPath = [targetPath stringByAppendingString:@"/index.html"];
        
        if ([fav.isProduct boolValue])
        {
            // Product was selected
            Product *product = [[ContentModel sharedInstance] productWithId:[fav.cntId intValue]];
            
            [self.appDelegate navigateToProductDetailWithProduct:product];
            //nslog(@"Current Selected product in FavoritesVC %@", product.name);
            
        }
        else
        {
            // add MyRecentlyViewed
            [[DashboardModel sharedInstance] addRecentlyViewedForContent:fav.favoriteToContent];
            ResourceViewerViewController* rviewer = [[ResourceViewerViewController alloc] initWithNibName:@"ResourceView" bundle:nil];
            
            rviewer.filePath = targetPath;
            [self presentViewController:rviewer animated:NO completion:nil];
            [rviewer play];
        }
    }
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    int nSections = 0;
    
    if ([[_favoritesFRC fetchedObjects] count])
    {
        return 1;
        
    }
    else
    {
        
        return nSections;
        
    }
    
}

-(NSString *)titleForSectionWithIndexPath:(NSIndexPath *)indexPath
{
    NSString *retTitle;
    id<NSFetchedResultsSectionInfo> sectionInfo = [[_favoritesFRC sections] objectAtIndex:indexPath.section];
    
    MyFavorite *myFav = (MyFavorite *)[[sectionInfo objects] objectAtIndex:indexPath.row];
    
    switch (_sortSegmentedControl.selectedSegmentIndex)
    {
        case kFavoritesSortABC:
        {
            retTitle = [NSString stringWithFormat:@"%@", [myFav.favoriteToContent title]];
        }
            break;
            
        case kFavoritesSortDate:
        {
            NSDate *crtDate = [myFav crtDt];
            
            retTitle = [NSString stringWithFormat:@"%@", [self.appDelegate.dateFormatter stringFromDate:crtDate]];
        }
            break;
            
        default:
        {
            //title = [NSString stringWithFormat:@"%@", [myFav.favoriteToContent title]];
        }
            break;
            
    }
    
    return retTitle;
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FavoritesCollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return -5.0f; // This is the minimum inter item spacing, can be more
}

#pragma mark -
#pragma mark UIGestureRecognizer Methods

- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
	// only when gesture was recognized, not when ended
	if (gesture.state == UIGestureRecognizerStateBegan)
	{
		// get affected cell
		FavoritesGridCVCell *cell = (FavoritesGridCVCell *)[gesture view];
        
		// get indexPath of cell
		NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        MyFavorite *fav = [_favoritesFRC.fetchedObjects objectAtIndex:indexPath.row];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
        {
            // iOS 8 logic
            self.view.window.tintColor = [UIColor grayColor];
        }

        if (!isEditing)
        {
            // do something with this action
            NSLog(@"Long-pressed cell at row %ld", (long)indexPath.row);
            
            Content *content = fav.favoriteToContent;
            ////nslog(@"Content is shareable : %@", content.isSharable);
            
            if (content.isSharable == [NSNumber numberWithInt:1])
            {
                
                UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                                          delegate: self
                                                                 cancelButtonTitle: @""
                                                            destructiveButtonTitle: nil
                                                                 otherButtonTitles: [fav.isOnDashboard boolValue] ? @"Remove from Home Screen" : @"Add to Home Screen",
                                               @"Remove from Favorites", @"Share", nil];
                
                actionSheet.tag = kFavoritesVCActionSheetFavorites;
                [actionSheet showFromRect: cell.frame inView: cell.superview animated: YES];
                
                //[actionSheet showFromRect: cell.favCellBorder.frame  inView: cell.viewForBaselineLayout animated: YES];
    
                self.longPressIndexPath = indexPath;
                
                            }
            else
            {
                UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                                          delegate: self
                                                                 cancelButtonTitle: @""
                                                            destructiveButtonTitle: nil
                                                                 otherButtonTitles: [fav.isOnDashboard boolValue] ? @"Remove from Home Screen" : @"Add to Home Screen",
                                               @"Remove from Favorites", nil];
                actionSheet.tag = kFavoritesVCActionSheetFavorites;
                [actionSheet showFromRect: cell.frame inView: cell.superview animated: YES];
                //[actionSheet showFromRect: cell.favCellBorder.frame inView: cell.viewForBaselineLayout animated: YES];

                self.longPressIndexPath = indexPath;
                
            }
            [self.favCollectionView reloadData];
            
        }
        else
        {
            //nslog(@"EDITING MODE Long-pressed cell at row %@", indexPath);
        }
        
	}
}

-(void)handleAddBoard:(id)sender
{
    MyFavorite *fav = [_favoritesFRC.fetchedObjects objectAtIndex:self.longPressIndexPath.row];
    
    //keep dashboard items under MAX_FAVORITES_ON_DASHBOARD declared in FavoritesModel.h
    if (![[FavoritesModel sharedInstance] canAddtoDashboard])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Too many Home Screen items" message:[NSString stringWithFormat:@"A maximum of %d Home Screen items can be added.", MAX_FAVORITES_ON_DASHBOARD] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [av show];
    }
    else
    {
        [[FavoritesModel sharedInstance] addtoDashboard:fav];
        
        //TrackingModel will be called for analytics
        if ([fav.isProduct intValue])
        {
            Product *prod;
            prod = [[ContentModel sharedInstance] productWithId:[fav.cntId intValue]];
            NSString *resourceString = [NSString stringWithFormat:@"%d:%@",[fav.cntId intValue], prod.name];
            [[TrackingModel sharedInstance] createTrackingDataWithResource:resourceString activityCode:TRACKING_ACTIVITY_ADDED_FAV_TO_DASH];
        }
        else
        {
            NSString *resourceString = [NSString stringWithFormat:@"%d:%@", [fav.favoriteToContent.cntId intValue], fav.favoriteToContent.title];
            [[TrackingModel sharedInstance] createTrackingDataWithResource:resourceString activityCode:TRACKING_ACTIVITY_ADDED_FAV_TO_DASH];
        }
    }
    
        /*
        if (fav.isProduct)
        {
            //TrackingModel will be called for analytics
            Product *prod;
            prod = [[ContentModel sharedInstance] productWithId:[fav.cntId intValue]];
            NSString *resourceString = [NSString stringWithFormat:@"%@", prod.name];
            [[TrackingModel sharedInstance] createTrackingDataWithResource:resourceString activityCode:TRACKING_ACTIVITY_ADDED_FAV_TO_DASH];
        }
        else
        {
        //TrackingModel will be called for analytics
        NSString *resourceString = [NSString stringWithFormat:@"%@", fav.favoriteToContent.title];
        [[TrackingModel sharedInstance] createTrackingDataWithResource:resourceString activityCode:TRACKING_ACTIVITY_ADDED_FAV_TO_DASH];
        }
        
 
    }
        
    */
    [self.collectionView reloadData];
    
}

-(void)handleRemoveBoard:(id)sender
{
    MyFavorite *fav = [_favoritesFRC.fetchedObjects objectAtIndex:self.longPressIndexPath.row];
    fav.isOnDashboard = [NSNumber numberWithBool:NO];
    [self.appDelegate saveContext];
    [self reloadFavorites];
    [self checkForDashboardFavorites];
    
}

-(void)handleRemoveFromDashboardEditMode:(id)sender
{
    MyFavorite *fav = [_favoritesFRC.fetchedObjects objectAtIndex:self.deleteTapIndexPath.row];
    //nslog(@"Delete Index path at row %ld",(long)self.deleteTapIndexPath.row);
    fav.isOnDashboard = [NSNumber numberWithBool:NO];
    [self.appDelegate saveContext];
    [self reloadFavorites];
    [self checkForDashboardFavorites];
    
}


-(void)handleRemoveFromFavorites:(id)sender
{
    MyFavorite *fav = [_favoritesFRC.fetchedObjects objectAtIndex:self.longPressIndexPath.row];
    [[FavoritesModel sharedInstance] deleteFavorite:fav];
    if (!all)
    {
        [self checkForDashboardFavorites];
        
    }
    [self reloadFavorites];
    
}

-(void)handleShare:(id)sender
{
    MyFavorite *fav = [_favoritesFRC.fetchedObjects objectAtIndex:self.longPressIndexPath.row];

    Content *content = fav.favoriteToContent;
    TabBarViewController *tabCntrl = (TabBarViewController *) self.tabBarController;
    [tabCntrl invokeEmailQueueOverlayVCWithContent:content];
}

- (void) addFavoriteWithType:(NSNumber *) contentCatId;
{
    [[FavoritesModel sharedInstance] addFavoriteWithCntId:[NSNumber numberWithInt:153] contentCatId:contentCatId];
    [self reloadFavorites];
}

#pragma mark -
#pragma mark Favorites Filter Methods

- (IBAction)filterButtonTouched:(id)sender
{
    NSString *titleString = @"Filters";
  
    if (isActionSheetShowing == NO)
    {
        /*
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: titleString
                                                                  delegate: self
                                                         cancelButtonTitle: @"Cancel"
                                                    destructiveButtonTitle: nil
                                                         otherButtonTitles: @"Articles", @"Messages", @"Videos", @"All", nil];
        */
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: titleString
                                                                  delegate: self
                                                         cancelButtonTitle: @"Cancel"
                                                    destructiveButtonTitle: nil
                                                         otherButtonTitles: @"Articles", @"Videos", @"Products", @"All", nil];

        
        actionSheet.tag = kFavoritesVCActionSheetFilters;
        
        //[actionSheet showFromRect:[self.filterButton frame] inView:self.view animated: YES];
        [actionSheet showFromBarButtonItem:_favFilterBarItem animated:YES];
        isActionSheetShowing = YES;
        
    }
    ////nslog(@"Filter tapped");
}

-(void)resetFilter
{
    [self.filterButton setImage:[UIImage imageNamed:@"filter_all" ] forState:UIControlStateNormal];
    filterType = kFavoritesFilterAll;
    all = YES;
}

#pragma mark -
#pragma mark UIActionSheet Methods

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
            [b setTitleColor:[UIColor colorWithRed:110.0f/255.0f green:110.0f/255.0f blue:110.0f/255.0f alpha:1] forState:UIControlStateNormal];
            [b setTitleColor:[UIColor colorWithRed:243.0f/255.0f green:6.0f/255.0f blue:23.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
             b.titleLabel.font = [UIFont fontWithName:@"Arial" size:18];
            //[b setBackgroundImage:[UIImage imageNamed:@"backActionSheetHighlighted.png"] forState:UIControlStateHighlighted];
            //[b setBackgroundImage:[UIImage imageNamed:@"backActionSheet.png"] forState:UIControlStateNormal];
        }
    }
    //
    
    if (actionSheet.tag == kFavoritesVCActionSheetFilters)
    {
        for (UIView *_currentView in actionSheet.subviews) {
            if ([_currentView isKindOfClass:[UILabel class]])
            {
                CGRect frame = ((UILabel *)_currentView).frame;
                frame.origin.y = 15;
                frame.size.height = 40;
                ((UILabel *)_currentView).frame = frame;
                //((UILabel *)_currentView).textAlignment = NSTextAlignmentCenter;
                [((UILabel *)_currentView) setFont:[UIFont fontWithName:@"Arial" size:20]];
                [((UILabel *)_currentView) setTextColor:[UIColor colorWithRed:243.0f/255.0f green:6.0f/255.0f blue:23.0f/255.0f alpha:1.0f]];

            }
        }
    }
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if  (actionSheet.tag == kFavoritesVCActionSheetFavorites)
    {
        MyFavorite *fav = [_favoritesFRC.fetchedObjects objectAtIndex:self.longPressIndexPath.row];
        
        if (buttonIndex == 0)
        {
            MyFavorite *fav = [_favoritesFRC.fetchedObjects objectAtIndex:self.longPressIndexPath.row];
            
            if ([fav.isOnDashboard boolValue] == YES)
            {
                [self handleRemoveBoard:self];
            }
            else
            {
                [self handleAddBoard:self];
                
            }
        }
        
        else if (buttonIndex == 1)
        {
            [self handleRemoveFromFavorites:self];
        }
        
        else if (buttonIndex == 2 && fav.favoriteToContent.isSharable == [NSNumber numberWithInt:1])
        {            
            [self handleShare:nil];
        }
    }
    
    else if(actionSheet.tag == kFavoritesVCActionSheetDashboard)
    {
        if (buttonIndex == 0)
        {
            [self handleRemoveFromDashboardEditMode:self];
        }
    }
    else if(actionSheet.tag == kFavoritesVCActionSheetFilters)
    {
        /*
        if (buttonIndex == 0)
        {
            [self.filterButton setImage:[UIImage imageNamed:@"filter_articles" ] forState:UIControlStateNormal];
            [self toggleBarButton:NO];
            filterType = kFavoritesFilterArticles;
        }
        if (buttonIndex == 1)
        {
            [self.filterButton setImage:[UIImage imageNamed:@"filter_messages" ] forState:UIControlStateNormal];
            [self toggleBarButton:NO];
            filterType = kFavoritesFilterMessages;
        }
        if (buttonIndex == 2)
        {
            [self.filterButton setImage:[UIImage imageNamed:@"filter_videos" ] forState:UIControlStateNormal];
            [self toggleBarButton:NO];
            filterType = kFavoritesFilterVideo;
        }
        if (buttonIndex == 3)
        {
            [self.filterButton setImage:[UIImage imageNamed:@"filter_all" ] forState:UIControlStateNormal];
            all = YES;
            [self toggleBarButton:NO];
            filterType = kFavoritesFilterAll;
        }
        */
        if (buttonIndex == 0)
        {
            [self.filterButton setImage:[UIImage imageNamed:@"filter_articles" ] forState:UIControlStateNormal];
            [self toggleBarButton:NO];
            filterType = kFavoritesFilterArticles;
        }
        if (buttonIndex == 1)
        {
            [self.filterButton setImage:[UIImage imageNamed:@"filter_videos" ] forState:UIControlStateNormal];
            [self toggleBarButton:NO];
            filterType = kFavoritesFilterVideo;
        }
        if (buttonIndex == 2)
        {
            [self.filterButton setImage:[UIImage imageNamed:@"filter_products" ] forState:UIControlStateNormal];
          //  all = YES;
            [self toggleBarButton:NO];
            filterType = kFavoritesFilterProduct;
            
        }
        if (buttonIndex == 3)
        {
            [self.filterButton setImage:[UIImage imageNamed:@"filter_all" ] forState:UIControlStateNormal];
            all = YES;
            [self toggleBarButton:NO];
            filterType = kFavoritesFilterAll;

        }
        isActionSheetShowing = NO;
        
        [self reloadFavorites];
        
    }
}


-(void)toggleEditMode
{
    if (isEditing == NO)
    {
        //going into edit mode
        
        //[self.editDashboardBarButton setImage:[UIImage imageNamed:@"edit_dashborad_done"] forState:UIControlStateNormal];
        isEditing = YES;
        
        self.collectionView = self.lxCollectionView;
        self.lxCollectionView.hidden = NO;
        self.favCollectionView.hidden = YES;
        
        [self.collectionView.visibleCells makeObjectsPerformSelector:@selector(startWaggle)];
        
        
    }
    else if (isEditing == YES)
    {
        //exiting edit mode
        if ([[_favoritesFRC fetchedObjects] count]==0)
        {
            _alertLabel.hidden = NO;
//            _alertImageView.hidden = NO;
            _appCopyView.hidden = YES;
        }
        isEditing = NO;
        self.collectionView = self.favCollectionView;
        self.lxCollectionView.hidden = YES;
        self.favCollectionView.hidden = NO;
        
        [self.collectionView.visibleCells makeObjectsPerformSelector:@selector(stopWaggle)];
    }
    
    [self reloadFavorites];
}


-(void)toggleBarButton:(bool)show
{
    if (show)
    {
        self.editDashboardBarButton.hidden = NO;
        
    } else
    {
        self.editDashboardBarButton.hidden = YES;
        
    }
}

#pragma mark -
#pragma mark Segment control

- (void)didChangeSegmentControl:(UISegmentedControl *)control
{
    switch (_sortSegmentedControl.selectedSegmentIndex)
    {
        case kFavoritesSortABC:
        {
            ////nslog(@"Sort changed to ABC-all items");
        }
            break;
            
        case kFavoritesSortDate:
        {
            ////nslog(@"Sort changed to Date-all items");
        }
            break;
            
        default:
        {
            
        }
            break;
    }
    
    [self reloadFavorites];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)dashboardButtonTouched:(id)sender
{
    if (all)
    {
        //go into dashboard mode
        //isEditing = YES;
        all = NO;
        //[self toggleBarButton:YES];
        
        [self.dashboardBarButton setStyle:UIBarButtonItemStylePlain];
        self.dashboardBarButton.title = nil;
        [self.dashboardButton setImage:[UIImage imageNamed:@"edit_dashborad_done"] forState:UIControlStateNormal];
        
        [self.filterButton setImage:[UIImage imageNamed:@"filter_all" ] forState:UIControlStateNormal];
        
        [self.filterButton setEnabled:NO];
        
        for(int index=0; index<self.sortSegmentedControl.numberOfSegments; index++)
        {
            [self.sortSegmentedControl setEnabled:NO forSegmentAtIndex:index];
        }
        
        filterType = kFavoritesFilterAll;
        [self toggleEditMode];
        _sortImageView.hidden = YES;
        [self checkForDashboardFavorites];
    }
    else
    {
        [self editBUtton];
    }
    
    [self reloadFavorites];
    [self checkForFavorites];
}

-(void) editBUtton
{
    if (isEditing)
    {
        [self toggleEditMode];
    }
    all = YES;
    
    [self toggleBarButton:NO];
    
    [self resetFilter];
    [self.filterButton setEnabled:YES];
    for(int index=0; index<self.sortSegmentedControl.numberOfSegments; index++)
    {
        [self.sortSegmentedControl setEnabled:YES forSegmentAtIndex:index];
    }
    [self.sortSegmentedControl setSelectedSegmentIndex:0];
    [self.dashboardBarButton setStyle:UIBarButtonItemStylePlain];
    self.dashboardBarButton.title = nil;
    _sortImageView.hidden = NO;
    
    [self.dashboardButton setImage:[UIImage imageNamed:@"edit_dashborad_274x60px"] forState:UIControlStateNormal];
}
- (IBAction)editDashboardButtonTouched:(id)sender
{
    [self toggleEditMode];
    
}

- (IBAction)editingModeDeleteButtonTouched:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    FavoritesGridCVCell *cell = (FavoritesGridCVCell *)[[btn superview] superview];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                              delegate: self
                                                     cancelButtonTitle: nil
                                                destructiveButtonTitle: nil
                                                     otherButtonTitles: @"Remove from Home Screen", nil];
    
    actionSheet.tag = kFavoritesVCActionSheetDashboard;
    
    //[actionSheet showFromRect: cell.frame inView: cell.superview animated: YES];
    [actionSheet showFromRect: cell.editingModeDeleteButton.frame inView: cell.viewForBaselineLayout animated: YES];

    //nslog(@"editing mode delete button touched at %ld", (long)indexPath.row);
    self.deleteTapIndexPath = indexPath;
    
    
}

- (IBAction)drawToolButtonTouched:(id)sender
{
    TabBarViewController* tab = (TabBarViewController*)self.tabBarController;
    [tab invokeDrawTool];
}

#pragma mark -
#pragma mark - LXReorderableCollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    NSMutableArray *mutArray = [[NSMutableArray alloc] initWithCapacity:1];
    [mutArray addObjectsFromArray:[_favoritesFRC fetchedObjects]];
    
    FavoritesGridCVCell *cell = (FavoritesGridCVCell*)[mutArray objectAtIndex:fromIndexPath.item];
    
    //FavoritesGridCVCell *cellTo = (FavoritesGridCVCell*)[mutArray objectAtIndex:toIndexPath.item];
    
    MyFavorite *fromFav = [_favoritesFRC.fetchedObjects objectAtIndex:fromIndexPath.row];
    MyFavorite *toFav = [_favoritesFRC.fetchedObjects objectAtIndex:toIndexPath.row];
    
    NSNumber *tempsort = fromFav.sortOrder;
    fromFav.sortOrder = toFav.sortOrder;
    toFav.sortOrder = tempsort;
    [self.appDelegate saveContext];
    [mutArray removeObjectAtIndex:fromIndexPath.item];
    [mutArray insertObject:cell atIndex:toIndexPath.item];
    self.dashboardItems = mutArray;
    [self reloadFavorites];
}

- (IBAction)sortButtonTouched:(id)sender
{
    if ([sender tag] == 2000)
    {
        _sortImageView.image = [UIImage imageNamed:@"segment_atoz.png"];
        _favoritesFRC = [[FavoritesModel sharedInstance] favoritesWithFavoritesSort:0 onDashboard:!all filterType:filterType];
    }
    else if ([sender tag] == 2001)
    {
        _sortImageView.image = [UIImage imageNamed:@"segment_date.png"];
        _favoritesFRC = [[FavoritesModel sharedInstance] favoritesWithFavoritesSort:1 onDashboard:!all filterType:filterType];
    }
    
    [self.collectionView reloadData];
}

@end
