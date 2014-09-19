//
//  ProcedureVC.m
//  edge
//
//  Created by iPhone Developer on 6/4/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "ProcedureVC.h"
#import "AppDelegate.h"
#import "DashboardModel.h"
#import "ContentModel.h"
#import "Content.h"
#import "Speciality.h"
#import "Procedure.h"
#import "MyEntitlement.h"
#import "KxMenu.h"
#import "DashboardModel.h"
#import "DashboardVC.h"
#import "ResourceViewerViewController.h"
#import "SpecialtyHotSpot.h"
#import "ProcedureModel.h"
#import "ProcedureCVCell.h"
#import "FavoritesModel.h"
#import "InteractiveViewerModel.h"
#import "PrivacyPolicyVC.h"
#import "TrackingModel.h"

#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]

@implementation HotSpotBtn
@end

@interface ProcedureVC ()
@property (nonatomic, strong) NSArray *dashboardItems;
@property (nonatomic, strong) NSArray *contentAreaContents;
@property (nonatomic, strong) UILabel *noContentLabel;

@end

@implementation ProcedureVC

{
    BOOL pageControlBeingUsed;
    int contentTypeNdx;
}

int selectedSortType;

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
    self.refernceView.hidden = YES;
    
    self.refernceViewborder.layer.cornerRadius = 8.0f;
    self.refernceViewborder.layer.borderWidth = 1.f;
    self.refernceViewborder.layer.borderColor = [UIColor lightGrayColor].CGColor;
	// Do any additional setup after loading the view.
    _titleLabel.font = [UIFont fontWithName:@"StagSans-Book" size:21];
    _specialtyMenuBtn.titleLabel.font = [UIFont fontWithName:@"StagSans-Book" size:21];
    _procedureMenuBtn.titleLabel.font = [UIFont fontWithName:@"StagSans-Book" size:21];
    pageControlBeingUsed = NO;
    
    //round border for contentarea
    _contentsAreaView.layer.cornerRadius = 8.0f;
    _contentsAreaView.layer.borderColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f].CGColor;
    _contentsAreaView.layer.borderWidth = 1.f;
    _contentsAreaView.clipsToBounds = YES;
    
    [self initViews];
    
    selectedSortType = kAssetsSortTypeVideo;
    if (![[DashboardModel sharedInstance]currentSpeciality])
    {
        [self loadDefaultSpecialty];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:)
                                                 name:@"refreshView" object:nil];
}

-(void)refreshView:(NSNotification *) notification
{

    [self loadDefaultSpecialty];
    
    [self viewWillAppear:YES];
    
}

- (void)loadDefaultSpecialty
{
    //set current procedure as nil bc of default specialty load never has procedure
    [[DashboardModel sharedInstance] setCurrentProcedure:nil];

    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    ////nslog(@"User Defaults object for key specialty = %@", [userDefaults objectForKey:@"speciality"]);
    
    @autoreleasepool {
    
    NSArray *specs = [[DashboardModel sharedInstance] specialities];
        
    NSString* defaultSpecialty = [userDefaults objectForKey:@"speciality"];
    if ((specs && specs.count > 0) && defaultSpecialty)
    {
        for (Speciality* speciality in specs)
        {
            if ([speciality.name isEqualToString:defaultSpecialty])
            {
                [[DashboardModel sharedInstance] setCurrentSpeciality:speciality];
                break;
            }
            else
            {
                Speciality *spec = [specs objectAtIndex:0];
                ////nslog(@"Specialty object at index 0  = %@", [[specs objectAtIndex:0] name]);
                [[DashboardModel sharedInstance] setCurrentSpeciality:spec];

            }
        }
        ////nslog(@"Current Specialty = %@", [[DashboardModel sharedInstance] currentSpeciality].name);
    }
    else
    {
      Speciality *spec = [specs objectAtIndex:0];
      ////nslog(@"Specialty object at index 0  = %@", [[specs objectAtIndex:0] name]);
      [[DashboardModel sharedInstance] setCurrentSpeciality:spec];
    }
    }
}

- (void) updateView
{
    self.interactiveViewerBtn.hidden =  YES;

    [self.procedureCollectionView reloadData];
    [self updateMenus];
    
    int customerType = ([[DashboardModel sharedInstance] currentCustomerType]? [[DashboardModel sharedInstance] currentCustomerType] :0);
    
    // load Specialty or Procedure data
    if (![[DashboardModel sharedInstance] currentProcedure])
    {
        [self loadSpecialityData];
        [self.interactiveViewerBtn setImage:[UIImage imageNamed:@"newspl_iteractive_select.png"] forState:UIControlStateNormal];
        self.interactiveViewerBtn.showsTouchWhenHighlighted = TRUE;

       // [self.interactiveViewerBtn setImage:[UIImage imageNamed:@"spl_iteractive_select"] forState:UIControlStateHighlighted];
        
        ////nslog(@"Specialty selected is %@", [[DashboardModel sharedInstance] currentSpeciality].name);
        
        NSArray *array;
        array = [[InteractiveViewerModel sharedInstance] fetchSpecialtyIV:[NSNumber numberWithInt:[[DashboardModel sharedInstance] currentSpecialityId]] withTarget: [NSNumber numberWithInt:(customerType < 10? customerType: 0)]];

        ////nslog(@"Current customer type update menu = %@", [NSNumber numberWithInt:[[DashboardModel sharedInstance] currentCustomerType]]);
        /*
        if (![[DashboardModel sharedInstance] currentCustomerType] == kCustomerTypeDefault)
        {
            array = [[InteractiveViewerModel sharedInstance] fetchSpecialtyIV:[NSNumber numberWithInt:[[DashboardModel sharedInstance] currentSpecialityId]] withTarget: [NSNumber numberWithInt:[[DashboardModel sharedInstance] currentCustomerType]]];
            self.interactiveViewerBtn.hidden =  NO;
        }
        else
        {
            //default to customertype 0
            array = [[InteractiveViewerModel sharedInstance] fetchSpecialtyIV:[NSNumber numberWithInt:[[DashboardModel sharedInstance] currentSpecialityId]] withTarget: [NSNumber numberWithInt:0]];
            self.interactiveViewerBtn.hidden =  NO;
        }
         */
        if ([array count] > 0)
        {
            self.interactiveViewerBtn.hidden =  NO;

        }
        
        NSString *tempStr = [NSString stringWithFormat:@"%@:%@", [[DashboardModel sharedInstance] currentSpeciality].splId, [[DashboardModel sharedInstance] currentSpeciality].name];

        [[TrackingModel sharedInstance] createTrackingDataWithResource:tempStr activityCode:TRACKING_ACTIVITY_VIEWED_PROCEDURE_SPECIALTY];
        
    }
    else
    {
        [self loadProcedureData];
        [self.interactiveViewerBtn setImage:[UIImage imageNamed:@"newprocedure_select_iv.png"] forState:UIControlStateNormal];
        self.interactiveViewerBtn.showsTouchWhenHighlighted = TRUE;

       // [self.interactiveViewerBtn setImage:[UIImage imageNamed:@"procedure_select_iv"] forState:UIControlStateHighlighted];
        
        ////nslog(@"Procedure selected is %@", [[DashboardModel sharedInstance] currentProcedure].name);
        ////nslog(@"ProcedureIV = %@", [[InteractiveViewerModel sharedInstance] fetchProcedureIV:[NSNumber numberWithInt:4] withTarget: [NSNumber numberWithInt:1]]);
        NSArray *array;
        array = [[InteractiveViewerModel sharedInstance] fetchProcedureIV:[[DashboardModel sharedInstance] currentProcedure].procId withTarget: [NSNumber numberWithInt:(customerType < 10? customerType: 0)]]; //Since NSNotFound is a large integer value, consider just upto 10 TARGETAUDIENCE.
        
        ////nslog(@"Current customer type update menu = %@", [NSNumber numberWithInt:[[DashboardModel sharedInstance] currentCustomerType]]);
        
        //NSArray *array;
/*
        if (![[DashboardModel sharedInstance] currentCustomerType] == kCustomerTypeDefault)
        {
            array = [[InteractiveViewerModel sharedInstance] fetchProcedureIV:[[DashboardModel sharedInstance] currentProcedure].procId withTarget: [NSNumber numberWithInt:[[DashboardModel sharedInstance] currentCustomerType]]];
            self.interactiveViewerBtn.hidden =  NO;

        }
        else
        {
            //default to customertype 0
            array = [[InteractiveViewerModel sharedInstance] fetchProcedureIV:[[DashboardModel sharedInstance] currentProcedure].procId withTarget: [NSNumber numberWithInt:0]];
            self.interactiveViewerBtn.hidden =  NO;
        }
 */
        if ([array count] > 0)
        {
            self.interactiveViewerBtn.hidden =  NO;
            
        }
        
        NSString *tempStr = [NSString stringWithFormat:@"%@:%@", [[DashboardModel sharedInstance] currentProcedure].procId, [[DashboardModel sharedInstance] currentProcedure].name];
        
        [[TrackingModel sharedInstance] createTrackingDataWithResource:tempStr activityCode:TRACKING_ACTIVITY_VIEWED_PROCEDURE];
        
    }
}

