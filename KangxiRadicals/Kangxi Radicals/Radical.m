//
//  Radical.m
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 26-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import "Radical.h"
#import "Character.h"
#import "Radical.h"


@implementation Radical

@dynamic rank;
@dynamic simplified;
@dynamic section;
@dynamic isFirstRadical;
@dynamic secondRadicals;
@dynamic firstRadical;
@dynamic characters;
@dynamic synonyms;
@dynamic trial;

- (NSString *)formattedSynonyms {
    if (self.synonyms) {
        return [NSString stringWithFormat:@"(%@)", self.synonyms];
    } else {
        return @"";
    }
}

+ (NSArray *)all:(NSManagedObjectContext *)context {
    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:kEntityRadical inManagedObjectContext:context]];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:fetch error:&error];
    
    if(error) {
        NSLog(@"%@",error);
    }
    
    return array;
}

@end
