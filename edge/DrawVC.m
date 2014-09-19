//
//  DrawVC.m
//  edge
//
//  Created by Vijaykumar on 6/22/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "DrawVC.h"
#import "InfColorPickerController.h"

@interface DrawVC ()

 
@end

@implementation DrawVC
@synthesize CloseButton,PencilView,ColorView,IsPencilViewThere,IsColorViewThere,EraseView,IsEraseViewThere,selectederaser,selectedpencil,selectedcolor;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.view.backgroundColor = [UIColor clearColor];
        //self.view.opaque = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.CloseButton.hidden = YES;
self.PencilView.frame = CGRectMake(597,44 ,260 , 47);
    self.ColorView.frame = CGRectMake(670,44 ,210 , 112);
    self.EraseView.frame = CGRectMake(780,44 ,208 , 47);
    self.selectedpencil.frame = CGRectMake(14, 40, 32, 2);
    self.selectederaser.frame = CGRectMake(13, 40, 32, 2);
    IsPencilViewThere = NO;
    IsColorViewThere = NO;
    IsEraseViewThere = NO;
    self.PencilView.hidden = YES;
    self.ColorView.hidden = YES;
    isWhiteCanvas = NO;
    self.EraseView.hidden = YES;self.DrawToolImageview.image = [UIImage imageNamed:@"new_drawtool_icons.png"];
    // Do any additional setup after loading the view from its nib.
//    self.drawControlView.layer.borderColor = [UIColor redColor].CGColor;
//    self.drawControlView.layer.cornerRadius = 30;
//    self.drawControlView.layer.masksToBounds = YES;
//    self.drawControlView.layer.borderWidth = 2.0f;
    
 //   self.mainDrawControlView.layer.borderColor = [UIColor blackColor].CGColor;
 //   self.mainDrawControlView.layer.cornerRadius = 10;
 //   self.mainDrawControlView.layer.masksToBounds = YES;
//    self.mainDrawControlView.layer.borderWidth = 1.0f;
    
 //   self.topDrawControlView.layer.borderColor = [UIColor blackColor].CGColor;
//self.topDrawControlView.layer.borderWidth = 1.0f;
 //   self.topDrawControlView.layer.cornerRadius = 10;
 //   self.topDrawControlView.layer.masksToBounds = YES;
    
  //  self.middleDrawControlView.layer.borderColor = [UIColor blackColor].CGColor;
//self.middleDrawControlView.layer.borderWidth = 1.0f;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doDoubleTap)] ;
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
}



#pragma mark By Manoj


-(IBAction)ShowPencilView:(id)sender
{
    self.DrawToolImageview.image = [UIImage imageNamed:@"new_drawtool_icons.png"];
  //drawView.color = [UIColor blackColor];

    [self removePencilViewandColorView];
   
    if (PencilView)
    {
        self.PencilView.hidden = NO;
       // self.PencilView.frame = CGRectMake(640,54 ,265 , 55);
        [self.view addSubview:self.PencilView];

        

        IsPencilViewThere = YES;
    }
    else
    {
        self.PencilView.hidden = YES;
        [self.PencilView removeFromSuperview];
        
        
        IsPencilViewThere = NO;
    }
}

-(IBAction)ShowcolorsView:(id)sender
{

    [self removePencilViewandColorView];

    if (ColorView)
    {
        self.ColorView.hidden = NO;
       // self.ColorView.frame = CGRectMake(698,54 ,215 , 95);
        [self.view addSubview:self.ColorView];
       
       
        IsColorViewThere = YES;
    }
    else
    {
        self.ColorView.hidden = YES;
        [self.ColorView removeFromSuperview];
      
        
        IsColorViewThere = NO;
    }
    
}


-(IBAction)ShowEraseView:(id)sender
{
     self.DrawToolImageview.image = [UIImage imageNamed:@"new_drawtool_icons_ereaser.png"];

    [self removePencilViewandColorView];
    if (isWhiteCanvas) {
    if (EraseView)
    {
        
        self.EraseView.hidden = NO;
        [self.view addSubview:self.EraseView];

       
        IsEraseViewThere = YES;

        
    }
    else
    {
        self.EraseView.hidden = YES;
        [self.EraseView removeFromSuperview];
        IsEraseViewThere = NO;
        
    }
    }
    else
        [self eraserButtonClicked:sender];
}


