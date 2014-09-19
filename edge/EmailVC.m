//
//  EmailVC.m
//  edge
//
//  Created by iPhone Developer on 5/31/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "EmailVC.h"
#import "EmailDetailCell.h"
#import "EmailModel.h"
#import "Surgeon.h"
#import "ContentModel.h"
#import "EmailQueueOverlayViewController.h"
#import "SharedLink.h"
#import "AppDelegate.h"
#import "ResourceViewerViewController.h"
#import "RegistrationModel.h"
#import "TrackingModel.h"
#import "StaticTextModel.h"
#import "AppDelegate.h"

@interface EmailVC ()

@property (nonatomic, strong) NSFetchedResultsController *surgeonFRC;
@property (nonatomic, strong) NSMutableArray *surgeonArray;
@property (nonatomic, strong) NSArray *sharedLinksArray;
@property (nonatomic, strong) UIPopoverController *popOver;
@property (nonatomic, strong) Surgeon *currentSurg;

@end

@implementation EmailVC
{
    int selectedSurgeonNdx;
    BOOL isEmailSent;
    BOOL isComingFromViewer;
    BOOL isMasterCellShowingDeleteButton;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (isComingFromViewer == NO)
    {
        selectedSurgeonNdx = -1;
        _currentSurg = nil;
        isEmailSent = NO;
        [_emailButton setEnabled:NO];
        [self reloadEmail];
    }
    else
    {
        [_emailButton setEnabled:YES];
        [_masterListTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedSurgeonNdx inSection:0] animated:NO scrollPosition:0];
    }
    
    if (_masterListTableView.hidden == NO) {
        self.masterListTableView.layer.borderWidth = 2;
        self.masterListTableView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    }
    
    if (_detailListTableView.hidden == NO) {
    self.detailListTableView.layer.borderWidth = 2;
    self.detailListTableView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadEmail];

    if ([_surgeonFRC.fetchedObjects count] == 0)
    {
        //self.placeHolderView.hidden = NO;
        //self.masterListTableView.hidden = YES;
        //self.detailListTableView.hidden = YES;
    }
    else
    {
       /// self.placeHolderView.hidden = YES;
        //self.masterListTableView.hidden = NO;
        //self.detailListTableView.hidden = NO;
        
        NSIndexPath *selectedCellIndexPath;
        if (isComingFromViewer == NO)
        {
            selectedCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        }
        else{
            selectedCellIndexPath = [NSIndexPath indexPathForRow:selectedSurgeonNdx inSection:0];
        }
        [_masterListTableView selectRowAtIndexPath:selectedCellIndexPath
                                          animated:YES
                                    scrollPosition:UITableViewScrollPositionNone];
        [_masterListTableView.delegate tableView:_masterListTableView didSelectRowAtIndexPath:selectedCellIndexPath];

    }
    _masterListTableView.tag = 77777;
    _detailListTableView.tag = 88888;
    
    
    //iOS7 fix for jagged lines on seperator for grouped style tableviews on first and last cells
    //first check if tableview responds under iOS7
    if ([_masterListTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_masterListTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_detailListTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_detailListTableView setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self deleteSurgeons];
    _titleLabel.font = [UIFont fontWithName:@"StagSans-Book" size:21];
    selectedSurgeonNdx = -1;
    isComingFromViewer = NO;
    [self checkForSurgeons];

}

