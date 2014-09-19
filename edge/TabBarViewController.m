//
//  TabBarViewController.m
//  edge
//
//  Created by Vijaykumar on 7/11/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "TabBarViewController.h"
#import "DrawVC.h"
#import "ContentSyncViewController.h"
#import "SearchSuggestionsVC.h"
#import "SearchResultsVC.h"
#import "SyncViewController.h"
#import "EmailQueueOverlayViewController.h"
#import "RootViewController.h"
#import "CustomNavigationBar.h"
#import "MyEntitlement.h"
#import "RegistrationModel.h"
#import "MyProfile.h"
#import "ProductsVC.h"
#import "DashboardModel.h"
#import "ContentSyncSchedulerViewController.h"

@interface TabBarViewController ()
@end

@implementation TabBarViewController

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
	// Do any additional setup after loading the view.
    self.delegate = self;
    @autoreleasepool {
        
    [self customizeTabs];
    _syncOptionsController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
    }
    // segue no work.  ?
    //[self performSegueWithIdentifier:@"SplashSegue" sender:nil];

    // try bute force
//    UIViewController *splashVC = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"SplashVC"];
//    [self presentViewController:splashVC animated:NO completion:^{}];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
//    [self.tabBar addObserver:self forKeyPath:@"selectedItem" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil]; //@TODO NOT USING CURRENTLY - Revisit to clear previous views

}

- (void) hideActivityIndicator {
    if (_progress)
    [_progress stopAnimating];
}

- (void) showActivityIndicator {
    
    if (!_progress) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Loading..." message: nil delegate:self cancelButtonTitle: nil otherButtonTitles: nil];
        _progress = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(125, 50, 30, 30)];
        _progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [alert addSubview: _progress];
        [_progress startAnimating];
        [self.view addSubview:alert];
        [alert show];
    } else {
        [_progress startAnimating];
    }
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
//@TODO    NOT USING CURRENTLY - Revisit
//    if ([keyPath isEqualToString:@"selectedItem"] && [object isKindOfClass:[UITabBar class]]){
//        UITabBar *bar = (UITabBar *) object;
//        
//        UITabBarItem *previousItem = [change objectForKey:NSKeyValueChangeOldKey];
//        NSUInteger previousControllerIndex = [bar.items indexOfObject:previousItem];
//        
//        UITabBarItem *currentItem = [change objectForKey:NSKeyValueChangeNewKey];
//        NSUInteger currentControllerIndex = [bar.items indexOfObject:currentItem];
//        if (previousItem != [NSNull null])
//        {
//            id ctrl = [[self viewControllers] objectAtIndex:previousControllerIndex];
//            if ([ctrl isKindOfClass:[SearchResultsVC class]]) {
//                SearchResultsVC* searchResultsVC = (SearchResultsVC*) ctrl;
//                searchResultsVC = nil;
//                //for (UIView *subview in searchResultsVC.view.subviews)
//                //{
//                //    subview = nil;
//                //}
//            }
//            
//        }
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    
    ////nslog(@"didSelectItem");
    
    if (_drawView) {
        [_drawView removeFromSuperView];
        _drawView = nil;
    }
    DashboardModel* model = [DashboardModel sharedInstance];
    model.currentCustomerType = NSNotFound;
    model.currentProcedure = nil;

    //    if ([item.title isEqualToString:@"Draw"]) {
    //        if (_drawView) {
    //            [_drawView removeFromSuperView];
    //            _drawView = nil;
    //        }
    //        _drawView = [[DrawVC alloc]initWithNibName:@"DrawView" bundle:nil] ;
    //        _drawView.view.backgroundColor = [UIColor clearColor];
    //        CGRect viewFrame = self.view.frame;
    //        float height = (viewFrame.size.height - self.tabBar.frame.size.height - 250);
    //        CGSize newSize = CGSizeMake(viewFrame.size.height, height);
    //        viewFrame.size = newSize;
    //        _drawView.view.frame = viewFrame;
    //        [self.view addSubview:_drawView.view];
    //    } else {
    //        if (_drawView) {
    //            [_drawView removeFromSuperView];
    //            _drawView = nil;
    //        }
    //    }
    
}
- (BOOL)tabBarController:(UITabBarController *)tbController shouldSelectViewController:(UIViewController *)viewController
{
    // if user clicks on the Procedure/Product tab, and user has navigated to Product detail,
    // the tab controller framework goes back through the Product view and then jumps to the ProductDetail
    // which is not good user experience.
    ////nslog(@"previous tab --%@ and newtab --- %@",viewController,self.selectedViewController);
    if (viewController == self.selectedViewController)
    {
        //nslog(@"viewController == self.selectedViewController");
        return NO;
    }
    if (tbController.selectedIndex ==1)
    {
        if ([self.selectedViewController isKindOfClass:[UINavigationController class]])
        {
            ////nslog(@"in if condition");
            [(UINavigationController *)self.selectedViewController popToRootViewControllerAnimated:NO];
        }
    }
    
    
    return YES;
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    //if (tabBarController.selectedIndex == 1)
    if ([viewController isKindOfClass:[UINavigationController class]])
    {
        [(UINavigationController *)viewController popToRootViewControllerAnimated:NO];
    }
    if (tabBarController.selectedIndex == 0)
    {
        NSArray *items;
        
        // load Stakeholder (Customer)
        items = [[DashboardModel sharedInstance] itemsWithDashboardItemType:kDashboardItemTypeStakeHolder];
        [[DashboardModel sharedInstance] clearSelectionWithDashboardItems:items];
        
        // load Speciality
        items = [[DashboardModel sharedInstance] itemsWithDashboardItemType:kDashboardItemTypeSpeciality];
        [[DashboardModel sharedInstance] clearSelectionWithDashboardItems:items];
 
    }
}