- (IBAction)interactiveViewerButtonTouched:(id)sender
{
    // load Specialty or Procedure data
    if (![[DashboardModel sharedInstance] currentProcedure])
    {
        //SPECIALTY
        [self loadSpecialityData];
        
       // //nslog(@"SpecialtyIV = %@", [[InteractiveViewerModel sharedInstance] fetchSpecialtyIV:[NSNumber numberWithInt:1] withTarget: [NSNumber numberWithInt:1]]);
        int customerType = ([[DashboardModel sharedInstance] currentCustomerType]? [[DashboardModel sharedInstance] currentCustomerType] :0);

        if ([[DashboardModel sharedInstance] currentSpecialityId])
        {
            ////nslog(@"Current specialty id = %d", [[DashboardModel sharedInstance] currentSpecialityId]);
            ////nslog(@"Target Audience = %u", [[DashboardModel sharedInstance] currentCustomerType]);

            NSArray *array;
            
            //below array should be correct but no customer type
            //array = [[InteractiveViewerModel sharedInstance] fetchSpecialtyIV:[NSNumber numberWithInt:[[DashboardModel sharedInstance] currentSpecialityId]] withTarget: [NSNumber numberWithInt:[[DashboardModel sharedInstance] currentCustomerType]]];

            /*
            //check if app has a customer type set if not set it
            if ([[DashboardModel sharedInstance] currentCustomerType])
            {
                array = [[InteractiveViewerModel sharedInstance] fetchSpecialtyIV:[NSNumber numberWithInt:[[DashboardModel sharedInstance] currentSpecialityId]] withTarget:[NSNumber numberWithInt:[[DashboardModel sharedInstance] currentCustomerType]]];

            }
            else
            {
                array = [[InteractiveViewerModel sharedInstance] fetchSpecialtyIV:[NSNumber numberWithInt:[[DashboardModel sharedInstance] currentSpecialityId]] withTarget:[NSNumber numberWithInt:1]];
            }
            */
            //using to get viewer temporary
            array = [[InteractiveViewerModel sharedInstance] fetchSpecialtyIV:[NSNumber numberWithInt:[[DashboardModel sharedInstance] currentSpecialityId]] withTarget:[NSNumber numberWithInt:(customerType < 10? customerType: 0)]];
           
            if ([array count] > 0)
            {
                NSString *str = [array objectAtIndex:0];
                str = [[ContentModel sharedInstance] addAppDocumentsPathToPath:str];
                
                ///get path and setup resource viewer
                if ([[str pathExtension] isEqual: @""])
                {
                    str = [NSString stringWithFormat:@"%@", str];
                }
                NSString* targetPath = str;
                ResourceViewerViewController* rviewer = [[ResourceViewerViewController alloc] initWithNibName:@"ResourceView" bundle:nil];
                rviewer.filePath = targetPath;
                
                ///Traverse string to get cntid
                NSString *totalString = str;
                NSRange urlStart = [totalString rangeOfString: @"specialtyiv/"];
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
                //
                
                NSString *tempStr = [NSString stringWithFormat:@"%@:%@", finalStringWithCntID, [[DashboardModel sharedInstance] currentSpeciality].name];
                
                [[TrackingModel sharedInstance] createTrackingDataWithResource:tempStr activityCode:TRACKING_ACTIVITY_VIEWED_SPECIALTY_INTERACTIVE_VIEWER_ASSET];

                [self presentViewController:rviewer animated:NO completion:nil];
                [rviewer play];
            }
        }
        
    }
    else
    {
        //PROCEDURE
        [self loadProcedureData];
        
        ////nslog(@"ProcedureIV = %@", [[InteractiveViewerModel sharedInstance] fetchProcedureIV:[NSNumber numberWithInt:4] withTarget: [NSNumber numberWithInt:1]]);
        int customerType = ([[DashboardModel sharedInstance] currentCustomerType]? [[DashboardModel sharedInstance] currentCustomerType] :0);
        if ([[DashboardModel sharedInstance] currentProcedure].procId)
        {
            ////nslog(@"Current Procedure = %@", [[DashboardModel sharedInstance] currentProcedure].name);
            ////nslog(@"Target Audience = %u", [[DashboardModel sharedInstance] currentCustomerType]);

            NSArray *array;
            
            
            //below array should be correct but no customer type
            //array = [[InteractiveViewerModel sharedInstance] fetchProcedureIV:[[DashboardModel sharedInstance] currentProcedure].procId withTarget: [NSNumber numberWithInt:[[DashboardModel sharedInstance] currentCustomerType]]];
            
            /*
            //check if app has a customer type set if not set it
            if ([[DashboardModel sharedInstance] currentCustomerType])
            {
                array = [[InteractiveViewerModel sharedInstance] fetchProcedureIV:[[DashboardModel sharedInstance] currentProcedure].procId withTarget:[NSNumber numberWithInt:[[DashboardModel sharedInstance] currentCustomerType]]];

            }
            else
            {
                array = [[InteractiveViewerModel sharedInstance] fetchProcedureIV:[[DashboardModel sharedInstance] currentProcedure].procId withTarget:[NSNumber numberWithInt:1]];

            }
            */
            //using to get viewer temporary
            array = [[InteractiveViewerModel sharedInstance] fetchProcedureIV:[[DashboardModel sharedInstance] currentProcedure].procId withTarget:[NSNumber numberWithInt:(customerType < 10? customerType: 0)]];
            
            if ([array count] > 0)
            {
                NSString *str = [array objectAtIndex:0];
                ///get path and setup resource viewer
                str = [[ContentModel sharedInstance] addAppDocumentsPathToPath:str];
                if ([[str pathExtension] isEqual: @""])
                {
                    str = [NSString stringWithFormat:@"%@/index.html", str];
                }
                NSString* targetPath = str;
                ResourceViewerViewController* rviewer = [[ResourceViewerViewController alloc] initWithNibName:@"ResourceView" bundle:nil];
                rviewer.filePath = targetPath;
                
                ///Traverse string to get cntid
                NSString *totalString = str;
                NSRange urlStart = [totalString rangeOfString: @"procedureiv/"];
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
                //
                
                NSString *tempStr = [NSString stringWithFormat:@"%@:%@", finalStringWithCntID, [[DashboardModel sharedInstance] currentProcedure].name];
                
                [[TrackingModel sharedInstance] createTrackingDataWithResource:tempStr activityCode:TRACKING_ACTIVITY_VIEWED_PROCEDURE_INTERACTIVE_VIEWER_ASSET];

                
                [self presentViewController:rviewer animated:NO completion:nil];
                [rviewer play];
            }
            else
            {
                //UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Interactive Viewer Touched but no content" message:[NSString stringWithFormat:@"For procedure %@", [[DashboardModel sharedInstance] currentProcedure].name] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                //[av show];
            }
        }
    }
}

