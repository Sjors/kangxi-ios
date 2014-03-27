//
//  UIView+Additions.m
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 24-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import "UIViewController+Additions.h"

@implementation UIViewController (Additions)
-(UIView *)titleViewWithText:(NSString *)title numberOfChineseCharacters:(NSInteger)n {
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:title];
    
    UIFont *font=[UIFont fontWithName:@"STKaiti" size:20.0f];
    [attString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, n)];
    
    
    UIView *customTitleView = [[UIView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 30.0f)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    
    titleLabel.attributedText = attString;
    [titleLabel sizeToFit];
    
    customTitleView.frame = CGRectMake(self.navigationItem.titleView.frame.size.width/2 - titleLabel.frame.size.width/2, self.navigationItem.titleView.frame.size.height/2 - titleLabel.frame.size.height/2, titleLabel.frame.size.width, titleLabel.frame.size.height);
    
    [customTitleView addSubview:titleLabel];
    
    return customTitleView;
}
@end
