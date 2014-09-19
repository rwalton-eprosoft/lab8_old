//
//  ProductDetailVC.m
//  edge
//
//  Created by iPhone Developer on 5/24/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "ProductDetailVC.h"
#import "AppDelegate.h"
#import "Product.h"
#import "Content.h"
#import "DashboardModel.h"
#import "DashboardVC.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ContentViewerVC.h"
#import "MessageContentCell.h"
#import "ContentModel.h"
#import "ResourceViewerViewController.h"
#import "FavoritesModel.h"
#import "UIImage+OverlayImage.h"
#import "UIImage+Resize.h"
#import "TabBarViewController.h"
#import "ProcedureModel.h"
#import "DashboardModel.h"
#import "Procedure.h"
#import "SCViewController.h"
#import "ProductDetailCVCell.h"
#import "ImageScrollViewController.h"
#import "ProcedureVC.h"
#import "ProductsVC.h"
#import "PrivacyPolicyVC.h"
#import "InteractiveViewerModel.h"
#import "TrackingModel.h"
#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]

@interface ProductDetailVC ()
@property (nonatomic, strong) NSArray *productImagesContents;
@property (nonatomic, strong) NSArray *contentAreaContents;
@property (nonatomic, strong) NSArray *dashboardItems;
@property (nonatomic, strong) NSArray *clinicalMessageContents;
@property (nonatomic, strong) NSArray *economicalMessageContents;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) Content *selectedContent;
@property (nonatomic, strong) DashboardItem *longPressDashboardItem;
@property (nonatomic, strong) NSFetchedResultsController *favoritesFRC;
@property (nonatomic, strong) NSDictionary *extendedAttribsDict;
@property (nonatomic, strong) UILabel *noContentLabel;

@end

@implementation ProductDetailVC

{
    int productImageNdx;
    int messageTypeNdx;
    int contentTypeNdx;
    BOOL pageControlBeingUsed;
    NSString * contentStringList;
    BOOL enableExtendedMetaData;
    BOOL isFromProcFlowToViewer;
    BOOL isComingThroughProcedure;
    
}
@synthesize refernceView;
@synthesize RefernceWebview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) customizeView:(UIView*)view
{
    view.layer.cornerRadius = 8.0f;
    view.layer.borderWidth = 1.f;
    view.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (IBAction)privacyPolicyTouched:(id)sender
{
    PrivacyPolicyVC *vc = [[PrivacyPolicyVC alloc] initWithNibName:@"PrivacyPolicyVC" bundle:nil];
    
    //    PrivacyPolicyVC *vc = (PrivacyPolicyVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"PrivacyID"];
    vc.istypeof = @"SPLIV";
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)interactiveViewerButtonTouched:(id)sender
{
    if (isComingThroughProcedure)
    {
        isFromProcFlowToViewer = YES;
    }
    
    @autoreleasepool {
        
        ////nslog(@"InteractiveViewerModel = %@", [[InteractiveViewerModel sharedInstance] fetchProductIV:[NSNumber numberWithInt:4] withTarget: [NSNumber numberWithInt:1] :[NSNumber numberWithInt:1]]);
        
        NSArray *array;
        //array = [[InteractiveViewerModel sharedInstance] fetchProductIV:[NSNumber numberWithInt:21] withTarget: [NSNumber numberWithInt:2] :[NSNumber numberWithInt:1]];
        //array = [[InteractiveViewerModel sharedInstance] fetchProductIV:[NSNumber numberWithInt:[[DashboardModel sharedInstance] currentProduct] withTarget: [NSNumber numberWithInt:2] :[NSNumber numberWithInt:1]];
        int customerType = ([[DashboardModel sharedInstance] currentCustomerType]? [[DashboardModel sharedInstance] currentCustomerType] :0);
        int procId       = ([[[DashboardModel sharedInstance] currentProcedure].procId intValue] > 0 ? [[[DashboardModel sharedInstance] currentProcedure].procId intValue]: 0);
        
        array = [[InteractiveViewerModel sharedInstance] fetchProductIV:[[DashboardModel sharedInstance] currentProduct].prodId withTarget: [NSNumber numberWithInt:(customerType < 10? customerType: 0)] :[NSNumber numberWithInt:procId]];
        
        //array = [[InteractiveViewerModel sharedInstance] fetchProcedureIV:[[DashboardModel sharedInstance] currentProcedure].procId withTarget: [NSNumber numberWithInt:[[DashboardModel sharedInstance] currentCustomerType]]];
        
        if ([array count] > 0)
        {
            NSString *str = [array objectAtIndex:0];
            str = [[ContentModel sharedInstance] addAppDocumentsPathToPath:str];
            ///get path and setup resource viewer
            if ([[str pathExtension] isEqual: @""]) {
                str = [NSString stringWithFormat:@"%@", str];
            }
            NSString* targetPath = str;
            ResourceViewerViewController* rviewer = [[ResourceViewerViewController alloc] initWithNibName:@"ResourceView" bundle:nil];
            rviewer.filePath = targetPath;
            
            ///Traverse string to get cntid
            NSString *totalString = str;
            NSRange urlStart = [totalString rangeOfString: @"productiv/"];
            NSRange urlEnd = [totalString rangeOfString: @"_index"];
            NSRange resultedMatch = NSMakeRange(urlStart.location, urlEnd.location - urlStart.location + urlEnd.length);
            NSString *linkString = [totalString substringWithRange:resultedMatch];
            
            NSString *totalString2 = linkString;
            NSRange urlStart2 = [totalString2 rangeOfString: @"/"];
            NSRange urlEnd2 = [totalString2 rangeOfString: @"_"];
            NSRange resultedMatch2 = NSMakeRange(urlStart2.location, urlEnd2.location - urlStart2.location + urlEnd2.length);
            NSString *linkString2 = [totalString2 substringWithRange:resultedMatch2];
            
            NSString *stringWithoutSpaces = [linkString2
                                             stringByReplacingOccurrencesOfString:@"/" withString:@""];
            NSString *finalStringWithCntID = [stringWithoutSpaces
                                              stringByReplacingOccurrencesOfString:@"_" withString:@""];
            
            //NSLog(@"Final string content id = %@", finalStringWithCntID);
            ///
            
            NSString *tempStr = [NSString stringWithFormat:@"%@:%@", finalStringWithCntID, _product.name];
            
            [[TrackingModel sharedInstance] createTrackingDataWithResource:tempStr activityCode:TRACKING_ACTIVITY_VIEWED_PRODUCT_INTERACTIVE_VIEWER_ASSET];

            
            [self presentViewController:rviewer animated:NO completion:nil];
            
            [rviewer play];
            rviewer = nil;
        }
        else
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Interactive Viewer Touched but no content" message:[NSString stringWithFormat:@"For specialty %@", [[DashboardModel sharedInstance] currentProduct].name] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [av show];
        }
    }
}

- (void)viewDidLoad
{
    @autoreleasepool {
        
        
        self.navItem = self.navigationItem;
        self.refernceView.hidden = YES;
        [super viewDidLoad];
        _topProductNameLbl.font = [UIFont fontWithName:@"StagSans-Book" size:21];
        
        // Do any additional setup after loading the view.
        
        // customize UI controls
        [self customizeView:_imagesAreaView];
        //[self customizeView:_productDescAreaView];
        [self customizeView:_messagesAreaView];
        [self customizeView:_contentsAreaView];
        [self customizeView:_refernceViewborder];
        
        // add swipe gestures to product image view
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(imageSwipeLeft)];
        swipe.direction = UISwipeGestureRecognizerDirectionLeft;
        [_productImageView addGestureRecognizer:swipe];
        
        swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(imageSwipeRight)];
        swipe.direction = UISwipeGestureRecognizerDirectionRight;
        [_productImageView addGestureRecognizer:swipe];
        
        //Swipe to go back
        //UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backBtnTouched)];
        //backSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        //[self.view addGestureRecognizer:backSwipe];
        
        // UIImageView, has to be setup so we can get the taps.
        _productImageView.userInteractionEnabled = YES;
        _productImageView.multipleTouchEnabled = YES;
        
        // set the Content area starting selected index
        contentTypeNdx = kContentTypeProductVideos;
        pageControlBeingUsed = NO;
        
        _messagesAreaView.layer.cornerRadius = 8.0f;
        _messagesAreaView.layer.borderColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f].CGColor;
        _messagesAreaView.layer.borderWidth = 1.f;
        _messagesAreaView.clipsToBounds = YES;
        
        _contentsAreaView.layer.cornerRadius = 8.0f;
        _contentsAreaView.layer.borderColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f].CGColor;
        _contentsAreaView.layer.borderWidth = 1.f;
        _contentsAreaView.clipsToBounds = YES;
        
        _imagesAreaView.layer.borderColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f].CGColor;
        