/*
- (IBAction)interactiveViewerButtonTouched:(id)sender
{
    // load Specialty or Procedure data
    if (![[DashboardModel sharedInstance] currentProcedure])
    {
        [self loadSpecialityData];

        //nslog(@"SpecialtyIV = %@", [[InteractiveViewerModel sharedInstance] fetchSpecialtyIV:[NSNumber numberWithInt:1] withTarget: [NSNumber numberWithInt:1]]);
        
        NSArray *array;
        array = [[InteractiveViewerModel sharedInstance] fetchSpecialtyIV:[NSNumber numberWithInt:1] withTarget: [NSNumber numberWithInt:1]];
        
        if ([array count] > 0)
        {
            NSString *str = [array objectAtIndex:0];
            str = [[ContentModel sharedInstance] addAppDocumentsPathToPath:str];

            ///get path and setup resource viewer
            if ([[str pathExtension] isEqual: @""]) {
                str = [NSString stringWithFormat:@"%@/index.html", str];
            }
            NSString* targetPath = str;
            ResourceViewerViewController* rviewer = [[ResourceViewerViewController alloc] initWithNibName:@"ResourceView" bundle:nil];
            rviewer.filePath = targetPath;
            [self presentViewController:rviewer animated:NO completion:nil];
            [rviewer play];
        }
        else
        {
            PrivacyPolicyVC *vc = [[PrivacyPolicyVC alloc] initWithNibName:@"PrivacyPolicyVC" bundle:nil];
            vc.istypeof = @"SPLIV";
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
    else
    {
        [self loadProcedureData];
        
        ////nslog(@"ProcedureIV = %@", [[InteractiveViewerModel sharedInstance] fetchProcedureIV:[NSNumber numberWithInt:4] withTarget: [NSNumber numberWithInt:1]]);
        NSArray *array;
        array = [[InteractiveViewerModel sharedInstance] fetchProcedureIV:[NSNumber numberWithInt:4] withTarget: [NSNumber numberWithInt:1]];
        
        if ([array count] > 0)
        {
            NSString *str = [array objectAtIndex:0];
            ///get path and setup resource viewer
            str = [[ContentModel sharedInstance] addAppDocumentsPathToPath:str];
            if ([[str pathExtension] isEqual: @""]) {
                str = [NSString stringWithFormat:@"%@/index.html", str];
            }
            NSString* targetPath = str;
            ResourceViewerViewController* rviewer = [[ResourceViewerViewController alloc] initWithNibName:@"ResourceView" bundle:nil];
            rviewer.filePath = targetPath;
            [self presentViewController:rviewer animated:NO completion:nil];
            [rviewer play];
        }
        else
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Interactive Viewer Touched but no content" message:[NSString stringWithFormat:@"For procedure %@", [[DashboardModel sharedInstance] currentProcedure].name] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [av show];

        }

    }

}
*/
/*
- (void) viewWillAppear:(BOOL)animated
{
    // be sure to call base class
    [super viewWillAppear:animated];
    
    if (self.procedureARCViewBtn.hidden == NO)
    {
        //Set to keep blinking effect
        self.procedureARCViewBtn.alpha = 1.0f;

    }
    if (![[DashboardModel sharedInstance]currentSpeciality])
    {
        [self loadDefaultSpecialty];
        
    }
    else
    {
        [self loadDefaultSpecialty];
    }
    [self updateView];
    
}
*/

- (void) viewWillAppear:(BOOL)animated
{
    // be sure to call base class
    [super viewWillAppear:animated];
    
    if (self.procedureARCViewBtn.hidden == NO)
    {
        //Set to keep blinking effect
        self.procedureARCViewBtn.alpha = 1.0f;
        
    }
    
    if (![[DashboardModel sharedInstance] currentSpeciality])
    {
        [[DashboardModel sharedInstance] setCurrentProcedure:nil];

        [self loadDefaultSpecialty];
    }
    
    Speciality *spec = [[DashboardModel sharedInstance] currentSpeciality];
    [[DashboardModel sharedInstance] setCurrentSpecialityId:[spec.splId intValue]];
    
    [self updateView];
    [self.procedureCollectionView reloadData];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    // be sure to call base class
    [super viewDidAppear:animated];
    
    ////nslog(@"Current selected specialty = %@", [[DashboardModel sharedInstance] currentSpeciality].name);
    ////nslog(@"Current selected procedure = %@", [[DashboardModel sharedInstance] currentProcedure].name);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

   // [[DashboardModel sharedInstance] setCurrentProcedure:nil];
}

#pragma mark - initViews

- (void) initViews
{
    [self customizeScrollView:_assetsScrollView];
}

- (void) loadSpecialityData
{
    Speciality *speciality = [[DashboardModel sharedInstance] currentSpeciality];
    
    if (speciality)
    {
        ////nslog(@"ProcedureVC . viewDidLoad . speciality.name: %@", speciality.name);
        
        // speciality image
        NSArray *contents = [[ContentModel sharedInstance] contentsForSpeciality:speciality withContentCatIds:[NSArray arrayWithObject:[NSNumber numberWithInt:kSpecialtyImage]]];
        
        if (contents && contents.count > 0)
        {
            Content *content = [contents objectAtIndex:0];
            if (content)
            {
                UIImage *image = [self.appDelegate loadImage:content.path];
                if (image)
                {
                    ////nslog(@"specialty cntId: %d image: %@", [content.cntId intValue], content.path);
                    _imageView.image = image;
                }
            }
        }
        
        // first, remove the previous hot spots, if any
        NSArray *subs = [self.view subviews];
        for (UIView *view in subs)
        {
            if ([view isKindOfClass:[HotSpotBtn class]])
            {
                [view removeFromSuperview];
            }
        }
        
        // if Procedure not selected, then create the Specialty hot spots over the image.
        /*
        if (![[DashboardModel sharedInstance] currentProcedure])
        {
            // look up the hot spots for the Speciality
            NSArray *hots = [[ContentModel sharedInstance] hotSpotsForSpecialty:speciality];
            for (SpecialtyHotSpot *hot in hots)
            {
                HotSpotBtn *btn = [self createHotSpotBtnWithSpecialtyHotSpot:hot];
                [self.view addSubview:btn];
            }
            
        }
         */
        
        // speciality description
        contents = [[ContentModel sharedInstance] contentsForSpeciality:speciality withContentCatIds:[NSArray arrayWithObject:[NSNumber numberWithInt:kSpecialtyMessage]]];
        
        [_descriptionWebView loadHTMLString:@"" baseURL:nil];
        if (contents && contents.count > 0)
        {
            Content *content = [contents objectAtIndex:0];
            if (content)
            {
                NSString *path = [[[ContentModel sharedInstance] addAppDocumentsPathToPath:content.path] stringByAppendingString:@""];
                
                if (path)
                {
                    [_descriptionWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];

                }
                
            }
        }
        else
        {
            ////nslog(@"No contents for specialty message");

        }
        // speciality assets
        [self loadAssetsBasedOnSort];
        
    }
    else
    {
        ////nslog(@"Load specialty data method and has no specialty");
        
    }
}

