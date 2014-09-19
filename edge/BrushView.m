//
//  BrushView.m
//  edge
//
//  Created by Vijaykumar on 6/24/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "BrushView.h"

@implementation BrushView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithControls {
    
     id x = [super init];
    _brushSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 50, 200, 20)];
    _brushSlider.maximumValue = 10.00;
    _brushSlider.minimumValue = 1.00;
    _brushSize = [[UILabel alloc] initWithFrame:CGRectMake(220, 50, 20, 20)];
    _brushSize.text = @"5.0";
    _brushSize.textAlignment = UIBaselineAdjustmentAlignCenters;
    [_brushSlider addTarget:self action:@selector(sliderHandler:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_brushSlider];
    [self.view addSubview:_brushSize];
    return x;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void) sliderHandler: (UISlider *)sender {
    int size = sender.value;
    [_brushSize setText:[NSString stringWithFormat:@"%d", size]];
}

@end
