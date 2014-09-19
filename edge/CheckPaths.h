//
//  CheckPaths.h
//  edge
//
//  Created by Dheeraj Raju on 07/03/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UpdateNotify.h"

@interface CheckPaths : NSObject
{
    NSMutableDictionary *dict;
    NSMutableArray *contents;
    NSString* contentPath;
    NSString *str;
    NSString *filePath;
    NSString *htmlLoop;
    NSDirectoryEnumerator *enumerator;
    int checkType;
    int html;
}
-(void) checkForPaths : (NSDictionary*) dictionry;


@end
