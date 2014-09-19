//
//  DashboardVC.m
//  edge
//
//  Created by iPhone Developer on 5/13/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "DashboardVC.h"
#import "AppDelegate.h"
#import "RegistrationModel.h"
#import "ScrollLargeCell.h"
#import "ScrollSmallCell.h"
#import "ProfileVC.h"
#import "SettingsVC.h"
#import "Speciality.h"
#import "ContentModel.h"
#import "DashboardModel.h"
#import "FavoritesModel.h"
#import "MyProfile.h"
#import "Content.h"
#import "MyFavorite.h"
#import "SearchResultsVC.h"
#import "ContentSyncViewController.h"
#import "TabBarViewController.h"
#import "FavoritesGridCVCell.h"
#import "ResourceViewerViewController.h"
#import "RegistrationVC.h"
#import "UIImage+Resize.h"
#import "UIImage+OverlayImage.h"
#import "FavoritesModel.h"
#import "Tracking.h"
#import "TrackingModel.h"
#import "Product.h"
#import "MyEntitlement.h"
#import "InteractiveViewerModel.h"
#import "HTTPClient.h"
#include "ContentSyncVerifier.h"
@implementation DashboardMenuItem

- (id) initWithImage:(UIImage*)image title:(NSString*)title dashboardItem:(DashboardItem*)dashboardItem
{
    if (self = [super initWithImage:image title:title])
    {
        _dashboardItem = dashboardItem;
    }
    return self;
}

@end

@implementation DashboardLongPressGestureRecognizer

@end
@implementation DashboardTapGestureRecognizer

@end

@implementation DashboardItemButton
@end

@interface DashboardVC ()
@property (nonatomic, strong) NSFetchedResultsController *favoritesFRC;
@property (nonatomic, strong) NSFetchedResultsController *trackingFRC;

@end

@implementation DashboardVC
{
    BOOL pageControlBeingUsed;

}

@synthesize SpecialitypgControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //[[TrackingModel sharedInstance] callTracking];
    [self registerForEvents];
    /*
    NSArray *items;
    
    // load Stakeholder (Customer)
    //items = [[DashboardModel sharedInstance] itemsWithDashboardItemType:kDashboardItemTypeStakeHolder];
    ////nslog(@"customers: %d", items.count);
    
    // load Speciality
    items = [[DashboardModel sharedInstance] itemsWithDashboardItemType:kDashboardItemTypeSpeciality];
    //NSLog(@"specialities: %d", items.count);
    
    ////nslog(@"specialities: %d", items.count);
    // sort Specialities by name
    //items = [items sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[(DashboardItem*)obj1 title] caseInsensitiveCompare:[(DashboardItem*)obj2 title]];
    }];
    
    items = nil;
     */
    
    stakeLab.hidden = YES;
    _StackholderLbl.hidden = NO;
    
    arrowBlnk2.hidden = YES;
    self.arrowBlink.hidden = NO;
    dashcheck = 0;
    
    specLab.hidden = YES;
    _SpecialityLbl.hidden = NO;
    currentNo = 0;
    
    self.rightArrowBtn.hidden = YES;
    rightArrowBtn.hidden = NO;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    // set the tab bar controller in the app delegate for all to use.
    self.appDelegate.tabBarController = self.tabBarController;
    
    _StackholderLbl.font = [UIFont fontWithName:@"StagSans-Light" size:22];
    _myfavouritesLbl.font = [UIFont fontWithName:@"StagSans-Light" size:22];
    _recentlyLbl.font = [UIFont fontWithName:@"StagSans-Light" size:22];
    _SpecialityLbl.font = [UIFont fontWithName:@"StagSans-Light" size:22];
    
    // _lastUpdateLbl.font = [UIFont fontWithName:@"StagSans-Book" size:12];
    // display the app version
    self.appVersionLbl.text = [self.appDelegate appVersionString];
    
    [self configScrollViews];
    
    
    
    //    if ([[RegistrationModel sharedInstance] isRegistered])
    //    {
    //        if (![[RegistrationModel sharedInstance] loadMyProfile])
    //        {
    //            NSLog(@"ERROR loading user's profile.");
    //        }
    //
    //        [[DashboardModel sharedInstance] initModel];
    //
    //        [self loadHomeData];
    //
    //    }
    //
    self.myFavPageControl.numberOfPages = 2;
    pageControlBeingUsed = NO;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
        
    }
    
    specLab = [[UILabel alloc] initWithFrame:_SpecialityLbl.frame];
    specLab.text = @"Specialty";
    specLab.font = _SpecialityLbl.font;
    specLab.textColor = [UIColor colorWithRed:204.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    specLab.hidden = YES;
    [self.view addSubview:specLab];
    
    stakeLab = [[UILabel alloc] initWithFrame:_StackholderLbl.frame];
    stakeLab.text = @"Stakeholder";
    stakeLab.font = _StackholderLbl.font;
    stakeLab.textColor = [UIColor colorWithRed:204.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    stakeLab.hidden = YES;
    [self.view addSubview:stakeLab];
    
    arrowBlnk2 = [UIButton buttonWithType:UIButtonTypeCustom];
    arrowBlnk2.frame = self.arrowBlink.frame;
    [arrowBlnk2 setImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"arrow_right" ofType:@"png"]] forState:UIControlStateNormal];
    arrowBlnk2.hidden = YES;
    [self.view addSubview:arrowBlnk2];
    
    rightArrowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightArrowBtn.frame = self.rightArrowBtn.frame;
    [rightArrowBtn setImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"3red_arrows1" ofType:@"png"]] forState:UIControlStateNormal];
    [rightArrowBtn addTarget:self action:@selector(ShowPopUp) forControlEvents:UIControlEventTouchUpInside];
    rightArrowBtn.hidden = NO;
    [self.view addSubview:rightArrowBtn];

    dashcheck = 0;
    currentNo = 0;
}

