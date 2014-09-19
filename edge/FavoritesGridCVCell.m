//
//  FavoritesGridCVCell.m
//  edge
//
//  Created by Ryan G Walton on 6/26/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "FavoritesGridCVCell.h"

#define degreesToRadians(x) (M_PI * (x) / 180.0)
#define kAnimationRotateDeg 0.5
#define kAnimationTranslateX 1.0
#define kAnimationTranslateY 1.0

@implementation FavoritesGridCVCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //    [self.favCellImageView.layer setBorderColor: [[UIColor grayColor] CGColor]];
    //    [self.favCellImageView.layer setBorderWidth: 3.0];
    //    CALayer * l = [self.favCellImageView layer];
    //    [l setMasksToBounds:YES];
    //    [l setCornerRadius:10.0];
    
    CALayer * l1 = [self.favCellImageView layer];
    [l1 setMasksToBounds:YES];
    //[l1 setCornerRadius:10.0];
    
    [self.favCellBorder.layer setBorderColor: [UIColor colorWithRed:243.0f/255.0f green:243.0f/255.0f blue:243.0f/255.0f alpha:1].CGColor];
    [self.favCellBorder.layer setBorderWidth: 1.0];
    CALayer * l = [self.favCellBorder layer];
    [l setMasksToBounds:YES];
   // [l setCornerRadius:10.0];
    
}

-(void)startWaggle
{
    //unhide deletebutton
    self.editingModeDeleteImageView.hidden = NO;
    self.editingModeDeleteButton.hidden = NO;
    
    /*
     
     //startWaggle
     
     int count = 1;
     CGAffineTransform leftWobble = CGAffineTransformMakeRotation(degreesToRadians( kAnimationRotateDeg * (count%2 ? +1 : -1 ) ));
     CGAffineTransform rightWobble = CGAffineTransformMakeRotation(degreesToRadians( kAnimationRotateDeg * (count%2 ? -1 : +1 ) ));
     CGAffineTransform moveTransform = CGAffineTransformTranslate(rightWobble, -kAnimationTranslateX, -kAnimationTranslateY);
     CGAffineTransform conCatTransform = CGAffineTransformConcat(rightWobble, moveTransform);
     
     // starting point
     self.transform = leftWobble;
     
     [UIView animateWithDuration:0.1
     delay:(count * 0.08)
     options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
     animations:^{ self.transform = conCatTransform; }
     completion: nil];
     */
}

-(void)handleWaggle
{
    //nslog(@"stop waggle");
    [self.layer removeAllAnimations];
    
}
-(void)stopWaggle
{
    //remove deletebutton
    self.editingModeDeleteImageView.hidden = YES;
    self.editingModeDeleteButton.hidden = YES;
    /*
     
     [self.layer removeAllAnimations];
     
     CGAffineTransform returnWobble = CGAffineTransformMakeRotation(0);
     
     [UIView animateWithDuration:0.1
     delay:0
     options: UIViewAnimationOptionAllowUserInteraction
     animations:^{ self.transform = returnWobble; }
     completion: nil];
     */
}

@end
