//
//  BytesConversionHelper.h
//  edge
//
//  Created by iPhone Developer on 6/18/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BYTES_IN_GIGABYTE                       1073741824
#define BYTES_IN_MEGABYTE                       1048576
#define KILOBYTES_IN_GIGABYTE                   8388608
#define KILOBYTES_IN_MEGABYTE                   0.0009765625

@interface BytesConversionHelper : NSObject

+ (CGFloat) convertKiloBytesToBytes:(CGFloat)kilobytes;
+ (CGFloat) convertBytesToKiloBytes:(CGFloat)bytes;
+ (NSString*) convertBytesToDisplayString:(CGFloat)bytes;
+ (NSString*) convertBytesToString:(CGFloat)bytes;
+ (CGFloat) convertBytesToRead:(CGFloat)bytes;

@end