-(void)ShowPopUp
{
    showMsg = [[UIImageView alloc] initWithFrame:CGRectMake(645, 134, 150, 50)];
    showMsg.image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"dashboard_popup" ofType:@"png"]];
   // UIImageView * popimageview
    [self.view addSubview:showMsg];
    
    [UIView animateWithDuration:5.0
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         showMsg.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)invokeContentSync
{
    NSMutableArray* tempEntitlements = [[NSMutableArray alloc] init];
    NSArray* myEntitlements = [[RegistrationModel sharedInstance].profile myProfileToMyEntitlement].allObjects;
    
    [[[UpdateNotify SharedManager] syncArray]removeAllObjects];
    [tempEntitlements removeAllObjects];
    
    for (int i = 0; i < [myEntitlements count]; i++)
    {
        MyEntitlement* entitlement =  [myEntitlements objectAtIndex:i];
        if ([[entitlement status] isEqualToNumber:[NSNumber numberWithInt:kEntitlementStatusEnabled]]) {
            [tempEntitlements addObject:entitlement]; //Add selected Specialites to get deltas
        }
    }
    
    [[UpdateNotify SharedManager] setSyncArray:tempEntitlements];
    sync.syncvalue1 = 1;
    ContentSyncModel* contentSyncModel = [ContentSyncModel sharedContentSync];
    contentSyncModel.syncFromDashboard = 1;
    
    TabBarViewController* tab = (TabBarViewController*)self.tabBarController;
    sync.delegate = tab;
    
    sync.hudView = self.view;
    sync.syncFromScheduler = NO;
    
    [sync syncBtnClicked:nil];
    
    tempEntitlements = nil;
    myEntitlements = nil;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![[RegistrationModel sharedInstance] isRegistered])
    {
        if (![[HTTPClient sharedClient1] hasWifi]) {
            [[[UIAlertView alloc] initWithTitle:@"Info" message:@"Connection to WIFI is required for Registration" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }

        [(TabBarViewController*)self.tabBarController performSegueWithIdentifier:@"RegistrationSegue" sender:nil];
    }
    else
    {
        if (!_justRunOnce) {
            _justRunOnce = YES;
            
            if (![[DownloadManager sharedManager] areDownloadsCompleted])
            {
                if ([[DownloadManager sharedManager] isInitialSyncStillPending]) {
                    if (![[HTTPClient sharedClient1] hasWifi]) {
                            [self initialDownloadMessage];
                            return;
                    }
                    
                    if ([[HTTPClient sharedClient1] hasWifi]) {
                       
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Your initial content download was unsuccessful. Please keep the application open until the download process is complete." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        alert.tag = 11;
                        [alert show];
                    }
                    [self unregisterForWifiEvents];
                    [self registerForWifiEvents];
                    [[NSNotificationCenter defaultCenter]  addObserver:self
                                                              selector:@selector(handleAllDownloadComplete:)
                                                                  name:DOWNLOAD_ALL_COMPLETE_EVENT
                                                                object:nil];
                    
                } else {
                    [[ContentSyncVerifier sharedInstance] enableBulbIcon];
                }
            }
        }
        
        [[DashboardModel sharedInstance] refreshDashboard];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ForNewEnt:)
                                                 name:@"ForNewEnt" object:nil];
}

-(void)handleAllDownloadComplete:(NSNotification*)pNotifcation
{
    DownloadManager* downloadMan = [DownloadManager sharedManager];
    downloadMan.isInitialSyncStillPending = NO;
    
    [self unregisterForWifiEvents];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DOWNLOAD_ALL_COMPLETE_EVENT object:nil];
}

-(void)ForNewEnt:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveHudInSyncVCSCreen" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ForNewEnt" object:nil];
    UIAlertView *showInfo = [[UIAlertView alloc] initWithTitle:@"Content Update" message:@"New Specialties, Procedures, and Products are available for download." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [showInfo show];
}

- (void) viewDidDisappear:(BOOL)animated {
    [self unregisterForEvents];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    //[[DashboardModel sharedInstance] initModel];
}

#pragma mark - Prepare for Segue

/*
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"DashboardToProfile"])
    {
        ProfileVC *vc = (ProfileVC*)segue.destinationViewController;
        vc.popoverDelegate = self;
    } else if ([segue.identifier isEqualToString:@"DashboardToSettings"])
    {
        SettingsVC *vc = (SettingsVC*)segue.destinationViewController;
        //vc.popoverDelegate = self;
    } else if ([segue.identifier isEqualToString:@"DashboardToSearch"])
    {
        SearchResultsVC *vc = (SearchResultsVC*)segue.destinationViewController;
        vc.popoverDelegate = self;
    }
}*/

