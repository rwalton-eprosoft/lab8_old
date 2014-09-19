//
//  CustomProgressView.m
//  edge
//
//  Created by Vijaykumar on 7/23/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "CustomProgressView.h"

@implementation CustomProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {

    UIImage *background = [[UIImage imageNamed:@"progress-bar-bg.png"]
                           resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 4)];
    UIImage *fill = [[UIImage imageNamed:@"progress-bar-fill.png"]
                     resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 4)];
    
    [background drawInRect:rect];
    NSInteger maxWidth = rect.size.width;
    
    NSInteger curWidth = floor([self progress] * maxWidth);
    
    CGRect fillRect = CGRectMake(rect.origin.x,
                                 rect.origin.y+1,
                                 curWidth,
                                 rect.size.height + 10);
    // Draw the fill
    [fill drawInRect:fillRect];
}

@end