-(void)checkForSurgeons
{
    [self reloadEmail];

    if ([_surgeonFRC.fetchedObjects count] == 0)
    {
        
        //UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No content added to queue." message:@"Share content to continue." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
     //   [av show];
        
    }
}
-(void)deleteSurgeons
{
    [[ContentModel sharedInstance] clearUserData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)sendEmailQueue:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        NSString * emailstring = @"<html> <head> <link rel='stylesheet' type='text/css' media='all' href='http://m.eprodevbox.com/assets/email_templates/style.css' /> </head> <body> <div class='wrap'> <span class='greeting'><span style='color:black;'>Hello,</span> <br> <p>Please find the information requested via the links below.</p> </div> <div class='hr'></div> <div class='wrap'> <table> {{Products}} </table> </div> <div class='hr'></div> <div class='wrap'> <p>Please feel free to contact me directly if I can answer any questions or provide you with further information.</p> <p>Regards,</p> <span class='name'>{{First Name}} {{Last Name}} </span> <br> <br> <img src='http://m.eprodevbox.com/assets/email_templates/logo.png' /> <br> <br> </div> <div class='hr'></div> <footer> <div class='wrap'> <p class='notice'> <span>Confidentiality Notice:</span> This e-mail transmission may contain confidential or legally privileged information that is intended only for the individual or entity named in the e-mail address. If you are not the intended recipient, you are hereby notified that any disclosure, copying, distribution, or reliance upon the contents of this e-mail is strictly prohibited. If you have received this e-mail transmission in error, please reply to the sender, so that J&J can arrange for proper delivery, and then please delete the message from your inbox. </p> </div> </footer> </body></html>";
        
        emailstring = [emailstring stringByReplacingOccurrencesOfString:@"http://m.eprodevbox.com" withString:WEB_SERVICE_BASE_SERVER];
        
        
        NSString *productsstring = @"";
        
        for (int j=0; j<[_sharedLinksArray count]; j++)
        {
            SharedLink *link = [_sharedLinksArray objectAtIndex:j];
            
            if (j==0)
            {
                productsstring = @"<tr><td width='30%'><img height='82px;' width='112px;'  src='{{Product Image Path}}' alt='{{Product Name}}' /></td><td width='70%' class='product_name'><a href='{{Product Link}}'>{{Product Name}}</a></td></tr>";
                productsstring = [productsstring stringByReplacingOccurrencesOfString:@"{{Product Image Path}}" withString:[NSString stringWithFormat:@"%@.s3.amazonaws.com%@",WEB_SERVICE_BASE_SERVER,link.thumbnailImgPath]];
               
                productsstring = [productsstring stringByReplacingOccurrencesOfString:@"{{Product Link}}" withString:[NSString stringWithFormat:@"%@/public/%@",WEB_SERVICE_BASE_SERVER,link.cntId]];
                //                  productsstring = [productsstring stringByReplacingOccurrencesOfString:@"{{Product Link}}" withString:@"http://www.ethicon.com/"];
                productsstring = [productsstring stringByReplacingOccurrencesOfString:@"{{Product Name}}" withString:link.title];
            }
            else
            {
                NSString * nextimage = @"<tr><td width='30%'><img height='82px;' width='112px;' src='{{Product Image Path}}' alt='{{Product Name}}' /></td><td width='70%' class='product_name'><a href='{{Product Link}}'>{{Product Name}}</a></td></tr>";
                
            
                nextimage = [nextimage stringByReplacingOccurrencesOfString:@"{{Product Image Path}}" withString:[NSString stringWithFormat:@"%@.s3.amazonaws.com%@",WEB_SERVICE_BASE_SERVER,link.thumbnailImgPath]];
                
                NSLog(@"---imae url %@",nextimage);
                //                nextimage = [nextimage stringByReplacingOccurrencesOfString:@"{{Product Link}}" withString:@"http://www.ethicon.com/"];
                nextimage = [nextimage stringByReplacingOccurrencesOfString:@"{{Product Link}}" withString:[NSString stringWithFormat:@"%@/public/%@",WEB_SERVICE_BASE_SERVER,link.cntId]];
                nextimage = [nextimage stringByReplacingOccurrencesOfString:@"{{Product Name}}" withString:link.title];
                
                productsstring= [NSString stringWithFormat:@"%@%@",productsstring,nextimage];
            }
        }
        // emailstring = [emailstring stringByReplacingOccurrencesOfString:@"{{First Name}}" withString:_currentSurg.name];
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        
        emailstring = [emailstring stringByReplacingOccurrencesOfString:@"{{First Name}}" withString:[userDefaults objectForKey:@"firstName"]];
        emailstring = [emailstring stringByReplacingOccurrencesOfString:@"{{Last Name}}" withString:[userDefaults objectForKey:@"lastName"]];
        emailstring = [emailstring stringByReplacingOccurrencesOfString:@"{{Products}}" withString:productsstring];
        
        //<!-- <tr><td><img src='{{Product Image Path}}' alt='{{Product Name}}' /></td><td class='product_name'><a href='{{Product Link}}'>{{Product Name}}</a></td></tr> -->
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:[NSString stringWithFormat:@"Ethicon information you requested"]];
        [mailViewController setMessageBody:emailstring isHTML:YES];
        // mailViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    else
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Cannot Send Mail" message:@"No mail account setup on device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [av show];
    }
}

#pragma mark -
#pragma mark MFMailCompserViewDataSource