- (void) configScrollViews
{
    [self customizeScrollView:_customerSV];
    [self customizeScrollView:_specialitySV];
    
    _myFavoritesCV.layer.cornerRadius = 13.0f;
    //_myFavoritesCV.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //_myFavoritesCV.layer.borderWidth = 1.0f;
    
    [self customizeScrollView:_recentlyViewedSV];
    
}

- (void) clearScrollView:(UIScrollView*)scrollView
{
    for (UIView *view in scrollView.subviews)
    {
        [view removeFromSuperview];
    }
}

- (void) updateView
{
    //NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    _greetingLbl.text = @"Welcome";// [NSString stringWithFormat:@"Welcome %@",[userDefaults objectForKey:@"firstName"]];
    _greetingLbl.font = [UIFont fontWithName:@"StagSans-Book" size:21];
    [self.appDelegate.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.appDelegate.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    //_lastUpdateLbl.text = [NSString stringWithFormat:@"Last updated: %@", [self.appDelegate.dateFormatter stringFromDate:[RegistrationModel sharedInstance].profile.contentUpdDt]];
    
    NSDate* date;
    DownloadManager* downloadMan = [DownloadManager sharedManager];
    NSArray* specialities = downloadMan.fetchAllSpecialities;
    for (NSManagedObject* speciality in specialities) {
        date = [speciality valueForKey:@"lastSyncDt"];
        break;
    }
    if (date != nil)
        _lastUpdateLbl.text = [NSString stringWithFormat:@"Last updated: %@",[self.appDelegate.dateFormatter stringFromDate:date]];
    else
        _lastUpdateLbl.text = [NSString stringWithFormat:@"Last updated: %@",@"Unknown"];

    //nslog(@"last updated was....%@",[self.appDelegate.dateFormatter stringFromDate:[RegistrationModel sharedInstance].profile.contentUpdDt]);

    //int cust = [DashboardModel sharedInstance].currentCustomerType;
    //BOOL specialitySelected = [DashboardModel sharedInstance].currentEntitlement != nil;
    //_rightArrowBtn.hidden = !(cust != NSNotFound && specialitySelected);
}

- (void) loadHomeData
{
    ////nslog(@"loadHomeData");
    NSArray *items;

    // load Stakeholder (Customer)
    items = [[DashboardModel sharedInstance] itemsWithDashboardItemType:kDashboardItemTypeStakeHolder];
    ////nslog(@"customers: %d", items.count);
    [self populateScrollView:_customerSV items:items];    
    
   // //nslog(@"",[InteractiveViewerModel f])
    
    // load Speciality
    items = [[DashboardModel sharedInstance] itemsWithDashboardItemType:kDashboardItemTypeSpeciality];
    ////nslog(@"specialities: %d", items.count);
    // sort Specialities by name
    items = [items sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[(DashboardItem*)obj1 title] caseInsensitiveCompare:[(DashboardItem*)obj2 title]];
    }];
    int numPages = 0;
    if (((items.count) % 3) != 0) {
        numPages = (((items.count)/3) +1);
    }
    else{
        numPages = ((items.count)/3);
    }
    SpecialitypgControl.numberOfPages = numPages;
    SpecialitypgControl.currentPage = 0;
    [self populateScrollView:_specialitySV items:items];

    // load MyFavorites
    [self reloadFavorites];
    
    // load MyRecentlyViewed
    items = [[DashboardModel sharedInstance] itemsWithDashboardItemType:kDashboardItemTypeMyRecentlyViewed];
    ////nslog(@"myRecentlyViewed: %d", items.count);
    [self populateScrollView:_recentlyViewedSV items:items];
    
    [self updateView];
    items = nil;
}

- (void) customizeScrollView:(UIScrollView*)scrollview
{
    scrollview.layer.cornerRadius = 13.0f;
    //scrollview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //scrollview.layer.borderWidth = 1.0f;
    
}

- (NSString*) overlayImageNameForContentCatId:(NSString*)mime
    {
        NSString *imageName;
        if ([[mime lowercaseString] isEqualToString:@"application/zip"])
        {
            
            imageName = @"html_small_btn";
            
        }
        else if ([[mime lowercaseString] isEqualToString:@"application/pdf"])
        {
            
            imageName = @"article_small_btn";
            
        }
        
        else if ([[mime lowercaseString] isEqualToString:@"video/quicktime"])
        {
            
            imageName = @"video_small_btn";
            
        }
        else
        {
            
            imageName = @"product_small_btn";
            
        }

    /*switch (contentCatId.intValue)
    {
        // video
        case kSpecialtyVideo:
        case kProcedureVideo:
        case kProductVideo:
        case kProductCompetitiveInfoVideos:
            imageName = @"video_small_btn";
            break;
        
        // article
        case kSpecialtyArticle:
        case kProcedureArticle:
        case kProductClinicalArticles:
        case kProductClinicalArticlesCharts:
        case kProductClinicalArticlesOthers:
            imageName = @"article_small_btn";
            break;
            
        // message
        case kSpecialtyMessage:
        case kProcedureMessage:
        case kProductClinicalMessage:
        case kProductNonClinicalMessage:
            imageName = @"html_small_btn";
            break;
        
        // product
        case CONTENT_CAT_ID_FAV_ON_PRODUCT:
            imageName = @"product_small_btn";
            break;
            
        default:
            imageName = @"product_small_btn";
            break;
    }*/
    return imageName;
}