#warning ATTEMPT TO FIX RESIZE ASPECT
        _productImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    [self.interactiveViewerBtn setImage:[UIImage imageNamed:@"newproduct_select_iv.png"] forState:UIControlStateNormal];
    self.interactiveViewerBtn.showsTouchWhenHighlighted = TRUE;
}

- (void)refreshView
{
    self.interactiveViewerBtn.hidden = YES;
    
   
    
    UIViewController *vc = [[self.navigationController childViewControllers] objectAtIndex:0];
    if ([vc isKindOfClass:[ProcedureVC class]])
    {
        // shared ProductDetail on top Procedure flow
        [[DashboardModel sharedInstance] setCurrentProduct:[[DashboardModel sharedInstance] currentProductProcedureFlow]];
        isComingThroughProcedure = YES;
        //NSLog(@"isComingThroughProcedure = YES");

    } else if ([vc isKindOfClass:[ProductsVC class]])
    {
        // shared ProductDetail on top Products flow
        [[DashboardModel sharedInstance] setCurrentProduct:[[DashboardModel sharedInstance] currentProductProductsFlow]];
        isComingThroughProcedure = NO;
        //NSLog(@"isComingThroughProcedure = NO");
        
        if ([[DashboardModel sharedInstance] currentProduct])
        {
            //not coming through procedure flow so track appropriately
            NSString *tempStr = [NSString stringWithFormat:@"%@:%@", [[DashboardModel sharedInstance] currentProduct].prodId, [[DashboardModel sharedInstance] currentProduct].name];
            [[TrackingModel sharedInstance] createTrackingDataWithResource:tempStr activityCode:TRACKING_ACTIVITY_VIEWED_PRODUCT];
        }

    }
    
    Product *productInModel = [[DashboardModel sharedInstance] currentProduct];
    
    if (productInModel)
    {
        [self setProduct:productInModel];
    }
    else
    {
        UIViewController *vc = [[self.navigationController childViewControllers] objectAtIndex:0];
        if ([vc isKindOfClass:[ProcedureVC class]])
        {
            // shared ProductDetail on top Procedure flow
            if ([[DashboardModel sharedInstance] currentProductProcedureFlow])
            {
                [self setProduct:[[DashboardModel sharedInstance] currentProductProcedureFlow]];
            }
        } else if ([vc isKindOfClass:[ProductsVC class]])
        {
            // shared ProductDetail on top Products flow
            if ([[DashboardModel sharedInstance] currentProductProductsFlow])
            {
                [self setProduct:[[DashboardModel sharedInstance] currentProductProductsFlow]];
            }
        }
    }
    
    _topProductNameLbl.text = _product.name;
    _productNameLbl.text = _product.name;
    
    @autoreleasepool {
        
        
        //
        // load product images area
        [self loadProductImages];
        // if Content with Images are found for the Product, then load the first image,
        // if not then the not found image will be displayed
        if (_productImagesContents.count)
        {
            productImageNdx = 0;
            [self loadProductImageWithIndex:productImageNdx];
        }
        _imagesNbrLbl.hidden = _imageZoomBtn.hidden = (_productImagesContents.count == 0);
        
        // to pick-up any changes to clinical vs. non-clinical for the message area contents.
        if (self.appDelegate.IsFromResource == YES)
        {
            self.appDelegate.IsFromResource = NO;
            [self.messagesTbl reloadData];
        }
        else
          [self configMessagesView];
        
        // load product desc area
        [self loadProductDescription];
        
        // load Contents area
        [self loadContents];
        
        // add MyRecentlyViewed
        [[DashboardModel sharedInstance] addRecentlyViewedForProduct:self.product];
        
        // set enablement for ExtendedMetaData (only on Procedure) flow
        enableExtendedMetaData = [self.tabBarController selectedIndex] == PROCEDURE_TAB_INDEX;
    }
    
    //set for interactiviewer
    NSArray *array;
    
#warning NEED TO REVIST
    
    //NSNotFound
    //Prior to Mac OS X v10.5, NSNotFound was defined as 0x7fffffff. For 32-bit systems, this was effectively the same as NSIntegerMax. To support 64-bit environments, NSNotFound is now formally defined as NSIntegerMax. This means, however, that the value is different in 32-bit and 64-bit environments
    //For now, check for upto 10 target audience
    
    int customerType = ([[DashboardModel sharedInstance] currentCustomerType]? [[DashboardModel sharedInstance] currentCustomerType] :0);
    int procId       = ([[[DashboardModel sharedInstance] currentProcedure].procId intValue] > 0 ? [[[DashboardModel sharedInstance] currentProcedure].procId intValue]: 0);
    
    //nslog(@"Product Id %d", [[[DashboardModel sharedInstance] currentProduct].prodId intValue]);
    //NSLog(@"ProductDetailVC refreshView customer type = %i procID = %i", customerType, procId);
    
    
    array = [[InteractiveViewerModel sharedInstance] fetchProductIV:[[DashboardModel sharedInstance] currentProduct].prodId withTarget: [NSNumber numberWithInt:(customerType < 10? customerType: 0)] :[NSNumber numberWithInt:procId]];
    
    Procedure* relavantSplty;
    NSSet* spltySet = [[[DashboardModel sharedInstance] currentProduct] productToProcedure];
    for (relavantSplty in spltySet)
        //nslog(@"ProductDetailVC spltySet contains member %@", relavantSplty.name);
        
        //nslog(@"Array = %@", array);
        
        
        if ([array count] > 0)
        {
            self.interactiveViewerBtn.hidden = NO;
        }
}

- (void) viewWillAppear:(BOOL)animated
{
    // be sure to call base class!
    [super viewWillAppear:animated];
    
    ////nslog(@"Current product in ProductDetailVC is %@", self.appDelegate.currentProduct.name);
    @autoreleasepool {
        
        [self refreshView];
    }
    //call pagecontrolchanged for case of product image viewed and returned to productdetailVC to keep selected image
    [self imagesPageControlChanged];
    
    if (isComingThroughProcedure)
    {
        isFromProcFlowToViewer = NO;
    }
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // before ProductDetail is popped off the stack, reset the current Product for the correct flow
    UIViewController *vc = [[self.navigationController childViewControllers] objectAtIndex:0];
 
    if (isFromProcFlowToViewer)
    {
        //NSLog(@"From Procedure flow to viewer");
    }
    
    if ([vc isKindOfClass:[ProcedureVC class]] && [[DashboardModel sharedInstance] currentProductProcedureFlow] && !isFromProcFlowToViewer)
    {
        // reset the current selected Product on the Procedure flow
        [[DashboardModel sharedInstance] setCurrentProductProcedureFlow:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView" object:nil];

        [self.navigationController popToRootViewControllerAnimated:YES];

    }

}
- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}
//- (void)viewDidAppear:(BOOL)animated
//{
//    [self refreshView];
//}

