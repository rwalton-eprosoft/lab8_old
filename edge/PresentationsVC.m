//
//  PresentationsVC.m
//  edge
//
//  Created by iPhone Developer on 5/21/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "PresentationsVC.h"
#import "GenericCell.h"
#import "PresentationViewController.h"
#import "PresentationModel.h"
#import "ContentModel.h"
//#import "TabbedDetailsView.h"

#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]


@interface PresentationsVC ()
//@property (strong, nonatomic) TabbedDetailsView *tabbedViews;

@end

@implementation PresentationsVC
@synthesize collectionView,listScrollView,detailScrollView,spinner;
@synthesize listArray,ext,centreButton,appDelegate;

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
    selectedpresentation = 0;
    countCheck = 0;
    _titleLabel.font = [UIFont fontWithName:@"StagSans-Book" size:21];
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _finalArray = [[NSMutableArray alloc] initWithCapacity:0];
    listArray = [[PresentationModel sharedInstance] pathsForPresentations];
    _metalistArray = [[PresentationModel sharedInstance] pathsForMetadataPresentations];
    _totalArray = [[NSMutableArray alloc] init];

    [self loadData];
    self.listScrollView.layer.borderColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0f].CGColor;
    self.listScrollView.layer.cornerRadius = 7;
    self.listScrollView.layer.masksToBounds = YES;
    self.listScrollView.layer.borderWidth = 1.0f;
    self.listScrollView.backgroundColor= [UIColor colorWithRed:243/255.0f green:243/255.0f blue:243/255.0f alpha:1.0f];
    self.detailScrollView.layer.borderColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0f].CGColor;
    self.detailScrollView.layer.cornerRadius = 7;
    self.detailScrollView.layer.masksToBounds = YES;
    self.detailScrollView.layer.borderWidth = 1.0f;
	// Do any additional setup after loading the view.
    //[self createTabs];
    
    _playButton.userInteractionEnabled = NO;
    
    UILabel *appcopyImageView = [[UILabel alloc] initWithFrame:CGRectMake(0, 88, 1024, 620)];
    appcopyImageView.backgroundColor = [UIColor whiteColor];
    appcopyImageView.textAlignment = NSTextAlignmentCenter;
    [appcopyImageView setText:@"There are no presentations available at present."];
    [appcopyImageView setFont:[UIFont fontWithName:@"Arial" size:15]];
    [appcopyImageView setTextColor:[UIColor colorWithRed:110.0/255 green:110.0/255 blue:110.0/255 alpha:1.0]];
    appcopyImageView.hidden = NO;
    [self.view addSubview:appcopyImageView];

    
    if ([listArray count] > 0)
    {
        _playButton.userInteractionEnabled = YES;
        appcopyImageView.hidden = YES;

    }
}


 - (void) viewWillAppear:(BOOL)animated
 {
     if (self.appDelegate.IsupdatedClicked == YES)
     {
         self.appDelegate.IsupdatedClicked = NO;
         _finalArray = [[NSMutableArray alloc] initWithCapacity:0];
         listArray = [[PresentationModel sharedInstance] pathsForPresentations];
         _metalistArray = [[PresentationModel sharedInstance] pathsForMetadataPresentations];
         
         [self loadData];
         
     }
 // be sure to call base class
 [super viewWillAppear:animated];
 
 }


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableViewDataSource

