//
//  ProcedureCVCell.h
//  edge
//
//  Created by Ryan G Walton on 11/11/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProcedureCVCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *contentImageView;
@property (nonatomic, strong) IBOutlet UILabel *contentTitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *playButtonOverlayImageView;
@property (strong, nonatomic) UIGestureRecognizer *procedureCellLongPress;
@property (strong, nonatomic) IBOutlet UIImageView *procedureCellBorder;

@end
