//
//  ContentSearchModel.h
//  edge
//
//  Created by Vijay on 11/04/13.
//  Copyright (c) 2013 eprosoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Content.h"
@class ContentSearchModel;

@interface ContentSearchModel : NSObject

@property (atomic, strong) NSArray* arcSteps;

+ (ContentSearchModel*) sharedInstance;

- (NSArray*) fetchContent;

- (NSArray*) fetchContentCategory;

- (NSArray*) fetchMedicalCategory;

- (void) loadContentSearch;

- (Content*) fetchContentById : (int) id;

@end

