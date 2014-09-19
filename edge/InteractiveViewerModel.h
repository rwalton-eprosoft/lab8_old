//
//  InteractiveViewerModel.h
//  edge
//
//  Created by Vijaykumar on 11/13/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InteractiveViewerModel : NSObject

+ (InteractiveViewerModel*) sharedInstance;

- (NSArray*) fetchSpecialtyIV : (NSNumber*) sptlyID withTarget: (NSNumber*) targetAudience;
- (NSArray*) fetchProcedureIV : (NSNumber*) procID withTarget : (NSNumber*) targetAudience;
- (NSArray*) fetchProductIV   : (NSNumber*) prodID withTarget : (NSNumber*) targetAudience : (NSNumber*) relavantProcId;
- (NSArray*) fetchProductClinicalMsg   : (NSNumber*) prodID withTarget : (NSNumber*) targetAudience withRelevantProcedure: (NSNumber*) relavantProcId;
- (NSArray*) fetchProductNonClinicalMsg   : (NSNumber*) prodID withTarget : (NSNumber*) targetAudience withRelevantProcedure: (NSNumber*) relavantProcId;

@end