-(void)removePencilViewandColorView
{
    
    if (PencilView)
    {
        self.PencilView.hidden = YES;
    }
    if (EraseView)
    {
        self.EraseView.hidden = YES;
    }
    if (ColorView)
    {
        self.ColorView.hidden=YES;
        
    }
    
   
}


#pragma mark End by Manoj


- (void)doDoubleTap  {
    _mainDrawControlView.hidden = NO;
    _drawToolBoxArrowView.hidden = NO;
}

- (void) viewWillDisappear:(BOOL)animated {
    //nslog(@"Draw tool viewWillDisappear");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonClicked:(id)sender {
    [_drawView saveToFile];
}

- (IBAction)newButtonClicked:(id)sender {
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New" message:@"Changes will be lost" delegate:self
                                           cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        [_drawView clearAll];
    }
}

- (IBAction)undoButtonClicked:(id)sender
{
    [self removePencilViewandColorView];
    [_drawView undo];
}

- (IBAction)redoButtonClicked:(id)sender {
    [self removePencilViewandColorView];
    [_drawView redo];
}

- (IBAction)brushButtonClicked:(id)sender {
    
    if (!_brushViewController) {
        BrushView *brushView = [[BrushView alloc] initWithControls];
        brushView.brushSize.text = [NSString stringWithFormat:@"%f", _drawView.lineWidth];
        brushView.brushSlider.value = _drawView.lineWidth;
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:brushView];
        popover.delegate = self;
        popover.popoverContentSize = CGSizeMake(280.0, 100);
        _brushViewController = popover;
        
        if([sender isKindOfClass: [UIBarButtonItem class]]) {
            [popover presentPopoverFromBarButtonItem: sender
                            permittedArrowDirections: UIPopoverArrowDirectionAny
                                            animated: YES ];
        }
        else {
            UIView* senderView = sender;
            
            [popover presentPopoverFromRect: [senderView bounds]
                                     inView: senderView
                   permittedArrowDirections: UIPopoverArrowDirectionAny
                                   animated: YES ];
        }
        
    } else {
        [_brushViewController dismissPopoverAnimated: YES];
        [self popoverControllerDidDismissPopover:_brushViewController];
        _brushViewController = nil;
    }
}

- (IBAction)eraserButtonClicked:(id)sender
{
     //nslog(@"000---%@",_drawView.color);
      [self removePencilViewandColorView];
    if (isWhiteCanvas == YES) {
    if ([sender tag] == 1)
    {
        _drawView.lineWidth = 1;
        self.selectederaser.frame = CGRectMake(167, 40, 32, 2);
    }
    else if ([sender tag] == 2)
    {
        _drawView.lineWidth = 2;
        self.selectederaser.frame = CGRectMake(115, 40, 32, 2);
        
    }else if ([sender tag] == 3)
    {
        _drawView.lineWidth = 3;
        self.selectederaser.frame = CGRectMake(63, 40, 32, 2);
       
        
    }
    else if ([sender tag] == 4)
    {
        _drawView.lineWidth = 4;
        self.selectederaser.frame = CGRectMake(13, 40, 32, 2);
    }
   
   
    self.color = _drawView.color;
  
   
    _drawView.drawStep = ERASE;
     [_drawView eraser];
    }
    else
    [_drawView clearAll];
}



- (IBAction)colorButtonClicked:(id)sender {
    _drawView.drawStep = DRAW;
    if([self dismissActivePopover])
		return;
    
	InfColorPickerController* picker = [InfColorPickerController colorPickerViewController];
    if (_drawView.color)
        picker.sourceColor = _drawView.color;
    
	picker.delegate = self;
    
	UIPopoverController* popover = [[UIPopoverController alloc] initWithContentViewController: picker];
	[self showPopover: popover from: sender];
}

