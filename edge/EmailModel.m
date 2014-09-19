//
//  EmailModel.m
//  edge
//
//  Created by Ryan G Walton on 8/8/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "EmailModel.h"
#import "Surgeon.h"
#import "SharedLink.h"
#import "AppDelegate.h"
#import "Content.h"

@interface EmailModel ()
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, assign) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSArray *surgeons;
@property (nonatomic, strong) NSArray *links;

@end

@implementation EmailModel

+ (EmailModel*) sharedInstance
{
    static EmailModel *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[EmailModel alloc] init];
        // Do any other initialisation stuff here
        [instance initModel];
    });
    
    return instance;
}

- (void) initModel
{
    // init favorites
    _appDelegate = [UIApplication sharedApplication].delegate;
    _managedObjectContext = _appDelegate.managedObjectContext;
}

#pragma mark -
#pragma Private Methods

- (NSFetchRequest*)surgeonFetchRequest
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Surgeon" inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    return fetchRequest;
}

- (NSFetchedResultsController *) surgeonWithLinks
{
    NSFetchRequest *fetchRequest = [self surgeonFetchRequest];

    NSString *sectionNameKeyPath;
    sectionNameKeyPath = @"name";

    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:sectionNameKeyPath ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:
                                sortDescriptor1,
                                nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
                                                            initWithFetchRequest:fetchRequest
                                                            managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionNameKeyPath
                                                            cacheName:nil];
    NSError *error = nil;
	if (![fetchedResultsController performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	     */
	    //nslog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    ////nslog(@"fetchedObjects.count: %d", fetchedResultsController.fetchedObjects.count);
    
    return fetchedResultsController;

    
}

- (void) addSurgeonWithName:(NSString *)name
{
    // Create a new instance of the entity
    Surgeon *surg = [NSEntityDescription insertNewObjectForEntityForName:@"Surgeon"
                                                  inManagedObjectContext:_appDelegate.managedObjectContext];
    surg.name = name;
    
    [_appDelegate saveContext];

}

- (void) deleteSurgeon:(Surgeon *)surg
{
    [_appDelegate.managedObjectContext deleteObject:surg];
    
    [_appDelegate saveContext];
}

- (void) deleteSharedLink:(SharedLink *)link forSurgeon:(Surgeon *)surg
{
    //surg.surgeonToSharedLink = link;
    ////nslog(@"Removing Link %@ for surgeon %@", link.title, surg.name);

    [_appDelegate.managedObjectContext deleteObject:link];
    
    [surg removeSurgeonToSharedLinkObject:link];
    
    [_appDelegate saveContext];
}

-(BOOL)doesSharedLink:(Content *)content existForSurgeon:(Surgeon *)surgeon
{
    //nslog(@"Content.title %@ and surgeon name %@", content.title, surgeon.name);
    BOOL found = NO;
    for (Content* cnt in [surgeon.surgeonToSharedLink allObjects])
    {
        if ([cnt.cntId isEqualToNumber: content.cntId])
        {
            found = YES;
        }
    }
    
    return found;
}

-(BOOL)areThereTooManySharedLinksforSurgeon:(Surgeon *)surgeon
{
    BOOL tooMany = NO;
    
    if ([surgeon.surgeonToSharedLink count] >= MAX_SHARED_LINKS_FOR_SURGEON)
    {
        tooMany = YES;
    }
    
    return tooMany;
}

- (void) createSharedLinkWithContent:(Content *)content forSugeon:(Surgeon *)surg
{
    if ([self areThereTooManySharedLinksforSurgeon:surg] == YES)
    {
        /*
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%d items are queued to share with %@", MAX_SHARED_LINKS_FOR_SURGEON, surg.name] message:[NSString stringWithFormat:@"Please navigate to the Email tab to send or delete links for %@", surg.name ] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        */
        
        //This verbage may change:
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Max Queue Reached: %d items", MAX_SHARED_LINKS_FOR_SURGEON] message:[NSString stringWithFormat:@"Please Navigate to the Email Tab to Send or Delete Links for %@", surg.name ] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

        [av show];
    }
    else if ([self doesSharedLink:content existForSurgeon:surg] == NO && [self areThereTooManySharedLinksforSurgeon:surg] == NO)
    {
        // Create a new instance of the entity
        SharedLink *link = [NSEntityDescription insertNewObjectForEntityForName:@"SharedLink"
                                                         inManagedObjectContext:_appDelegate.managedObjectContext];
        
        link.title = content.title;
        link.crtDt = [NSDate date];
        link.contentCatId = content.contentCatId;
        link.cntId = content.cntId;
        link.thumbnailImgPath = content.thumbnailImgPath;
        link.path = content.path;
        link.externalLink = content.externalLink;
        link.sharedLinkToSurgeon = surg;
        [surg addSurgeonToSharedLinkObject:link];
        
        //NSLog(@"thumbnail path = %@", content.thumbnailImgPath);
        //NSLog(@"cntID = %@", content.cntId);
        
        [_appDelegate saveContext];
    }
    else
    {
        ////nslog(@"Shared link exists for surgeon");
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"This link is already shared with %@", surg.name] message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [av show];
    }
}

/*
- (void) deleteSharedLinkWithContent:(Content *)content forSugeon:(Surgeon *) surg
{
    ////nslog(@"Removing Link %@", content);

    [surg removeSurgeonToSharedLinkObject:content];
    
    [_appDelegate saveContext];

}
*/

@end
