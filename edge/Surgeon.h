//
//  Surgeon.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SharedLink;

@interface Surgeon : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *surgeonToSharedLink;
@end

@interface Surgeon (CoreDataGeneratedAccessors)

- (void)addSurgeonToSharedLinkObject:(SharedLink *)value;
- (void)removeSurgeonToSharedLinkObject:(SharedLink *)value;
- (void)addSurgeonToSharedLink:(NSSet *)values;
- (void)removeSurgeonToSharedLink:(NSSet *)values;

@end
