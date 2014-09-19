//
//  TabBarViewController.h
//  edge
//
//  Created by Vijaykumar on 7/11/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@protocol DrawVCDelegate;


@protocol SearchSuggestionsDelegate;

@protocol RootVCDelegate;
@class RootViewController;
@class DrawVC;
@class ContentSyncViewController;
@class SearchSuggestionsVC;
@class SearchResultsVC;
@class Content;
@class EmailQueueOverlayViewController;



@interface TabBarViewController : UITabBarController <UITabBarControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, retain) SearchSuggestionsVC *searchSuggestionsView;
@property (nonatomic, retain) SearchResultsVC *searchResultsView;
@property (nonatomic, retain) EmailQueueOverlayViewController *emailQueueOverlayVC;
@property (nonatomic, retain) DrawVC *drawView;
@property (nonatomic, retain) ContentSyncViewController* contentSyncVC;
@property (nonatomic, assign) int previousTabItem;
@property (atomic, retain) UIPopoverController* contentSyncPopup;
@property (nonatomic, retain) IBOutlet UIButton *hasNewContentBtn;
@property (nonatomic, retain) IBOutlet  UIActivityIndicatorView *progress;

@property (nonatomic ,retain)  RootViewController *syncOptionsController;

@property (nonatomic , assign)  BOOL syncFromScheduler;

- (void) becomeSearchSuggestionsDelegate:(id<SearchSuggestionsDelegate>)delegate withSearchBar:(UISearchBar*)searchBar;
- (void) hideSearchSuggestions;
- (void) showSearchSuggestions;
- (void) removeSearchSuggestions;
- (void) invokeSearchResultsWithSearchstring:searchString;
- (void) removeSearchResults;


- (void) invokeDrawTool;
- (void) invokeDrawToolWithDelegate:(id<DrawVCDelegate>)delegate;
- (void) invokeSyncWithDelegate:(id<RootVCDelegate>)delegate;

- (void) invokeContentSync;
- (void) invokeEmailQueueOverlayVCWithContent:(Content *)content;
- (void) hideEmailQueueVC;
- (void) dismisspopover;

- (IBAction)contentSyncClicked:(id)sender;
- (void) deleteSpecialities: (NSArray*) tempMyEntitlementsDeleteList;
- (void) refreshProducts;
- (void) removeContentSync;
- (void) showActivityIndicator;
- (void) hideActivityIndicator;

@end