- (void) becomeSearchSuggestionsDelegate:(id<SearchSuggestionsDelegate>)delegate withSearchBar:(UISearchBar*)searchBar
{
    if (!self.searchSuggestionsView || !self.searchSuggestionsView.view.superview) {
        
        self.searchSuggestionsView = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"SearchSuggestionsVC"];
        
        self.searchSuggestionsView.view.hidden = YES;
        
        // move over to under search control
        CGRect frame;
        frame.origin.x = 1024.f - 470.f;
        frame.origin.y = 45.0f;
        frame.size.width = 350.0f;
        frame.size.height = 320.0f;
        self.searchSuggestionsView.view.frame = frame;
        
        self.searchSuggestionsView.tabs = self;
        
        [self.view addSubview:self.searchSuggestionsView.view];
        
    }
    
    // set the searchSuggestionsView's delegate
    self.searchSuggestionsView.delegate = delegate;
    
    // search suggestions view is the searhcBar delegate
    searchBar.delegate = self.searchSuggestionsView;
    
}

- (void) hideSearchSuggestions
{
    if (self.searchSuggestionsView && self.searchSuggestionsView.view.superview)
    {
        self.searchSuggestionsView.view.hidden = YES;
    }
}

- (void) showSearchSuggestions
{
    if (self.searchSuggestionsView && self.searchSuggestionsView.view.superview)
    {
        self.searchSuggestionsView.view.hidden = NO;
    }
}

- (void) removeSearchSuggestions
{
    if (self.searchSuggestionsView)
    {
        if (self.searchSuggestionsView.view.superview)
        {
            [self.searchSuggestionsView.view removeFromSuperview];
        }
        self.searchSuggestionsView = nil;
    }
}

- (void) invokeSearchResultsWithSearchstring:searchString
{
    if (!self.searchResultsView || !self.searchResultsView.view.superview)
    {
        //Vijay -- Moved SearchResults to Tabbar which should always be visible.
        //TODO -- Instead of hard coding index to 7, loop thru viewControllers and get SearchResultsVC
        NSArray *viewControllers = self.viewControllers;
        for (int i =0 ; i< [viewControllers count]; i++) {
            if ([[viewControllers objectAtIndex:i] isKindOfClass:[SearchResultsVC class]]) {
                self.searchResultsView = [viewControllers objectAtIndex:i];
                [self setSelectedIndex:i];
               self.searchResultsView.tabs = self;
            }
        }
//        SearchResultsVC *sr = (SearchResultsVC *)[[self viewControllers] objectAtIndex:7];
//        self.searchResultsView = sr; //[self vi]; //[self.storyboard instantiateViewControllerWithIdentifier:@"SearchResultsVC"];
//        CGRect frame;
//        frame.origin.x = 20.0f;
//        frame.origin.y = 33.0f;
//        frame.size.width = 980.0f;
//        frame.size.height = 720.0f;
//        self.searchResultsView.view.frame = frame;
//        [self setSelectedIndex:7];
//        self.searchResultsView.tabs = self;
        
        //[self.view addSubview:self.searchResultsView.view];
    }
    [self.searchResultsView performSearchWithSearchstring:searchString];
    
}

