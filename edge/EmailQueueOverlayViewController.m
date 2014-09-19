//
//  EmailQueueOverlayViewController.m
//  edge
//
//  Created by Ryan G Walton on 8/8/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "EmailQueueOverlayViewController.h"
#import "Surgeon.h"
#import "EmailModel.h"
#import "TrackingModel.h"

@interface EmailQueueOverlayViewController ()

@property (nonatomic, strong) NSFetchedResultsController *surgeonFRC;

@end

@implementation EmailQueueOverlayViewController

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
    
    self.view.layer.borderColor = [UIColor blackColor].CGColor;
    self.view.layer.borderWidth = 5.0f;
    self.view.layer.cornerRadius = 5;
    self.view.layer.masksToBounds = YES;
    
    [self reloadSurgeons];
    if (self.addSurgeonTextField.text.length == 0)
    {
        [self.addNewSurgeonButton setEnabled:NO];
    }
    [self.queueButton setHidden:YES];
    _addSurgeonTextField.clearButtonMode = UITextFieldViewModeWhileEditing;

    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
    {
        // iOS 8 logic
        //move tool bar items to correct locations
        _cancelButton.frame = CGRectMake(_cancelButton.frame.origin.x, _cancelButton.frame.origin.y +200, _cancelButton.frame.size.width, _cancelButton.frame.size.height);
        _addSurgeonTextField.autocorrectionType = UITextAutocorrectionTypeNo;

    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    [super viewWillDisappear:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int retValue = 0;
    
    retValue = [_surgeonFRC.fetchedObjects count];
    
    return retValue;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Surgeon *surg;
    surg = [_surgeonFRC.fetchedObjects objectAtIndex:indexPath.row];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    //cell.selectedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"email_sdbar_red_bkg"]];
    cell.selectedBackgroundView.backgroundColor =[UIColor lightGrayColor];
    NSString *tempString = surg.name;
    cell.textLabel.text = tempString;
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
    if ([_addSurgeonTextField isFirstResponder])
    {
        [_addSurgeonTextField resignFirstResponder];
    }
    
    [self.queueButton setHidden:NO];
    _surgeonIndexPath = indexPath;
    
}
#pragma mark - UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
// return NO to disallow editing.
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [_surgeonTableView deselectRowAtIndexPath:[_surgeonTableView indexPathForSelectedRow] animated:YES];
    [self.queueButton setHidden:YES];
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *testString = [_addSurgeonTextField.text stringByReplacingCharactersInRange:range withString:string];
    testString = [testString stringByTrimmingCharactersInSet:
                  [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if( testString.length)
        _addNewSurgeonButton.enabled = YES;
    else
        _addNewSurgeonButton.enabled = NO;
    return  YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    _addNewSurgeonButton.enabled = NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // called when 'return' key pressed. return NO to ignore.
    return YES;
}

-(void)reloadSurgeons
{
    _surgeonFRC = [[EmailModel sharedInstance] surgeonWithLinks];
    
    [self.surgeonTableView reloadData];
}

- (IBAction)cancelButtonTouched:(id)sender
{
    ////nslog(@"Cancel Button Touched");

    self.view.hidden = YES;
    _queueButton.hidden = YES;

    [self.view endEditing:YES];
}

- (IBAction)queueButtonTouched:(id)sender
{
    /*
    //nslog(@"Queue Button Touched");
    Surgeon *surg = [_surgeonFRC.fetchedObjects objectAtIndex:_surgeonIndexPath.row];
    [[EmailModel sharedInstance] createSharedLinkWithContent:_content forSugeon:surg];

    _queueButton.hidden = YES;
    [self reloadSurgeons];
*/
    
    ////nslog(@"Queue Button Touched");
    
    Surgeon *surg = [_surgeonFRC.fetchedObjects objectAtIndex:_surgeonIndexPath.row];
    
    [[EmailModel sharedInstance] createSharedLinkWithContent:_content forSugeon:surg];
    
    _queueButton.hidden = YES;
    [self reloadSurgeons];
    self.view.hidden = YES;
    _queueButton.hidden = YES;
    
    [self.view endEditing:YES];

}

- (IBAction)addNewSurgeonBtnTapped:(id)sender
{
    ////nslog(@"New Surgeon Button Touched");
    
    NSString *name = self.addSurgeonTextField.text;
    
    [[EmailModel sharedInstance] addSurgeonWithName:name];
    
    _addSurgeonTextField.text = nil;
    [_addNewSurgeonButton setEnabled:NO];
    
    //TrackingModel will be called for analytics
    NSString *resourceString = [NSString stringWithFormat:@"%@", name];
    [[TrackingModel sharedInstance] createTrackingDataWithResource:resourceString activityCode:TRACKING_ACTIVITY_ADDED_SURGEON];
    
    
    [self reloadSurgeons];
}

@end