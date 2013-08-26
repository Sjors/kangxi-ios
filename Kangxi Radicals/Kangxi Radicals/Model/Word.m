//
//  Word.m
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 25-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import "Word.h"
#import "Character.h"


@implementation Word

@dynamic simplified;
@dynamic english;
@dynamic wordLength;
@dynamic characters;

// Duplicate from Character
-(NSString *)pinyin {
    NSMutableString *pinyin = [self.simplified mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)(pinyin),
                      NULL, kCFStringTransformMandarinLatin, NO);
    
    return pinyin;
}

+ (Word *)fetchBySimplified:(NSString *)simplified inManagedObjectContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:kEntityWord inManagedObjectContext:context]];
    
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