- (void) loadProcedureData
{
    Procedure *procedure = [[DashboardModel sharedInstance] currentProcedure];
    
    ////nslog(@"procedure name: %@ procId: %d", procedure.name, [procedure.procId intValue]);
    
    if (procedure)
    {
        // procedure image
        NSArray *contents = [[ContentModel sharedInstance] contentsForProcedure:procedure withContentCatIds:[NSArray arrayWithObject:[NSNumber numberWithInt:kProcedureImage]]];
        
        if (contents && contents.count > 0)
        {
            Content *content = [contents objectAtIndex:0];
            if (content)
            {
                UIImage *image = [self.appDelegate loadImage:content.path];
                if (image)
                {
                    _imageView.image = image;
                }
            }
        } else{
            _imageView.image = nil;
        }
        
        // first, remove the previous hot spots, if any
        NSArray *subs = [self.view subviews];
        for (UIView *view in subs)
        {
            if ([view isKindOfClass:[HotSpotBtn class]])
            {
                [view removeFromSuperview];
            }
        }
        
        // procedure description
        contents = [[ContentModel sharedInstance] contentsForProcedure:procedure withContentCatIds:[NSArray arrayWithObject:[NSNumber numberWithInt:kProcedureMessage]]];
        
        if (contents && contents.count > 0)
        {
            Content *content = [contents objectAtIndex:0];
            if (content)
            {
                NSString *path = [[[ContentModel sharedInstance] addAppDocumentsPathToPath:content.path] stringByAppendingString:@""];
                
                if (path)
                {
                    [_descriptionWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
                }
                
            }
        }
        
        // procedure assets
        [self loadAssetsBasedOnSort];
    }
}

- (void) loadAssetsBasedOnSort
{
    //int contentCatId;
    NSArray *contentCatIds;

    if ([DashboardModel sharedInstance].currentProcedure)
    {
        switch (selectedSortType) {
            case kAssetsSortTypeVideo:
                //contentCatId = kProcedureVideo;
                contentCatIds = [NSArray arrayWithObject:[NSNumber numberWithInt:kProcedureVideo]];

                break;
            case kAssetsSortTypeArticle:
                //contentCatId = kProcedureArticle;
                contentCatIds = [NSArray arrayWithObject:[NSNumber numberWithInt:kProcedureArticle]];

                break;
            case kAssetsSortTypeResources:
                //contentCatId = kProcedureMessage;
                contentCatIds = [NSArray arrayWithObjects:[NSNumber numberWithInt:kProcedureOtherCollateralBrochures], [NSNumber numberWithInt:kProcedureOtherCollateralCharts], [NSNumber numberWithInt:kProcedureOtherCollateralFAQS], [NSNumber numberWithInt:kProcedureOtherCollateralOther], [NSNumber numberWithInt:kProcedureOtherCollateralApps], nil];
                break;
                
            default:
                //contentCatId = kProcedureVideo;
                contentCatIds = [NSArray arrayWithObject:[NSNumber numberWithInt:kProcedureVideo]];

                break;
        }
        
        [self loadAssetsWithContents:[[ContentModel sharedInstance] contentsForProcedure:[DashboardModel sharedInstance].currentProcedure withContentCatIds:contentCatIds]];
    }
    else
    {
        switch (selectedSortType) {
            case kAssetsSortTypeVideo:
                //contentCatId = kSpecialtyVideo;
                contentCatIds = [NSArray arrayWithObject:[NSNumber numberWithInt:kSpecialtyVideo]];

                break;
            case kAssetsSortTypeArticle:
                //contentCatId = kSpecialtyArticle;
                contentCatIds = [NSArray arrayWithObject:[NSNumber numberWithInt:kSpecialtyArticle]];

                break;
            case kAssetsSortTypeResources:
                //contentCatId = kSpecialtyMessage;
                contentCatIds = [NSArray arrayWithObjects:[NSNumber numberWithInt:kSpecialtyOtherCollateralBrochures], [NSNumber numberWithInt:kSpecialtyOtherCollateralCharts], [NSNumber numberWithInt:kSpecialtyOtherCollateralFAQS], [NSNumber numberWithInt:kSpecialtyOtherCollateralOther], [NSNumber numberWithInt:kSpecialtyOtherCollateralApps], nil];

                break;
                
            default:
               // contentCatId = kSpecialtyVideo;
                contentCatIds = [NSArray arrayWithObject:[NSNumber numberWithInt:kSpecialtyVideo]];

                break;
        }
        
        [self loadAssetsWithContents:[[ContentModel sharedInstance] contentsForSpeciality:[DashboardModel sharedInstance].currentSpeciality withContentCatIds:contentCatIds]];
    }
}
/*working
 - (void) loadAssetsBasedOnSort
 {
 int contentCatId;
 
 if ([DashboardModel sharedInstance].currentProcedure)
 {
 switch (selectedSortType) {
 case kAssetsSortTypeVideo:
 contentCatId = kProcedureVideo;
 break;
 case kAssetsSortTypeArticle:
 contentCatId = kProcedureArticle;
 break;
 case kAssetsSortTypeResources:
 contentCatId = kProcedureMessage;
 break;
 
 default:
 contentCatId = kProcedureVideo;
 break;
 }
 
 [self loadAssetsWithContents:[[ContentModel sharedInstance] contentsForProcedure:[DashboardModel sharedInstance].currentProcedure withContentCatIds:[NSArray arrayWithObject:[NSNumber numberWithInt:contentCatId]]]];
 }
 else
 {
 switch (selectedSortType) {
 case kAssetsSortTypeVideo:
 contentCatId = kSpecialtyVideo;
 break;
 case kAssetsSortTypeArticle:
 contentCatId = kSpecialtyArticle;
 break;
 case kAssetsSortTypeResources:
 contentCatId = kSpecialtyMessage;
 break;
 
 default:
 contentCatId = kSpecialtyVideo;
 break;
 }
 
 [self loadAssetsWithContents:[[ContentModel sharedInstance] contentsForSpeciality:[DashboardModel sharedInstance].currentSpeciality withContentCatIds:[NSArray arrayWithObject:[NSNumber numberWithInt:contentCatId]]]];
 }
 }
 */

//collectionview conversion
- (void) loadAssetsWithContents:(NSArray*)contents
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:contents.count];
    
    int ndx = 0;
    DashboardItem *item;
    for (Content *content in contents)
    {
        //NSString *imageName;
        int itemType;
        
        itemType = [content.contentCatId intValue];
        switch (itemType) {
            case kSpecialtyVideo:
            case kProcedureVideo:
                //imageName = @"video_dummy_thumb";
                break;
            case kSpecialtyArticle:
            case kProcedureArticle:
                //imageName = @"article_dummy_thumb";
                break;
            case kSpecialtyMessage:
            case kProcedureMessage:
                //imageName = @"message_dummy_thumb";
                break;
                
            default:
                //imageName = @"message_dummy_thumb";

                break;
        }
        
        self.contentAreaContents = contents;

        item = [[DashboardItem alloc] initWithTitle:content.title
                                           itemType:itemType
                                             itemId:ndx
                                           selected:NO
                                   defaultSelection:NO];
        
        //item.imageName = imageName;
        ////nslog(@"Image name =  %@", item.imageName);
        
        item.imageName = content.thumbnailImgPath;
        ////nslog(@"thumbnailImgPath name =  %@", content.thumbnailImgPath);

        
        [items addObject:item];
        
        ndx++;
    }
    
    self.dashboardItems = items;
    [self.procedureCollectionView reloadData];
    
    //commented out scrollview population - keeping code around to confirm w/ collectionview data scrollview hidden in storyboard
    //[self populateScrollView:_assetsScrollView items:[NSArray arrayWithArray:items]];
    
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
}


/*
- (void) loadAssetsWithContents:(NSArray*)contents
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:contents.count];
 
    int ndx = 0;
    DashboardItem *item;
    for (Content *content in contents)
    {
        NSString *imageName;
        int itemType;
 
        itemType = [content.contentCatId intValue];
        switch (itemType) {
            case kSpecialtyVideo:
            case kProcedureVideo:
                imageName = @"_video-24.png";
                break;
            case kSpecialtyArticle:
            case kProcedureArticle:
                imageName = @"_icon-presentation.png";
                break;
            case kSpecialtyMessage:
            case kProcedureMessage:
                imageName = @"_Message_attention.png";
                break;
                
            default:
                break;
        }
        
        item = [[DashboardItem alloc] initWithTitle:content.title
                                           itemType:itemType
                                             itemId:ndx
                                           selected:NO
                                   defaultSelection:NO];
        item.imageName = imageName;
        
        [items addObject:item];
        
        ndx++;
    }
    
    //_dashboardItems = contents;
    //
    self.dashboardItems = items;
    [self.procedureCollectionView reloadData];
    //
    [self populateScrollView:_assetsScrollView items:[NSArray arrayWithArray:items]];
    
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

    
}
*/

// Specialty - dynamic "hot spot" button support
//