- (void) populateScrollView:(UIScrollView*)scrollview items:(NSArray*)items
{
    /* CGFloat vWidth = 120.0f, vHeight = 120.0f;
     CGFloat xOffset = 0.0f, yOffset = 4.0f;
     CGFloat width = 64.0f, height = 64.0f, margin = 10.0f, vsep = 4.0f;*/
    
    CGFloat vWidth = 120.0f, vHeight = 120.0f;
    CGFloat xOffset = 0.0f, yOffset = 4.0f;
    CGFloat width = 54.0f, height = 54.0f, margin = 10.0f, vsep = 4.0f;
    
    // first clear the scroll view of any child views.
    [self clearScrollView:scrollview];
    
    CGRect frame;
    UIView *view;
    DashboardItemButton *dashboardBtn;
    DashboardItem *dashboardItem;
    UIImage *img;
    UILabel *lbl;
    for (int i=0; i<items.count; i++)
    {
        dashboardItem = [items objectAtIndex:i];
        
        view = [[UIView alloc] initWithFrame:CGRectMake(xOffset, yOffset, vWidth, vHeight)];
        view.backgroundColor = [UIColor clearColor];
        
        dashboardBtn = [DashboardItemButton buttonWithType:UIButtonTypeCustom];
        if (dashboardItem.itemType == kDashboardItemTypeMyRecentlyViewed)
        {
            UIView *view11 = [[UIView alloc] initWithFrame:CGRectMake(22, 34, 76, 62)];
            view11.layer.borderColor = [UIColor colorWithRed:243.0f/255.0f green:243.0f/255.0f blue:243.0f/255.0f alpha:1].CGColor;
            view11.layer.borderWidth = 1.0f;
            view11.backgroundColor = [UIColor clearColor];
            [view addSubview:view11];
            
            UIImageView *immvie = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 66, 52)];
           
            // for no images
            
            UIImageView *productThumbnailImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 66, 52)];
            productThumbnailImage.image = [self.appDelegate loadImage:dashboardItem.imageName];
            if (!productThumbnailImage.image)
            {
                 UILabel * producttitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 66, 52)];
                producttitle.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
                producttitle.text = dashboardItem.title;
                producttitle.numberOfLines = 0;
                producttitle.font = [UIFont fontWithName:@"Arial" size:10];
                producttitle.textAlignment = NSTextAlignmentCenter;
                [productThumbnailImage addSubview:producttitle];
                UIGraphicsBeginImageContext(productThumbnailImage.bounds.size);
                [productThumbnailImage.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage *bitmap = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                productThumbnailImage.image = bitmap;
            }
            
            
            
            immvie.image = productThumbnailImage.image;
            
           
            immvie.contentMode = UIViewContentModeScaleToFill;
            immvie.clipsToBounds = YES;
            
            UIImageView *centreButton = [[UIImageView alloc] initWithFrame:CGRectMake(41.5f, 27.5f, 25, 25)];
            centreButton.contentMode = UIViewContentModeScaleToFill;
            centreButton.clipsToBounds = YES;
            
            Content *content = [[ContentModel sharedInstance] contentWithThumbPath:dashboardItem.imageName];
            [centreButton setImage:[UIImage imageNamed:[self overlayImageNameForContentCatId:content.mime]]];
            
            [immvie addSubview:centreButton];
            [view11 addSubview:immvie];
            centreButton = nil;
            immvie = nil;
           
        }
        else
        {
            img = [UIImage imageNamed:dashboardItem.imageName];
            if(!img)
            {
                img = [self.appDelegate loadImage:dashboardItem.imageName];
            }
            
        }
        [dashboardBtn setImage:img forState:UIControlStateNormal];
        
        if (dashboardItem.currentSelection)
        {
            //dashcheck = 1;
            img = [UIImage imageNamed:dashboardItem.imageNameSelected];
            if(!img)
            {
                img = [self.appDelegate loadImage:dashboardItem.imageNameSelected];
            }
            [dashboardBtn setImage:img forState:UIControlStateNormal];
        }
        
        int typ = (int)dashboardItem.itemType;
        if (typ == kDashboardItemTypeStakeHolder)
        {
            if(dashboardItem.currentSelection == NO)
            {
                img = [UIImage imageNamed:dashboardItem.imageName];
                [dashboardBtn setImage:img forState:UIControlStateNormal];
            }

        }
        
        frame = dashboardBtn.frame;
        frame.size = CGSizeMake(width, height);
        frame.origin.x = (vWidth - width)/2;
        frame.origin.y = vsep+35;
        
        dashboardBtn.frame = frame;
        
        dashboardBtn.dashboardItem = dashboardItem;
        [dashboardBtn addTarget:self action:@selector(dashboardItemSelected:) forControlEvents:UIControlEventTouchDown];
        
        [view addSubview:dashboardBtn];
        
        if (dashboardItem.defaultSelection)
        {
            UIImageView *icon = [[UIImageView alloc] initWithImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"checkbox-checked_16" ofType:@"png"]]];
            frame = icon.frame;
            frame.origin.x = dashboardBtn.frame.origin.x + dashboardBtn.frame.size.width - icon.frame.size.width;
            frame.origin.y = dashboardBtn.frame.origin.y + dashboardBtn.frame.size.height - icon.frame.size.height;
            icon.frame = frame;
            [view addSubview:icon];
            icon = nil;
        }
        
        xOffset = 0.0f;
        yOffset = dashboardBtn.frame.origin.y + dashboardBtn.frame.size.height + vsep;
        lbl = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, vWidth, 44.0f)];
        lbl.text = [NSString stringWithFormat:@"%@", dashboardItem.title];
        lbl.numberOfLines = 0;
        
        {
            lbl.autoresizingMask = UIViewAutoresizingFlexibleWidth |
            UIViewAutoresizingFlexibleHeight;
            lbl.backgroundColor = [UIColor clearColor];
            lbl.textAlignment = NSTextAlignmentCenter;
            if (dashboardItem.currentSelection)
            {
            lbl.textColor = [UIColor colorWithRed:204.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
            }
            else
            {
              lbl.textColor = [UIColor darkGrayColor];
            }
            
        }
        
        if (dashboardItem.itemType == kDashboardItemTypeMyRecentlyViewed)
        {
            lbl.font = [UIFont fontWithName:@"Arial" size:11.0f];
        }
        else
            
            lbl.font = [UIFont fontWithName:@"Arial" size:12.0f];
        
        [view addSubview:lbl];
        
        xOffset = (i * margin) + (i * vWidth) + margin;
        yOffset = vsep;
        frame = view.frame;
        frame.origin.x = xOffset;
        view.frame = frame;
        
        [scrollview addSubview:view];
    }
    xOffset += (vWidth + margin);
    scrollview.contentSize = CGSizeMake(xOffset, vHeight);
    lbl = nil;
}

