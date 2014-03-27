//
//  Radical.h
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 26-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Chinese.h"

#define kEntityRadical @"Radical"

@class Character, Radical;

@interface Radical : NSManagedObject<Chinese>

@property (nonatomic, retain) NSNumber * section;
@property (nonatomic, retain) NSNumber * isFirstRadical;
@property (nonatomic, retain) NSSet *secondRadicals;
@property (nonatomic, retain) Radical *firstRadical;
@property (nonatomic, retain) NSSet *characters;
@property (nonatomic, retain) NSString * synonyms;
@property (nonatomic, retain) NSNumber * trial;

@end

@interface Radical (CoreDataGeneratedAccessors)

- (void)addSecondRadicalsObject:(Radical *)value;
- (void)removeSecondRadicalsObject:(Radical *)value;
- (void)addSecondRadicals:(NSSet *)values;
- (void)removeSecondRadicals:(NSSet *)values;

- (void)addCharactersObject:(Character *)value;
- (void)removeCharactersObject:(Character *)value;
- (void)addCharacters:(NSSet *)values;
- (void)removesCharacters:(NSSet *)values;

- (NSString *)formattedSynonyms;

+ (NSArray *)all:(NSManagedObjectContext *)context;


@end