- (HotSpotBtn*)createHotSpotBtnWithSpecialtyHotSpot:(SpecialtyHotSpot*)hot
{
    HotSpotBtn *btn = [HotSpotBtn buttonWithType:UIButtonTypeCustom];
    NSString *htitle = [NSString stringWithFormat:@"splId: %d procId:%d cntId: %d", [hot.splId intValue], [hot.procId intValue], [hot.cntId intValue]];
    [btn setTitle:htitle forState:UIControlStateNormal];
    btn.layer.borderColor = [UIColor blueColor].CGColor;
    btn.layer.borderWidth = 2.f;
    [btn sizeToFit];
    [btn.titleLabel setTextColor:[UIColor redColor]];
    CGRect frame = CGRectMake([hot.x floatValue], [hot.y floatValue], [hot.width floatValue], [hot.height floatValue]);
    btn.frame = [self.imageView convertRect:frame toView:self.view];
    [btn addTarget:self action:@selector(hotSpotTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    // save the hot spot in the button
    btn.hot = hot;
    
    return btn;
}

- (void) hotSpotTouched:(id)sender
{
    HotSpotBtn *btn = (HotSpotBtn*)sender;
    
    //    NSString *title = [NSString stringWithFormat:@"splId: %d procId:%d cntId: %d", [btn.hot.splId intValue], [btn.hot.procId intValue], [btn.hot.cntId intValue]];
    //    [[[UIAlertView alloc] initWithTitle:@"Hot Spot" message:title delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
    
    Procedure *procedure = [[ProcedureModel sharedInstance] procedureWithProcId:[btn.hot.procId intValue]];
    [[DashboardModel sharedInstance] setCurrentProcedure:procedure];
    [self updateView];
    [self loadProcedureData];
    self.procedureARCViewBtn.hidden = NO;
    [self arrowBlinkMethod];

}

- (void) resetProcedureSelected
{
    [DashboardModel sharedInstance].currentProcedure = nil;
    [self loadSpecialityData];
    self.procedureARCViewBtn.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    //NSLog(@"ProcedureVC memory warning");

}

- (IBAction) assetsSortChanged
{
    selectedSortType = _assetsSortSegCtl.selectedSegmentIndex;
    
    [self loadAssetsBasedOnSort];
}

- (IBAction) procedureARCViewBtnTouched
{
    [self performSegueWithIdentifier:@"ProcedureARCSegue" sender:nil];
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
        
        
       
        
        NSString * urlstring;
        NSString * filePath2 = [NSString stringWithFormat:@"%@%@",DocumentsDirectory,[[[request URL] absoluteString] substringFromIndex:7]];
       
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
           
                rviewer.filePath = urlstring;
        
            [rviewer play];
            
            
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
            
            
            
            urlstring = [NSString stringWithFormat:@"%@%@?current=%@",DocumentsDirectory,[self.appDelegate getAppContentPath:@"references"],code];
          
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
            self.refernceView.hidden = NO;
           
            _RefernceWebview = [[UIWebView alloc] initWithFrame:CGRectMake(2, 2, 930, 530)];
            _RefernceWebview.backgroundColor = [UIColor whiteColor];
            
            
            NSURL *url = [[NSURL alloc] initWithString:[urlstring stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
            
            
            NSURLRequest *thereq = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:120];
            
            [self.refernceViewborder addSubview:_RefernceWebview];
            [_RefernceWebview loadRequest:thereq];
            [self.RefernceWebview loadRequest:thereq];
            
            
        }
        
    }
    return YES;
}

-(IBAction)closeReferenceview:(id)sender

{
    
    [self.RefernceWebview removeFromSuperview];
    
    
    
    self.refernceView.hidden = YES;
    [_RefernceWebview stopLoading];
    _RefernceWebview = nil;
    [_RefernceWebview loadHTMLString:@"<html><head></head><body></body></html>" baseURL:nil];
    
    
    [self.descriptionWebView reload];
}





#pragma mark -

- (void) populateScrollView:(UIScrollView*)scrollview items:(NSArray*)items
{
    CGFloat vWidth = 160.0f, vHeight = 150.0f;
    CGFloat xOffset = 0.0f, yOffset = 0.0f;
    CGFloat width = 64.0f, height = 64.0f, margin = 10.0f, vsep = 4.0f;
    
    // first clear the scroll view
    [self clearScrollView:scrollview];
    
    CGRect frame;
    UIView *view;
    DashboardItemButton *dashboardBtn;
    DashboardItem *dashboardItem;
    UIImage *img;
    UILabel *lbl;
    for (int i=0; i<items.count; i++)
    {
        dashboardItem = [items objectAtIndex:i];
        
        yOffset = 0.0f;
        view = [[UIView alloc] initWithFrame:CGRectMake(xOffset, yOffset, vWidth, vHeight)];
        //view.layer.borderColor = [UIColor blueColor].CGColor;
        //view.layer.borderWidth = 1.0f;
        
        dashboardBtn = [DashboardItemButton buttonWithType:UIButtonTypeCustom];
        img = [[UIImage imageNamed:dashboardItem.imageName] resizableImageWithCapInsets:UIEdgeInsetsZero];
        ////nslog(@"Scrollview image name = %@", img);
        [dashboardBtn setImage:img forState:UIControlStateNormal];
        
        if (dashboardItem.currentSelection)
        {
            dashboardBtn.layer.borderColor = [UIColor redColor].CGColor;
            dashboardBtn.layer.borderWidth = 2.0f;
        }
        
        frame = dashboardBtn.frame;
        frame.size = CGSizeMake(width, height);
        frame.origin.x = (vWidth - width)/2;
        frame.origin.y = vsep;
        dashboardBtn.frame = frame;
        
        dashboardBtn.dashboardItem = dashboardItem;
        [dashboardBtn addTarget:self action:@selector(dashboardItemSelected:) forControlEvents:UIControlEventTouchDown];
        //[self setupLongPressWithBtn:dashboardBtn];
        
        [view addSubview:dashboardBtn];
        
        if (dashboardItem.defaultSelection)
        {
            UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkbox-checked_16.png"]];
            frame = icon.frame;
            frame.origin.x = dashboardBtn.frame.origin.x + dashboardBtn.frame.size.width - icon.frame.size.width;
            frame.origin.y = dashboardBtn.frame.origin.y + dashboardBtn.frame.size.height - icon.frame.size.height;
            icon.frame = frame;
            [view addSubview:icon];
        }
        
        xOffset = 0.0f;
        yOffset = dashboardBtn.frame.origin.y + dashboardBtn.frame.size.height;
        lbl = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, vWidth, 82.0f)];
        lbl.font = [UIFont systemFontOfSize:16.0f];
        lbl.adjustsFontSizeToFitWidth = YES;
        lbl.text = [NSString stringWithFormat:@"%@", dashboardItem.title];
        lbl.numberOfLines = 0;
        
        {
            lbl.autoresizingMask = UIViewAutoresizingFlexibleWidth |
            UIViewAutoresizingFlexibleHeight;
            //lbl.backgroundColor = [UIColor clearColor];
            lbl.textAlignment = NSTextAlignmentCenter;
            //lbl.font = [UIFont boldSystemFontOfSize:13.0f];
            lbl.textColor = [UIColor darkGrayColor];
            lbl.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
            lbl.shadowOffset = CGSizeMake(0.0f, 1.0f);
            
        }
        
        [view addSubview:lbl];
        
        xOffset = (i * margin) + (i * vWidth) + margin;
        frame = view.frame;
        frame.origin.x = xOffset;
        view.frame = frame;
        
        [scrollview addSubview:view];
    }
    xOffset += (vWidth + margin);
    scrollview.contentSize = CGSizeMake(xOffset, vHeight);
}