//- (IBAction)prstButton1Clicked:(id)sender {
//    
//    PresentationViewController* presentationViewController = [[PresentationViewController alloc] initWithNibName:@"PresentationViewController" bundle:nil];
//    
//    [self presentViewController:presentationViewController animated:NO completion:nil];
//    [presentationViewController loadPresentations:@"{\"Presentations\":[{\"prstId\":\"1\",\"cntId\":[\"/assets/content/articles/product/3_article__the_science_of_stapling_and_leaks_g__randal_baker_md.pdf\",\"/assets/content/videos/product/109_powered_echelon_flex_gastric_sleeve.mp4\",\"/assets/content/messages/procedure/131_sleeve_gastrectomy/index.html\"]}]}"];
//}
//
//- (IBAction)prstButton2Clicked:(id)sender {
//    
//    PresentationViewController* presentationViewController = [[PresentationViewController alloc] initWithNibName:@"PresentationViewController" bundle:nil];
//    
//    [self presentViewController:presentationViewController animated:NO completion:nil];
//    [presentationViewController loadPresentations:@"{\"Presentations\":[{\"prstId\":\"1\",\"cntId\":[\"/assets/content/articles/product/108_powered_echelon_510k_approval_letter.pdf\",\"/assets/content/articles/product/specification/98_forces_and_deformations_of_the_abdominal_wall.pdf\",\"/assets/content/videos/product/87_ethicon_physiomesh_2nd_look.mp4\"]}]}"];
//}
//
//- (IBAction)prstButton3Clicked:(id)sender {
//    
//    PresentationViewController* presentationViewController = [[PresentationViewController alloc] initWithNibName:@"PresentationViewController" bundle:nil];
//    
//    [self presentViewController:presentationViewController animated:NO completion:nil];
//    [presentationViewController loadPresentations:@"{\"Presentations\":[{\"prstId\":\"1\",\"cntId\":[\"/assets/content/articles/product/assembly/59_physiomesh_vs_ventralight_st_degraded_pics.pdf\",\"/assets/content/articles/product/assembly/18_value_dossier_on_thoracic_surgery.pdf\",\"/assets/content/articles/product/assembly/110_powered_echelon_sales_aid_provider_focused.pdf\"]}]}"];
//}

-(void)loadData
{
    
    [self creatinglistScrollView];
    [self presentationListclicked:0];
}

-(void)creatinglistScrollView
{
    for (UIView * view in self.listScrollView.subviews) {
        [view removeFromSuperview];
    }
    int y = 50;
    
    for (int i=0; i<[listArray count]; i++)
    {
        UIView *userView=[[UIView alloc] initWithFrame:CGRectMake(0, y, 188, 150)];
        UIButton * PresentationButton=[[UIButton alloc]initWithFrame:CGRectMake(72, 0, 45,38)];
        if (selectedpresentation == i)
            [PresentationButton setImage:[UIImage imageNamed:@"PR_folder_select.png"] forState:UIControlStateNormal];
        else
            [PresentationButton setImage:[UIImage imageNamed:@"PR_folder.png"] forState:UIControlStateNormal];
        
		[PresentationButton addTarget:self action:@selector(presentationListclicked:) forControlEvents:UIControlEventTouchUpInside];
		PresentationButton.tag = i;
        UILabel * title1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 188, 40)];
        title1.numberOfLines = 2;
        NSArray* pstname = [[[listArray objectAtIndex:i] valueForKey:@"SpecialtyPresentations"] valueForKey:@"prstId"];
        if (pstname != nil && pstname.count > 0)
            title1.text = [NSString stringWithFormat:@"%@", [pstname objectAtIndex:0]];
        else
            title1.text = [NSString stringWithFormat:@"Presentation-%d", i];
                           
        title1.font = [UIFont fontWithName:@"Arial" size:14];
        title1.textAlignment = NSTextAlignmentCenter;
        title1.backgroundColor = [UIColor clearColor];
        
        [userView addSubview:PresentationButton];
        [userView addSubview:title1];
        [self.listScrollView addSubview:userView];
        
        //        if (i == [listArray count]-1)
        //        {
        //            y=y+20;
        //        }
        //        elsez
        y = y+110;
        
    }
    self.listScrollView.contentSize=CGSizeMake(188, y+30);

}

