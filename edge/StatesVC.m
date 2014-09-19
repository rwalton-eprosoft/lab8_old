//
//  StatesVC.m
//  edge
//
//  Created by iPhone Developer on 6/8/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "StatesVC.h"

@interface StatesVC ()

@end

@implementation StatesVC

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
	// Do any additional setup after loading the view.
    
    // add the target to all the state buttons
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton*)view;
            [btn addTarget:self action:@selector(stateBtnTouched:) forControlEvents:UIControlEventTouchDown];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) stateBtnTouched:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    NSString *title = [[btn titleLabel] text];
    
    if (_statesDelegate)
    {
        [_statesDelegate stateSelectedWithTitle:title];
        [self cancelBtnTouched];
    }
    
}

- (IBAction) cancelBtnTouched
{
    [self doneBtnTouched];
}

@end
