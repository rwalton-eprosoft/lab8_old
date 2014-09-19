//
//  SearchResultsGridCVCell.h
//  edge
//
//  Created by iPhone Developer on 8/23/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsGridCVCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIView *imageBorderView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLbl;
@property (nonatomic, strong) IBOutlet UILabel *dateLbl;
@property (weak, nonatomic) IBOutlet UIImageView *overlayImageView;

@end