- (void)mailComposeController:(MFMailComposeViewController*)mailController didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    NSString *msg1;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            msg1 = @"Email was cancelled";
            isEmailSent = NO;
            break;
            
        case MFMailComposeResultSaved:
            msg1= @"Email is Saved";
            isEmailSent = NO;
            
            break;
        case MFMailComposeResultSent:
        {
            //TrackingModel will be called for analytics
            NSMutableString *resourceString = [NSMutableString stringWithString:@""];
            for (SharedLink *link in _sharedLinksArray)
            {
                NSString *tempStr = [NSString stringWithFormat:@"%@:%@", link.cntId, link.title];
                [resourceString appendString:[NSString stringWithFormat:@"%@,", tempStr]];
            }
                    
            [[TrackingModel sharedInstance] createTrackingDataWithResource:resourceString activityCode:TRACKING_ACTIVITY_SENT_EMAIL];
            //End Tracking
            
            msg1 = @"Your Email has been sent";
            
            for (SharedLink *link in _sharedLinksArray)
            {
                [[EmailModel sharedInstance] deleteSharedLink:link forSurgeon:_currentSurg];
                
            }
            
            NSMutableArray *mutableLinks = [NSMutableArray arrayWithArray:_sharedLinksArray];
            [mutableLinks removeAllObjects];
            _sharedLinksArray = [NSArray arrayWithArray:mutableLinks];
            isEmailSent = YES;
            _detailOverlayView.hidden = NO;
//            _alertImageView.hidden= NO;
            [self.detailListTableView reloadData];
            self.detailListTableView.hidden = NO;
            [_emailButton setEnabled:NO];
            
            break;
        }
            
        case MFMailComposeResultFailed:
            msg1 = @"Message sending failed";
            isEmailSent = NO;
            
            break;
        default:
            msg1 = @"Your Mail is not Sent";
            isEmailSent = NO;
            
            break;
    }
    UIAlertView *mailResuletAlert = [[UIAlertView alloc]initWithFrame:CGRectMake(10, 170, 300, 120)];
    mailResuletAlert.message=msg1;
    mailResuletAlert.title = @"Mail Results";
    [mailResuletAlert addButtonWithTitle:@"OK"];
    [mailResuletAlert show];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int retValue = MINIMUM_ROW_COUNT;
    self.masterListTableView.hidden = NO;
    //self.placeHolderView.hidden = YES;
    
    if (tableView == self.masterListTableView)
    {
        if ([_surgeonFRC.fetchedObjects count] < retValue && [_surgeonFRC.fetchedObjects count] != 0)
        {
            retValue =  MINIMUM_ROW_COUNT;
            //[_masterListTableView setScrollEnabled:NO];

        }
        else if ([_surgeonFRC.fetchedObjects count] == 0)
        {
            //self.placeHolderView.hidden = NO;
        }
        else
        {
            retValue = [_surgeonFRC.fetchedObjects count];
            //[_masterListTableView setScrollEnabled:YES];

        }
        
        if ([_surgeonFRC.fetchedObjects count] <= 13)
        {
            //[_masterListTableView setScrollEnabled:NO];

        }
        else
        {
            [_masterListTableView setScrollEnabled:YES];

        }
    }
    else if (tableView == self.detailListTableView)
    {
        [_emailButton setEnabled:NO];
        
        if (selectedSurgeonNdx != -1)
        {
            if (_sharedLinksArray)
            {                
                if ([_sharedLinksArray count] >= 13)
                {
                    retValue = _sharedLinksArray.count;
                    [_emailButton setEnabled:YES];
                    _detailOverlayView.hidden = YES;
                }
                else
                {
                    retValue = _sharedLinksArray.count;
                    
                    if (retValue  == 0 && _currentSurg.name != nil && isEmailSent == NO)
                    {
                        _detailOverlayView.hidden = NO;
                    }
                    else
                    {
                        [_emailButton setEnabled:YES];
                        retValue = MINIMUM_ROW_COUNT;
                    }
                }
            }
        }
        else if (selectedSurgeonNdx == -1)
        {
            _detailOverlayView.hidden = NO;
        }
    }
    else if (tableView == self.popOverTableView)
    {
        retValue = [_surgeonFRC.fetchedObjects count];
    }
    
    isEmailSent = NO;
    return retValue;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView.tag == 77777 && [_surgeonFRC.fetchedObjects count] <= 13)
    {
        int cellHeight = 41;
        *targetContentOffset = CGPointMake(targetContentOffset->x,
                                           targetContentOffset->y - (((int)targetContentOffset->y) % cellHeight));
    }
    else if (scrollView.tag == 88888 && [_sharedLinksArray count] <= 13)
    {
        int cellHeight = 100;
        *targetContentOffset = CGPointMake(targetContentOffset->x,
                                           targetContentOffset->y - (((int)targetContentOffset->y) % cellHeight));

    }
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    static NSString *dummyCellIdentifier = @"DummyCell";
    static NSString *detailCellIdentifier = @"DetailCell";
    static NSString *detailDummyCellIdentifier = @"DetailDummyCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if (tableView == self.masterListTableView)
    {
        if (indexPath.row < [_surgeonFRC.fetchedObjects count])
        {
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            //cell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
            //cell.selectedBackgroundView.backgroundColor =[UIColor lightGrayColor];

            Surgeon *surg;
            surg = [_surgeonFRC.fetchedObjects objectAtIndex:indexPath.row];
            NSString *tempString = surg.name;
            cell.textLabel.text = tempString;
            cell.textLabel.font = [UIFont systemFontOfSize:18.0];
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            isMasterCellShowingDeleteButton = NO;

            if ([_currentSurg isEqual:surg]) {
                [cell setSelected:YES];
            }
            return cell;
        }
        else
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:dummyCellIdentifier];
            cell.editing = NO;
            [cell setUserInteractionEnabled:NO];
            return cell;
        }
    }
    else if (tableView == self.detailListTableView)
    {
        EmailDetailCell *cell = (EmailDetailCell*)[tableView dequeueReusableCellWithIdentifier:detailCellIdentifier];
        
        if ([_sharedLinksArray count] > 0)
        {
           // _alertImageView.hidden = NO;
            if (indexPath.row < [_sharedLinksArray count])
            {
                [cell setUserInteractionEnabled:YES];
                SharedLink *link;
                link = [_sharedLinksArray objectAtIndex:indexPath.row];
                
                cell.titleLabel.text = link.title;
                cell.dateLabel.text = [self.appDelegate.dateFormatter stringFromDate:link.crtDt];
                
                //thumbnail path
                NSString *comString = [NSString stringWithFormat:@"%@", link.thumbnailImgPath];
                if ([comString isEqualToString:@""])
                {
                    cell.imageView.image = [UIImage imageNamed:@"noassets.png"];
                    
                }
                else
                {
                    cell.imageView.image = [self.appDelegate loadImage:comString];
                }
                //cell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
                //cell.selectedBackgroundView.backgroundColor =[UIColor lightGrayColor];
                ////nslog(@"SharedLinksArray count in cellForRow = %lu", (unsigned long)[_sharedLinksArray count]);

            }
            else
            {
//                _alertImageView.hidden = YES;
                _detailOverlayView.hidden = YES;
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:detailDummyCellIdentifier];
                [cell setUserInteractionEnabled:NO];
                return cell;
            }
        }
        else{
            [cell setUserInteractionEnabled:NO];
        }
        return cell;
    }
    else if (tableView == self.popOverTableView)
    {
        cell.textLabel.text=[NSString stringWithFormat:@"Row number %d",indexPath.row];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (_masterListTableView == tableView && [_surgeonFRC.fetchedObjects count] -1 >= indexPath.row)
    {
        if ([_masterListTableView isEditing])
        {
            isMasterCellShowingDeleteButton = YES;
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.textLabel.textAlignment = NSTextAlignmentRight;
        }
        else
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
        }
        
    return YES;
    }
    else
    {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Surgeon *surg = [_surgeonFRC.fetchedObjects objectAtIndex:indexPath.row];
        [[EmailModel sharedInstance] deleteSurgeon:surg];
        [_emailButton setEnabled:NO];
        selectedSurgeonNdx  = -1;
        
        NSMutableArray *mutableLinks = [NSMutableArray arrayWithArray:_sharedLinksArray];
        [mutableLinks removeAllObjects];
        
        _sharedLinksArray = [NSArray arrayWithArray:mutableLinks];
        
        [self.detailListTableView reloadData];
    }
    
    //[self reloadEmail];
    [self checkForSurgeons];
    /*
    if ([_surgeonFRC.fetchedObjects count] == 0)
    {
        //self.placeHolderView.hidden = NO;
        //self.masterListTableView.hidden = YES;
        //self.detailListTableView.hidden = YES;
    }
    else
    {
        //self.placeHolderView.hidden = YES;
        //self.masterListTableView.hidden = NO;
        //self.detailListTableView.hidden = NO;
    }
*/
}

