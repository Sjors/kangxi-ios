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

@end