- (void) configMessagesView
{
    // freshen setting for customer type to pickup any change to clinical vs. non-clinical
    CustomerType custType = [[DashboardModel sharedInstance] currentCustomerType];
    messageTypeNdx = custType == kCustomerTypeNonClinical ? kMessageTypeEconomical :kMessageTypeClinical;
    
    // first turn them both off.
    UIButton *msgBtn = (UIButton*)[_messagesAreaView viewWithTag:kMessageTypeClinical];
    msgBtn.selected = NO;
    msgBtn = (UIButton*)[_messagesAreaView viewWithTag:kMessageTypeEconomical];
    msgBtn.selected = NO;
    // turn the selected one on.
    msgBtn = (UIButton*)[_messagesAreaView viewWithTag:messageTypeNdx];
    msgBtn.selected = YES;
    
    //    _clinicalMessageContents = [[ContentModel sharedInstance] contentsForProduct:_product withContentCatIds:[NSArray arrayWithObject:[NSNumber numberWithInt:kProductClinicalMessage]]];
    //
    //    _economicalMessageContents = [[ContentModel sharedInstance] contentsForProduct:_product withContentCatIds:[NSArray arrayWithObject:[NSNumber numberWithInt:kProductNonClinicalMessage]]];
    
    int customerType = ([[DashboardModel sharedInstance] currentCustomerType]? [[DashboardModel sharedInstance] currentCustomerType] :0);
    int procId       = ([[[DashboardModel sharedInstance] currentProcedure].procId intValue] > 0 ? [[[DashboardModel sharedInstance] currentProcedure].procId intValue]: 0);
    
    //NSLog(@"ProductDetailVC configMessagesView customer type = %i procID = %i", customerType, procId);
    
    _clinicalMessageContents =  [[InteractiveViewerModel sharedInstance] fetchProductClinicalMsg:_product.prodId withTarget:[NSNumber numberWithInt:(customerType < 10? customerType: 0)] withRelevantProcedure:[NSNumber numberWithInt: procId]];
    
    //NSLog(@"clinical message contents = %@", _clinicalMessageContents);
    
//    if (_clinicalMessageContents == nil || _clinicalMessageContents.count <= 0) {
//        _clinicalMessageContents = [[ContentModel sharedInstance] contentsForProduct:_product withContentCatIds:[NSArray arrayWithObject:[NSNumber numberWithInt:kProductClinicalMessage]]];
//    }
    
    _economicalMessageContents = [[InteractiveViewerModel sharedInstance] fetchProductNonClinicalMsg:_product.prodId withTarget:[NSNumber numberWithInt:(customerType < 10? customerType: 0)] withRelevantProcedure:[NSNumber numberWithInt: procId]];
    
    //NSLog(@"economical message contents = %@", _economicalMessageContents);
    
//    if (_economicalMessageContents == nil || _economicalMessageContents.count <= 0)
//    {
//        _economicalMessageContents = [[ContentModel sharedInstance] contentsForProduct:_product withContentCatIds:[NSArray arrayWithObject:[NSNumber numberWithInt:kProductNonClinicalMessage]]];
//    }
    
    [_messagesTbl reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
//    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Memory Warning" message:@"Device memory warning." delegate:self cancelButtonTitle:@"OK"otherButtonTitles:nil, nil];
//    [av show];
}

/*
 #pragma mark -
 
 - (void) imageSwipeLeft
 {
 //nslog(@"imageSwipeLeft");
 //nslog(@"productImageIndex = %d", productImageNdx);
 
 if (productImageNdx > 0)
 {
 [self loadProductImageWithIndex:--productImageNdx];
 _imagesPageControl.currentPage = productImageNdx;
 }
 
 }
 
 - (void) imageSwipeRight
 {
 if (productImageNdx < _imagesPageControl.numberOfPages - 1)
 {
 //nslog(@"imageSwipeRight");
 [self loadProductImageWithIndex:++productImageNdx];
 _imagesPageControl.currentPage = productImageNdx;
 
 }
 }
 */

#pragma mark -
#pragma mark - Image swipe

- (void) imageSwipeRight
{
    if (productImageNdx > 0)
    {
        [self loadProductImageWithIndex:--productImageNdx];
        _imagesPageControl.currentPage = productImageNdx;
    }
    //called to refresh pagecontrol on swipe
    [self imagesPageControlChanged];
    
    ////nslog(@"imageSwipeRight");
    ////nslog(@"productImageIndex = %d", productImageNdx);
}

- (void) imageSwipeLeft
{
    if (productImageNdx < _imagesPageControl.numberOfPages - 1)
    {
        [self loadProductImageWithIndex:++productImageNdx];
        _imagesPageControl.currentPage = productImageNdx;
    }
    //called to refresh pagecontrol on swipe
    [self imagesPageControlChanged];
    
    ////nslog(@"imageSwipeleft");
    ////nslog(@"productImageIndex = %d", productImageNdx);
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int nRows = 0;
    
    switch (messageTypeNdx) {
        case kMessageTypeClinical:
            nRows = _clinicalMessageContents.count;
            break;
            
        case kMessageTypeEconomical:
            nRows = _economicalMessageContents.count;
            break;
            
        default:
            break;
    }
    
    return nRows;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageContentCell *cell;
    
    Content *content;
    NSString* filePath;
    
    switch (messageTypeNdx) {
        case kMessageTypeClinical:
            if ([[_clinicalMessageContents objectAtIndex:indexPath.row] isKindOfClass:[Content class]])
                content = [_clinicalMessageContents objectAtIndex:indexPath.row];
            else
                filePath = [_clinicalMessageContents objectAtIndex:indexPath.row];
            break;
            
        case kMessageTypeEconomical:
            if ([[_economicalMessageContents objectAtIndex:indexPath.row] isKindOfClass:[Content class]])
                content = [_economicalMessageContents objectAtIndex:indexPath.row];
            else
                filePath = [_economicalMessageContents objectAtIndex:indexPath.row];
            break;
            
        default:
            break;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"MessageContentCell"];
    
    NSString *basePath = [[ContentModel sharedInstance] addAppDocumentsPathToPath:@"/"];
    
    NSString *fullPath = @"";
    if (content)
        fullPath = [[[ContentModel sharedInstance] addAppDocumentsPathToPath:content.path] stringByAppendingString:@""];
    else
        fullPath = [[[ContentModel sharedInstance] addAppDocumentsPathToPath:filePath] stringByAppendingString:@""];
    
    NSError *error;
    NSString *contentStr = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    
    NSMutableArray *substrings = [NSMutableArray new];
    NSScanner *scanner = [NSScanner scannerWithString:contentStr];
    [scanner scanUpToString:@"href" intoString:nil]; // Scan all characters before #
    while(![scanner isAtEnd]) {
        NSString *substring = nil;
        [scanner scanString:@"href= " intoString:nil]; // Scan the # character
        if([scanner scanUpToString:@" " intoString:&substring]) {
            // If the space immediately followed the #, this will be skipped
            [substrings addObject:substring];
        }
        [scanner scanUpToString:@">[" intoString:nil]; // Scan all characters before next #
    }
    // do something with substrings
    contentStringList = @"";
    for (int k =1;k<[substrings count]; k++)
    {
        
        
        NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"]"];
        NSRange range = [[substrings objectAtIndex:k] rangeOfCharacterFromSet:charSet];
        
        if (range.location == NSNotFound)
        {
            // ... oops
        }
        else
        {
            if (k==1)
            {
                contentStringList = [NSString stringWithFormat:@"%@",[[substrings objectAtIndex:k] substringWithRange:NSMakeRange(2, range.location-2)]];
            }
            else
                contentStringList = [NSString stringWithFormat:@"%@,%@",contentStringList,[[substrings objectAtIndex:k] substringWithRange:NSMakeRange(2, range.location-2)]];
        }
    }
    
    //[cell.webView loadHTMLString:contentStr baseURL:[NSURL fileURLWithPath:basePath]];
    NSURL *urlpath = [[NSURL alloc] initWithString:[fullPath stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:urlpath];
    //nslog(@"url request is %@",urlpath);
    [cell.webView loadRequest:urlReq];
    
    cell.webView.delegate = self;
    content = nil;
    
    return cell;
}


#pragma mark - webiview




-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    // NSString * resultstring = [self
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
       
        
        //[self.view addSubview:refernceView];
        
        //   //nslog(@"checking---file:///Users/epromacmini/Library/Application%20Support/iPhone%20Simulator/7.0/Applications/B7B7346C-0410-4569-8CA6-C4B998D8414E/Documents/assets/content/videos/product/642_01_sfx_310_12_sfx_product_overview_animation_ca.mp4");
        
        NSString * urlstring;
        //nslog(@"after delete %@",[[[request URL] absoluteString] substringFromIndex: 7]);
        NSString * filePath2 = [NSString stringWithFormat:@"%@%@",DocumentsDirectory,[[[request URL] absoluteString] substringFromIndex:7]];
        //nslog(@"original url -- %@%@",DocumentsDirectory,[[[request URL] absoluteString] substringFromIndex: 7]);
        //NSString* ext = [[filePath pathExtension] lowercaseString];
        //nslog(@"extension -- %@",ext);
        NSString * realpath = [[request URL] absoluteString];
        NSString* ext1 = [[realpath pathExtension] lowercaseString];
        NSString * ExternalLink =[realpath substringToIndex:4];
        if ([ExternalLink isEqualToString:@"http"])
        {
            ResourceViewerViewController* rviewer = [[ResourceViewerViewController alloc] initWithNibName:@"ResourceView" bundle:nil];
            
            rviewer.filePath = realpath;
            self.appDelegate.IsFromResource = YES;
            [self presentViewController:rviewer animated:NO completion:nil];
            [rviewer.webView setScalesPageToFit:YES];
            [rviewer.Spinner startAnimating];
            [rviewer loadExternalurl];
            
            rviewer = nil;
            return YES;

        }

      
        if ([ext1 isEqualToString:@"mp4"] ||
            [ext1 isEqualToString:@"m3u8"] ||
            [ext1 isEqualToString:@"m4v"] || ([ext1 isEqualToString:@"pdf"]) || [ext1 isEqualToString:@"jpg"] || [ext1 isEqualToString:@"png"] || [ext1 isEqualToString:@"html"])
        {
            
            
            urlstring = filePath2;
           
            self.appDelegate.IsFromResource = YES;
            ResourceViewerViewController* rviewer = [[ResourceViewerViewController alloc] initWithNibName:@"ResourceView" bundle:nil];
            
           [self presentViewController:rviewer animated:NO completion:nil];
 [rviewer.webView setScalesPageToFit:YES];
         //   NSString * ExternalLink2 =[realpath substringToIndex:4];
//             if ([ExternalLink2 isEqualToString:@"file"])
//             {
//                
//                 NSString * realpath2 = [[request URL] absoluteString];
//                 rviewer.filePath = realpath2;
//                 //[rviewer loadExternalurl];
//             }
//            else
            {
                rviewer.filePath = urlstring;
                
            }
            [rviewer play];
            
            rviewer = nil;

        }
        else
        {
            
            NSArray *substrings = [[[request URL] absoluteString] componentsSeparatedByString:@"#"];
            NSString *code;
            if (substrings.count)
            {
                code =  [substrings objectAtIndex:((substrings.count) -1)];
            }
            else
                code = @"1";
            
            code = [code stringByReplacingOccurrencesOfString:@"." withString:@"_"];
            
            
            
//            NSString *code =  [[[request URL] absoluteString] substringFromIndex: [[[request URL] absoluteString] length] - 2];
//            //nslog(@"--before-%@",code);
//            if([code hasPrefix:@"#"])
//            {
//                code = [[[request URL] absoluteString] substringFromIndex: [[[request URL] absoluteString] length] - 1];
//                //nslog(@"---%@",code);
//            }
            
            //NSString * strippedNumber = [code stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@""];
            //nslog(@"--- %@",strippedNumber);
            
           
            urlstring = [NSString stringWithFormat:@"%@%@?current=%@",DocumentsDirectory,[self.appDelegate getAppContentPath:@"references"],code];
            //urlstring = [NSString stringWithFormat:@"%@/assets/content/applications/885_references/index.html?current=%@&list=%@",DocumentsDirectory, code,contentStringList];
            //nslog(@" in class");
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
            self.refernceView.hidden = NO;
           // UIWebView * referWebview
            RefernceWebview = [[UIWebView alloc] initWithFrame:CGRectMake(2, 2, 926, 528)];
            RefernceWebview.backgroundColor = [UIColor whiteColor];
            //[RefernceWebview stringByEvaluatingJavaScriptFromString:@"document.open();document.close();"];
            
            NSURL *url = [[NSURL alloc] initWithString:[urlstring stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
           
          //  NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
            
            NSURLRequest *thereq = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:120];
            
            [self.refernceViewborder addSubview:RefernceWebview];
            [RefernceWebview loadRequest:thereq];
            [self.RefernceWebview loadRequest:thereq];
            
            
        }
        
        //        if ([ext isEqualToString:@""] || [ext isKindOfClass:[NSNull class]])
        //        {
        //
        //        }
        //        else
        //        {
        //
        //
        //
        //
        //        }
        
        //nslog(@"---final---%@",filePath);
       
    }
    return YES;
}

