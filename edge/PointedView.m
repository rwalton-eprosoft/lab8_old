//
//  PointedView.m
//  edge
//
//  Created by Vijaykumar on 8/4/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "PointedView.h"
#define kArrowHeight 50

@implementation PointedView

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
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIBezierPath *fillPath = [UIBezierPath bezierPath];
    [fillPath moveToPoint:CGPointMake(0, self.bounds.origin.y+kArrowHeight)];
    [fillPath addLineToPoint:CGPointMake(self.bounds.size.width/1.2-(kArrowHeight/2), kArrowHeight)];
    [fillPath addLineToPoint:CGPointMake(self.bounds.size.width/1.2, 0)];
    [fillPath addLineToPoint:CGPointMake(self.bounds.size.width/1.2+(kArrowHeight/2), kArrowHeight)];
    [fillPath addLineToPoint:CGPointMake(self.bounds.size.width, kArrowHeight)];
    [fillPath addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height)];
    [fillPath addLineToPoint:CGPointMake(0, self.bounds.size.height)];
    [fillPath closePath];
    
    CGContextAddPath(context, fillPath.CGPath);
    CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGContextFillPath(context);
}


@end
