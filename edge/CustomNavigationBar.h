//
//  CustomNavigationBar.h
//  edge
//
//  Created by Vijaykumar on 8/23/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomNavigationBar : UINavigationBar
@property (nonatomic, retain) UIImageView *navigationBarBackgroundImage;
-(void) setBackgroundWith:(UIImage*)backgroundImage;

@end