- (void) dashboardItemSelected:(id)sender
{
    DashboardItemButton *dashboardBtn = (DashboardItemButton*)sender;
    DashboardItem *dashboardItem = dashboardBtn.dashboardItem;
    
    if (dashboardItem)
    {
        int itemType = dashboardItem.itemType;
        int itemId = dashboardItem.itemId;
        
        Content *content = [_dashboardItems objectAtIndex:itemId];
        if (content)
        {
            ////nslog(@"content.path: %@", content.path);
            
            NSString* targetPath = [[ContentModel sharedInstance] addAppDocumentsPathToPath:content.path];
            
            switch (itemType) {
                case kSpecialtyMessage:
                case kProcedureMessage:
                    targetPath = [targetPath stringByAppendingString:@""];
                    break;
                default:
                    break;
            }
            
            // add MyRecentlyViewed
            [[DashboardModel sharedInstance] addRecentlyViewedForContent:content];
            
            ResourceViewerViewController* rviewer = [[ResourceViewerViewController alloc] initWithNibName:@"ResourceView" bundle:nil];
            rviewer.filePath = targetPath;
            [self presentViewController:rviewer animated:NO completion:nil];
            [rviewer play];
        }
    }
    
}

- (void) updateMenus
{
    NSString *sName;
    if ([[DashboardModel sharedInstance] currentSpeciality])
    {
        sName = [[[DashboardModel sharedInstance] currentSpeciality] name];

    }
    else
    {
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        sName = [userDefaults objectForKey:@"speciality"];

        //sName = @"Specialty";
    }
    //self.specialtyMenuBtn.hidden = !sName;
    [self.specialtyMenuBtn setTitle:[self addDownArrowToTitle:sName] forState:UIControlStateNormal];
    [self sizeToFitToolbarButton:self.specialtyMenuBtn];
    
    NSString *pName;
    if ([[DashboardModel sharedInstance] currentProcedure]) {
        pName = [[[DashboardModel sharedInstance] currentProcedure] name];
        self.procedureARCViewBtn.hidden = NO;
        [self arrowBlinkMethod];

    } else{
        pName = @"Select Procedure";
        self.procedureARCViewBtn.hidden = YES;
    }
    //self.procedureMenuBtn.hidden = !sName;
    [self.procedureMenuBtn setTitle:[self addDownArrowToTitle:pName] forState:UIControlStateNormal];
    [self sizeToFitToolbarButton:self.procedureMenuBtn];
    
    [self.toolbar sizeToFit];
}

- (IBAction) specialtyMenuBtnTouched
{
    //NSOperatingSystemVersion ios8_0_0 = (NSOperatingSystemVersion){8, 0, 0};
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
    {
        // iOS 8 logic
        self.view.window.tintColor = [UIColor grayColor];

        
//        UIAlertController *alertController = [UIAlertController
//                                              alertControllerWithTitle:nil
//                                              message:nil
//                                              preferredStyle:UIAlertControllerStyleActionSheet];
//        
//
//        NSArray *specialties = [[DashboardModel sharedInstance] specialities];
//        
//        for (Speciality *specialty in specialties)
//        {
//            UIAlertAction *okAction = [UIAlertAction
//                                       actionWithTitle:specialty.name
//                                       style:UIAlertActionStyleDefault
//                                       handler:^(UIAlertAction *action)
//                                       {
//                                           NSLog(@"OK action");
//                                       }];
//            
//            [alertController addAction:okAction];
//        }
//        
//        [alertController setModalPresentationStyle:UIModalPresentationPopover];
//        
//        UIPopoverPresentationController *popPresenter = [alertController
//                                                         popoverPresentationController];
//        popPresenter.sourceView = _specialtyMenuBtn;
//        popPresenter.sourceRect = _specialtyMenuBtn.bounds;
//        
//        //[self presentViewController:alertController animated:YES completion:nil];
//        
//        specialties = nil;
//        
//        
//        UIPopoverController *pC = [[UIPopoverController alloc] initWithContentViewController:alertController];
//        
//        CGRect frame = [self.view convertRect:self.specialtyMenuBtn.frame toView:self.view];
//        [pC presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//
//        
//
    }
    
        // iOS 7 and below logic
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                                 delegate: self
                                                        cancelButtonTitle: nil
                                                   destructiveButtonTitle: nil
                                                        otherButtonTitles: nil];
        
        actionSheet.tag = TAG_ACTION_SHEET_SPECIALTY;
        
        NSArray *specialties = [[DashboardModel sharedInstance] specialities];
        
        for (Speciality *specialty in specialties)
        {
            [actionSheet addButtonWithTitle:specialty.name];
            
        }
        
        //for iOS7 to get proper seperator on last item
        [actionSheet addButtonWithTitle:@""];
        [actionSheet setCancelButtonIndex:(actionSheet.numberOfButtons - 1)];
        
        CGRect frame = [self.view convertRect:self.specialtyMenuBtn.frame toView:self.view];
        
        [actionSheet showFromRect:frame inView:self.view animated:YES];
        
        specialties = nil;
        actionSheet = nil;
    
}

