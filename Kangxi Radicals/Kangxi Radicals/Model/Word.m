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
@dynamic position;
@dynamic characters;

// Duplicate from Character
-(NSString *)pinyin {
    NSMutableString *pinyin = [self.simplified mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)(pinyin),
                      NULL, kCFStringTransformMandarinLatin, NO);
    
    return pinyin;
}

@end