- (IBAction)mySpecPageControlSwiped:(id)sender
{
    // for adding images for page control.
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    
    SpecialitypgControl.currentPage = (scrollView.contentOffset.x/100);
    
}


- (void) dashboardItemSelected:(id)sender
{
    DashboardItemButton *dashboardBtn = (DashboardItemButton*)sender;
    DashboardItem *dashboardItem = dashboardBtn.dashboardItem;
    
    if (dashboardItem)
    {
        if (dashboardItem.isProduct)
        {
            // Product was selected
            Product *product = [[ContentModel sharedInstance] productWithId:dashboardItem.itemId];
            [self.appDelegate navigateToProductDetailWithProduct:product];
        }
        else
        {
            int typ = (int)dashboardItem.itemType;
            ////nslog(@"itemType: %d", typ);
            if (typ == kDashboardItemTypeStakeHolder || typ == kDashboardItemTypeSpeciality)
                //&& !dashboardItem.currentSelection)
            {
                [[DashboardModel sharedInstance] dashboardItemSelected:dashboardItem];
                [self loadHomeData];
            }
            if (typ == kDashboardItemTypeStakeHolder)
            {
                if (dashboardItem.currentSelection)
                {
                    
                    stakeLab.hidden = NO;
                    _StackholderLbl.hidden = YES;
                    
                    arrowBlnk2.hidden = NO;
                    self.arrowBlink.hidden = YES;
                    dashcheck = 1;
                    
                }
                
                else
                {
                    stakeLab.hidden = YES;
                    _StackholderLbl.hidden = NO;
                    
                    arrowBlnk2.hidden = YES;
                    self.arrowBlink.hidden = NO;
                    dashcheck = 0;
                    
                }
            }
            if (typ == kDashboardItemTypeSpeciality)
            {
                if (dashboardItem.currentSelection)
                {
                    specLab.hidden = NO;
                    _SpecialityLbl.hidden = YES;
                    currentNo = 1;
                }
                
                else
                {
                    specLab.hidden = YES;
                    _SpecialityLbl.hidden = NO;
                    currentNo = 0;
                }
            }
            if (dashcheck == 1 && currentNo == 1)
            {
                self.rightArrowBtn.hidden = NO;
                rightArrowBtn.hidden = YES;
                showMsg.hidden = YES;
            }
            else
            {
                self.rightArrowBtn.hidden = YES;
                rightArrowBtn.hidden = NO;
            }

            if (typ == kDashboardItemTypeMyRecentlyViewed)
            {
                Content *content = [[ContentModel sharedInstance] contentWithId:dashboardItem.itemId];
                
                NSString *tempStr = [NSString stringWithFormat:@"%@:%@", content.cntId, dashboardItem.title];
                [[TrackingModel sharedInstance] createTrackingDataWithResource:tempStr activityCode:TRACKING_ACTIVITY_VIEWED_PRODUCT_ASSET];
                
                [self openContentInContentViewer:content];
            }
            
        }
    }
    
}

