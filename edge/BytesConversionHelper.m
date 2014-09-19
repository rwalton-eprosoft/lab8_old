//
//  BytesConversionHelper.m
//  edge
//
//  Created by iPhone Developer on 6/18/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "BytesConversionHelper.h"
#import "AppDelegate.h"

@implementation BytesConversionHelper

+ (CGFloat) convertKiloBytesToBytes:(CGFloat)kilobytes
{
    return kilobytes * 1024;
}

+ (CGFloat) convertBytesToKiloBytes:(CGFloat)bytes
{
    return bytes / 1024;
}

+ (NSString*) convertBytesToDisplayString:(CGFloat)bytes
{
    CGFloat val = bytes / BYTES_IN_GIGABYTE;
    NSString *units = @"GB";
    if (val < 0.01f)
    {
        val = bytes / BYTES_IN_MEGABYTE;
        units = @"MB";
    }
    
    NSString *str = [NSString stringWithFormat:@"%.2f %@", val, units];
    return str;
}

+ (NSString*) convertBytesToString:(CGFloat)bytes
{
    CGFloat val = bytes / BYTES_IN_GIGABYTE;
    NSString *units = @"GB";
    if (val < 0.01f)
    {
        val = bytes / BYTES_IN_MEGABYTE;
        units = @"MB";
    }
    
    NSNumberFormatter *format = [[NSNumberFormatter alloc]init];
    [format setNumberStyle:NSNumberFormatterDecimalStyle];
    [format setRoundingMode:NSNumberFormatterRoundDown];
    [format setMaximumFractionDigits:2];
    
    NSString *numberFormatter = [format stringFromNumber:[NSNumber numberWithFloat: val]];
    NSString *str = [NSString stringWithFormat:@"%@ %@", numberFormatter, units];
    return str;
}
+ (CGFloat) convertBytesToRead:(CGFloat)bytes
{
    CGFloat val = bytes / BYTES_IN_GIGABYTE;
    if (val < 0.01f)
    {
        val = bytes / BYTES_IN_MEGABYTE;
    }
    return val;
   
}
@end
