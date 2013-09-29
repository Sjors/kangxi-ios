//
//  AboutViewController.m
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 04-09-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import "AboutViewController.h"
#import "Mixpanel.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    fontLink.font = [UIFont fontWithName:@"STKaiti" size:18.0f];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *url;
    
    switch (indexPath.section) {
    case 0:
        switch (indexPath.row) {
        case 0:
            url = @"http://mandarinposter.com/resources/simplified-radicals-list-free-printable-reference/";
        break;
        
        default:
        break;
        }
        break;
            
    case 1:
        switch (indexPath.row) {
        case 0:
            url = @"mailto:sjors@kangxiradicals.com";
            break;
        case 1:
            url = @"http://purpledunes.com/";
            break;
        case 2:
            url = @"http://sprovoost.nl/";
            break;
        default:
            break;
        }
        break;
    case 2:
        switch (indexPath.row) {
        case 0:
            url = @"http://en.m.wiktionary.org/";
            break;
        case 1:
            url = @"http://www.cc-cedict.org/";
            break;
        case 2:
            url = @"http://commons.wikimedia.org/wiki/Commons:Chinese_characters_decomposition";
            break;
        case 3:
            url = @"http://lingomi.com/blog/hsk-lists-2010/";
            break;
        case 4:
            url = @"http://www.forvo.com/languages/zh/";
            break;
        case 5:
            url = @"http://en.m.wikipedia.org/wiki/List_of_CJK_fonts";
            break;
        default:
            break;
        }
        break;
    default:
        break;
    }
    
    if(url!=nil) {
#ifndef DEBUG
        [[Mixpanel sharedInstance] track:@"Follow Link" properties:@{@"URL" : url}];
#endif
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
 
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}
@end