-(IBAction)closeReferenceview:(id)sender

{
    
   // [self.refernceView removeFromSuperview];
    [self.RefernceWebview removeFromSuperview];
   // self.RefernceWebview.delegate = nil;
   
   
    
    self.refernceView.hidden = YES;
    [RefernceWebview stopLoading];
    RefernceWebview = nil;
   [RefernceWebview loadHTMLString:@"<html><head></head><body></body></html>" baseURL:nil];

    
    [self.messagesTbl reloadData];
}



-(NSString *)scanString:(NSString *)string startTag:(NSString *)startTag endTag:(NSString *)endTag
{
    
    NSString* scanString = @"";
    
    if (string.length > 0) {
        
        NSScanner* scanner = [[NSScanner alloc] initWithString:string];
        
        @try {
            [scanner scanUpToString:startTag intoString:nil];
            scanner.scanLocation += [startTag length];
            [scanner scanUpToString:endTag intoString:&scanString];
        }
        @catch (NSException *exception) {
            return nil;
        }
        @finally {
            return scanString;
        }
        
    }
    
    return scanString;
    
}
#pragma mark -

- (void) loadProductImages
{
    @autoreleasepool {
        
        
        /*
         ProductImage = 19
         */
        
        _productImagesContents = [[ContentModel sharedInstance] contentsForProduct:_product withContentCatIds:[NSArray arrayWithObject:[NSNumber numberWithInt:kProductImage]]];
        
        if (!_productImagesContents || _productImagesContents.count < 1)
        {   // no content images found, so load dummy image
            _productImageView.image = [UIImage imageNamed:PRODUCT_MISSING_IMAGE];
            _imagesPageControl.numberOfPages = 1;
            
        }
        else
        {
            //#warning TEST CODE -
            //        if (_productImagesContents.count == 1)
            //        {
            //            NSMutableArray *imgs = [NSMutableArray arrayWithArray:_productImagesContents];
            //            [imgs addObject:[_productImagesContents objectAtIndex:0]];
            //            _productImagesContents = imgs;
            //        }
            
            UIImageView *productThumbnailImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 66, 52)];
            UILabel * producttitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 66, 52)];
            for (Content *content in _productImagesContents)
            {
                ////nslog(@"content.path: %@", content.path);
                if (content.path)
                {
                    ////nslog(@"content.thumbnailImgPath: %@", content.thumbnailImgPath);
                    productThumbnailImage.image = [self.appDelegate loadImage:content.path];
                    
                    
                    producttitle.text = content.title;
                    break;
                }
                
            }
            if (!productThumbnailImage.image)
            {
                
                producttitle.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
                
                producttitle.numberOfLines = 0;
                producttitle.font = [UIFont fontWithName:@"Arial" size:11];
                producttitle.textAlignment = NSTextAlignmentCenter;
                [productThumbnailImage addSubview:producttitle];
                UIGraphicsBeginImageContext(productThumbnailImage.bounds.size);
                [productThumbnailImage.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage *bitmap = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                productThumbnailImage.image = bitmap;
            }
            _productImageView.image = productThumbnailImage.image;
            
            //        for (Content *content in _productImagesContents)
            //        {
            //            ////nslog(@"content.path: %@", content.path);
            //
            //            UIImage *image = [self.appDelegate loadImage:content.path];
            //            if (image)
            //            {
            //                _productImageView.image = image;
            //                break;
            //            }
            //        }
            
            _imagesPageControl.numberOfPages = _productImagesContents.count;
            productThumbnailImage = nil;
            //_productImagesContents = nil;
            
        }
        
        //nslog(@"%d images for product: %@", _imagesPageControl.numberOfPages, _product.name);
        
        _imagesNbrLbl.text = [NSString stringWithFormat:@"1/%d", _imagesPageControl.numberOfPages];
    }
    //_productImagesContents = nil;
}

- (void) loadProductDescription
{
    _productDescTextView.text = _product.desc;
}

- (void) loadProductImageWithIndex:(int)ndx
{
    Content *content;
    
    // ensure safe array indexing
    if (ndx < 0) ndx = 0;
    else if (ndx > _productImagesContents.count - 1) ndx = _productImagesContents.count - 1;
    
    if (_productImagesContents.count > 0) {
        content = [_productImagesContents objectAtIndex:ndx];
        
        ////nslog(@"content.path: %@", content.path);
        
        _productImageView.image = [self.appDelegate loadImage:content.path];
    }
    _imagesNbrLbl.text = [NSString stringWithFormat:@"%d/%d", _imagesPageControl.currentPage + 1, _imagesPageControl.numberOfPages];
}

