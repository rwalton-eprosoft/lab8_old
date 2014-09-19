//
//  UIImage+Resize.m
//  edge
//
//  Created by iPhone Developer on 8/9/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    //[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    [image drawAtPoint:CGPointMake(0, 0)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
