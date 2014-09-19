//
//  BaseVC.h
//  edge
//
//  Created by iPhone Developer on 5/24/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopoverDismissor.h"
#import "RNGridMenu.h"
#import "SearchSuggestionsVC.h"
#import "DrawVC.h"
#import "SettingsVC.h"
#import "TabBarViewController.h"
#import "RootViewController.h"
#import "UpdateNotify.h"
#import "SyncViewController.h"
#import "RegistrationModel.h"
#import "MyProfile.h"
#import "SyncedData.h"
#import "DownloadManager.h"

@class AppDelegate;
@class Content;

@protocol RootVCDelegate;


#define TAG_ALERT_VIEW_HANDLE_LOCALLY    999
#define CONTENT_UNAVAILABLE_TEXT @"Assets coming soon"

@interface BaseVC : UIViewController <UISearchBarDelegate, PopoverDismissor, RNGridMenuDelegate, SearchSuggestionsDelegate, DrawVCDelegate, SettingsVCDelegate,UIPopoverControllerDelegate,RootVCDelegate>

{
    UIView *cntntUpdate;
    UIImageView *imgView;
    UIView *cmpleteView;
    UIView *cmpleteView1;
    NSMutableArray *title,*lstArray;
    UITableView *contenttable;
    UIButton *syncbutton;
    UIScrollView *scrllView,*subScrllView;
    
    SyncViewController *sync;
    DownloadManager *downloadmanagr;
    
}

@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, strong) IBOutlet UINavigationItem *navItem;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UIButton *hasNewContentBtn;
@property (strong, nonatomic) IBOutlet TabBarViewController *delegate;



- (IBAction) deregisterBtnTouched;
- (IBAction) showMenu;
- (UIView*) appTitleView;
- (void) addLogoToNavigationItem:(UINavigationItem*)navItem;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void) customizeScrollView:(UIScrollView*)scrollview;
- (void) clearScrollView:(UIScrollView*)scrollView;

- (void) openContentInContentViewer:(Content*)content;

- (IBAction) drawToolBtnTouched;
- (IBAction) syncBtnTouched;
- (IBAction) settingsBtnTouched:(id)sender;
- (void) UpdateIcons;

@end
