//
//  FirstRadical.h
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 23-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kEntityFirstRadical @"FirstRadical"

@class SecondRadical;

@interface FirstRadical : NSManagedObject

@property (nonatomic, retain) NSString * simplified;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSSet *secondRadicals;
@end

@interface FirstRadical (CoreDataGeneratedAccessors)

- (void)addSecondRadicalsObject:(SecondRadical *)value;
- (void)removeSecondRadicalsObject:(SecondRadical *)value;
- (void)addSecondRadicals:(NSSet *)values;
- (void)removeSecondRadicals:(NSSet *)values;

@end
