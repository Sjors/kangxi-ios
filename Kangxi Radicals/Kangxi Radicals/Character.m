//
//  Character.m
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 26-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import "Character.h"
#import "Radical.h"
#import "Word.h"


@implementation Character

@dynamic position;
@dynamic simplified;
@dynamic words;

-(NSString *)pinyin {
    NSMutableString *pinyin = [self.simplified mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)(pinyin),
                      NULL, kCFStringTransformMandarinLatin, NO);
    
    return pinyin;
}

+ (Character *)fetchBySimplified:(NSString *)simplified inManagedObjectContext:(NSManagedObjectContext *)context  includesPropertyValuesAndSubentities:(BOOL)includesPropertyValuesAndSubentities {
    
    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:kEntityCharacter inManagedObjectContext:context]];
    fetch.includesPropertyValues = includesPropertyValuesAndSubentities;
    fetch.includesSubentities = includesPropertyValuesAndSubentities;
    
    
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"simplified = %@", simplified]];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:fetch error:&error];
    
    
    if (array != nil) {
        NSUInteger count = [array count];
        //
        if (count > 0) {
            return [array objectAtIndex:0];
        } else {
            return nil;
        }
    }
    else {
        NSLog(@"%@",error);
        // Deal with error.
        return nil;
    }
}

@end
