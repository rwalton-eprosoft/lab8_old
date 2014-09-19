//
//  SelectorVC.m
//  edge
//
//  Created by iPhone Developer on 6/13/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "SelectorPopoverVC.h"

@interface SelectorPopoverVC ()

@end

@implementation SelectorPopoverVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = _popoverTitle;
     
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BasicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [_items objectAtIndex:indexPath.row];
    
    if (indexPath.row == _selectedItemIndex)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectorDelegate)
    {
        [_selectorDelegate itemSelectedWithIndex:indexPath.row tag:_tag];
    }
    [self cancelBtnTouched];
}

- (IBAction) cancelBtnTouched
{
    if (_popoverDelegate)
    {
        [_popoverDelegate dismissCurrentPopover];
    }
}


@end
