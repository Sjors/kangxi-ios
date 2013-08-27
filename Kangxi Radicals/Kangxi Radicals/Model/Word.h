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
@property (nonatomic, retain) NSNumber * wordLength;
@property (nonatomic, retain) NSSet *characters;
@end

@interface Word (CoreDataGeneratedAccessors)

- (void)addCharactersObject:(Character *)value;
- (void)removeCharactersObject:(Character *)value;
- (void)addCharacters:(NSSet *)values;
- (void)removeCharacters:(NSSet *)values;

-(NSString *)pinyin;

+ (Word *)fetchBySimplified:(NSString *)simplified inManagedObjectContext:(NSManagedObjectContext *)context  includesPropertyValuesAndSubentities:(BOOL)includesPropertyValuesAndSubentities;
@end
