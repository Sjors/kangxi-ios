//
//  Word.h
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 25-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kEntityWord @"Word"

@class Character;

@interface Word : NSManagedObject

@property (nonatomic, retain) NSString * simplified;
@property (nonatomic, retain) NSString * english;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) Character *character;


@end
