//
//  ImageScrollViewController.m
//  edge
//
//  Created by EAI-WKS-00011 on 10/29/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "ImageScrollViewController.h"

@interface ImageScrollViewController ()

@end

@implementation ImageScrollViewController
@synthesize LargeIMGView,ListScrView,Spinner,selectedindex;
@synthesize pathsarray;

@synthesize Imagepaths,currentPath;

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
     pathsarray = [Imagepaths componentsSeparatedByString:@"\n"];
    
    
    self.ListScrView.contentSize=CGSizeMake(([pathsarray count]*1014),718);
    
    
    
    
    NSArray *subviews=[self.ListScrView subviews];
    
   
    
    for(int i=0;i<[subviews count];i++)
    {
        UIView *view=[subviews objectAtIndex:i];
        [view removeFromSuperview];
    }
   
    if (selectedindex == 0)
    {
      //  leftButton.hidden = YES;
        [leftButton setImage:[UIImage imageNamed:@"arrow_leftgrey.png"] forState:UIControlStateNormal];
        leftButton.userInteractionEnabled = NO;
    }
    else
    {
        leftButton.hidden = NO;
        [leftButton setImage:[UIImage imageNamed:@"arrow_left.png"] forState:UIControlStateNormal];
        leftButton.userInteractionEnabled = YES;
    }
    if (selectedindex == ([pathsarray count]-1))
    {
        //rigthButton.hidden = YES;
        [rigthButton setImage:[UIImage imageNamed:@"arrow-rigthgrey.png"] forState:UIControlStateNormal];
        rigthButton.userInteractionEnabled = NO;
    }
    else
    {
        rigthButton.hidden = NO;
        [rigthButton setImage:[UIImage imageNamed:@"arrow-rigth.png"] forState:UIControlStateNormal];
        rigthButton.userInteractionEnabled = YES;
    }
    [self.Spinner startAnimating];
    [self performSelector:@selector(createscrollview) withObject:nil afterDelay:0.2];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)createscrollview
{
    
    @autoreleasepool {
        
   
    //nslog(@"index---%d",selectedindex);
    
    UIView *userView=[[UIView alloc] initWithFrame:CGRectMake((selectedindex*1014), 0, 1014, 718)];
    userView.tag = selectedindex;
    UIImageView *backgroundImgView=[[UIImageView alloc] initWithFrame:CGRectMake(0,0, 1014, 718)];
     //[AsynchronousFreeloader loadImageFromLink:[pathsarray objectAtIndex:selectedindex] forImageView:backgroundImgView withPlaceholderView:nil andContentMode:UIViewContentModeScaleToFill];
    //nslog(@"urll= %@",[pathsarray objectAtIndex:selectedindex]);
        
        NSData *imageData = [[NSData alloc] initWithContentsOfFile:[pathsarray objectAtIndex:selectedindex]];
        
        [backgroundImgView setImage:[UIImage imageWithData:imageData]];
        imageData = nil;
  // [backgroundImgView setImage:[UIImage imageWithContentsOfFile:[pathsarray objectAtIndex:selectedindex]]];
     backgroundImgView.contentMode = UIViewContentModeScaleAspectFit;
    [userView addSubview:backgroundImgView];
    //nslog(@"image---%@",backgroundImgView.image);
    
    [self.ListScrView addSubview:userView];
    if (selectedindex == 0)
    {
       // leftButton.hidden = YES;
        [leftButton setImage:[UIImage imageNamed:@"arrow_leftgrey.png"] forState:UIControlStateNormal];
        leftButton.userInteractionEnabled = NO;
        //arrow_left
       

    }
    else
    {
        leftButton.hidden = NO;
        [leftButton setImage:[UIImage imageNamed:@"arrow_left.png"] forState:UIControlStateNormal];
        leftButton.userInteractionEnabled = YES;
    }
    if (selectedindex == ([pathsarray count]-1))
    {
       // rigthButton.hidden = YES;
        [rigthButton setImage:[UIImage imageNamed:@"arrow-rigthgrey.png"] forState:UIControlStateNormal];
        rigthButton.userInteractionEnabled = NO;
    }
    else
    {
        //rigthButton.hidden = NO;
        [rigthButton setImage:[UIImage imageNamed:@"arrow-rigth.png"] forState:UIControlStateNormal];
        rigthButton.userInteractionEnabled = YES;
    }
    
    [self.ListScrView setPagingEnabled:YES];
    //self.scrollview.contentSize=CGSizeMake(x,maxheight);
	
	
	[self.ListScrView setContentOffset:CGPointMake(selectedindex*1014, 0)];
    [self.Spinner stopAnimating];
         }
}

