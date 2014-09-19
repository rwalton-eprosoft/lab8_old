//
//  UIImage+OverlayImage.m
//  edge
//
//  Created by iPhone Developer on 8/4/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "UIImage+OverlayImage.h"

@implementation UIImage (OverlayImage)

- (UIImage*) drawImage:(UIImage*)fgImage atPoint:(CGPoint)point
{
    UIImage *bgImage = self;
    
    UIGraphicsBeginImageContextWithOptions(bgImage.size, FALSE, 0.0);
    [bgImage drawInRect:CGRectMake( 0, 0, bgImage.size.width, bgImage.size.height)];
    
    //[fgImage drawInRect:CGRectMake( point.x, point.y, fgImage.size.width, fgImage.size.height)];

    // adjust to center
    CGFloat x = point.x - fgImage.size.width/2;
    CGFloat y = point.y - fgImage.size.height/2;
    
    [fgImage drawInRect:CGRectMake( x, y, fgImage.size.width, fgImage.size.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