#pragma mark UIPopoverControllerDelegate methods

- (void) showPopover: (UIPopoverController*) popover from: (id) sender
{
	popover.delegate = self;
    
	_activePopover = popover ;
    
	if([sender isKindOfClass: [UIBarButtonItem class]]) {
		[_activePopover presentPopoverFromBarButtonItem: sender
                               permittedArrowDirections: UIPopoverArrowDirectionAny
                                               animated: YES ];
	}
	else {
		UIView* senderView = sender;
        
		[_activePopover presentPopoverFromRect: [senderView bounds]
                                        inView: senderView
                      permittedArrowDirections: UIPopoverArrowDirectionAny
                                      animated: YES ];
	}
}

- (BOOL) dismissActivePopover
{
	if( _activePopover ) {
		[_activePopover dismissPopoverAnimated: YES];
		[self popoverControllerDidDismissPopover: _activePopover];
		return YES;
	}
    
	return NO;
}

- (void) popoverControllerDidDismissPopover: (UIPopoverController*) popoverController
{
	if( [popoverController.contentViewController isKindOfClass: [InfColorPickerController class]]) {
		InfColorPickerController* picker = (InfColorPickerController*) popoverController.contentViewController;
		[ self applyPickedColor: picker ];
	}
    
	if( popoverController == _activePopover ) {
		_activePopover = nil;
	}
    
    if( [popoverController.contentViewController isKindOfClass: [BrushView class]]) {
        BrushView* brushView = (BrushView*) popoverController.contentViewController;
        
        _drawView.lineWidth = (CGFloat)[brushView.brushSize.text floatValue];
    }
}

- (void) applyPickedColor: (InfColorPickerController*) picker
{
    _drawView.color = picker.resultColor;
}

- (void) removeFromSuperView {
    [self.drawView removeFromSuperview];
    [self.view removeFromSuperview];
    if (self.delegate)
    {
        [self.delegate drawToolRemoved];
    }
}

- (IBAction)closeButtonClicked:(id)sender {
    [self removeFromSuperView];
    
}

- (IBAction)whiteCanvasBtnClicked:(id)sender {
    [self removePencilViewandColorView];
    self.selectedpencil.frame = CGRectMake(14, 40, 32, 2);
    self.selectederaser.frame = CGRectMake(13, 40, 32, 2);
    self.DrawToolImageview.image = [UIImage imageNamed:@"new_drawtool_icons.png"];
    [self.drawView clearAll];
    self.drawView.backgroundColor = [UIColor whiteColor];
    self.drawView.opaque = NO;
    self.drawView.layer.borderColor = [UIColor colorWithRed:152 green:151 blue:151 alpha:1].CGColor;
   self.drawView.layer.borderWidth = 1;

    [self.drawView reloadInputViews];
    _drawView.drawStep = DRAW;
    isWhiteCanvas = YES;
    self.selectedcolor.backgroundColor = [UIColor blackColor];
}

- (IBAction)closeDrawToolBar:(id)sender {
    _mainDrawControlView.hidden = YES;
    _drawToolBoxArrowView.hidden = YES;
}


#pragma Draw Tool Bar Options

