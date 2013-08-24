//
//  SecondRadical.h
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 23-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kEntitySecondRadical @"SecondRadical"

@class Character, FirstRadical;

@interface SecondRadical : NSManagedObject

@property (nonatomic, retain) NSString * simplified;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSSet *characters;
@property (nonatomic, retain) FirstRadical *firstRadical;
@end

@interface SecondRadical (CoreDataGeneratedAccessors)

- (void)addCharactersObject:(Character *)value;
- (void)removeCharactersObject:(Character *)value;
- (void)addCharacters:(NSSet *)values;
- (void)removeCharacters:(NSSet *)values;

@end
