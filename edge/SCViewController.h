//
//  SCViewController.h
//  edge
//
//  Created by Manoj on 10/18/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawVC.h"

@interface SCViewController : UIViewController


@property (nonatomic,strong) NSArray *pathsarray;
@property (nonatomic,strong) IBOutlet UIImageView * Image;
@property (nonatomic,strong) NSString * Imagepaths;
@property (nonatomic,strong) NSString * currentPath;
@property (nonatomic, strong) DrawVC *drawView;

-(void)showimage:(NSString *)path;
- (IBAction)closeButtonTouched:(id)sender;
-(IBAction)drawToolButtonClicked:(id)sender;
@end