-(void)creatingdetailScrollView
{
    for (UIView * view in self.detailScrollView.subviews) {
        [view removeFromSuperview];
    }
    int x =40;
    int y = 40;
    int count = 0;
    
    NSArray* contents = [[PresentationModel sharedInstance] presentationContent];
    NSArray* pathContents = [[PresentationModel sharedInstance] presentationPathContent];
    NSMutableArray *temp = [[NSMutableArray alloc] init];

        if (selectedpresentation == countCheck)
        {
            NSString* presentationPath = _prstPathCntIds;
            if (_prstPathCntIds.length>0)
            {
                [temp removeAllObjects];
                [_totalArray removeAllObjects];

            UIView * userview = [[UIView alloc] initWithFrame:CGRectMake(x, y, 118, 90)];
            userview.layer.borderColor = [UIColor colorWithRed:243.0f/255.0f green:243.0f/255.0f blue:243.0f/255.0f alpha:1].CGColor;
            userview.layer.borderWidth = 1.0f;
            centreButton = [[UIImageView alloc] initWithFrame:CGRectMake(75.5f, 47.5f, 35, 35)];
            centreButton.contentMode = UIViewContentModeScaleToFill;
            centreButton.clipsToBounds = YES;
            
            UIButton * backgroundBtn = [[UIButton alloc] initWithFrame:CGRectMake(3, 3, 112, 84)];
            [_totalArray addObject:presentationPath];
            NSString * path = [DocumentsDirectory stringByAppendingPathComponent:presentationPath];
            ext = [[path pathExtension] lowercaseString];
            backgroundBtn.tag = count;
                [self settingOverlay];
            [temp addObject:[pathContents objectAtIndex:selectedpresentation]];
            for (NSManagedObject* mo in temp) {
                if ([[mo valueForKey:@"path"] isEqualToString:presentationPath])
                {
                    UIImage *image = [UIImage imageWithContentsOfFile:[DocumentsDirectory stringByAppendingPathComponent:[mo valueForKey:@"thumbnailImgPath"]]];
                    [backgroundBtn setImage:image forState:UIControlStateNormal];
                }
            }
            [backgroundBtn addTarget:self action:@selector(detailbuttonCLicked:) forControlEvents:UIControlEventTouchUpInside];
            [userview addSubview:backgroundBtn];
            [self.detailScrollView addSubview:userview];
            [backgroundBtn addSubview:centreButton];
            
            x+=178;
                if ((count+1)%4==0)
                {
                    y+=137;
                    //if added image is 4 th image
                    
                    x=40;
                }
                countCheck ++;

    }
        }
    if (checkingMet == 1)
    {

        for (int k=0;k<[[_finalArray objectAtIndex:0] count]; k++)
        {
            count ++;
            UIView * userview = [[UIView alloc] initWithFrame:CGRectMake(x, y, 118, 90)];
            userview.layer.borderColor = [UIColor colorWithRed:243.0f/255.0f green:243.0f/255.0f blue:243.0f/255.0f alpha:1].CGColor;
            userview.layer.borderWidth = 1.0f;
            centreButton = [[UIImageView alloc] initWithFrame:CGRectMake(75.5f, 47.5f, 35, 35)];
            centreButton.contentMode = UIViewContentModeScaleToFill;
            centreButton.clipsToBounds = YES;
            
            UIButton * backgroundBtn = [[UIButton alloc] initWithFrame:CGRectMake(3, 3, 112, 84)];
            NSString* presentationPath = [[_finalArray objectAtIndex:0] objectAtIndex:k];
            [_totalArray addObject:presentationPath];
            NSString * path = [DocumentsDirectory stringByAppendingPathComponent:presentationPath];
            ext = [[path pathExtension] lowercaseString];
            backgroundBtn.tag = count;
            [self settingOverlay];
            for (NSManagedObject* mo in contents) {
                
                if ([[mo valueForKey:@"path"] isEqualToString:presentationPath])
                {
                    
                    UIImage *image = [UIImage imageWithContentsOfFile:[DocumentsDirectory stringByAppendingPathComponent:[mo valueForKey:@"thumbnailImgPath"]]];
                    [backgroundBtn setImage:image forState:UIControlStateNormal];
                }
            }
            [backgroundBtn addTarget:self action:@selector(detailbuttonCLicked:) forControlEvents:UIControlEventTouchUpInside];
            [userview addSubview:backgroundBtn];
            [self.detailScrollView addSubview:userview];
            [backgroundBtn addSubview:centreButton];
            
            x+=178;
            
            if ((count+1)%4==0)
            {
                y+=137;
                //if added image is 4 th image
                
                x=40;
            }
        }
    }
    self.detailScrollView.contentSize=CGSizeMake(759, y+30);
}