- (void) loadContents
{
    NSArray *contentCatIds;
    NSString *imageName;
    
    // set item type to the belonging tab index
    int itemType = contentTypeNdx;
    
    switch (contentTypeNdx) {
        case kContentTypeProductVideos:
            //contentCatId = itemType = kProductVideo;
            contentCatIds = [NSArray arrayWithObject:[NSNumber numberWithInt:kProductVideo]];
            //imageName = IMAGE_VIDEOS_ICON;
            break;
        case kContentTypeClinicalArticles:
            contentCatIds = [NSArray arrayWithObjects:[NSNumber numberWithInt:kProductClinicalArticles], [NSNumber numberWithInt:kProductClinicalArticlesCharts], [NSNumber numberWithInt:kProductClinicalArticlesOthers], nil];
            //imageName = IMAGE_ARTICLES_ICON;
            break;
        case kContentTypeProductSpecs:
            
            contentCatIds = [NSArray arrayWithObjects:[NSNumber numberWithInt:kProductSpecs], [NSNumber numberWithInt:kProductSpecsIFU], nil];
            //imageName = IMAGE_SPECIFICATIONS_ICON;
            break;
        case kContentTypeCompetitiveInfo:
            contentCatIds = [NSArray arrayWithObjects:[NSNumber numberWithInt:kProductCompetitiveInfo], [NSNumber numberWithInt:kProductCompetitiveInfoVideos], [NSNumber numberWithInt:kProductCompetitiveInfoCharts], [NSNumber numberWithInt:kProductCompetitiveInfoOthers], nil];
            //imageName = IMAGE_COMPETITIVE_ICON;
            break;
        case kContentTypeVACPAC:
            contentCatIds = [NSArray arrayWithObjects:[NSNumber numberWithInt:kProductVACPAC510k], [NSNumber numberWithInt:kProductVACPACIFU], [NSNumber numberWithInt:kProductVACPACEconomic], [NSNumber numberWithInt:kProductVACPACEvidenceSummary], [NSNumber numberWithInt:kProductVACPACMSDS], [NSNumber numberWithInt:kProductVACPACOther], nil];
            //imageName = IMAGE_VACPAC_ICON;
            break;
        case kContentTypeResources:
            contentCatIds = [NSArray arrayWithObjects:[NSNumber numberWithInt:kProductResourcesSalesaid], [NSNumber numberWithInt:kProductResourcesReimbursementSheet], [NSNumber numberWithInt:kProductResourcesSellsheet], [NSNumber numberWithInt:kProductResourcesSSI], [NSNumber numberWithInt:kProductResourcesBrochures], [NSNumber numberWithInt:kProductResourcesInservice], [NSNumber numberWithInt:kProductResourcesFAQS], [NSNumber numberWithInt:kProductResourcesApps], nil];
            //imageName = IMAGE_RESOURCES_ICON;
            break;
            
        default:
            break;
    }
    
    self.contentAreaContents = [[ContentModel sharedInstance] contentsForProduct:_product withContentCatIds:contentCatIds];
    
    // load the extended attributes for the contents
    NSDictionary* targetAudience  = [self loadExtendedAttribsForContentIds:self.contentAreaContents forKey:@"TARGETAUDIENCE"];
    
    self.extendedAttribsDict = [self loadExtendedAttribsForContentIds:self.contentAreaContents forKey:@"RELEVANTPROCEDURES"];
    
    // sort the contents
    //self.contentAreaContents = [self sortContentsByExtendedAttribs:self.contentAreaContents]; //@deprecated
    self.contentAreaContents = [self sortContentsByExtendedAttribs:self.contentAreaContents withRelevantProcedure:self.extendedAttribsDict withTargetAudience:targetAudience];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    int ndx = 0;
    NSString *imgPath;
    DashboardItem *item;
    for (Content *content in _contentAreaContents)
    {
        NSString *pathLength = content.path;
        if (pathLength.length > 0)
        {
            imgPath = content.thumbnailImgPath;
            
            item = [[DashboardItem alloc] initWithTitle:content.title
                                               itemType:itemType
                                                 itemId:ndx
                                               selected:NO
                                       defaultSelection:NO];
            item.imageName = imgPath;
            [items addObject:item];
        }
        ndx++;
    }
    
    // sort the items
    
    self.dashboardItems = items;
    [self.contentsCollectionView reloadData];
    
    int cnt = 0;
    int itemCnt = self.dashboardItems.count;
    
    // determine how many pages we have, based on 3 items per page
    if (itemCnt > 0)
    {
        if (itemCnt > 6)
        {
            cnt = itemCnt / 6;
            
            if (itemCnt % 6 > 0)
            {
                cnt++;
            }
            
        }
        else
        {
            cnt = 1;
        }
    }
    self.contentPageControl.numberOfPages = cnt;
    contentCatIds = nil;
    
}

- (BOOL) isContentRelevantWithCntId:(NSNumber*)cntId withDefaultProc : (BOOL) isDefaultProc
{
    BOOL productIsRelevantToProc = NO;
    NSString *currentProcedureProcIdStr = [[[[DashboardModel sharedInstance] currentProcedure] procId] stringValue];
    if (isDefaultProc)
        currentProcedureProcIdStr = [NSString stringWithFormat:@"0"];
    
    NSArray *procIds = [self.extendedAttribsDict objectForKey:[cntId stringValue]];
    for (NSString *procIdStr in procIds)
    {
        if ([procIdStr isEqualToString:currentProcedureProcIdStr])
        {
            productIsRelevantToProc = YES;
            break;
        }
    }
    
    return productIsRelevantToProc;
    
}

- (BOOL) isContentRelavantToTargetAudience : (NSNumber*) cntId  :(NSDictionary*) targetAudienceDict isDefault: (BOOL) isDefaultAudience {
    
    BOOL isTargetAudience = NO;
    int customerType = ([[DashboardModel sharedInstance] currentCustomerType]? [[DashboardModel sharedInstance] currentCustomerType] :0);
    if (isDefaultAudience)
        customerType = 0;
    
    NSString* customerTypeStringValue = [NSString stringWithFormat:@"%d",customerType];
    NSArray *targetAudience = [targetAudienceDict objectForKey:[cntId stringValue]];
    for (NSString *audience in targetAudience)
    {
        if ([audience isEqualToString:customerTypeStringValue])
        {
            isTargetAudience = YES;
            break;
        }
    }
    return isTargetAudience;
}

- (BOOL) isContentRelavantToProcedure : (NSNumber*) cntId : (NSDictionary*) relevantProcedure withDefaultProc : (BOOL) isDefaultProc {
    return [self isContentRelevantWithCntId:cntId withDefaultProc : isDefaultProc];
}

- (NSArray*)sortContentsByExtendedAttribs:(NSArray*)array withRelevantProcedure: (NSDictionary*) relevantProcs withTargetAudience: (NSDictionary*) targetAudience
{
    @autoreleasepool {
        
        NSMutableArray* targetAudienceWithRelevantProcs =    [[NSMutableArray alloc] init];
        NSMutableArray* targetAudienceWithDefaultProcs =     [[NSMutableArray alloc] init];
        NSMutableArray* remainingContentWithTargetAudience = [[NSMutableArray alloc] init];
        
        NSMutableArray* defaultTargetAudienceWithRelevantProcs = [[NSMutableArray alloc] init];
        NSMutableArray* defaultTargetAudienceWithDefaultProcs = [[NSMutableArray alloc] init];
        NSMutableArray* remainingContents = [[NSMutableArray alloc] init];
        
        NSMutableArray *sortedArray = [[NSMutableArray alloc] init];
        
        int customerType = ([[DashboardModel sharedInstance] currentCustomerType]? [[DashboardModel sharedInstance] currentCustomerType] :0);
        NSString *currentProcedureProcIdStr = [[[[DashboardModel sharedInstance] currentProcedure] procId] stringValue];
        for (Content* cnt in array) {
            if (customerType != NSNotFound) { //When Stake Holder is selected --> Flow from Dashboard
                if ([self isContentRelavantToTargetAudience : cnt.cntId :targetAudience isDefault:NO] && [self isContentRelavantToProcedure :cnt.cntId :relevantProcs withDefaultProc : NO]) { //When Stake Holder and Procedure is selected --> Flow from Dashboard
                    [targetAudienceWithRelevantProcs addObject:cnt];
                } else if ([self isContentRelavantToTargetAudience : cnt.cntId :targetAudience isDefault:NO] && [self isContentRelavantToProcedure :cnt.cntId :relevantProcs withDefaultProc : YES]) { //When Stake Holder and Procedure is selected (but, no records, so use Default Proc) --> Flow from Dashboard
                    [targetAudienceWithDefaultProcs addObject:cnt];
                } /*else if ([self isContentRelavantToTargetAudience : cnt.cntId :targetAudience isDefault:NO]) { //When Stake Holder and Procedure is selected (but, no records) --> Flow from Dashboard
                    //Client Request -- When a Stake Holder and a Procedure are selected, show only those specific contents and hence commenting following 1 if conditions)
                    [remainingContentWithTargetAudience addObject:cnt];
                }*/
            } else if (currentProcedureProcIdStr != nil && currentProcedureProcIdStr.length > 0) {
                if ([self isContentRelavantToProcedure :cnt.cntId :relevantProcs withDefaultProc : NO]) { //No Stake Holder, but selected procedure --> Flow from Procedure
                    [defaultTargetAudienceWithRelevantProcs addObject:cnt];
                } else if ([self isContentRelavantToProcedure :cnt.cntId :relevantProcs withDefaultProc : YES]) { //No Stake Holder, but selected procedure (no records, so use default procedure) --> Flow from Procedure
                    [defaultTargetAudienceWithDefaultProcs addObject:cnt];
                } /*else { //No Stake Holder, no Procedure --> Flow from Product
                    //Client Request -- When a Procedure are selected, show only those specific contents and hence commenting following 2 if conditions
                    [remainingContents addObject:cnt];
                }*/
            } else {
                [remainingContents addObject:cnt];
            }
        }
            [sortedArray addObjectsFromArray:[self sortByContentSortOrder :targetAudienceWithRelevantProcs]];         //Sort by sortOrder
            [sortedArray addObjectsFromArray:[self sortByContentSortOrder :targetAudienceWithDefaultProcs]];          //Sort by sortOrder
            [sortedArray addObjectsFromArray:[self sortByContentSortOrder :remainingContentWithTargetAudience]];      //Sort by sortOrder
            
            [sortedArray addObjectsFromArray:[self sortByContentSortOrder :defaultTargetAudienceWithRelevantProcs]];  //Sort by sortOrder
            [sortedArray addObjectsFromArray:[self sortByContentSortOrder :defaultTargetAudienceWithDefaultProcs]];   //Sort by sortOrder
            [sortedArray addObjectsFromArray:[self sortByContentSortOrder :remainingContents]];                       //Sort by sortOrder
            return sortedArray;
    }
}

