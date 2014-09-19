//
//  ProductListCVCell.m
//  edge
//
//  Created by iPhone Developer on 5/26/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "ProductListCVCell.h"

@implementation ProductListCVCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        self.titleLbl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.titleLbl.backgroundColor = [UIColor clearColor];
        self.titleLbl.textAlignment = NSTextAlignmentCenter;
        self.titleLbl.font = [UIFont boldSystemFontOfSize:13.0f];
        self.titleLbl.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        self.titleLbl.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
        self.titleLbl.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        self.descrLbl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.descrLbl.backgroundColor = [UIColor clearColor];
        self.descrLbl.textAlignment = NSTextAlignmentLeft;
        self.descrLbl.font = [UIFont systemFontOfSize:13.0f];
        self.descrLbl.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        self.descrLbl.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
        self.descrLbl.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        self.imageLbl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageLbl.backgroundColor = [UIColor clearColor];
        self.imageLbl.textAlignment = NSTextAlignmentCenter;
        self.imageLbl.font = [UIFont boldSystemFontOfSize:13.0f];
        self.imageLbl.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        self.imageLbl.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
        self.imageLbl.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
    }

    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
    self.titleLbl.text = nil;
    self.descrLbl.text = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