-(void) settingOverlay
{
    if ([ext isEqualToString:@"mp4"] ||
        [ext isEqualToString:@"m3u8"] ||
        [ext isEqualToString:@"m4v"])
    {
        centreButton.image = [UIImage imageNamed:@"video_large_btn"];
    }
    else if ([ext isEqualToString:@"pdf"])
    {
        centreButton.image = [UIImage imageNamed:@"article_large_btn"];
    }
    else if ([ext isEqualToString:@"jpg"] || [ext isEqualToString:@"png"])
    {
        centreButton.image = [UIImage imageNamed:@"image_large_btn"];
    }
    else
    {
        if ([ext isEqualToString:@"html"])
        {
        }
        else{
        }
        centreButton.image = [UIImage imageNamed:@"html_large_btn"];
    }

}

-(IBAction)presentationListclicked:(id)sender
{
    
    //NSString * json = [self.listArray objectAtIndex:[sender tag]];
    
    selectedpresentation = [sender tag];
    countCheck = selectedpresentation;

    /*
     NSLog(@"selected tag %d",[sender tag]);
     NSArray *subviews=[self.listScrollView subviews];
     for(int j=0;j<[subviews count];j++)
     {
     
     UIView *local_subview=[subviews objectAtIndex:j];
     NSArray *sbview_local=[local_subview subviews];
     
     for(UIView *sb_local in sbview_local)
     {
     if([sb_local isKindOfClass:[UIButton class]])
     {
     NSLog(@"selected tag %d",sb_local.tag);
     if(sb_local.tag==[sender tag])
     {
     
     UIButton *new_button=(UIButton *)[sb_local viewWithTag:[sender tag]];
     
     [new_button setImage:[UIImage imageNamed:@"PR_folder_select.png"] forState:UIControlStateNormal];
     }
     else
     {
     UIButton *new_button=(UIButton *)[sb_local viewWithTag:[sender tag]];
     
     [new_button setImage:[UIImage imageNamed:@"PR_folder.png"] forState:UIControlStateNormal];
     }
     }
     }
     }
     
     */
   // NSData* data = [json dataUsingEncoding:NSUTF8StringEncoding];

    if ([self.listArray count]>0)
    {
        
    NSDictionary* parsedObject123 = [self.listArray objectAtIndex:[sender tag]];//[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    _prstPathCntIds = [parsedObject123 objectForKey:@"SpecialtyPresentations"] ;

    for (NSDictionary* cntId in [parsedObject123 objectForKey:@"SpecialtyPresentations"])
    {

        if ([cntId objectForKey:@"path"] != NULL)
        {
            _prstPathCntIds = [cntId objectForKey:@"path"];
            _pathId = [cntId objectForKey:@"prstId"];
            
        }
    }
    }
    
    NSMutableArray *check = [[NSMutableArray alloc] initWithCapacity:0];
    [check removeAllObjects];
    checkingMet = 0;
    for (int i = 0; i < [_metalistArray count]; i++)
    {
        check = [[[[_metalistArray objectAtIndex:i] objectForKey:@"SpecialtyPresentations"] objectAtIndex:0] objectForKey:@"prstId"];
        if ([_pathId isEqualToString:(NSString *)check])
        {
            [_finalArray addObject:[[[[_metalistArray objectAtIndex:i] objectForKey:@"SpecialtyPresentations"] objectAtIndex:0] objectForKey:@"cntId"]];
            checkingMet = 1;
        }
        
    }
    [self creatinglistScrollView];
    [self creatingdetailScrollView];
    
}

-(IBAction)detailbuttonCLicked:(id)sender
{
    PresentationViewController* presentationViewController = [[PresentationViewController alloc] initWithNibName:@"PresentationViewController" bundle:nil];
    //NSString * json = [self.listArray objectAtIndex:selectedpresentation];
    [self presentViewController:presentationViewController animated:NO completion:nil];
    presentationViewController.counter = [sender tag];
    [presentationViewController loadPresentations:self.totalArray];
}

-(IBAction)playbuttonCLicked:(id)sender
{
    PresentationViewController* presentationViewController = [[PresentationViewController alloc] initWithNibName:@"PresentationViewController" bundle:nil];
    //NSString * json = [self.listArray objectAtIndex:selectedpresentation];
    [self presentViewController:presentationViewController animated:NO completion:nil];
    presentationViewController.counter =0;
    [presentationViewController loadPresentations:self.totalArray];
}

@end
