//
//  BaseVC.m
//  edge
//
//  Created by iPhone Developer on 5/24/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "BaseVC.h"
#import "AppDelegate.h"
#import "UITabBarController+ShowHideBar.h"
#import "KxMenu.h"
#import "RegistrationModel.h"
#import "ResourceViewerViewController.h"
#import "ContentModel.h"
#import "Content.h"
#import "SearchSuggestionsVC.h"
#import "SearchResultsVC.h"
#import "DrawVC.h"
#import "TabBarViewController.h"
#import "DashboardModel.h"
#import "SettingsVC.h"
#import "TrackingModel.h"
#import "CustomNavigationBar.h"
#import "ContentSyncVerifier.h"
#import "MyEntitlement.h"

@interface BaseVC () <SearchSuggestionsDelegate>
@property (nonatomic, strong) KxMenuItem *currentMenuItem;
@property (nonatomic, strong) UIStoryboardPopoverSegue *currentPopoverSegue;
@property (nonatomic, strong) DrawVC *drawVC;
@property (nonatomic, strong) UIButton *drawToolBtn;
@property (nonatomic, strong) UIButton *syncBtn;
@property (nonatomic, strong) UIButton *settingsBtn;
@property (nonatomic, strong) TabBarViewController *tabs;

@property (nonatomic, strong) SettingsVC * SettingsVcont;
@property (nonatomic, readwrite) BOOL isThere;
@property (nonatomic, strong) UIPopoverController * popover;
@property (nonatomic, strong) UIPopoverController *settingsPopover;


@end

@implementation BaseVC

{
    BOOL drawToolEnabled;
    BOOL setingsEnabled;
    NSMutableArray *tempEntitlements;
    NSArray *myEntitlements;

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
	// Do any additional setup after loading the view.
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.isThere = NO;
    
    _tabs = (TabBarViewController*)self.tabBarController;
    _tabs.hasNewContentBtn = _hasNewContentBtn;
    _hasNewContentBtn.enabled = NO;

    [_hasNewContentBtn addTarget:self action:@selector(newContentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if (_hasNewContentBtn)
        [ContentSyncVerifier sharedInstance].hasNewContentBtn = _hasNewContentBtn;//works for ios 6.0
    
    
    // method working only for ios 7.0
    if ([ContentSyncVerifier sharedInstance].changeinvalue == YES)
    {
        [self.hasNewContentBtn setImage:[UIImage imageNamed:@"bulp_active.png"] forState:UIControlStateNormal];
        _hasNewContentBtn.enabled = YES;
        //nslog(@"_hasNewContentBtn.enabled is%d",_hasNewContentBtn.enabled);
    }
    // method working only for ios 7.0
    if ([ContentSyncVerifier sharedInstance].changeinvalue == NO)
    {
        [self.hasNewContentBtn setImage:[UIImage imageNamed:@"bulp_inactive.png"] forState:UIControlStateNormal];
        _hasNewContentBtn.enabled = NO;
        //nslog(@"_hasNewContentBtn.enabled is%d",_hasNewContentBtn.enabled);
    }
    
    [self addLogoToNavigationItem:self.navItem];
    [self createRightTopControls];
    [self updateRightSideControls];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars=NO;
        self.automaticallyAdjustsScrollViewInsets=NO;
        self.navigationController.navigationBar.translucent = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
    sync = [[SyncViewController alloc] init];
    _drawToolBtn.selected = YES;
    
    tempEntitlements = [[NSMutableArray alloc] init];
    myEntitlements = [[RegistrationModel sharedInstance].profile myProfileToMyEntitlement].allObjects;
    ContentSyncModel* csm = [ContentSyncModel sharedContentSync];
    csm.customTabBarViewController = (TabBarViewController*)self.tabBarController;


}

-(void)viewWillAppear:(BOOL)animated
{
    //TrackingModel will be called for analytics
    NSString *resourceString = [NSString stringWithFormat:@"%@",[[self class]description]];
    [[TrackingModel sharedInstance] createTrackingDataWithResource:resourceString activityCode:TRACKING_ACTIVITY_VIEWED_PAGE];
    //[sync unregisterForEvents];
    [self UpdateIcons];
    _drawToolBtn.selected = YES;
}

- (void) addLogoToNavigationItem:(UINavigationItem*)navItem
{
    UIImageView *logoIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ethicon_logo_root.png"]];
    logoIV.frame = CGRectMake(-18, 0, 182, 44);
    
    // add an outer view to move the image to the right
    CGRect frame = logoIV.frame;
    frame.size.width += 10.f;
    UIView *outerView = [[UIView alloc] initWithFrame:frame];
    
    // move image to right
    frame = logoIV.frame;
    frame.origin.x = -18;
    logoIV.frame = frame;
    
    [outerView addSubview:logoIV];
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:outerView];
    //[btn setTarget:self];
    //[btn setAction:@selector(logoButtonTouched:)];
    
    [navItem setLeftBarButtonItem:btn];
    
    //make button area smaller as to avoid conflict/confusion for user w/ back button and nav item button
    UIView *outerView2 = [[UIView alloc] initWithFrame:outerView.frame];
    outerView2.frame = CGRectMake(0, 0, 150, 25);
    
    UIButton *homeLogoButton = [[UIButton alloc] initWithFrame:outerView2.frame];
    [homeLogoButton addTarget:self action:@selector(logoButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [outerView addSubview:homeLogoButton];
}

-(IBAction)logoButtonTouched:(id)sender
{
    [self.tabBarController setSelectedIndex:0];
}

- (void) updateRightSideControls
{
    // container view
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 400.f, 44.f)];
    
    // search bar
    
//    if (_drawToolBtn.selected)
//    {
//        _drawToolBtn.userInteractionEnabled = NO;
//    }
//    else
        _drawToolBtn.userInteractionEnabled = YES;
    
    _searchBar.userInteractionEnabled = !_drawToolBtn.selected;
    [view addSubview:_searchBar];
    
    // draw tool button
    
    [view addSubview:_drawToolBtn];
    
    // content sync button
    _syncBtn.enabled = !_drawToolBtn.selected;
    [view addSubview:_syncBtn];
    
    // settings button
    _settingsBtn.enabled = !_drawToolBtn.selected;
    [view addSubview:_settingsBtn];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView:view];
    [_navItem setRightBarButtonItem:bbi];
    
//  if (_drawToolBtn.selected)
//  {
//      
//   }
//    else
//    {
//        _syncBtn.enabled = YES;
//        _settingsBtn.enabled = YES;
//        _drawToolBtn.enabled = YES;
//    }
    
    
}

