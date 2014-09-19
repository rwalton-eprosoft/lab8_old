//
//  ProcPickVC.m
//  edge
//
//  Created by Ryan G Walton on 9/16/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import "ProcPickVC.h"
#import "Speciality.h"

@interface ProcPickVC ()

@end

@implementation ProcPickVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // // Custom initialization
        
        //Initialize the array
        _proceduresMutableArray = [NSMutableArray array];
        
        //Set up the array
        NSArray *procedures = [[[[DashboardModel sharedInstance] currentSpeciality] specialityToProcedure] allObjects];
        
        for (Procedure *procedure in procedures)
        {
            [_proceduresMutableArray addObject:procedure];
        }
        
        //sort alphabetically
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        [_proceduresMutableArray sortUsingDescriptors:[NSArray arrayWithObject:sort]];
        
        //Make row selections persist/or not.
        //self.clearsSelectionOnViewWillAppear = NO;
        
        //Calculate how tall the view should be by multiplying the individual row height by the total number of rows.
        NSInteger rowsCount = [_proceduresMutableArray count];
        
        NSInteger singleRowHeight = [self.tableView.delegate tableView:self.tableView
                                               heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        NSInteger totalRowsHeight = rowsCount * singleRowHeight;
        
        //Calculate how wide the view should be by finding how wide each string is expected to be
        CGFloat largestLabelWidth = 0;
        
        for   (Procedure *procedure in procedures)
        {
            //Check size of text using our app font for UITableViewCell's textLabel.
            CGSize labelSize = [procedure.name sizeWithFont:[UIFont fontWithName:@"Arial" size:21]];
            
            if (labelSize.width > largestLabelWidth) {
                largestLabelWidth = labelSize.width;
            }
        }
        
        //Add a little padding to the width
        CGFloat popoverWidth = largestLabelWidth + 100;
        
        //Set the property to tell the popover container how big this view will be.
        self.contentSizeForViewInPopover = CGSizeMake(popoverWidth, totalRowsHeight);
        
        NSLog(@"Total rows height = %ld", (long)totalRowsHeight);
        NSLog(@"table height = %f", self.tableView.frame.size.height);
        

    }
    return self;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self setContentSizeForViewInPopover:self.tableView.contentSize];
}

- (void)dealloc
{
    [self.tableView removeObserver:self forKeyPath:@"contentSize"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    _tableView.backgroundColor = [UIColor redColor];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
     }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_proceduresMutableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView setScrollEnabled:NO];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [[_proceduresMutableArray objectAtIndex:indexPath.row] name];
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:21];
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.highlightedTextColor = [UIColor redColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Procedure *selectedProc = [_proceduresMutableArray objectAtIndex:indexPath.row];
    
    //Notify the delegate if it exists.
    if (_delegate != nil)
    {
        [_delegate selectedProcedure:selectedProc];
    }
}

@end