#pragma mark -
#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    _detailOverlayView.hidden = YES;
//    if ([_sharedLinksArray count]>0) {
//    _alertImageView.hidden = YES;
//    }
//    else{
//        _alertImageView.hidden = NO;
//    }
    if (tableView == self.masterListTableView)
    {
        selectedSurgeonNdx = indexPath.row;
        Surgeon *surg = [_surgeonFRC.fetchedObjects objectAtIndex:indexPath.row];
        
        _sharedLinksArray = [surg.surgeonToSharedLink allObjects];
        
        [_emailButton setEnabled:YES];
        
        _currentSurg = surg;
    }
    else
    {
        SharedLink *link;
        link = [_sharedLinksArray objectAtIndex:indexPath.row];
        
        ///get path and setup resource viewer
        NSString* targetPath = [[ContentModel sharedInstance] addAppDocumentsPathToPath:link.path];
        
        switch ([link.contentCatId intValue])
        {
            case kSpecialtyMessage:
            case kProcedureMessage:
            case kProductMessage:
            case kProductClinicalMessage:
            case kProductNonClinicalMessage:
               // targetPath = [targetPath stringByAppendingString:@"/index.html"];
                break;
            default:
                break;
        }
//        if (![_alertImageView isHidden]) {
        ResourceViewerViewController* rviewer = [[ResourceViewerViewController alloc] initWithNibName:@"ResourceView" bundle:nil];
        rviewer.filePath = targetPath;
        [self presentViewController:rviewer animated:NO completion:nil];
        [rviewer play];
        isComingFromViewer = YES;
//        }
    }
    
    [self.detailListTableView reloadData];
}