- (void) removeSearchResults
{
    if (self.searchResultsView)
    {
        if (self.searchResultsView.view.superview)
        {
            [self.searchResultsView.view removeFromSuperview];
        }
        self.searchResultsView = nil;
    }
}

- (void) invokeDrawTool {
    
    if (!_drawView || !_drawView.view.superview) {
        _drawView = [[DrawVC alloc]initWithNibName:@"DrawView" bundle:nil] ;
        _drawView.view.backgroundColor = [UIColor clearColor];
        
        CGRect viewFrame = self.view.frame;
        float height = (viewFrame.size.height - self.tabBar.frame.size.height - 50);
        CGSize newSize = CGSizeMake(viewFrame.size.width, height);
        viewFrame.origin.y = 45; //50;
        viewFrame.size = newSize;
        _drawView.view.frame = viewFrame;
        [self.view addSubview:_drawView.view];
    } else {
        _drawView.mainDrawControlView.hidden = NO;
        _drawView.drawToolBoxArrowView.hidden = NO;
        [_drawView removeFromSuperView];
    }
}

///////////////
- (void) invokeDrawToolWithDelegate:(id<DrawVCDelegate>)delegate
{
    [self invokeDrawTool];
    _drawView.delegate = delegate;
}

- (void) invokeSyncWithDelegate:(id<RootVCDelegate>)delegate;
{
    _syncOptionsController.delegate1 = delegate;
}

- (IBAction)contentSyncClicked:(id)sender {
    
    if (!_contentSyncPopup)
    {
        
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:_syncOptionsController];
        
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navController];
        CustomNavigationBar *bar =[[CustomNavigationBar alloc]init];
        //[bar setBackgroundWith: [UIImage imageNamed:@""]];
        //bar.alpha = 0.7f;
        bar.tintColor = [UIColor colorWithRed:243/255.0f green:243/255.0f blue:243/255.0f alpha:1.0f];
        [navController setValue:bar forKeyPath:@"navigationBar"];
        
        _syncOptionsController.delegate = self;
        popover.delegate = self;
        popover.popoverContentSize = CGSizeMake(300.0, 300);
        _contentSyncPopup = popover;
        
        if([sender isKindOfClass: [UIBarButtonItem class]]) {
            [popover presentPopoverFromBarButtonItem: sender
                            permittedArrowDirections: UIPopoverArrowDirectionAny
                                            animated: YES ];
        } else {
            UIView* senderView = sender;
            
            [popover presentPopoverFromRect: [senderView bounds]
                                     inView: senderView
                   permittedArrowDirections: UIPopoverArrowDirectionAny
                                   animated: YES ];
        }
        
    }
    else
    {
        [_contentSyncPopup dismissPopoverAnimated: NO];
        [self popoverControllerDidDismissPopover:_contentSyncPopup];
        _contentSyncPopup = nil;
    }
}

-(void) dismisspopover
{
    [_contentSyncPopup dismissPopoverAnimated: NO];
    [self popoverControllerDidDismissPopover:_contentSyncPopup];
    _contentSyncPopup = nil;
}


- (void) popoverControllerDidDismissPopover: (UIPopoverController*) popoverController
{
    UIViewController *navigationController = popoverController.contentViewController;
    
    for (UIViewController* child in navigationController.childViewControllers) {
        if ([child isKindOfClass: [ContentSyncSchedulerViewController class]]) {
            [(ContentSyncSchedulerViewController*) child saveScheduleData];
        }
    }
    
    if ([popoverController.contentViewController isKindOfClass: [UINavigationController class]]) {
        //nslog(@"_contentSyncPopup ...... dismissed....");
        _contentSyncPopup = nil;
        [_syncOptionsController.delegate1 syncButtonStatus:NO];
        
    }
}
- (BOOL) popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}
//////////////

