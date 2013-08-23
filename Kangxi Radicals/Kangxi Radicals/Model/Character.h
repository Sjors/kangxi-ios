//
//  Character.h
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 23-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SecondRadical;

@interface Character : NSManagedObject

@property (nonatomic, retain) NSString * simplified;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) SecondRadical *secondRadical;

@end
