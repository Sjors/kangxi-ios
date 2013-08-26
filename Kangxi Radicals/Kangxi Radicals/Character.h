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

@property (nonatomic, retain) Radical *secondRadical;
@property (nonatomic, retain) NSSet *words;
@end

@interface Character (CoreDataGeneratedAccessors)

- (void)addWordsObject:(Word *)value;
- (void)removeWordsObject:(Word *)value;
- (void)addWords:(NSSet *)values;
- (void)removeWords:(NSSet *)values;

-(NSString *)pinyin;

@end