-(IBAction)pushright:(id)sender
{
    if (selectedindex < ([pathsarray count]-1))
    {
        
        selectedindex++;
        if (selectedindex <= ([pathsarray count]-1)){
            //rigthButton.hidden = YES;
            [rigthButton setImage:[UIImage imageNamed:@"arrow-rigthgrey.png"] forState:UIControlStateNormal];
            rigthButton.userInteractionEnabled = NO;
        }
        else
        {
            rigthButton.hidden = NO;
            [rigthButton setImage:[UIImage imageNamed:@"arrow-rigth.png"] forState:UIControlStateNormal];
            rigthButton.userInteractionEnabled = YES;
        }
        if ([self.ListScrView viewWithTag:selectedindex])
        {
            [self.ListScrView setContentOffset:CGPointMake(selectedindex*1014, 0) animated:YES];
            if (selectedindex == 0)
            {
               // leftButton.hidden = YES;
                [leftButton setImage:[UIImage imageNamed:@"arrow_leftgrey.png"] forState:UIControlStateNormal];
                leftButton.userInteractionEnabled = NO;
            }
            else
            {
                leftButton.hidden = NO;
                [leftButton setImage:[UIImage imageNamed:@"arrow_left.png"] forState:UIControlStateNormal];
                leftButton.userInteractionEnabled = YES;
            }
            if (selectedindex == ([pathsarray count]-1))
            {
               // rigthButton.hidden = YES;
                [rigthButton setImage:[UIImage imageNamed:@"arrow-rigthgrey.png"] forState:UIControlStateNormal];
                rigthButton.userInteractionEnabled = NO;
            }
            else
            {
                rigthButton.hidden = NO;
                [rigthButton setImage:[UIImage imageNamed:@"arrow-rigth.png"] forState:UIControlStateNormal];
                rigthButton.userInteractionEnabled = YES;
            }
            [self.Spinner stopAnimating];
        }
        else
        {
            [self.Spinner startAnimating];
            [self performSelector:@selector(createscrollview) withObject:nil afterDelay:0.2];
        }
    }
    
}
-(IBAction)pushleft:(id)sender
{
    if (selectedindex > 0)
    {
       
        
        selectedindex--;
        if (selectedindex == 0)
        {
           // leftButton.hidden = YES;
            [leftButton setImage:[UIImage imageNamed:@"arrow_leftgrey.png"] forState:UIControlStateNormal];
            leftButton.userInteractionEnabled = NO;
        }
        else
        {
            leftButton.hidden = NO;
            [leftButton setImage:[UIImage imageNamed:@"arrow_left.png"] forState:UIControlStateNormal];
            leftButton.userInteractionEnabled = YES;
        }
        
        NSArray *subviews=[self.ListScrView subviews];
        
        //nslog(@"--curent image -- %d-- %d",selectedindex,subviews.count);
        
        for(int i=0;i<[subviews count];i++)
        {
            UIView *view=[subviews objectAtIndex:i];
            //nslog(@"-----tag ---%d",view.tag);
        }
        if ([self.ListScrView viewWithTag:selectedindex])
        {
            
            if (selectedindex==0)
            {
                [self.Spinner startAnimating];
                [self performSelector:@selector(createscrollview) withObject:nil afterDelay:0.2];
            }
            else
                [self.ListScrView setContentOffset:CGPointMake(selectedindex*1014, 0) animated:YES];
            if (selectedindex == 0)
            {
               // leftButton.hidden = YES;
                [leftButton setImage:[UIImage imageNamed:@"arrow_leftgrey.png"] forState:UIControlStateNormal];
                leftButton.userInteractionEnabled = NO;
            }
            else
            {
                leftButton.hidden = NO;
                [leftButton setImage:[UIImage imageNamed:@"arrow_left.png"] forState:UIControlStateNormal];
                leftButton.userInteractionEnabled = YES;
            }
            if (selectedindex == ([pathsarray count]-1))
            {
                //rigthButton.hidden = YES;
                [rigthButton setImage:[UIImage imageNamed:@"arrow-rigthgrey.png"] forState:UIControlStateNormal];
                rigthButton.userInteractionEnabled = NO;
            }
            else
            {
                rigthButton.hidden = NO;
            [rigthButton setImage:[UIImage imageNamed:@"arrow-rigth.png"] forState:UIControlStateNormal];
            rigthButton.userInteractionEnabled = YES;
            }
            [self.Spinner stopAnimating];
        }
        else
        {
            [self.Spinner startAnimating];
            [self performSelector:@selector(createscrollview) withObject:nil afterDelay:0.2];
        }
    }
    
}

- (IBAction)closeButtonTouched:(id)sender
{
    [self unLoadDrawTool];
    [self dismissViewControllerAnimated:NO completion:nil];
}

//-(void)showimage:(NSString *)path
//{
//    //nslog(@"current path --- %@",path);
//   // Image.image =[UIImage imageWithContentsOfFile:path];
//}
-(IBAction)drawToolButtonClicked:(id)sender
{
    [self loadDrawTool];
    //[self showTransparentDrawTool];
    
}

- (void) loadDrawTool {
    if (_drawView) {
        [_drawView removeFromSuperView];
        _drawView = nil;
    } else {
        _drawView = [[DrawVC alloc]initWithNibName:@"DrawView" bundle:nil];
        _drawView.view.backgroundColor = [UIColor clearColor];
        
        CGRect viewFrame = self.view.frame;
        float height = (viewFrame.size.height - 49 - 250 - 50);
        CGSize newSize = CGSizeMake(viewFrame.size.width, height);
        viewFrame.origin.y = 50;
        viewFrame.size = newSize;
        
        _drawView.view.frame = viewFrame;
        _drawView.view.frame = CGRectMake(0, 40, 1024, 700);
        [self.view addSubview:_drawView.view];
        [self.view bringSubviewToFront:_drawView.view];
    }
}

- (void) unLoadDrawTool {
    if (_drawView) {
        [_drawView removeFromSuperView];
        _drawView = nil;
    }
}


-(IBAction)ImageBtnpressed:(id)sender
{
    
}


@end