- (void) createRightTopControls
{
    
    // search bar
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20.0f, 7.0f, 180.f, 30.f)];
    [self.searchBar setBackgroundImage:[[UIImage imageNamed:@"nav_bar_bkg"] stretchableImageWithLeftCapWidth:0 topCapHeight:0]];
    self.searchBar.userInteractionEnabled = YES;
     self.searchBar.layer.cornerRadius = 7.0f;
     self.searchBar.layer.borderColor = [UIColor colorWithRed:196.0f/255.0f green:196.0f/255.0f blue:196.0f/255.0f alpha:1].CGColor;
     self.searchBar.layer.borderWidth = 2.0f;
    
    // draw tool button
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"pencil"] forState:UIControlStateNormal];
   // [btn setImage:[UIImage imageNamed:@"pencil-select"] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(drawToolBtnTouched) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(215.f, 0.f, 63.f, 44.f);
    _drawToolBtn = btn;
    
    // content sync button
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setImage:[UIImage imageNamed:@"exchange"] forState:UIControlStateNormal];
   // [btn1 setImage:[UIImage imageNamed:@"exchange-select"] forState:UIControlStateSelected];
    [btn1 addTarget:self action:@selector(syncBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    btn1.frame = CGRectMake(280.f, 0.f, 65.f, 44.f);
    _syncBtn = btn1;
    
    // settings button
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
//    [btn2 setImage:[UIImage imageNamed:@"settings-select"] forState:UIControlStateSelected];
    [btn2 addTarget:self action:@selector(settingsBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    btn2.frame = CGRectMake(345.f, 0.f, 43.f, 44.f);
    _settingsBtn = btn2;
    
}

- (void) viewDidAppear:(BOOL)animated
{
    //nslog(@"BaseVC viewDidAppear");
    [self hookSearchSuggestions];
}

- (void) cleanupMenuViews
{
    [_tabs removeSearchSuggestions];
    [_tabs removeSearchResults];
    
    // handle draw tool
    if (_drawToolBtn.selected)
    {
        [self toggleDrawTool];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [_tabs hideEmailQueueVC];

//    //nslog(@"BaseVC viewDidDisappear");
    //[self cleanupMenuViews];
    
    [super viewWillDisappear:animated];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self cleanupMenuViews];
}

#pragma mark -

- (void) customizeScrollView:(UIScrollView*)scrollview
{
    scrollview.layer.cornerRadius = 11.0f;
    scrollview.layer.borderColor = [UIColor darkGrayColor].CGColor;
    scrollview.layer.borderWidth = 1.0f;
}

- (void) clearScrollView:(UIScrollView*)scrollView
{
    for (UIView *view in scrollView.subviews)
    {
        [view removeFromSuperview];
    }
}

- (void) openContentInContentViewer:(Content*)content
{
    // add MyRecentlyViewed
    [[DashboardModel sharedInstance] addRecentlyViewedForContent:content];
    
    ResourceViewerViewController* rviewer = [[ResourceViewerViewController alloc] initWithNibName:@"ResourceView" bundle:nil];
    NSString* targetPath = [[ContentModel sharedInstance] addAppDocumentsPathToPath:content.path];
    //targetPath = [targetPath stringByAppendingString:@"/index.html"];
    rviewer.filePath = targetPath;
    [self presentViewController:rviewer animated:NO completion:nil];
    [rviewer.webView setScalesPageToFit:YES];
    [rviewer play];
}

#pragma mark - Prepare for Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    _currentPopoverSegue = (UIStoryboardPopoverSegue *)segue;
}

#pragma mark - PopoverDismissor

- (void) dismissCurrentPopover
{
    if (_currentPopoverSegue)
    {
        [[_currentPopoverSegue popoverController] dismissPopoverAnimated: YES];
    }
    
}

#pragma mark -
#pragma mark action handling

- (IBAction) drawToolBtnTouched
{
    //nslog(@"drawToolBtnTouched");
    [self showDrawTool];
    _syncBtn.enabled = NO;
    _settingsBtn.enabled = NO;
    _drawToolBtn.enabled = YES;
    //[_drawToolBtn setImage:[UIImage imageNamed:@"pencil"] forState:UIControlStateNormal];
    [_drawToolBtn setImage:[UIImage imageNamed:@"pencil-select"] forState:UIControlStateNormal];
   self.searchBar.userInteractionEnabled = NO;
    
    if (!_drawToolBtn.selected)
    {
        // update the buttons
        [self toggleDrawTool];
        _syncBtn.enabled = YES;
        _settingsBtn.enabled = YES;
        _drawToolBtn.enabled = YES;
        self.searchBar.userInteractionEnabled = YES;
        [_drawToolBtn setImage:[UIImage imageNamed:@"pencil"] forState:UIControlStateNormal];
      
        
        [_syncBtn setImage:[UIImage imageNamed:@"exchange"] forState:UIControlStateNormal];
       
        [_settingsBtn setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
        

    }
    
}

- (IBAction) syncBtnTouched : (id) sender
{
    //    [[[UIAlertView alloc] initWithTitle:@"Information" message:@"Item not implemented." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil] show];
    //[self showContentSync];
    TabBarViewController* tab = (TabBarViewController*)self.tabBarController;
    [tab contentSyncClicked:sender];
    //[self showContentSync];
    [tab invokeSyncWithDelegate:self];
    [self syncButtonStatus:YES];
}

- (IBAction) newContentBtnClicked : (id) sender
{
    //NSString* newContentReport = [[ContentSyncVerifier sharedInstance] contentChangeReport];
    //[[[UIAlertView alloc] initWithTitle:@"Info" message:newContentReport delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    
    cmpleteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    cmpleteView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:cmpleteView];
    
    cntntUpdate = [[UIView alloc]initWithFrame:CGRectMake(110, 60, 600, 550)];
    
    cmpleteView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    cmpleteView1.backgroundColor = [UIColor blackColor];
    cmpleteView1.alpha = 0.5;
    
    [cmpleteView addSubview:cmpleteView1];
    
    
    cntntUpdate = [[UIView alloc]initWithFrame:CGRectMake(110, 60, 600, 550)];
    
    imgView = [[UIImageView alloc]initWithFrame:CGRectMake(110, 60, 600, 550)];
    imgView.image = [UIImage imageNamed:@"popup_bg@2x.png"];
    [cntntUpdate addSubview:imgView];
    [cmpleteView addSubview:cntntUpdate];
    
    
    UIButton *cancelbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelbutton setFrame:CGRectMake(135, 72, 85, 30)];
    [cancelbutton setImage:[UIImage imageNamed:@"cancel_update.png"] forState:UIControlStateNormal];
    [cancelbutton addTarget:self action:@selector(buttonMethod) forControlEvents:UIControlEventTouchUpInside];
    [cntntUpdate addSubview:cancelbutton];
    
    
    
    syncbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [syncbutton setFrame:CGRectMake(705, 620, 85, 30)];
    [syncbutton setImage:[UIImage imageNamed:@"sync_update.png"] forState:UIControlStateNormal];
    [syncbutton addTarget:self action:@selector(syncMethod:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:syncbutton];
    
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(195, 10, 200, 30)];
    textLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.text = @"Content Update List";
    textLabel.font= [UIFont fontWithName:@"Arial" size: 18.0];
    textLabel.textColor = [UIColor colorWithRed:243.0f/255.0f green:6.0f/255.0f blue:23.0f/255.0f alpha:1.0f];
    [imgView addSubview:textLabel];
    
    title = [[NSMutableArray alloc] initWithArray:[[UpdateNotify SharedManager] titlearray]];
    lstArray = [[NSMutableArray alloc] initWithArray:[[UpdateNotify SharedManager] lastArray]];
    
    
    scrllView = [[UIScrollView alloc] initWithFrame:CGRectMake(120, 120, 580, 430)];
    //scrllView.backgroundColor = [UIColor lightGrayColor];
    [scrllView setContentSize:cntntUpdate.frame.size];
    
    CGFloat y = 10;
    
    
    [cntntUpdate addSubview:scrllView];
    if (lstArray.count <= 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 500, 20)];
        label.text = @"Resume Downloads";
        [scrllView addSubview:label];
    }
    
    for (int k =0; k<[lstArray count]; k++)
    {
        y = y + 20;

        SyncedData * totObj = [lstArray objectAtIndex:k];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, y + 30, 500, 20)];
        label.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
        label.text = [NSString stringWithFormat:@"%d. %@ %@",k+1,totObj.names,@":"];
        label.font= [UIFont fontWithName:@"Arial" size: 18.0];
        label.textColor = [UIColor colorWithRed:110.0f/255.0f green:110.0f/255.0f blue:110.0f/255.0f alpha:1];
        [scrllView addSubview:label];
        y = y + 30;
        
        for (int j =0; j<[totObj.contents count]; j++)
        {
            y = y + 20;

            //nslog(@"for %@ content -- %@",totObj.names,[totObj.contents objectAtIndex:j]);
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(45, y, 550, 20)];
            label.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
            label.text = [NSString stringWithFormat:@"%@",[totObj.contents objectAtIndex:j]];
            label.textColor = [UIColor colorWithRed:110.0f/255.0f green:110.0f/255.0f blue:110.0f/255.0f alpha:1];
            label.font= [UIFont fontWithName:@"Arial" size: 15.0];
            label.numberOfLines = 0;
            [label sizeToFit];
            
            [scrllView addSubview:label];
            
            UILabel *bullet = [[UILabel alloc] initWithFrame:CGRectMake(30, y, 10, 20)];
            bullet.text = [NSString stringWithFormat:@"\u2022"];
            bullet.textColor = [UIColor colorWithRed:243.0f/255.0f green:6.0f/255.0f blue:23.0f/255.0f alpha:1.0f];
            bullet.font= [UIFont fontWithName:@"Arial" size: 18.0];
            [scrllView addSubview:bullet];
            
            y = y + label.frame.size.height+10;
        }
        y = y + 20;
    }
    
    for (int k = 0; k < [title count]; k++)
    {
        
        y = y + 20;

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25, y, 500, 20)];
        label.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
        label.text = [NSString stringWithFormat:@"%@",[title objectAtIndex:k]];
        label.textColor = [UIColor colorWithRed:110.0f/255.0f green:110.0f/255.0f blue:110.0f/255.0f alpha:1];
        label.font= [UIFont fontWithName:@"Arial" size: 15.0];
        [scrllView addSubview:label];
        label.numberOfLines = 0;
        [label sizeToFit];

        [scrllView addSubview:label];
        
        UILabel *bullet = [[UILabel alloc] initWithFrame:CGRectMake(10, y, 10, 20)];
        bullet.text = [NSString stringWithFormat:@"\u2022"];
        bullet.textColor = [UIColor colorWithRed:243.0f/255.0f green:6.0f/255.0f blue:23.0f/255.0f alpha:1.0f];
        bullet.font= [UIFont fontWithName:@"Arial" size: 18.0];
        [scrllView addSubview:bullet];
        
        y = y + label.frame.size.height;
    }
    scrllView.contentSize=CGSizeMake(120, y);
    
}

