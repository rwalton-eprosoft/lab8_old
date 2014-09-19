//
//  ProductListCVCell.h
//  edge
//
//  Created by iPhone Developer on 5/26/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductListCVCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIView *imageBorderView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLbl;
@property (nonatomic, strong) IBOutlet UILabel *descrLbl;
@property (nonatomic, strong) IBOutlet UILabel *imageLbl;

@end
