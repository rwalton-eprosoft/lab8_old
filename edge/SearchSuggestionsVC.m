//
//  SearchSuggestionsVC.m
//  edge
//
//  Created by iPhone Developer on 7/22/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "SearchSuggestionsVC.h"
#import "AppDelegate.h"
#import "ContentModel.h"
#import "TabBarViewController.h"
#import "PointedView.h"
#import "TrackingModel.h"

@interface SearchSuggestionsVC ()

@end

@implementation SearchSuggestionsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.hidden = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    self.backView.layer.cornerRadius = 10.f;
     self.backView.layer.borderColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0f].CGColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark public

- (void) show
{
    //nslog(@"SearchSuggestionsVC show");
    if (self.view.hidden)
    {
        self.view.hidden = NO;
    }

    //[_tabs showSearchSuggestions];
}

- (void) hide
{
    //nslog(@"SearchSuggestionsVC hide");
    if (!self.view.hidden)
    {
        self.view.hidden = YES;
    }
    
    //[_tabs hideSearchSuggestions];
}

#pragma mark - 
#pragma mark private

- (void) backgroundSuggestionSearchWithSearchString:(NSString*)searchString
{
    self.suggestions = [NSMutableArray arrayWithArray:[[ContentModel sharedInstance] suggestionsSearchWithSearchString:searchString]];

    //nslog(@"suggestions:%@",self.suggestions);
    if (self.suggestions.count > 0)
    {
        [self show];
        [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:NO];
    } else{
        [self hide];
    }
}

- (void) refreshTable
{
    for (int i = 0 ; i < self.suggestions.count; i++) {
        NSString *text = [self.suggestions objectAtIndex:i];
        NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"] ;
        if ([text rangeOfCharacterFromSet:set].location != NSNotFound) {
            [self.suggestions  removeObjectAtIndex:i];
        }
    }
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int nRows = 0;
    
    if (self.suggestions)
    {
        nRows = self.suggestions.count;
    }
    
    //nslog(@"suggestions: %d", nRows);
    
    
    return nRows;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BasicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *text = [self.suggestions objectAtIndex:indexPath.row];
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    cell.textLabel.text = text;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *suggestion = [self.suggestions objectAtIndex:indexPath.row];
    
    [self hide];
    
    [[TrackingModel sharedInstance] createTrackingDataWithResource:suggestion activityCode:TRACKING_ACTIVITY_USED_SEARCH];

    [self.delegate suggestionSelected:suggestion];
}

#pragma mark -
#pragma mark UISearchBarDelegate

// called when text starts editing
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setText:@""];
    if (self.delegate)
    {
        [self.delegate searchBarTextDidBeginEditing];
    }
}

// called when text ends editing
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self hide];
}

// called when text changes (including clear)
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSRange whiteSpaceRange = [searchText rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if (searchText.length > MINIMUM_SEARCH_STRING_LENGTH && whiteSpaceRange.location == NSNotFound )
    {
        //[self performSelectorInBackground:@selector(backgroundSuggestionSearchWithSearchString:) withObject:searchText];
        [self performSelector:@selector(backgroundSuggestionSearchWithSearchString:) withObject:searchText];
        
        //[self show];

    }
    else
    {
        self.suggestions = nil;
        [self refreshTable];
        
        [self hide];
    }
    
}

// called when keyboard search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self hide];
    
    if (self.delegate)
    {
        [[TrackingModel sharedInstance] createTrackingDataWithResource:searchBar.text activityCode:TRACKING_ACTIVITY_USED_SEARCH];

        [self.delegate performSearchWithSearchString:searchBar.text];
        
    }

}

@end