-(void) buttonMethod
{
    syncbutton.hidden = YES;
    [cmpleteView removeFromSuperview];
    
}

-(void) syncMethod:(id) sender
{
    [cmpleteView removeFromSuperview];
    syncbutton.hidden = YES;
    
    //sync.delegate = self.delegate;
    
    [[[UpdateNotify SharedManager] syncArray]removeAllObjects];
    [tempEntitlements removeAllObjects];
    
    for (int i =0; i<[myEntitlements count]; i++)
    {
        MyEntitlement* entitlement =  [myEntitlements objectAtIndex:i];
        if ([entitlement.status isEqualToNumber:[NSNumber numberWithInt:kEntitlementStatusEnabled]]) {
            [tempEntitlements addObject:entitlement]; //Add selected Specialites to get deltas
        }
        
    }
    [[UpdateNotify SharedManager] setSyncArray:tempEntitlements];
    
    sync.syncvalue1 = 1;
    
    TabBarViewController* tab = (TabBarViewController*)self.tabBarController;
    sync.delegate = tab;
    sync.hudView = tab.view;
    sync.syncFromScheduler = NO;
    [sync syncBtnClicked:sender];
}

// sync status



-(IBAction)settingsBtnTouched:(id)sender
{
    
    //[self toggleDrawTool];
    
    SettingsVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsVC"];
    vc.delegate = self;
    UINavigationController *naviCon = [[UINavigationController alloc]initWithRootViewController:vc];
    
    CustomNavigationBar *bar =[[CustomNavigationBar alloc]init];
    //[bar setBackgroundWith: [UIImage imageNamed:@""]];
    //bar.alpha = 0.7f;
    bar.tintColor = [UIColor blackColor];
    [naviCon setValue:bar forKeyPath:@"navigationBar"];
    
    self.settingsPopover = [[UIPopoverController alloc] initWithContentViewController:naviCon];
    self.settingsPopover.delegate = self;
    CGRect frame;
    if ((self.tabBarController.selectedIndex == 2) || (self.tabBarController.selectedIndex == 1))
    {
        frame = CGRectMake(980.f,0.0f, 0, 0);
    }
    else
        frame = CGRectMake(980.f,43.f, 0, 0);
    self.settingsPopover.popoverContentSize = CGSizeMake(300, 300);
    [self.settingsPopover presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    _syncBtn.enabled = NO;
    _settingsBtn.enabled = YES;
    _drawToolBtn.enabled = NO;
    [_drawToolBtn setImage:[UIImage imageNamed:@"pencil"] forState:UIControlStateNormal];
    
     [_syncBtn setImage:[UIImage imageNamed:@"exchange"] forState:UIControlStateNormal];
  
    [_settingsBtn setImage:[UIImage imageNamed:@"settings-select"] forState:UIControlStateNormal];
    
    
    
}


- (void) dismissSettingsPopover
{
    if (self.settingsPopover)
    {
        
        [self.settingsPopover dismissPopoverAnimated:YES];
        
        self.settingsPopover = nil;
        _syncBtn.enabled = YES;
        _settingsBtn.enabled = YES;
        _drawToolBtn.enabled = YES;
        [_drawToolBtn setImage:[UIImage imageNamed:@"pencil"] forState:UIControlStateNormal];
      
        
          [_syncBtn setImage:[UIImage imageNamed:@"exchange"] forState:UIControlStateNormal];
      
        [_settingsBtn setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
       
    }
    
}

- (BOOL) popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    _syncBtn.enabled = YES;
    _settingsBtn.enabled = YES;
    _drawToolBtn.enabled = YES;
    [_drawToolBtn setImage:[UIImage imageNamed:@"pencil"] forState:UIControlStateNormal];
   
    
    [_syncBtn setImage:[UIImage imageNamed:@"exchange"] forState:UIControlStateNormal];
    
    [_settingsBtn setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
    
    return YES;
   
}


#pragma mark -
#pragma mark present the draw tool

- (void) toggleDrawTool
{
    _drawToolBtn.selected = !_drawToolBtn.selected;
    
    // update the search and buttons visibility.
    [self updateRightSideControls];
    
}

- (void) showContentSync
{
    TabBarViewController* tab = (TabBarViewController*)self.tabBarController;
    [tab invokeContentSync];
}

- (void) showDrawTool
{
    TabBarViewController* tab = (TabBarViewController*)self.tabBarController;
    [tab invokeDrawToolWithDelegate:self];
}

#pragma mark RootVCDelegate
// sync status


-(void)syncButtonStatus:(BOOL)isthere
{
    if (isthere == YES)
    {
         [_drawToolBtn setImage:[UIImage imageNamed:@"pencil"] forState:UIControlStateNormal];
    
          [_syncBtn setImage:[UIImage imageNamed:@"exchange-select"] forState:UIControlStateNormal];
        [_settingsBtn setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
        _syncBtn.enabled = YES;
        _settingsBtn.enabled = NO;
        _drawToolBtn.enabled = NO;
    }
    else
    {
        [_drawToolBtn setImage:[UIImage imageNamed:@"pencil"] forState:UIControlStateNormal];
        
          [_syncBtn setImage:[UIImage imageNamed:@"exchange"] forState:UIControlStateNormal];
        [_settingsBtn setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
        _syncBtn.enabled = YES;
        _settingsBtn.enabled = YES;
        _drawToolBtn.enabled = YES;
    }
}

#pragma mark DrawVCDelegate

- (void) drawToolRemoved
{
    [self toggleDrawTool];
}

#pragma mark ContentSyncDelegate

-(void)ShowBulb
{
    [self.hasNewContentBtn setImage:[UIImage imageNamed:@"bulp_active.png"] forState:UIControlStateNormal];
    _hasNewContentBtn.enabled = YES;
}
//#pragma mark -
//#pragma mark tab controller show, then hide after delay
//
//- (void) toggleTabController
//{
//    [self.tabBarController setHidden:NO];
//    [self.tabBarController hideAfterDelay];
//}


-(void)UpdateIcons
{
    [_drawToolBtn setImage:[UIImage imageNamed:@"pencil"] forState:UIControlStateNormal];
    
    [_syncBtn setImage:[UIImage imageNamed:@"exchange"] forState:UIControlStateNormal];
    [_settingsBtn setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
    _syncBtn.enabled = YES;
    _settingsBtn.enabled = YES;
    _drawToolBtn.enabled = YES;
    self.searchBar.text = @"";
}

#pragma mark -
#pragma mark Logout button handling

- (void) doDeregister
{
    [[RegistrationModel sharedInstance] deregistration];
    [self.tabBarController performSegueWithIdentifier:@"RegistrationSegue" sender:nil];
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        [self doDeregister];
    }
}

- (void) confirmDeregister
{
    [[[UIAlertView alloc] initWithTitle:@"Confirmation Required" message:@"Are you sure you want to cancel your registration?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
}

- (IBAction) deregisterBtnTouched
{
    [self confirmDeregister];
}

#pragma mark -
#pragma mark KxMenu

- (IBAction) showMenu
{
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:@"Dashboard"
                     image:[UIImage imageNamed:@"home_icon"]
                    target:self
                    action:@selector(pushMenuItem:)
                       tag:0],
      [KxMenuItem menuItem:@"Portfolio"
                     image:[UIImage imageNamed:@"sample23"]
                    target:self
                    action:@selector(pushMenuItem:)
                       tag:1],
      [KxMenuItem menuItem:@"ARC"
                     image:[UIImage imageNamed:@"arrow-small-02"]
                    target:self
                    action:@selector(pushMenuItem:)
                       tag:2],
      [KxMenuItem menuItem:@"Presentations"
                     image:[UIImage imageNamed:@"presentation"]
                    target:self
                    action:@selector(pushMenuItem:)
                       tag:3],
      [KxMenuItem menuItem:@"Forms"
                     image:[UIImage imageNamed:@"document-seal"]
                    target:self
                    action:@selector(pushMenuItem:)
                       tag:4],
      [KxMenuItem menuItem:@"Favorites"
                     image:[UIImage imageNamed:@"28-star"]
                    target:self
                    action:@selector(pushMenuItem:)
                       tag:5],
      [KxMenuItem menuItem:@"Email"
                     image:[UIImage imageNamed:@"18-envelope"]
                    target:self
                    action:@selector(pushMenuItem:)
                       tag:6]
      ];
    
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(20.0f, 88.0f, 0.0f, 0.0f)
                 menuItems:menuItems];
}

- (void) pushMenuItem:(id)sender
{
    //self.currentMenuItem.foreColor = [UIColor whiteColor];
    
    KxMenuItem *item = (KxMenuItem*)sender;
    //item.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    //self.currentMenuItem = item;
    //[KxMenu refreshMenu];
    
    [self.tabBarController setSelectedIndex:item.tag];
}

- (UIView*) appTitleView
{
    UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edge_title.png"]];
    return view;
}

#pragma mark -
#pragma mark SearchSuggestions support

- (void) hookSearchSuggestions
{
    //nslog(@"hookSearchSuggestions");
    [_tabs becomeSearchSuggestionsDelegate:self withSearchBar:self.searchBar];
}

//- (void) createSearchSuggestions
//{
//    if (!self.searchSuggestionsVC)
//    {
//        self.searchSuggestionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchSuggestionsVC"];
//
//        // make us (the current view controller) the search suggestions delegate
//        self.searchSuggestionsVC.delegate = self;
//
//        // make the SearchSuggestionsVC the searchBar delegate
//        self.searchBar.delegate = self.searchSuggestionsVC;
//
//        // move over to under search control
//        CGRect frame = self.searchSuggestionsVC.view.frame;
//        frame.origin.x = 1024.f - 350.f; //self.view.frame.size.width - frame.size.width;
//        frame.origin.y = 88.0f;
//        frame.size.width = 350.0f;
//        frame.size.height = 360.0f;
//        self.searchSuggestionsVC.view.frame = frame;
//
//        self.searchSuggestionsVC.view.hidden = YES;
//
//        // lastly, add to view
//        [self.view addSubview:self.searchSuggestionsVC.view];
//
//    }
//
//}
//
//- (void) destroySearchSuggestions
//{
//    if (self.searchSuggestionsVC)
//    {
//        [self.searchSuggestionsVC.view removeFromSuperview];
//        self.searchSuggestionsVC = nil;
//    }
//}

#pragma mark -
#pragma mark SearchSuggestionsDelegate

- (void)searchBarTextDidBeginEditing
{
    //[self.searchResultsVC hide];
    
    [_tabs hideSearchSuggestions];
    
}

- (void) suggestionSelected:(NSString*)suggestion
{
    //    //nslog(@"suggestionSelected: %@", suggestion);
    //    if (self.searchSuggestionsVC.isBeingPresented)
    //    {
    //        [self.searchSuggestionsVC hide];
    //    }
    
    [_tabs hideSearchSuggestions];
    
    self.searchBar.text = suggestion;
    
    [self performSearchWithSearchString:suggestion];
    
}

- (void) performSearchWithSearchString:(NSString*)searchString
{
    [_searchBar resignFirstResponder];
    
    [_tabs invokeSearchResultsWithSearchstring:searchString];
    
}

#pragma mark -
#pragma mark SearchResults support

//- (void) createSearchResults
//{
//    if (!self.searchResultsVC)
//    {
//        self.searchResultsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchResultsVC"];
//
//        CGRect frame = self.searchResultsVC.view.frame;
//        frame.origin.x = 10.0f;
//        frame.origin.y = 48.0f;
//        frame.size.width = 1004.0f;
//        frame.size.height = 648.0f;
//        self.searchResultsVC.view.frame = frame;
//
//        self.searchResultsVC.view.hidden = YES;
//
//        // lastly, add to view
//        [self.view addSubview:self.searchResultsVC.view];
//    }
//}
//
//- (void) destroySearchResults
//{
//    if (self.searchResultsVC)
//    {
//        [self.searchResultsVC.view removeFromSuperview];
//        self.searchResultsVC = nil;
//    }
//}








@end