- (NSArray*) sortByContentSortOrder :(NSArray*) array {
    
    NSArray* sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        Content *contentA = (Content*)a;
        Content *contentB = (Content*)b;
        NSNumber* sortOrderA = contentA.sortOrder;
        NSNumber* sortOrderB = contentB.sortOrder;
        return [sortOrderA compare:sortOrderB];
    }];
    return sortedArray;
}

- (NSDictionary*) loadExtendedAttribsForContentIds:(NSArray*)contents forKey:(NSString*) key
{
    NSDictionary *dict;
    NSMutableArray *cntIds = [[NSMutableArray alloc] init];
    for (Content *content in contents)
    {
        [cntIds addObject:[content.cntId copy]];
        
    }
    dict = [[ProcedureModel sharedInstance] metadataDictForContentId:cntIds andForKey:key];
    return dict;
}

/*
 - (void) populateScrollView:(UIScrollView*)scrollview items:(NSArray*)items
 {
 //CGFloat vWidth = 150.0f, vHeight = 140.0f;
 CGFloat vWidth = 144.f, vHeight = 154.f;
 CGFloat xOffset = 0.0f, yOffset = 20.0f;
 CGFloat width = 112.f, height = 82.f;
 CGFloat margin = 20.0f, vsep = 5.0f;
 
 BOOL enableExtendedMetData = [(TabBarViewController*)self.tabBarController selectedIndex] == PROCEDURE_TAB_INDEX; // Procedure tab
 
 // first clear the scroll view
 [self clearScrollView:scrollview];
 
 CGRect frame;
 UIView *view;
 DashboardItemButton *dashboardBtn;
 DashboardItem *dashboardItem;
 UIImage *img;
 UILabel *lbl;
 ////nslog(@"populateScrollView items.count: %d", items.count);
 
 // display 3 items per scrollView horizontal screen
 ////nslog(@"self.contentsScrollView.bounds.size.width: %f ", self.contentsScrollView.bounds.size.width);
 //CGFloat spacer = (self.contentsScrollView.bounds.size.width - (3 * vWidth) / 4);
 //CGFloat spacer = 19.f; //(508 - (3 * vWidth) / 4);
 ////nslog(@"spacer: %f", spacer);
 //xOffset = spacer;
 
 for (int i=0; i<items.count; i++)
 {
 dashboardItem = [items objectAtIndex:i];
 
 view = [[UIView alloc] initWithFrame:CGRectMake(xOffset, yOffset, vWidth, vHeight)];
 view.backgroundColor = [UIColor clearColor];
 //        view.layer.borderColor = [UIColor redColor].CGColor;
 //        view.layer.borderWidth = 1.f;
 
 UIView *view11 = [[UIView alloc] initWithFrame:CGRectMake(11, 5, 122, 92)];
 view11.layer.borderColor = [UIColor colorWithRed:243.0f/255.0f green:243.0f/255.0f blue:243.0f/255.0f alpha:1].CGColor;
 view11.layer.borderWidth = 1.0f;
 [view addSubview:view11];
 
 dashboardBtn = [DashboardItemButton buttonWithType:UIButtonTypeCustom];
 
 img = [[self.appDelegate loadImage:dashboardItem.imageName] resizableImageWithCapInsets:UIEdgeInsetsZero];
 ////nslog(@"thumbnail width: %f height: %f", img.size.width, img.size.height);
 img = [img imageWithImage:img scaledToSize:CGSizeMake(width, height)];
 ////nslog(@"thumbnail width: %f height: %f", img.size.width, img.size.height);
 if ((int)dashboardItem.itemType == kProductVideo)
 {
 img = [img drawImage:[UIImage imageNamed:@"product_videos_select2"] atPoint:CGPointMake(img.size.width/2, img.size.height/2)];
 }
 [dashboardBtn setImage:img forState:UIControlStateNormal];
 
 frame = dashboardBtn.frame;
 frame.size = CGSizeMake(width, height);
 frame.origin.x = (vWidth - width)/2;
 frame.origin.y = vsep * 2;
 dashboardBtn.frame = frame;
 
 dashboardBtn.dashboardItem = dashboardItem;
 //[dashboardBtn addTarget:self action:@selector(dashboardItemSelected:) forControlEvents:UIControlEventTouchDown];
 [self setupLongPressWithBtn:dashboardBtn];
 [self setupTapWithBtn:dashboardBtn];
 
 //        dashboardBtn.layer.borderColor = [UIColor redColor].CGColor;
 //        dashboardBtn.layer.borderWidth = 1.f;
 [view addSubview:dashboardBtn];
 
 xOffset = 0.0f;
 yOffset = dashboardBtn.frame.origin.y + dashboardBtn.frame.size.height + vsep;
 //yOffset = dashboardBtn.frame.origin.y + img.size.height;
 lbl = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, vWidth, 44.0f)];
 lbl.font = [UIFont fontWithName:@"Arial" size:12.f];
 lbl.adjustsFontSizeToFitWidth = YES;
 lbl.text = [NSString stringWithFormat:@"%@", dashboardItem.title];
 lbl.numberOfLines = 3;
 
 {
 lbl.autoresizingMask = UIViewAutoresizingFlexibleWidth |
 UIViewAutoresizingFlexibleHeight;
 lbl.backgroundColor = [UIColor clearColor];
 lbl.textAlignment = NSTextAlignmentCenter;
 lbl.textColor = [UIColor darkGrayColor];
 }
 
 //        lbl.layer.borderColor = [UIColor redColor].CGColor;
 //        lbl.layer.borderWidth = 1.f;
 
 [view addSubview:lbl];
 
 xOffset = (i * margin) + (i * vWidth) + margin;
 //xOffset += vWidth + spacer;
 yOffset = vsep;
 frame = view.frame;
 frame.origin.x = xOffset;
 view.frame = frame;
 
 #warning TEST CODE FOR EXTENDED ATTRIBS
 if (enableExtendedMetData)
 {
 BOOL productIsRelevantToProc = NO;
 Content *content = [self.contentAreaContents objectAtIndex:dashboardItem.itemId];   // itemId is ndx into Contents array
 if (content)
 {
 productIsRelevantToProc = [self isContentRelevantWithCntId:content.cntId];
 }
 
 if (productIsRelevantToProc)
 {
 //view.layer.borderColor = [UIColor greenColor].CGColor;
 view.layer.borderWidth = 1.f;
 
 //self.contentsCollectionView.layer.borderColor = [UIColor greenColor].CGColor;
 //self.contentsCollectionView.layer.borderWidth = 2.f;
 }
 }
 
 [scrollview addSubview:view];
 yOffset = 20.0;
 }
 
 xOffset += (vWidth + margin);
 xOffset = (items.count * margin) + (items.count * vWidth) + margin;
 scrollview.contentSize = CGSizeMake(xOffset, vHeight);
 scrollview.pagingEnabled = YES;
 
 }
 */

- (void) handleAddToFavorites:(DashboardItem *)dashboardItem
{
    if (dashboardItem)
    {
        int itemId = dashboardItem.itemId;
        
        Content *content = [_contentAreaContents objectAtIndex:itemId];
        if (content)
        {
            [[FavoritesModel sharedInstance] addFavoriteWithContent:content];
            
        }
    }
    
}

#pragma mark -