- (void) deleteSpecialities: (NSArray*) tempMyEntitlementsDeleteList {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSArray *myEntitlements = [[RegistrationModel sharedInstance].profile myProfileToMyEntitlement].allObjects;
    
    NSString* specialityDeletedMessage = @"";
    for (MyEntitlement* entitlement in tempMyEntitlementsDeleteList) {
        if([[DownloadManager sharedManager] specialityDeSelected: [entitlement splId]]) {
            for (MyEntitlement* profileEntitlement in myEntitlements) {
                if ([[entitlement splId] intValue] == [[profileEntitlement splId] intValue])
                profileEntitlement.status = [NSNumber numberWithInt:kEntitlementStatusDisabled];
            }
            specialityDeletedMessage = [specialityDeletedMessage stringByAppendingString:[entitlement name]];
        }
    }
    
    specialityDeletedMessage = [NSString stringWithFormat:@"Specialites [%@] are deleted",specialityDeletedMessage];
    [[[UIAlertView alloc] initWithTitle:@"Info" message:specialityDeletedMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    
    [hud hide:YES];
}

- (void) invokeContentSync {
    
    if (!_contentSyncVC || !_contentSyncVC.view.superview || !_contentSyncVC.isDownloading) {
        if (_contentSyncVC) {
            [_contentSyncVC reset];
            _contentSyncVC = nil;
        }
        
        _contentSyncVC = [[ContentSyncViewController alloc] initWithNibName:@"ContentSyncViewController" bundle:nil];
        if (_syncFromScheduler) {
            _contentSyncVC.syncFromScheduler = YES;
            _contentSyncVC.view.hidden = YES;
        }
        _contentSyncVC.view.backgroundColor = [UIColor clearColor];
        _contentSyncVC.delegate = self;
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self.view addSubview:_contentSyncVC.view];
    } else {
        _contentSyncVC.view.hidden = NO;
    }
    
    if (_contentSyncPopup) { //Close the popup when sync is in progress
        [_contentSyncPopup dismissPopoverAnimated: YES];
        [self popoverControllerDidDismissPopover:_contentSyncPopup];
        _contentSyncPopup = nil;
        
    }
}

- (void) invokeEmailQueueOverlayVCWithContent:(Content *)content
{
    if (_emailQueueOverlayVC)
        _emailQueueOverlayVC.view.hidden = NO;
    else
    {
        _emailQueueOverlayVC = [[EmailQueueOverlayViewController alloc] initWithNibName:@"EmailQueueOverlayViewController" bundle:nil];
        //_emailQueueOverlayVC.view.backgroundColor = [UIColor clearColor];
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self.view addSubview:_emailQueueOverlayVC.view];
        
        CGRect frame = _emailQueueOverlayVC.view.frame;
        
        frame.origin.x = 350.0f;
        frame.origin.y = 115.0f;
        
        _emailQueueOverlayVC.view.frame = frame;
        
    }
    _emailQueueOverlayVC.content = content;
    [_emailQueueOverlayVC reloadSurgeons];
    
    [self.view bringSubviewToFront:_emailQueueOverlayVC.view];
    
}
- (void) hideEmailQueueVC
{
    if (_emailQueueOverlayVC && _emailQueueOverlayVC.view.superview)
    {
        _emailQueueOverlayVC.view.hidden = YES;
    }
}