-(void) arrowBlinkMethod
{
    [UIView animateWithDuration:0.7
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut |
     UIViewAnimationOptionRepeat |
     UIViewAnimationOptionAutoreverse |
     UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.arrowBlink.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                     }];
}
-(void) rightArrwButnMethod
{
    [UIView animateWithDuration:0.7
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut |
     UIViewAnimationOptionRepeat |
     UIViewAnimationOptionAutoreverse |
     UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.rightArrowBtn.alpha = 0.1f;
                     }
                     completion:^(BOOL finished){
                     }];
}
#pragma mark -
#pragma mark app event handling

- (void) registerForEvents
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDashboardRefreshed) name:APP_EVENT_DASHBOARD_REFRESHED object:nil];
    
}

- (void) unregisterForEvents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_DASHBOARD_REFRESHED object:nil];
    
}

- (void) handleDashboardRefreshed
{
    [self loadHomeData];
}

#pragma mark -
#pragma mark action handling

- (IBAction)myFavPageControlSwiped:(id)sender
{/*
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.myFavoritesCV.frame.size.width * self.myFavPageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.myFavoritesCV.frame.size;
    [self.myFavoritesCV scrollRectToVisible:frame animated:YES];
    
    // Keep track of when scrolls happen in response to the page control
	// value changing. If we don't do this, a noticeable "flashing" occurs
	// as the the scroll delegate will temporarily switch back the page
	// number.
	pageControlBeingUsed = YES;
   */ 
}

- (IBAction) rightArrowBtnTouched
{
    _currentEntitlement = [[DashboardModel sharedInstance] currentEntitlement];
    [[DashboardModel sharedInstance] setCurrentSpeciality:_currentEntitlement.myEntitlementToSpeciality];

    [self.tabBarController setSelectedIndex:PROCEDURE_TAB_INDEX];
    self.rightArrowBtn  .alpha = 1.0f;
}

#pragma mark -
#pragma mark Sync button handling

- (void) doSync
{
    [[ContentModel sharedInstance] syncMasterData];
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERT_VIEW_HANDLE_LOCALLY)
    {
        if (buttonIndex != alertView.cancelButtonIndex)
        {
            [self doSync];
        }
    }  else if (alertView.tag == 10) {
        if (buttonIndex == alertView.cancelButtonIndex){
            [[DownloadManager sharedManager] resetData];
            exit(0);
        }
    } else if (alertView.tag == 11) {
        [self invokeContentSync];
    }else {
        // let the super class handle the alert view
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

- (void) confirmSync
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation Required" message:@"Are you sure you want to download content from the server?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = TAG_ALERT_VIEW_HANDLE_LOCALLY;
    [alert show];
    
}

//- (IBAction) syncBtnTouched
//{
//    [self confirmSync];
//}

#pragma mark - Favorites
#pragma mark UICollectionView Data Source Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    ////nslog(@"\nFavorites number of items %d",[[_favoritesFRC fetchedObjects] count]);
    return [[_favoritesFRC fetchedObjects] count];
    
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"FavDashCollectionCell";
    
    MyFavorite *fav;
    fav = [_favoritesFRC.fetchedObjects objectAtIndex:indexPath.row];
    Product *product;
    
    if ([fav.isProduct boolValue])
    {
        product = [[ContentModel sharedInstance] productWithId:[fav.cntId intValue]];
        
    }
    
    FavoritesGridCVCell *cell = (FavoritesGridCVCell*)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    cell.dataTypeLabel.textAlignment = NSTextAlignmentCenter;
    
    //Set artifact title
    NSString *str;
    switch ([fav.contentCatId intValue])
    {
            // video
        case kSpecialtyVideo:
        case kProcedureVideo:
        case kProductVideo:
        case kProductCompetitiveInfoVideos:
            str = @"Video";
            
            if (fav.favoriteToContent.title)
            {
                str = fav.favoriteToContent.title;
            }
            break;
            
            // article
        case kSpecialtyArticle:
        case kProcedureArticle:
        case kProductClinicalArticles:
        case kProductClinicalArticlesCharts:
        case kProductClinicalArticlesOthers:
            str = @"Article";
            
            if (fav.favoriteToContent.title)
            {
                str = fav.favoriteToContent.title;
            }
            break;
            
            // message
        case kSpecialtyMessage:
        case kProcedureMessage:
        case kProductClinicalMessage:
        case kProductNonClinicalMessage:
            str = @"Message";
            
            if (fav.favoriteToContent.title)
            {
                str = fav.favoriteToContent.title;
            }
            break;
            
            // product
        case CONTENT_CAT_ID_FAV_ON_PRODUCT:
            str = product.name;
            break;
            
        default:
            str = fav.favoriteToContent.title;
            break;
    }
    cell.dataTypeLabel.text = str;
    
    //long press setup
    UILongPressGestureRecognizer *longPressGesture =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    cell.favCellLongPress = longPressGesture;
    [cell addGestureRecognizer:longPressGesture];
    
    UIImage *overlayImg;
    if ([fav.contentCatId intValue] == CONTENT_CAT_ID_FAV_ON_PRODUCT)
    {
        NSArray *contents = [[ContentModel sharedInstance] contentsForProduct:product withContentCatIds:[NSArray arrayWithObject:[NSNumber numberWithInt:kProductImage]]];
        
        
        
        
        UIImageView *productThumbnailImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 66, 52)];
        UILabel * producttitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 66, 52)];
        for (Content *content in contents)
        {
            ////nslog(@"content.path: %@", content.path);
            if (content.thumbnailImgPath)
            {
                ////nslog(@"content.thumbnailImgPath: %@", content.thumbnailImgPath);
                productThumbnailImage.image = [self.appDelegate loadImage:content.thumbnailImgPath];
                overlayImg = [UIImage imageNamed:[self overlayImageNameForContentCatId:content.mime]];
                producttitle.text = content.title;
                break;
            }
            
        }
        
        //NSLog(@"---fav title--- %@",producttitle.text);
        if (!productThumbnailImage.image)
        {
            
            producttitle.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
            
            producttitle.numberOfLines = 0;
            producttitle.font = [UIFont fontWithName:@"Arial" size:10];
            producttitle.textAlignment = NSTextAlignmentCenter;
            [productThumbnailImage addSubview:producttitle];
            UIGraphicsBeginImageContext(productThumbnailImage.bounds.size);
            [productThumbnailImage.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *bitmap = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            productThumbnailImage.image = bitmap;
        }
        
        cell.favCellImageView.image = productThumbnailImage.image;
        
        contents = nil;
        productThumbnailImage = nil;
        
    } else{
        ////nslog(@"\n content.thumbnailImgPath: %@",fav.favoriteToContent.thumbnailImgPath);
        
           UIImageView *productThumbnailImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 66, 52)];
          productThumbnailImage.image = [self.appDelegate loadImage:fav.favoriteToContent.thumbnailImgPath];
        
        if (!productThumbnailImage.image)
        {
            UILabel * producttitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 66, 52)];
            producttitle.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
            producttitle.text = fav.favoriteToContent.title;
            producttitle.numberOfLines = 0;
            producttitle.font = [UIFont fontWithName:@"Arial" size:10];
            producttitle.textAlignment = NSTextAlignmentCenter;
            [productThumbnailImage addSubview:producttitle];
            UIGraphicsBeginImageContext(productThumbnailImage.bounds.size);
            [productThumbnailImage.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *bitmap = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            productThumbnailImage.image = bitmap;
        }
        
        cell.favCellImageView.image = productThumbnailImage.image;
        
        overlayImg = [UIImage imageNamed:[self overlayImageNameForContentCatId:fav.favoriteToContent.mime]];
        productThumbnailImage = nil;
    }