- (IBAction)brush1BtnClicked:(id)sender {
    [self removePencilViewandColorView];
  self.selectedpencil.frame = CGRectMake(221, 40, 32, 2);
   
    _drawView.lineWidth = 1;
    _mainDrawControlView.hidden = YES;
    _drawToolBoxArrowView.hidden = YES;
    _drawView.drawStep = DRAW;

}
- (IBAction)brush2BtnClicked:(id)sender {
    [self removePencilViewandColorView];
  
   self.selectedpencil.frame = CGRectMake(167, 40, 32, 2);
    _drawView.lineWidth = 2;
    _mainDrawControlView.hidden = YES;
    _drawToolBoxArrowView.hidden = YES;
    _drawView.drawStep = DRAW;
}
- (IBAction)brush3BtnClicked:(id)sender {
    [self removePencilViewandColorView];
   
    self.selectedpencil.frame = CGRectMake(117, 40, 32, 2);
    _drawView.lineWidth = 3;
    _mainDrawControlView.hidden = YES;
    _drawToolBoxArrowView.hidden = YES;
    _drawView.drawStep = DRAW;
}
- (IBAction)brush4BtnClicked:(id)sender {
    [self removePencilViewandColorView];
   
    self.selectedpencil.frame = CGRectMake(65, 40, 32, 2);
    _drawView.lineWidth = 4;
    _mainDrawControlView.hidden = YES;
    _drawToolBoxArrowView.hidden = YES;
    _drawView.drawStep = DRAW;
}
- (IBAction)brush5BtnClicked:(id)sender {
    [self removePencilViewandColorView];
   self.selectedpencil.frame = CGRectMake(14, 40, 32, 2);
    
    _drawView.lineWidth = 5;
    _mainDrawControlView.hidden = YES;
    _drawToolBoxArrowView.hidden = YES;
    _drawView.drawStep = DRAW;
}

- (IBAction)redBtnClicked:(id)sender {
    
    [self removePencilViewandColorView];
    self.selectedcolor.backgroundColor = [UIColor redColor];
    _drawView.color = [UIColor redColor];
    _mainDrawControlView.hidden = YES;
    _drawToolBoxArrowView.hidden = YES;
    _drawView.drawStep = DRAW;
}

- (IBAction)orangeBtnClicked:(id)sender {
  
     [self removePencilViewandColorView];
    self.selectedcolor.backgroundColor = [UIColor orangeColor];

    _drawView.color = [UIColor orangeColor];
    _mainDrawControlView.hidden = YES;
    _drawToolBoxArrowView.hidden = YES;
    _drawView.drawStep = DRAW;
}

- (IBAction)yelloBtnClicked:(id)sender {
 
     [self removePencilViewandColorView];
    _drawView.color = [UIColor blackColor];
    self.selectedcolor.backgroundColor = [UIColor blackColor];

    _mainDrawControlView.hidden = YES;
    _drawToolBoxArrowView.hidden = YES;
    _drawView.drawStep = DRAW;
}

- (IBAction)greenBtnClicked:(id)sender {
  
     [self removePencilViewandColorView];
    _drawView.color = [UIColor greenColor];
    self.selectedcolor.backgroundColor = [UIColor greenColor];

    _mainDrawControlView.hidden = YES;
    _drawToolBoxArrowView.hidden = YES;
    _drawView.drawStep = DRAW;
}

- (IBAction)cyanBtnClicked:(id)sender {
  
     [self removePencilViewandColorView];
    self.selectedcolor.backgroundColor = [UIColor cyanColor];

    _drawView.color = [UIColor cyanColor];
    _mainDrawControlView.hidden = YES;
    _drawToolBoxArrowView.hidden = YES;
    _drawView.drawStep = DRAW;
}

- (IBAction)blueBtnClicked:(id)sender {
  
     [self removePencilViewandColorView];
    _drawView.color = [UIColor blueColor];
    self.selectedcolor.backgroundColor = [UIColor blueColor];

    _mainDrawControlView.hidden = YES;
    _drawToolBoxArrowView.hidden = YES;
    _drawView.drawStep = DRAW;
}

- (IBAction)pinkBtnClicked:(id)sender {
  
     [self removePencilViewandColorView];
    self.selectedcolor.backgroundColor = [UIColor magentaColor];

    _drawView.color = [UIColor magentaColor];
    _mainDrawControlView.hidden = YES;
    _drawToolBoxArrowView.hidden = YES;
    _drawView.drawStep = DRAW;
}

- (IBAction)purpleBtnClicked:(id)sender {
  
     [self removePencilViewandColorView];
    self.selectedcolor.backgroundColor = [UIColor purpleColor];

    _drawView.color = [UIColor purpleColor];
    
    _mainDrawControlView.hidden = YES;
    _drawToolBoxArrowView.hidden = YES;
    _drawView.drawStep = DRAW;
}
@end