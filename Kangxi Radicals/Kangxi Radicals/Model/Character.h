//
//  Character.h
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 23-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Chinese.h"

#define kEntityCharacter @"Character"

@class SecondRadical;

@interface Character : NSManagedObject<Chinese>

@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) SecondRadical *secondRadical;

-(NSString *)pinyin;

@end
