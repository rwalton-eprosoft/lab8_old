//
//  FavoritesGridCVCell.h
//  edge
//
//  Created by Ryan G Walton on 6/26/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface FavoritesGridCVCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *favCellImageView;
@property (weak, nonatomic) IBOutlet UILabel *dataTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dashboardIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *editingModeDeleteImageView;
@property (weak, nonatomic) IBOutlet UIButton *editingModeDeleteButton;
@property (strong, nonatomic) UIGestureRecognizer *favCellLongPress;
@property (weak, nonatomic) IBOutlet UIImageView *centerImageView;

@property (weak, nonatomic) IBOutlet UIImageView *favCellBorder;


@end
