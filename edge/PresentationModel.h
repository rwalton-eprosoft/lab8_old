//
//  PresentationModel.h
//  edge
//
//  Created by Vijay on 10/06/13.
//  Copyright (c) 2013 eprosoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PresentationModel : NSObject

+ (PresentationModel*) sharedInstance;
- (NSMutableArray*) pathsForPresentations;

- (NSArray*) presentationContent;
- (NSMutableArray*) pathsForMetadataPresentations;
- (NSArray*) presentationPathContent;

@end