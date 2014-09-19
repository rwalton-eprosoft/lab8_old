//
//  EmailModel.h
//  edge
//
//  Created by Ryan G Walton on 8/8/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Surgeon, SharedLink, Content;

#define MAX_SHARED_LINKS_FOR_SURGEON          20

@interface EmailModel : NSObject

+ (EmailModel*) sharedInstance;

- (void) addSurgeonWithName:(NSString *)name;
- (NSFetchedResultsController *) surgeonWithLinks;
- (void) deleteSurgeon:(Surgeon *)surg;
- (void) createSharedLinkWithContent:(Content *)content forSugeon:(Surgeon *) surg;
- (void) deleteSharedLink:(SharedLink *)link forSurgeon:(Surgeon *)surg;

//- (void) deleteSharedLinkWithContent:(Content *)content forSugeon:(Surgeon *) surg;

@end
