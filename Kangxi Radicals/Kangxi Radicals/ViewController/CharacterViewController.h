//
//  CharacterViewController.h
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 24-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Character.h"
#import "UIViewController+Additions.h"

@interface CharacterViewController : UITableViewController {
    NSFetchedResultsController *_fetchedResultsController;
}

@property NSManagedObjectContext *managedObjectContext;
@property (readonly) NSFetchedResultsController *fetchedResultsController;

@property Character *character;

@end