- (void) customizeTabs
{
    UITabBarItem *item;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil] forState:UIControlStateSelected];
        
        
        // Home
        item = [self.tabBar.items objectAtIndex:0];
        //item.selectedImage = [[UIImage imageNamed:@"home_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        item.selectedImage = [[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"home_select" ofType:@"png"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        //item.image = [[UIImage imageNamed:@"home"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        item.image = [[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"home" ofType:@"png"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        
        // Procedures
        item = [self.tabBar.items objectAtIndex:1];
        //item.selectedImage = [[UIImage imageNamed:@"procedures_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        item.selectedImage = [[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"procedures_select" ofType:@"png"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        //item.image = [[UIImage imageNamed:@"procedures"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        item.image = [[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"procedures" ofType:@"png"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        
        // Products
        item = [self.tabBar.items objectAtIndex:2];
        //item.selectedImage = [[UIImage imageNamed:@"products_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        item.selectedImage = [[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"products_select" ofType:@"png"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        //item.image = [[UIImage imageNamed:@"products"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        item.image = [[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"products" ofType:@"png"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        
        
        // Presentation
        item = [self.tabBar.items objectAtIndex:3];
        //item.selectedImage = [[UIImage imageNamed:@"presentations_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        item.selectedImage = [[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"presentations_select" ofType:@"png"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        //item.image = [[UIImage imageNamed:@"presentations"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        item.image = [[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"presentations" ofType:@"png"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        
        
        // Favorites
        item = [self.tabBar.items objectAtIndex:4];
        //item.selectedImage = [[UIImage imageNamed:@"favorites_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        item.selectedImage = [[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"favorites_select" ofType:@"png"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        //item.image = [[UIImage imageNamed:@"favorites"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        item.image = [[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"favorites" ofType:@"png"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        

        // Forms
        item = [self.tabBar.items objectAtIndex:5];
        //item.selectedImage = [[UIImage imageNamed:@"forms_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        item.selectedImage = [[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"forms_select" ofType:@"png"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

       // item.image = [[UIImage imageNamed:@"forms"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        item.image = [[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"forms" ofType:@"png"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        
        // Email
        item = [self.tabBar.items objectAtIndex:6];
        //item.selectedImage = [[UIImage imageNamed:@"email_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        item.selectedImage = [[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"email_select" ofType:@"png"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        //item.image = [[UIImage imageNamed:@"email"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        item.image = [[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"email" ofType:@"png"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        
        // Search
        item = [self.tabBar.items objectAtIndex:7];
        //item.selectedImage = [[UIImage imageNamed:@"search_results_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        item.selectedImage = [[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"search_results_select" ofType:@"png"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        //item.image = [[UIImage imageNamed:@"search_results"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        item.image = [[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"search_results" ofType:@"png"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    }
    else{
        
        
        // Home
        //[item setFinishedSelectedImage:[UIImage imageNamed:@"home_select"] withFinishedUnselectedImage:[UIImage imageNamed:@"home"]];
        [item setFinishedSelectedImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"home_select" ofType:@"png"]] withFinishedUnselectedImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"home" ofType:@"png"]]];

        
        // Procedures
        //[item setFinishedSelectedImage:[UIImage imageNamed:@"procedures_select"] withFinishedUnselectedImage:[UIImage imageNamed:@"procedures"]];
        [item setFinishedSelectedImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"procedures_select" ofType:@"png"]] withFinishedUnselectedImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"procedures" ofType:@"png"]]];

        
        // Products
        //[item setFinishedSelectedImage:[UIImage imageNamed:@"products_select"] withFinishedUnselectedImage:[UIImage imageNamed:@"products"]];
        [item setFinishedSelectedImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"products_select" ofType:@"png"]] withFinishedUnselectedImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"products" ofType:@"png"]]];

        
        // Presentation
        //[item setFinishedSelectedImage:[UIImage imageNamed:@"presentations_select"] withFinishedUnselectedImage:[UIImage imageNamed:@"presentations"]];
        [item setFinishedSelectedImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"presentations_select" ofType:@"png"]] withFinishedUnselectedImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"presentations" ofType:@"png"]]];

        
        // Favorites
        //[item setFinishedSelectedImage:[UIImage imageNamed:@"favorites_select"] withFinishedUnselectedImage:[UIImage imageNamed:@"favorites"]];
        [item setFinishedSelectedImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"favorites_select" ofType:@"png"]] withFinishedUnselectedImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"favorites" ofType:@"png"]]];

        
        // Forms
       // [item setFinishedSelectedImage:[UIImage imageNamed:@"forms_select"] withFinishedUnselectedImage:[UIImage imageNamed:@"forms"]];
        [item setFinishedSelectedImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"forms_select" ofType:@"png"]] withFinishedUnselectedImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"forms" ofType:@"png"]]];

        
        // Email
        //[item setFinishedSelectedImage:[UIImage imageNamed:@"email_select"] withFinishedUnselectedImage:[UIImage imageNamed:@"email"]];
        [item setFinishedSelectedImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"email_select" ofType:@"png"]] withFinishedUnselectedImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"email" ofType:@"png"]]];

        
        // Search
        //[item setFinishedSelectedImage:[UIImage imageNamed:@"search_results_select"] withFinishedUnselectedImage:[UIImage imageNamed:@"search_results"]];
        [item setFinishedSelectedImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"search_results_select" ofType:@"png"]] withFinishedUnselectedImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"search_results" ofType:@"png"]]];

        
    }
    
}

/**
 Once downloads are complete, refresh the products.
 */
- (void) refreshProducts {
    
    UINavigationController *navigationController = [[self viewControllers] objectAtIndex:2];
    NSArray *viewControllers = navigationController.viewControllers;
    //nslog(@"%@......",viewControllers);
    if (viewControllers && viewControllers.count > 0) {
        ProductsVC *productsVC = (ProductsVC *)viewControllers[0];
        if (productsVC) {
            ProductsVC* products = (ProductsVC*)productsVC;
            [products refreshProducts];
        }
    }
}

- (void) removeContentSync {
    
    if (_contentSyncVC) _contentSyncVC = nil;
}

@end
