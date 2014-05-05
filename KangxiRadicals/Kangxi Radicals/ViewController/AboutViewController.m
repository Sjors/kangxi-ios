//
//  AboutViewController.m
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 04-09-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import "AboutViewController.h"
#import "Mixpanel.h"
#import <StoreKit/StoreKit.h>

@interface AboutViewController  () <SKProductsRequestDelegate>
@property NSArray *menu;
@property NSArray *products;
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
    
    
    [self populateTable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpgrade:) name:@"didUpgrade" object:nil];
    
}

-(void)dealloc {
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(didUpgrade:))];
}

- (void)populateTable {
    NSArray *upgradeMenuItems;

    if([[[NSUserDefaults standardUserDefaults]
         stringForKey:@"fullVersion"] isEqualToString:@"paid"]) {
        upgradeMenuItems =  @[@{
                             @"title" : @"Full version",
                             @"subtitle" : @"Thank you for your support.",
                             @"url": @""
                             }
#ifdef DEBUG
                            ,@{
                                @"title" : @"Downgrade",
                                @"subtitle" : @"Debug mode only",
                                @"url": @"downgrade"
                                },
#endif
                            
                             ];
    } else if ([[[NSUserDefaults standardUserDefaults]
                 stringForKey:@"fullVersion"] isEqualToString:@"pending"]) {
        upgradeMenuItems =  @[@{
                             @"title" : @"Purchasing full version...",
                             @"subtitle" : @"Please wait and follow the instructions.",
                             @"url": @""
                             }];
    } else {
        upgradeMenuItems =  @[@{
                             @"title" : @"Buy full version",
                             @"subtitle" : @"Find many more characters.",
                             @"url": @"upgrade"
                             },@{
                              @"title" : @"Restore Previous Purchase",
                              @"subtitle" : @"If you bought the full version before on any device.",
                              @"url": @"restore"
                              }
                            ];
    }
    
    self.menu = @[
                  @{
                      @"header": @"Learning Resources",
                      @"rows" :  @[
                              @{
                                  @"title" : @"App Tutorial  (PDF)",
                                  @"subtitle" : @"Print, fold and practice using this app.",
                                  @"url": @"http://kangxiradicals.com/tutorial.pdf"
                                  },
                              @{
                                  @"title" : @"Radicals List (PDF)",
                                  @"subtitle" : @"Print, hang on your wall and memorize them",
                                  @"url": @"http://mandarinposter.com/resources/simplified-radicals-list-free-printable-reference/"
                                  }
                              ]
                      },
                  @{
                      @"header": @"Full Version",
                      @"rows" :  upgradeMenuItems,
                    },
                  @{
                      @"header": @"Contact",
                      @"rows" :  @[
                              @{
                                  @"title" : @"Sjors Provoost",
                                  @"subtitle" : @"sjors@kangxiradicals.com",
                                  @"url": @"mailto:sjors@kangxiradicals.com"
                                  },
                              
                              @{
                                  @"title" : @"Purple Dunes",
                                  @"subtitle" : @"http://purpledunes.com/",
                                  @"url": @"http://purpledunes.com/"
                                  },
                              @{
                                  @"title" : @"Personal Blog",
                                  @"subtitle" : @"http://provoost.tumblr.com",
                                  @"url": @"http://provoost.tumblr.com"
                                  },
                              ]
                      },
                  @{
                      @"header": @"Sources",
                      @"rows" :  @[
                              @{
                                  @"title" : @"Wiktionary.org",
                                  @"subtitle" : @"Creative Commons dictionary",
                                  @"url": @"http://en.m.wiktionary.org/"
                                  },
                              @{
                                  @"title" : @"CE-DICT",
                                  @"subtitle" : @"Creative Commons Chinese dictionary database",
                                  @"url": @"http://www.cc-cedict.org/"
                                  },
                              @{
                                  @"title" : @"Wiki Commons",
                                  @"subtitle" : @"Character decomposition database",
                                  @"url": @"http://commons.wikimedia.org/wiki/Commons:Chinese_characters_decomposition"
                                  },
                              @{
                                  @"title" : @"HSK (Hànyǔ Shuǐpíng Kǎoshì)",
                                  @"subtitle" : @"Word list compiled by Lingomi.com",
                                  @"url": @"http://lingomi.com/blog/hsk-lists-2010/",
                                  },
                              @{
                                  @"title" : @"华文楷体",
                                  @"subtitle" : @"This gorgeous font is called STKaiti",
                                  @"url": @"http://en.m.wikipedia.org/wiki/List_of_CJK_fonts",
                                  @"useSpecialFont" : @YES
                                  }
                              ],
                      }
                  ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.menu count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.menu objectAtIndex:section] objectForKey:@"rows"] count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self.menu objectAtIndex:section] objectForKey:@"header"];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    static NSString *CellIdentifier = @"linkCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [[[self.menu objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row];
    
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *subTitleLabel = (UILabel *)[cell viewWithTag:2];

    titleLabel.text = [item valueForKey:@"title"];
    subTitleLabel.text = [item valueForKey:@"subtitle"];

    
    if ([item objectForKey:@"useSpecialFont"] != nil && [[item objectForKey:@"useSpecialFont"] boolValue]) {
        titleLabel.font = [UIFont fontWithName:@"STKaiti" size:18.0f];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [[[self.menu objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row];
    
    NSString *url = [item objectForKey:@"url"];
    
    if ([url isEqualToString:@"upgrade"]) {
#ifndef DEBUG
        [[Mixpanel sharedInstance] track:@"Tap Upgrade"];
#endif
        // Intentionally not synchronising:
        [[NSUserDefaults standardUserDefaults] setObject:@"pending" forKey:@"fullVersion"];
        [self validateProductIdentifiers:@[@"1000characters"]];
        [self populateTable];
        [self.tableView reloadData];
    } else if ([url isEqualToString:@"restore"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"restorePurchases" object:nil];
        [[NSUserDefaults standardUserDefaults] setObject:@"pending" forKey:@"fullVersion"];
        [self populateTable];
        [self.tableView reloadData];
    }
#ifdef DEBUG
    else if ([url isEqualToString:@"downgrade"]) {
        [[NSUserDefaults standardUserDefaults]
         setObject:@"unpaid" forKey:@"fullVersion"];
        
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self populateTable];
        [self.tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didDowngrade" object:nil];
    }

#endif
    else {
#ifndef DEBUG

        [[Mixpanel sharedInstance] track:@"Follow Link" properties:@{@"URL" : url}];
#endif
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
 
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

#pragma mark In App Purchase
- (void)validateProductIdentifiers:(NSArray *)productIdentifiers
{
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    productsRequest.delegate = self;
    [productsRequest start];
}
// SKProductsRequestDelegate protocol method
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    self.products = response.products;
    for (NSString *invalidIdentifier in response.invalidProductIdentifiers) {
        // Handle any invalid product identifiers.
        [[[UIAlertView alloc ]initWithTitle:@"Upgrade error" message:[NSString stringWithFormat:@"Something went wrong with the upgrade. Please contact support and mention 'Invalid Product Identifier %@'", invalidIdentifier] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    [self displayStoreUI];
}

- (void)displayStoreUI {
  // We only have one possible purchase, so no need to display additional UI.
    [self requestPayment:[self.products firstObject]];
}

-(void)requestPayment:(SKProduct *)product {
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)didUpgrade:(id)sender {
    [self populateTable];
    [self.tableView reloadData];
}

@end
