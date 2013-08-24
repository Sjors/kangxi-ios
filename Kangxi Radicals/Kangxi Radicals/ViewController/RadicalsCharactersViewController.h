//
//  RadicalsCharactersViewController.h
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 23-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FirstRadical.h"
#import "Chinese.h"

@interface RadicalsCharactersViewController : UICollectionViewController {
    NSFetchedResultsController *_fetchedResultsController;
}
@property NSManagedObjectContext *managedObjectContext;
@property (readonly) NSFetchedResultsController *fetchedResultsController;
@property NSString *mode;
@property id<Chinese>radical;
@end