//    cell.favCellImageView.image = [cell.favCellImageView.image drawImage:overlayImg atPoint:CGPointMake(cell.favCellImageView.image.size.width-20, cell.favCellImageView.image.size.height-20)];
    cell.centerImageView.image = overlayImg;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"cell #%d was selected", indexPath.row);
    
    MyFavorite *fav;
    fav = [_favoritesFRC.fetchedObjects objectAtIndex:indexPath.row];
    ////nslog(@"Cell name is %@ item type is %@, created on %@", fav.favoriteToContent.title, fav.contentCatId, fav.crtDt);
    
    ///get path and setup resource viewer
    NSString* targetPath = [[ContentModel sharedInstance] addAppDocumentsPathToPath:fav.favoriteToContent.path];
    
    //targetPath = [targetPath stringByAppendingString:@"/index.html"];
    
    // add MyRecentlyViewed
    [[DashboardModel sharedInstance] addRecentlyViewedForContent:fav.favoriteToContent];
    
    if ([fav.isProduct boolValue])
    {
        // Product was selected
        Product *product = [[ContentModel sharedInstance] productWithId:[fav.cntId intValue]];
        
        [self.appDelegate navigateToProductDetailWithProduct:product];
        
    }
    else
    {
        ResourceViewerViewController* rviewer = [[ResourceViewerViewController alloc] initWithNibName:@"ResourceView" bundle:nil];
        rviewer.filePath = targetPath;
        
        //NSString *tempStr = [NSString stringWithFormat:@"%@:%@", fav.favoriteToContent.cntId, fav.title];
        //NSLog(@"Temp string = %@", tempStr);
        
        NSString *resourceString = [NSString stringWithFormat:@"%d:%@", [fav.favoriteToContent.cntId intValue], fav.favoriteToContent.title];
        [[TrackingModel sharedInstance] createTrackingDataWithResource:resourceString activityCode:TRACKING_ACTIVITY_VIEWED_PRODUCT_ASSET];

        
        [self presentViewController:rviewer animated:NO completion:nil];
        [rviewer play];
    }

}


