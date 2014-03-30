//
//  RadicalCharacterCollectionViewCell.m
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 03-09-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import "RadicalCharacterCollectionViewCell.h"

@implementation RadicalCharacterCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    UILabel *simplified = (UILabel *)[self viewWithTag:1];
    simplified.textColor =  TINTCOLOR;
    simplified.font = [UIFont fontWithName:@"STKaiti" size:50];
    
    if(IS_WIDESCREEN) {
        UILabel *synonyms = (UILabel *)[self viewWithTag:2];
        synonyms.font = [UIFont fontWithName:@"STKaiti" size:20];
        synonyms.alpha = 0.7;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)prepareForReuse {
    UILabel *simplified = (UILabel *)[self viewWithTag:1];
    simplified.text = @"";
    
    if(IS_WIDESCREEN) {
        UILabel *synonyms = (UILabel *)[self viewWithTag:2];
        synonyms.text = @"";
    }

}

@end