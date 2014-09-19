//
//  sizeValidation.h
//  edge
//
//  Created by Dheeraj Raju on 24/07/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyProfile.h"

@interface sizeValidation : NSObject

+ (sizeValidation *)SharedManager;

@property (nonatomic, strong) MyProfile *profile;
@property (nonatomic, assign) CGFloat totalContentDownloadSize;


- (void) callServer:(NSArray*)array isIncrSize:(int)isIncrSize;
- (CGFloat) totalFreeStorageSpace;


@end