#pragma mark -
#pragma mark Handler Methods

-(void)reloadEmail
{
    _surgeonFRC = [[EmailModel sharedInstance] surgeonWithLinks];
    
    [self.masterListTableView reloadData];
    if ([_surgeonFRC.fetchedObjects count]>0)
    {
        if (selectedSurgeonNdx >0)
        {
             Surgeon *surg = [_surgeonFRC.fetchedObjects objectAtIndex:selectedSurgeonNdx];
            NSMutableArray *mutableLinks = [NSMutableArray arrayWithArray:_sharedLinksArray];
            [mutableLinks removeAllObjects];
            
            _sharedLinksArray = [NSArray arrayWithArray:mutableLinks];

          
            _sharedLinksArray = [surg.surgeonToSharedLink allObjects];
        }
        else
        {
            Surgeon *surg = [_surgeonFRC.fetchedObjects objectAtIndex:0];
            
            NSMutableArray *mutableLinks = [NSMutableArray arrayWithArray:_sharedLinksArray];
            [mutableLinks removeAllObjects];
            
            _sharedLinksArray = [NSArray arrayWithArray:mutableLinks];

            
            _sharedLinksArray = [surg.surgeonToSharedLink allObjects];
        }
        
        [self.detailListTableView reloadData];
    }
    
    
}

- (IBAction)handleDeleteLinkForSurgeon:(id)sender
{
    ////nslog(@"Shared links array count in deleteLink = %lu", (unsigned long)[_sharedLinksArray count]);
    UIButton *btn = (UIButton *)sender;
    
    EmailDetailCell *cell = (EmailDetailCell *)[[[btn superview] superview] superview];
    
    NSIndexPath *indexPath = [self.detailListTableView indexPathForCell:cell];
    
    ////nslog(@"Index path = %ld", (long)indexPath.row);

    SharedLink *link = [_sharedLinksArray objectAtIndex:indexPath.row];
    ////nslog(@"Link in EMAILVC = %@", link.title);
    

    [[EmailModel sharedInstance] deleteSharedLink:link forSurgeon:_currentSurg];
    NSMutableArray *mutableLinks = [NSMutableArray arrayWithArray:_sharedLinksArray];
    [mutableLinks removeObjectAtIndex:indexPath.row];
    
    _sharedLinksArray = [NSArray arrayWithArray:mutableLinks];

    [self.detailListTableView reloadData];
    //[self.appDelegate saveContext];
}

@end