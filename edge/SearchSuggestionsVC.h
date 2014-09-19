//
//  SearchSuggestionsVC.h
//  edge
//
//  Created by iPhone Developer on 7/22/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TabBarViewController;
@class PointedView;

@protocol SearchSuggestionsDelegate <NSObject>

- (void)searchBarTextDidBeginEditing;
- (void) suggestionSelected:(NSString*)suggestion;
- (void) performSearchWithSearchString:(NSString*)searchString;

@end

@interface SearchSuggestionsVC : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet PointedView *pointedView;
@property (nonatomic, strong) IBOutlet UIView *backView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, weak) id<SearchSuggestionsDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *suggestions;

@property (nonatomic, weak) TabBarViewController *tabs;

- (void) show;
- (void) hide;

@end
