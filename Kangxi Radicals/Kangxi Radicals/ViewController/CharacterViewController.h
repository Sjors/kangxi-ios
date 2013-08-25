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
}

@property NSManagedObjectContext *managedObjectContext;
@property Character *character;

@end