- (void) openContentInContentViewer:(Content*)content
{
    //    _selectedContent = content;
    //    [self performSegueWithIdentifier:@"ProductDetailToContentViewer" sender:nil];
    
    // add MyRecentlyViewed
    [[DashboardModel sharedInstance] addRecentlyViewedForContent:content];
    
    ResourceViewerViewController* rviewer = [[ResourceViewerViewController alloc] initWithNibName:@"ResourceView" bundle:nil];
    NSString* targetPath = [[ContentModel sharedInstance] addAppDocumentsPathToPath:content.path];
    
    rviewer.filePath = targetPath;
    [self presentViewController:rviewer animated:NO completion:nil];
    [rviewer.webView setScalesPageToFit:YES];
    [rviewer play];
}

#pragma mark -
#pragma mark UIActionSheet Methods

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    //#warning iOS7 test bed
    
    //Gets an array af all of the subviews of our actionSheet
    NSArray *subviews = [actionSheet subviews];
    
    for (UIView *v in subviews)
    {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *b = (UIButton*)v;
            [b setTitleColor:[UIColor colorWithRed:110.0f/255.0f green:110.0f/255.0f blue:110.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [b setTitleColor:[UIColor colorWithRed:243.0f/255.0f green:6.0f/255.0f blue:23.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
            
        }
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kActionSheetIsFavoriteTagAddToFavorite && buttonIndex != 1 && buttonIndex == 0)
    {
        //[self handleAddToFavorites:_longPressDashboardItem];
        Content *content = [_contentAreaContents objectAtIndex:self.contentLongPressIndexPath.row];
        [[FavoritesModel sharedInstance] addFavoriteWithContent:content];
        
        //temp trial test to manage content deletion
        //[self.appDelegate.managedObjectContext deleteObject:content];
        //[self.appDelegate saveContext];
        
    }
    else if (actionSheet.tag == kActionSheetIsFavoriteTagAddToFavorite && buttonIndex == 1)
    {
        //[self handleShare:_longPressDashboardItem];
        [self handleShare:self];
        
        
    }
    else if (actionSheet.tag == kActionSheetIsFavoriteTagCancelandSharable && buttonIndex == 0)
    {
        //[self handleShare:_longPressDashboardItem];
        [self handleShare:self];
        
    }
    else if (actionSheet.tag == kActionSheetIsFavoriteTagCancel && buttonIndex == 1)
    {
        //[self handleShare:_longPressDashboardItem];
        [self handleShare:self];
        
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ProductDetailToContentViewer"])
    {
        ContentViewerVC *vc = (ContentViewerVC*)segue.destinationViewController;
        vc.content = _selectedContent;
    }
}

- (void) playVideoWithPath:(NSString*)contentPath
{
    NSURL *url = [[NSURL alloc] initFileURLWithPath:[self.appDelegate prefixDocumentsPathToPath:contentPath]];
    
    //nslog(@"video url: %@", url);
    
    _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDonePressed:) name:MPMoviePlayerDidExitFullscreenNotification object:_moviePlayer];
    
    _moviePlayer.controlStyle = MPMovieControlStyleDefault;
    _moviePlayer.shouldAutoplay = YES;
    
    [self.view addSubview:_moviePlayer.view];
    [_moviePlayer setFullscreen:YES animated:YES];
}

- (void) moviePlayBackDonePressed:(NSNotification*)notification
{
    [_moviePlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:_moviePlayer];
    
    if ([_moviePlayer respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [_moviePlayer.view removeFromSuperview];
    }
    _moviePlayer = nil;
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    [_moviePlayer stop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer];
    
    if ([_moviePlayer respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [_moviePlayer.view removeFromSuperview];
    }
}

#pragma mark -

- (IBAction) backBtnTouched
{
    isFromProcFlowToViewer = NO;
    // before ProductDetail is popped off the stack, reset the current Product for the correct flow
    UIViewController *vc = [[self.navigationController childViewControllers] objectAtIndex:0];
    if ([vc isKindOfClass:[ProcedureVC class]])
    {
        // reset the current selected Product on the Procedure flow
        [[DashboardModel sharedInstance] setCurrentProductProcedureFlow:nil];
    } else if ([vc isKindOfClass:[ProductsVC class]])
    {
        // reset the current selected Product on the Products flow
        [[DashboardModel sharedInstance] setCurrentProductProductsFlow:nil];
    }
    
    _messagesAreaView = nil;
    _messagesTbl = nil;
    _messagesControlsBackView = nil;
    
    /*
    //
    _productImagesContents = nil;
    _contentAreaContents = nil;
    _dashboardItems = nil;
    _clinicalMessageContents = nil;
    _economicalMessageContents = nil;
    _moviePlayer = nil;
    _selectedContent = nil;
    _longPressDashboardItem = nil;
    _favoritesFRC = nil;
    _extendedAttribsDict = nil;
    //
    self.refernceView = nil;
    self.RefernceWebview = nil;
    self.refernceViewborder = nil;
    self.imagesAreaView = nil;
    //
    */

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) imageZoomBtnTouched
{
    if (isComingThroughProcedure)
    {
        isFromProcFlowToViewer = YES;
    }
    ImageScrollViewController * IMGVC = [[ImageScrollViewController alloc] initWithNibName:@"ImageScrollViewController" bundle:nil];
    NSString * totalstring = @"";
    
    for (int i=0; i<[_productImagesContents count]; i++)
    {
        Content *content = [_productImagesContents objectAtIndex:i];
        IMGVC.Imagepaths = @"";
        NSString* targetPath = [[ContentModel sharedInstance] addAppDocumentsPathToPath:content.path];
        if (i==0)
        {
            totalstring = targetPath;
        }
        else
            totalstring = [NSString stringWithFormat:@"%@\n%@",totalstring,targetPath];
    }
    IMGVC.Imagepaths = totalstring;
    IMGVC.selectedindex = _imagesPageControl.currentPage;
    if (_imagesPageControl.currentPage ==0)
    {
        IMGVC.currentPath = @"";
        //IMGVC.currentimage = 0;
    }
    else
    {
        
        Content *content2 = [_productImagesContents objectAtIndex:_imagesPageControl.currentPage];
        IMGVC.currentPath = [[ContentModel sharedInstance] addAppDocumentsPathToPath:content2.path];;
    }
    
    
    [self presentViewController:IMGVC animated:NO completion:nil];
    
}

- (IBAction) image360BtnTouched
{
    
}

- (IBAction) imagesPageControlChanged
{
    ////nslog(@"imagesPageControlChanged");
    
    productImageNdx = _imagesPageControl.currentPage;
    [self loadProductImageWithIndex:productImageNdx];
}

- (IBAction) messagesControlBtnTouched:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    if (btn.tag != messageTypeNdx)
    {
        UIButton *prevBtn = (UIButton*)[_messagesAreaView viewWithTag:messageTypeNdx];
        prevBtn.selected = NO;
        
        btn.selected = YES;
        messageTypeNdx = btn.tag;
    }
    
    // reload messages
    [_messagesTbl reloadData];
}

- (IBAction) contentsControlBtnTouched:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    if (btn.tag != contentTypeNdx)
    {
        UIButton * prevBtn = (UIButton*)[_contentsAreaView viewWithTag:contentTypeNdx];
        prevBtn.selected = NO;
        
        btn.selected = YES;
        contentTypeNdx = btn.tag;
    }
    
    // reload Contents
    [self loadContents];
}

//new for collection view

#pragma mark - ProductDetail
#pragma mark UICollectionView Data Source Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (![self.dashboardItems count])
    {
        if (!_noContentLabel)
        {
            CGRect frame = CGRectMake(_contentsCollectionView.bounds.origin.x, _contentsCollectionView.bounds.origin.y -10, _contentsCollectionView.bounds.size.width, _contentsCollectionView.bounds.size.height);
            _noContentLabel = [[UILabel alloc] initWithFrame:frame];
        }
        
        _noContentLabel.hidden = NO;
        _noContentLabel.font = [UIFont fontWithName:@"Arial" size:16];
        _noContentLabel.numberOfLines = 0;
        _noContentLabel.textAlignment = NSTextAlignmentCenter;
        UIColor *tempcolor = [UIColor lightGrayColor];
        _noContentLabel.textColor = tempcolor;
        _noContentLabel.text = CONTENT_UNAVAILABLE_TEXT;
        _noContentLabel.frame = CGRectMake(_noContentLabel.frame.origin.x, _noContentLabel.frame.origin.y, _noContentLabel.frame.size.width, _noContentLabel.frame.size.height);
        [collectionView addSubview:_noContentLabel];
        
        return [self.dashboardItems count];
    }
    else
    {
        if (_noContentLabel)
        {
            _noContentLabel.hidden = YES;
        }
        
        return [self.dashboardItems count];
    }

    
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ProductDetailCVCell";
    
    DashboardItem *dashboardItem;
    dashboardItem = [self.dashboardItems objectAtIndex:indexPath.row];
    
    ProductDetailCVCell *cell = (ProductDetailCVCell*)[_contentsCollectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if (enableExtendedMetaData)
    {
        //nslog(@"enableExtendedMetaData: %@", enableExtendedMetaData ? @"Yes" : @"No");
    }
    
    //Set artifact title
    NSString *str;
    str = dashboardItem.title;
    cell.contentTitleLabel.text = str;
    cell.contentTitleLabel.numberOfLines = 3;
    
    
    UIImageView *productThumbnailImage;
    productThumbnailImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 112, 82)];
    productThumbnailImage.image = [self.appDelegate loadImage:dashboardItem.imageName];
    cell.playButtonOverlayImageView.layer.borderColor = [UIColor colorWithRed:243.0f/255.0f green:243.0f/255.0f blue:243.0f/255.0f alpha:1.0f].CGColor;
    cell.playButtonOverlayImageView.layer.borderWidth = 1.0f;
    
    if (!productThumbnailImage.image)
    {
        ////nslog(@">>>>> thumnbnail not set or found. using placeholder image!!!!!");
        // productThumbnailImage.image = [UIImage imageNamed:PRODUCT_THUMBNAIL_IMAGE_NOT_FOUND];200 157
        UILabel * producttitle;
        
        producttitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 112, 82)];
        
        producttitle.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        producttitle.text = dashboardItem.title;
        producttitle.numberOfLines = 0;
        producttitle.font = [UIFont fontWithName:@"Arial" size:14];
        producttitle.textAlignment = NSTextAlignmentCenter;
        [productThumbnailImage addSubview:producttitle];
        UIGraphicsBeginImageContext(productThumbnailImage.bounds.size);
        [productThumbnailImage.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *bitmap = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        productThumbnailImage.image = bitmap;
        
    }
    if ((int)dashboardItem.itemType == kProductVideo)
    {
        //cell.playButtonOverlayImageView.hidden = NO;
        
        //cell.playButtonOverlayImageView.image = [UIImage imageNamed:@"product_videos_select2"];
    }
    else{
        //cell.playButtonOverlayImageView.hidden = YES;
    }
    cell.contentImageView.image = productThumbnailImage.image;
    productThumbnailImage = nil;
    
    //long press setup
    UILongPressGestureRecognizer *longPressGesture =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    cell.productDetailCellLongPress = longPressGesture;
    [cell addGestureRecognizer:longPressGesture];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ////nslog(@"cell #%d was selected", indexPath.row);
    
    if (isComingThroughProcedure)
    {
        isFromProcFlowToViewer = YES;
    }
    
    DashboardItem *dashboardItem = [self.dashboardItems objectAtIndex:indexPath.row];
    if (dashboardItem)
    {
        //int itemType = dashboardItem.itemType;
        int itemId = dashboardItem.itemId;
        
        Content *content = [_contentAreaContents objectAtIndex:itemId];
        if (content)
        {
            ////nslog(@"content.path: %@", content.path);
            
            //NSString* targetPath = [[ContentModel sharedInstance] addAppDocumentsPathToPath:content.path];
            
            //targetPath = [targetPath stringByAppendingString:@"/index.html"];
            
            // add MyRecentlyViewed
            [[DashboardModel sharedInstance] addRecentlyViewedForContent:content];
            
            //ResourceViewerViewController* rviewer = [[ResourceViewerViewController alloc] initWithNibName:@"ResourceView" bundle:nil];
            //rviewer.filePath = targetPath;
            //[self presentViewController:rviewer animated:NO completion:nil];
            //[rviewer play];
            
            NSString *tempStr = [NSString stringWithFormat:@"%@:%@", content.cntId, dashboardItem.title];
            //NSLog(@"TempStr = %@", tempStr);
            
            [[TrackingModel sharedInstance] createTrackingDataWithResource:tempStr activityCode:TRACKING_ACTIVITY_VIEWED_PRODUCT_ASSET];
            
            //NSLog(@"TRACKING-VIEWED_ASSET in didSelectItem for %@", dashboardItem.title);

            [self openContentInContentViewer:content];
        }
    }
}

