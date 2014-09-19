//
//  SCViewController.m
//  edge
//
//  Created by Manoj on 10/18/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "SCViewController.h"
#import "SCPageScrubberBar.h"

@interface SCViewController () <SCPageScrubberBarDelegate>
@property (nonatomic, strong) SCPageScrubberBar* scrubberBar;
@end

@implementation SCViewController
@synthesize pathsarray;
@synthesize Image;
@synthesize Imagepaths,currentPath;

- (void)viewDidLoad
{
    [super viewDidLoad];
   pathsarray = [[NSArray alloc] init];
    [Image setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    Image.layer.borderColor = [UIColor darkGrayColor].CGColor;
    Image.layer.cornerRadius = 7;
    Image.layer.masksToBounds = YES;
    //Image.layer.borderWidth = 1.0f;
	// Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.scrubberBar];
    [self.view bringSubviewToFront:self.scrubberBar];
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (SCPageScrubberBar *)scrubberBar
{
    if (_scrubberBar == nil) {
        pathsarray = [Imagepaths componentsSeparatedByString:@"\n"];
        
        
        CGRect nFrame = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? CGRectMake((512.0f - (([pathsarray count]*15))/2), 728.0f, ([pathsarray count]*15), 40.0f) : CGRectMake(20.0f, 400.0f, 280.0f, 30.0f);
        _scrubberBar = [[SCPageScrubberBar alloc] initWithFrame:nFrame];
        _scrubberBar.delegate = self;
        _scrubberBar.minimumValue = 0;
        

        _scrubberBar.maximumValue = [pathsarray count]-1;
        _scrubberBar.isPopoverMode = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    }
    return _scrubberBar;
}

#pragma mark - DSPopupSliderDelegate

- (NSString*)scrubberBar:(SCPageScrubberBar*)scrubberBar titleTextForValue:(CGFloat)value
{
    NSInteger current = (int)value+1;
    //nslog(@"---index--%d and int value--%d",current,(int)value);
    Image.image =[UIImage imageWithContentsOfFile:[self.pathsarray objectAtIndex:(int)value]];
    //nslog(@"---currentpath--%@",currentPath);
    if ([currentPath isEqualToString:@""])
    {
        
    }
    else
    {
        int index;
        for (int k=0; k<[pathsarray count]; k++)
        {
            if ([currentPath isEqualToString:[self.pathsarray objectAtIndex:k]])
            {
                index = k;
            }
        }
        
        Image.image =[UIImage imageWithContentsOfFile:currentPath];
        currentPath = @"";
        [self scrubberBar:scrubberBar titleTextForValue:(CGFloat)index];
        
    }
    return [NSString stringWithFormat:@"image %d", current];
   
  //
    
}

- (NSString *)scrubberBar:(SCPageScrubberBar *)scrubberBar subtitleTextForValue:(CGFloat)value
{
//    NSInteger current = (int)value + 1;
//    return [NSString stringWithFormat:@"Page %d", current];
    return nil;
}

- (void)scrubberBar:(SCPageScrubberBar*)scrubberBar valueSelected:(CGFloat)value
{
}
- (IBAction)closeButtonTouched:(id)sender
{
    [self unLoadDrawTool];
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)showimage:(NSString *)path
{
    //nslog(@"current path --- %@",path);
    Image.image =[UIImage imageWithContentsOfFile:path];
}
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


@end
