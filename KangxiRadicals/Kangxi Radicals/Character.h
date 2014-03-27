//
//  Character.h
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 26-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Chinese.h"

#define kEntityCharacter @"Character"


@class Radical, Word;

@interface Character : NSManagedObject <Chinese>

@property (nonatomic, retain) NSSet *words;
@end

@interface Character (CoreDataGeneratedAccessors)

- (void)addWordsObject:(Word *)value;
- (void)removeWordsObject:(Word *)value;
- (void)addWords:(NSSet *)values;
- (void)removeWords:(NSSet *)values;

- (void)addSecondRadicalsObject:(Radical *)value;
- (void)removeSecondRadicalsObject:(Radical *)value;
- (void)addSecondRadicals:(NSSet *)values;
- (void)removeSecondRadicals:(NSSet *)values;

-(NSString *)pinyin;

+ (Character *)fetchBySimplified:(NSString *)simplified inManagedObjectContext:(NSManagedObjectContext *)context  includesPropertyValuesAndSubentities:(BOOL)includesPropertyValuesAndSubentities;


@end