- (IBAction) procedureMenuBtnTouched
{
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                              delegate: self
                                                     cancelButtonTitle: nil
                                                destructiveButtonTitle: nil
                                                     otherButtonTitles: nil];
    actionSheet.tag = TAG_ACTION_SHEET_PROCEDURE;
    
    NSArray *procedures = [[[[DashboardModel sharedInstance] currentSpeciality] specialityToProcedure] allObjects];
    
    for (Procedure *procedure in procedures)
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
        {
            [actionSheet addButtonWithTitle:procedure.name];
        }
        else
        {
            //since using actionsheet, HIG states not to change actionsheet size, thus truncate procedure name
            if (procedure.name.length >= 25)
            {
                NSString *origString = procedure.name;
                const int clipLength = 25;
                if([origString length]>clipLength)
                {
                    NSString *first = [origString substringToIndex: 10];   // LEFT$
                    NSString *mid = @"...";
                    NSString *last = [origString substringFromIndex: procedure.name.length -10];  // RIGHT$
                    NSString *appendString = [NSString stringWithFormat:@"%@%@%@",first, mid, last];
                    origString = appendString;
                }
                
                [actionSheet addButtonWithTitle:origString];
            }
            else
            {
                [actionSheet addButtonWithTitle:procedure.name];
            }
        }
    }
    
    ////nslog(@"Number of buttons on actionsheet = %ld", (long)actionSheet.numberOfButtons);
    if (actionSheet.numberOfButtons == 0)
    {
        //"No Procedures Available"];
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"No Procedures for %@", [[DashboardModel sharedInstance] currentSpeciality].name] message:@"Please choose another specialty" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [av show];
    }
    else
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
        {
            // iOS 8 logic
            self.view.window.tintColor = [UIColor grayColor];
            
            //temporary as issues w/ presenting actionsheet on tableview
            [actionSheet addButtonWithTitle:@""];
            [actionSheet setCancelButtonIndex:(actionSheet.numberOfButtons - 1)];
            [actionSheet showFromRect:self.procedureMenuBtn.frame inView:self.view animated:YES];
            
//            //Custom ProcedurePickerVC
//            _procPicker = nil;
//            _procedurePickerPopover = nil;
//            
//            //Create the procedurePickerVC.
//            _procPickVC = [[ProcPickVC alloc] init];
//            
//            //Set this VC as the delegate.
//            _procPickVC.delegate = self;
//            
//            //The _procedurePickerPopover is not showing. Show it.
//            if (!_procedurePickerPopover)
//            {
//                _procedurePickerPopover = [[UIPopoverController alloc] initWithContentViewController:_procPickVC];
//                
//            }
//            
//            //Present popover w/ only up direction
//            [_procedurePickerPopover presentPopoverFromRect:self.procedureMenuBtn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
        else
        {
        //for iOS7 to get proper seperator on last item
        //[actionSheet addButtonWithTitle:@""];
        //[actionSheet setCancelButtonIndex:(actionSheet.numberOfButtons - 1)];
        //[actionSheet showFromRect:self.procedureMenuBtn.frame inView:self.view animated:YES];
        
        //Custom ProcedurePickerVC
        _procPicker = nil;
        _procedurePickerPopover = nil;
        
        //Create the procedurePickerVC.
        _procPicker = [[ProcedurePickerViewController alloc] initWithStyle:UITableViewStylePlain];
        
        //Set this VC as the delegate.
        _procPicker.delegate = self;
        
        //The _procedurePickerPopover is not showing. Show it.
        if (!_procedurePickerPopover)
        {
            _procedurePickerPopover = [[UIPopoverController alloc] initWithContentViewController:_procPicker];

        }
        
        //Present popover w/ only up direction
        [_procedurePickerPopover presentPopoverFromRect:self.procedureMenuBtn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
    }
}

- (void) sizeToFitToolbarButton:(UIButton*)btn
{
    CGFloat ht = btn.frame.size.height;
    [btn sizeToFit];
    CGRect frame = btn.frame;
    frame.size.height = ht;
    btn.frame = frame;
    
}

- (NSString*) addDownArrowToTitle:(NSString*)title_
{
    return [NSString stringWithFormat:@"%@  ▾", title_];
    
}
/*
#pragma mark - UIActionSheetDelegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {   // be careful, cancelButtonIndex = -1
        
        switch (actionSheet.tag) {
            case TAG_ACTION_SHEET_SPECIALTY:
            {
                // set the current Specialty in the Dashboard
                NSArray *specs = [[DashboardModel sharedInstance] specialities];
                Speciality *spec = [specs objectAtIndex:buttonIndex];
                [[DashboardModel sharedInstance] setCurrentSpeciality:spec];
                [[DashboardModel sharedInstance] setCurrentSpecialityId:[spec.splId intValue]];
                [[DashboardModel sharedInstance] setCurrentProcedure:nil];
                
                // set the Specialty menu
                [self.specialtyMenuBtn setTitle:[self addDownArrowToTitle:spec.name] forState:UIControlStateNormal];
                [self sizeToFitToolbarButton:self.specialtyMenuBtn];
                
                // set the Procedure menu as needed
                NSRange rng = NSRangeFromString(@"{ 0, 9}");
                if (![[self.procedureMenuBtn.titleLabel.text substringWithRange:rng] isEqualToString:@"Procedure"])
                {
                    [self.procedureMenuBtn setTitle:[self addDownArrowToTitle:@"Procedure"] forState:UIControlStateNormal];
                    [self sizeToFitToolbarButton:self.procedureMenuBtn];
                    [self toggleViews];
                }
                
                [self.toolbar sizeToFit];
                
                // lastly, reload Specialty data
                self.procedureARCViewBtn.hidden = YES;
                [self updateView];
                [self loadSpecialityData];
            }
                break;
            case TAG_ACTION_SHEET_PROCEDURE:
            {
                // set the current Procedure in the Dashboard
                NSArray *procs = [[[[DashboardModel sharedInstance] currentSpeciality] specialityToProcedure] allObjects];
                Procedure *proc = [procs objectAtIndex:buttonIndex];
                [[DashboardModel sharedInstance] setCurrentProcedure:proc];
                
                // set the Procedure menu as needed
                NSRange rng = NSRangeFromString(@"{ 0, 9}");
                if ([[self.procedureMenuBtn.titleLabel.text substringWithRange:rng] isEqualToString:@"Procedure"])
                {
                    [self toggleViews];
                }
                [self.procedureMenuBtn setTitle:[self addDownArrowToTitle:proc.name] forState:UIControlStateNormal];
                [self sizeToFitToolbarButton:self.procedureMenuBtn];
                
                [self.toolbar sizeToFit];
                
                // lastly, update the view
                self.procedureARCViewBtn.hidden = NO;
                [self updateView];
                [self loadProcedureData];
            }
                break;
                
            default:
                break;
        }
    }
    
}
*/

#pragma mark -
#pragma mark UIActionSheet Methods

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{    
    //Gets an array af all of the subviews of our actionSheet
    NSArray *subviews = [actionSheet subviews];
    
    for (UIView *v in subviews)
    {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *b = (UIButton*)v;
            //[b setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [b setTitleColor:[UIColor colorWithRed:110.0f/255.0f green:110.0f/255.0f blue:110.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [b setTitleColor:[UIColor colorWithRed:243.0f/255.0f green:6.0f/255.0f blue:23.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
        }
    }
    subviews = nil;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kActionSheetIsFavoriteOnProcedureTagAddToFavorite && buttonIndex != 1 && buttonIndex == 0)
    {
        //[self handleAddToFavorites:_longPressDashboardItem];
        Content *content = [_contentAreaContents objectAtIndex:self.contentLongPressIndexPath.row];
        [[FavoritesModel sharedInstance] addFavoriteWithContent:content];
        
        //temp trial test to manage content deletion
        //[self.appDelegate.managedObjectContext deleteObject:content];
        //[self.appDelegate saveContext];
        
    }
    else if (actionSheet.tag == kActionSheetIsFavoriteOnProcedureTagAddToFavorite && buttonIndex == 1)
    {
        //[self handleShare:_longPressDashboardItem];
        [self handleShare:self];
        
        
    }
    else if (actionSheet.tag == kActionSheetIsFavoriteOnProcedureTagCancelandSharable && buttonIndex == 0)
    {
        //[self handleShare:_longPressDashboardItem];
        [self handleShare:self];
        
    }
    else if (actionSheet.tag == kActionSheetIsFavoriteOnProcedureTagCancel && buttonIndex == 1)
    {
        //[self handleShare:_longPressDashboardItem];
        [self handleShare:self];
        
    }
    else if (buttonIndex != actionSheet.cancelButtonIndex)
    {   // be careful, cancelButtonIndex = -1
        
        switch (actionSheet.tag) {
            case TAG_ACTION_SHEET_SPECIALTY:
            {
                // set the current Specialty in the Dashboard
                NSArray *specs = [[DashboardModel sharedInstance] specialities];
                Speciality *spec = [specs objectAtIndex:buttonIndex];
                [[DashboardModel sharedInstance] setCurrentSpeciality:spec];
                [[DashboardModel sharedInstance] setCurrentSpecialityId:[spec.splId intValue]];
                [[DashboardModel sharedInstance] setCurrentProcedure:nil];
                
                // set the Specialty menu
                [self.specialtyMenuBtn setTitle:[self addDownArrowToTitle:spec.name] forState:UIControlStateNormal];
                [self sizeToFitToolbarButton:self.specialtyMenuBtn];
                
                // set the Procedure menu as needed
                NSRange rng = NSRangeFromString(@"{ 0, 9}");
                if (![[self.procedureMenuBtn.titleLabel.text substringWithRange:rng] isEqualToString:@"Procedure"])
                {
                    [self.procedureMenuBtn setTitle:[self addDownArrowToTitle:@"Procedure"] forState:UIControlStateNormal];
                    [self sizeToFitToolbarButton:self.procedureMenuBtn];
                    [self toggleViews];
                }
                
                ////nslog(@"Selected specialty is now = %@", spec.name);
                [self.toolbar sizeToFit];
                
                // lastly, reload Specialty data
                self.procedureARCViewBtn.hidden = YES;
                [self updateView];
                [self loadSpecialityData];
                
                spec = nil;
                specs = nil;
            }
                break;
            case TAG_ACTION_SHEET_PROCEDURE:
            {
                // set the current Procedure in the Dashboard
                NSArray *procs = [[[[DashboardModel sharedInstance] currentSpeciality] specialityToProcedure] allObjects];
                Procedure *proc = [procs objectAtIndex:buttonIndex];
                [[DashboardModel sharedInstance] setCurrentProcedure:proc];
                
                // set the Procedure menu as needed
                NSRange rng = NSRangeFromString(@"{ 0, 9}");
                if ([[self.procedureMenuBtn.titleLabel.text substringWithRange:rng] isEqualToString:@"Procedure"])
                {
                    [self toggleViews];
                }
                [self.procedureMenuBtn setTitle:[self addDownArrowToTitle:proc.name] forState:UIControlStateNormal];
                [self sizeToFitToolbarButton:self.procedureMenuBtn];
                
                [self.toolbar sizeToFit];
                
                // lastly, update the view
                self.procedureARCViewBtn.hidden = NO;
                [self arrowBlinkMethod];
                [self updateView];
                [self loadProcedureData];
            }
                break;
                
            default:
                break;
        }
    }

}