#pragma mark -
#pragma mark UIGestureRecognizer Methods

- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    // only when gesture was recognized, not when ended
	if (gesture.state == UIGestureRecognizerStateBegan)
	{
		// get affected cell
		ProductDetailCVCell *cell = (ProductDetailCVCell *)[gesture view];
        
		// get indexPath of cell
		NSIndexPath *indexPath = [self.contentsCollectionView indexPathForCell:cell];
        Content *content = [_contentAreaContents objectAtIndex:indexPath.row];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
        {
            // iOS 8 logic
            self.view.window.tintColor = [UIColor grayColor];
        }

        
        BOOL isFavorite = [[FavoritesModel sharedInstance] isContentAFavorite:content];
        NSString *str;
        
        if (isFavorite)
        {
            str = @"Already a Favorite";
            
            if (content.isSharable == [NSNumber numberWithInt:0])
            {
                //nslog(@"Favorite and NOT sharable");
                UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: str
                                                                          delegate: self
                                                                 cancelButtonTitle: nil
                                                            destructiveButtonTitle: nil
                                                                 otherButtonTitles: @"OK",nil];
                
                actionSheet.tag = kActionSheetIsFavoriteTagCancel;
                
                
                [actionSheet showFromRect: cell.frame inView: cell.superview animated: YES];
                
                self.contentLongPressIndexPath = indexPath;
                
                
            }
            else if (content.isSharable == [NSNumber numberWithInt:1])
            {
                ////nslog(@"Favorite and sharable");
                UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: str
                                                                          delegate: self
                                                                 cancelButtonTitle: nil
                                                            destructiveButtonTitle: nil
                                                                 otherButtonTitles: @"Share",nil];
                
                actionSheet.tag = kActionSheetIsFavoriteTagCancelandSharable;
                
                [actionSheet showFromRect: cell.frame inView: cell.superview animated: YES];
                
                self.contentLongPressIndexPath = indexPath;
                
            }
        }
        else
        {
            str = @"Add to Favorites";
            
            if (content.isSharable == [NSNumber numberWithInt:0])
            {
                ////nslog(@"Not Favorite and NOT sharable");
                
                UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                                          delegate: self
                                                                 cancelButtonTitle: nil
                                                            destructiveButtonTitle: nil
                                                                 otherButtonTitles: str, nil];
                
                actionSheet.tag = kActionSheetIsFavoriteTagAddToFavorite;
                
                [actionSheet showFromRect: cell.frame inView: cell.superview animated: YES];
                
                self.contentLongPressIndexPath = indexPath;
                
                
            }
            else if (content.isSharable == [NSNumber numberWithInt:1])
            {
                ////nslog(@"Not Favorite and sharable");
                
                UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                                          delegate: self
                                                                 cancelButtonTitle: nil
                                                            destructiveButtonTitle: nil
                                                                 otherButtonTitles: str, @"Share", nil];
                
                actionSheet.tag = kActionSheetIsFavoriteTagAddToFavorite;
                
                [actionSheet showFromRect: cell.frame inView: cell.superview animated: YES];
                
                self.contentLongPressIndexPath = indexPath;
                
            }
        }
    }
}

-(void)handleShare:(id)sender
{
    Content *content = [_contentAreaContents objectAtIndex:self.contentLongPressIndexPath.row];
    if (content)
    {
        TabBarViewController *tabCntrl = (TabBarViewController *) self.tabBarController;
        [tabCntrl invokeEmailQueueOverlayVCWithContent:content];
    }
}

- (IBAction)myCVPageControlSwiped:(id)sender
{
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.contentsCollectionView.frame.size.width * self.contentPageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.contentsCollectionView.frame.size;
    [self.contentsCollectionView scrollRectToVisible:frame animated:YES];
    
    // Keep track of when scrolls happen in response to the page control
    // value changing. If we don't do this, a noticeable "flashing" occurs
    // as the the scroll delegate will temporarily switch back the page
    // number.
    pageControlBeingUsed = YES;
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate

// keep the page control in-sync with the scrollview
// called when any offset changes
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!pageControlBeingUsed)
    {
        // Update the page when more than 50% (when pageWidth/2) of the previous/next page is visible
        CGFloat pageWidth = self.contentsCollectionView.frame.size.width;
        int page = floor((self.contentsCollectionView.contentOffset.x - pageWidth / 7) / pageWidth) + 1;
        self.contentPageControl.currentPage = page;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlBeingUsed = NO;
    //CGPoint location = [scrollView.panGestureRecognizer locationInView:scrollView];
    ////nslog(@"%@",NSStringFromCGPoint(location));
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
}



@end
