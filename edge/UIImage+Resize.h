//
//  UIImage+Resize.h
//  edge
//
//  Created by iPhone Developer on 8/9/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;

@end
