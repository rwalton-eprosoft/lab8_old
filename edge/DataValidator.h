//
//  DataQuery.h
//  edge
//
//  Created by Vijaykumar on 6/24/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataValidator : NSObject
- (void) getContentByContentCategory;

@property (atomic, strong) NSMutableString* report;
- (NSString*) getReport;
-(NSDictionary *)fetchCoreData;
@end
