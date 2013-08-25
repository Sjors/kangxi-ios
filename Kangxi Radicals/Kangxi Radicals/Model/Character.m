//
//  Character.m
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 23-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import "Character.h"
#import "SecondRadical.h"


@implementation Character

@dynamic simplified;
@dynamic position;
@dynamic secondRadical;

-(NSString *)pinyin {
    NSMutableString *pinyin = [self.simplified mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)(pinyin),
                      NULL, kCFStringTransformMandarinLatin, NO);
    
    return pinyin;
}

@end
