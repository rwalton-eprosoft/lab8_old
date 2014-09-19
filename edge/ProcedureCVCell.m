//
//  ProcedureCVCell.m
//  edge
//
//  Created by Ryan G Walton on 11/11/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "ProcedureCVCell.h"

@implementation ProcedureCVCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CALayer * l1 = [self.contentImageView layer];
    [l1 setMasksToBounds:YES];
    
    [self.procedureCellBorder.layer setBorderColor: [UIColor colorWithRed:243.0f/255.0f green:243.0f/255.0f blue:243.0f/255.0f alpha:1].CGColor];
    [self.procedureCellBorder.layer setBorderWidth: 1.0];
    CALayer * l = [self.procedureCellBorder layer];
    [l setMasksToBounds:YES];
    
}


@end