- (void) toggleViews
{
    // no op
}

-(void) arrowBlinkMethod
{
    [UIView animateWithDuration:0.7
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut |
     UIViewAnimationOptionRepeat |
     UIViewAnimationOptionAutoreverse |
     UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.procedureARCViewBtn.alpha = 0.1f;
                     }
                     completion:^(BOOL finished){
                     }];
}

//new for collection view

#pragma mark - Procedure
#pragma mark UICollectionView Data Source Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (![self.dashboardItems count])
    {
        if (!_noContentLabel)
        {
            _noContentLabel = [[UILabel alloc] initWithFrame:collectionView.bounds];
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
    static NSString *identifier = @"ProcedureCVCell";
    
    DashboardItem *dashboardItem;
    dashboardItem = [self.dashboardItems objectAtIndex:indexPath.row];
    
    ProcedureCVCell *cell = (ProcedureCVCell*)[_procedureCollectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];

    //Set artifact title
    NSString *str;
    str = dashboardItem.title;
    cell.contentTitleLabel.text = str;
    
    //UIImage *img;
    //img = [self.appDelegate loadImage:dashboardItem.imageName];
    ////nslog(@"Procedure VC cell for item image view for cell is %@", dashboardItem.imageName);
    
    if (((int)dashboardItem.itemType == kProcedureVideo || (int)dashboardItem.itemType == kSpecialtyVideo))
    {
        
        [cell.playButtonOverlayImageView setImage:[UIImage imageNamed:@"video_small_btn"]];
    }
    else if (((int)dashboardItem.itemType == kSpecialtyArticle || (int)dashboardItem.itemType == kProcedureArticle))
    {
        cell.playButtonOverlayImageView.image = [UIImage imageNamed:@"article_small_btn"];

    }
    else // (((int)dashboardItem.itemType == kSpecialtyMessage || (int)dashboardItem.itemType == kProcedureMessage))
    {
        cell.playButtonOverlayImageView.image = [UIImage imageNamed: @"html_small_btn"];

    }

    cell.contentImageView.image = [self.appDelegate loadImage:dashboardItem.imageName];

    //long press setup
    UILongPressGestureRecognizer *longPressGesture =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    cell.procedureCellLongPress = longPressGesture;
    [cell addGestureRecognizer:longPressGesture];


    return cell;
}

- (NSString*) overlayImageNameForContentCatId:(NSString*)mime
{
    NSString *imageName;
    if ([[mime lowercaseString] isEqualToString:@"application/zip"])
    {
        
        imageName = @"html_small_btn";
        
    }
    else if ([[mime lowercaseString] isEqualToString:@"application/pdf"])
    {
        
        imageName = @"article_small_btn";
        
    }
    
    else if ([[mime lowercaseString] isEqualToString:@"video/quicktime"])
    {
        
        imageName = @"video_small_btn";
        
    }
    else
    {
        
        imageName = @"product_small_btn";
        
    }
       return imageName;
}

/*
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //nslog(@"cell #%d was selected", indexPath.row);
 
    DashboardItem *dashboardItem = [self.dashboardItems objectAtIndex:indexPath.row];
    if (dashboardItem)
    {
        int itemType = dashboardItem.itemType;
        int itemId = dashboardItem.itemId;
        
        
    }
}
*/

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
   // //nslog(@"cell #%d was selected", indexPath.row);

    DashboardItem *dashboardItem = [self.dashboardItems objectAtIndex:indexPath.row];
    ////nslog(@"dashboard item item  %d", dashboardItem.itemId);

    if (dashboardItem)
    {
        //int itemType = dashboardItem.itemType;
        int itemId = dashboardItem.itemId;
        
        Content *content = [_contentAreaContents objectAtIndex:itemId];
        
        if (content)
        {
            // add MyRecentlyViewed
            [[DashboardModel sharedInstance] addRecentlyViewedForContent:content];
            
            [self openContentInContentViewer:content];
            
        }
        
        NSString *tempStr = [NSString stringWithFormat:@"%@:%@", content.cntId, dashboardItem.title];
        [[TrackingModel sharedInstance] createTrackingDataWithResource:tempStr activityCode:TRACKING_ACTIVITY_VIEWED_PROCEDURE_ASSET];
        
        //NSLog(@"TRACKING-PROCEDURE_ASSET in didSelectItem for %@", dashboardItem.title);

    }
}
- (IBAction)myCVPageControlSwiped:(id)sender
{
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.procedureCollectionView.frame.size.width * self.contentPageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.procedureCollectionView.frame.size;
    [self.procedureCollectionView scrollRectToVisible:frame animated:YES];
    
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
        CGFloat pageWidth = self.procedureCollectionView.frame.size.width;
        int page = floor((self.procedureCollectionView.contentOffset.x - pageWidth / 7) / pageWidth) + 1;
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


#pragma mark -
#pragma mark UIGestureRecognizer Methods

- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    // only when gesture was recognized, not when ended
	if (gesture.state == UIGestureRecognizerStateBegan)
	{
		// get affected cell
		ProcedureCVCell *cell = (ProcedureCVCell *)[gesture view];
        
		// get indexPath of cell
		NSIndexPath *indexPath = [self.procedureCollectionView indexPathForCell:cell];
        Content *content = [_contentAreaContents objectAtIndex:indexPath.row];
        
        BOOL isFavorite = [[FavoritesModel sharedInstance] isContentAFavorite:content];
        NSString *str;
        
        if (isFavorite)
        {
            str = @"Already a Favorite";
            
            if (content.isSharable == [NSNumber numberWithInt:0])
            {
                ////nslog(@"Favorite and NOT sharable");
                UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: str
                                                                          delegate: self
                                                                 cancelButtonTitle: nil
                                                            destructiveButtonTitle: nil
                                                                 otherButtonTitles: @"OK",nil];
                
                actionSheet.tag = kActionSheetIsFavoriteOnProcedureTagCancel;
                
                
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
                
                actionSheet.tag = kActionSheetIsFavoriteOnProcedureTagCancelandSharable;
                
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
                
                actionSheet.tag = kActionSheetIsFavoriteOnProcedureTagAddToFavorite;
                
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
                
                actionSheet.tag = kActionSheetIsFavoriteOnProcedureTagAddToFavorite;
                
                [actionSheet showFromRect: cell.frame inView: cell.superview animated: YES];
                
                self.contentLongPressIndexPath = indexPath;
                
            }
        }
    }
}

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

-(void)handleShare:(id)sender
{
    Content *content = [_contentAreaContents objectAtIndex:self.contentLongPressIndexPath.row];
    if (content)
    {
        TabBarViewController *tabCntrl = (TabBarViewController *) self.tabBarController;
        [tabCntrl invokeEmailQueueOverlayVCWithContent:content];
    }
}

#pragma mark - ProcedurePickerDelegate method
-(void)selectedProcedure:(Procedure *)proc;
{
    ////nslog(@"Selected procedure = %@", proc.name);

    // set the current Procedure in the Dashboard
    [[DashboardModel sharedInstance] setCurrentProcedure:proc];
    
    // set the Procedure menu as needed
    NSRange rng = NSRangeFromString(@"{ 0, 9}");
    if ([[self.procedureMenuBtn.titleLabel.text substringWithRange:rng] isEqualToString:@"Procedure"])
    {
        [self toggleViews];
    }
    
    [self.procedureMenuBtn setTitle:[self addDownArrowToTitle:proc.name] forState:UIControlStateNormal];
    [self sizeToFitToolbarButton:self.procedureMenuBtn];
    
    [self.toolbar sizeToFit];
    
    // lastly, update the view
    self.procedureARCViewBtn.hidden = NO;
    [self arrowBlinkMethod];
    [self updateView];
    [self loadProcedureData];
    
    //Dismiss the popover if it's showing.
    if (_procedurePickerPopover)
    {
        [_procedurePickerPopover dismissPopoverAnimated:YES];
        _procedurePickerPopover = nil;
    }
}

@end
