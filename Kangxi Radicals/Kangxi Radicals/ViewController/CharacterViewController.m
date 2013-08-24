//
//  CharacterViewController.m
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 24-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import "CharacterViewController.h"

@interface CharacterViewController ()

@end

@implementation CharacterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [self titleViewWithText:self.character.simplified numberOfChineseCharacters:1];
    
    simplified.font = [UIFont fontWithName:@"STKaiti" size:250];
    simplified.text = self.character.simplified;
    
    NSMutableString *string = [self.character.simplified mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)(string),
                      NULL, kCFStringTransformMandarinLatin, NO);
    
    pinyin.text = string;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
