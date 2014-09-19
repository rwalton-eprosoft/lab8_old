//
//  ProductDetailCVCell.h
//  edge
//
//  Created by Ryan G Walton on 10/24/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductDetailCVCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *contentImageView;
@property (strong, nonatomic) IBOutlet UILabel *contentTitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *playButtonOverlayImageView;
@property (strong, nonatomic) UIGestureRecognizer *productDetailCellLongPress;

@end