-(void)reloadFavorites
{
    _favoritesFRC = [[FavoritesModel sharedInstance] favoritesWithFavoritesSort:kFavoritesSortABC onDashboard:YES filterType:kFavoritesFilterAll];
    
    [self.myFavoritesCV reloadData];
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
		FavoritesGridCVCell *cell = (FavoritesGridCVCell *)[gesture view];
        
		// get indexPath of cell
		NSIndexPath *indexPath = [self.myFavoritesCV indexPathForCell:cell];
        MyFavorite *fav = [_favoritesFRC.fetchedObjects objectAtIndex:indexPath.row];
        
        // do something with this action
        ////nslog(@"Long-pressed cell at row %ld", (long)indexPath.row);
        
        Content *content = fav.favoriteToContent;
        ////nslog(@"Content is shareable : %@", content.isSharable);
        
        if (content.isSharable == [NSNumber numberWithInt:1])
        {
            UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                                      delegate: self
                                                             cancelButtonTitle: nil
                                                        destructiveButtonTitle: nil
                                                             otherButtonTitles: @"Remove from Home Screen", @"Share", nil];
            
            actionSheet.tag = kDashboardVCActionSheetFavorites;
            [actionSheet showFromRect: cell.frame inView: cell.superview animated: YES];
            self.favoriteLongPressIndexPath = indexPath;
            
        }
        else
        {
            UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                                      delegate: self
                                                             cancelButtonTitle: nil
                                                        destructiveButtonTitle: nil
                                                             otherButtonTitles: @"Remove from Home Screen", nil];
            actionSheet.tag = kDashboardVCActionSheetFavorites;
            [actionSheet showFromRect: cell.frame inView: cell.superview animated: YES];
            self.favoriteLongPressIndexPath = indexPath;
            
        }
        [self.myFavoritesCV reloadData];
        
        
	}
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        
    }
    
}

#pragma mark -
#pragma mark UIActionSheet Methods

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    //Gets an array af all of the subviews of our actionSheet
    NSArray *subviews = [actionSheet subviews];
    
    for (UIView *v in subviews)
    {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *b = (UIButton*)v;
            [b setTitleColor:[UIColor colorWithRed:110.0f/255.0f green:110.0f/255.0f blue:110.0f/255.0f alpha:1] forState:UIControlStateNormal];
            [b setTitleColor:[UIColor colorWithRed:243.0f/255.0f green:6.0f/255.0f blue:23.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
            
            //[b setBackgroundImage:[UIImage imageNamed:@"backActionSheetHighlighted.png"] forState:UIControlStateHighlighted];
            //[b setBackgroundImage:[UIImage imageNamed:@"backActionSheet.png"] forState:UIControlStateNormal];
        }
    }
    //
    
    if (actionSheet.tag == kDashboardVCActionSheetFavorites)
    {
        for (UIView *_currentView in actionSheet.subviews) {
            if ([_currentView isKindOfClass:[UILabel class]])
            {
                //[((UILabel *)_currentView) setFont:[UIFont boldSystemFontOfSize:14.0f]];
                [((UILabel *)_currentView) setTextColor:[UIColor colorWithRed:243.0f/255.0f green:6.0f/255.0f blue:23.0f/255.0f alpha:1.0f]];
                
            }
        }
    }
    subviews = nil;
    /*
    //Gets an array af all of the subviews of our actionSheet
    NSArray *subviews = [actionSheet subviews];
    
    for (UIView *v in subviews)
    {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *b = (UIButton*)v;
            [b setFrame:CGRectMake(13, 3, 200, 50)];
            [b setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [b setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            
            //[b setBackgroundImage:[UIImage imageNamed:@"backActionSheetHighlighted.png"] forState:UIControlStateHighlighted];
            //[b setBackgroundImage:[UIImage imageNamed:@"backActionSheet.png"] forState:UIControlStateNormal];
        }
    }

    if (actionSheet.tag == kDashboardVCActionSheetFavorites)
    {
        for (UIView *_currentView in actionSheet.subviews) {
            if ([_currentView isKindOfClass:[UILabel class]]) {
                [((UILabel *)_currentView) setFont:[UIFont boldSystemFontOfSize:18.f]];
            }
        }
    }
     */
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if  (actionSheet.tag == kDashboardVCActionSheetFavorites)
    {
        if (buttonIndex == 0)
        {
            ////nslog(@"Remove tapped");
            [self handleRemoveBoard:self];
        }
        else if (buttonIndex == 1)
        {
            ////nslog(@"Share tapped");
            [self handleShare:self];
        }
    }

}

-(void)handleRemoveBoard:(id)sender
{
    MyFavorite *fav = [_favoritesFRC.fetchedObjects objectAtIndex:self.favoriteLongPressIndexPath.row];
    fav.isOnDashboard = [NSNumber numberWithBool:NO];
    [self.appDelegate saveContext];
    [self reloadFavorites];
}

-(void)handleShare:(id)sender
{
    MyFavorite *fav = [_favoritesFRC.fetchedObjects objectAtIndex:self.favoriteLongPressIndexPath.row];
    Content *content = fav.favoriteToContent;
    TabBarViewController *tabCntrl = (TabBarViewController *) self.tabBarController;
    [tabCntrl invokeEmailQueueOverlayVCWithContent:content];
}

- (void) registerForWifiEvents
{
    [self unregisterForWifiEvents];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNoWifi) name:APP_EVENT_NO_WIFI object:nil];
}



- (void) handleNoWifi {
    [self initialDownloadMessage];
}

- (void) initialDownloadMessage {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Your initial content download was unsuccessful. To use the platform, it’s MANDATORY to complete the Content Download.  Please ensure to stay connected to internet via WiFi to complete the process." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    alert.tag = 10;
    [alert show];
}

- (void) unregisterForWifiEvents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_NO_WIFI object:nil];
}


@end
