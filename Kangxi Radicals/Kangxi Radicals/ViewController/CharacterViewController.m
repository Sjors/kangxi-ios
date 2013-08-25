//
//  CharacterViewController.m
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 24-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import "CharacterViewController.h"
#import "Word.h"

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
    
    NSString *titleText = [NSString stringWithFormat:@"%@ %@",self.character.simplified, self.character.pinyin];
    self.navigationItem.titleView = [self titleViewWithText:titleText numberOfChineseCharacters:1];
    
    [self.fetchedResultsController performFetch:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark Tableview and delegates
-(int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.fetchedResultsController fetchedObjects] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    static NSString *CellIdentifier = @"wordCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Word *word = [self.fetchedResultsController objectAtIndexPath:indexPath];
    

    NSString *character_pinyin_text = [NSString stringWithFormat:@"%@ (%@)", word.simplified, word.pinyin];
    
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:character_pinyin_text];
    
    UIFont *font=[UIFont fontWithName:@"STKaiti" size:20.0f];
    [attString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [word.simplified length])];
    
    UILabel *character_pinyin = (UILabel *)[cell viewWithTag:1];
    character_pinyin.attributedText = attString;
    
    UILabel *english = (UILabel *)[cell viewWithTag:2];
    english.text = word.english;

    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark - NSFetchedResultController and delegates
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:kEntityWord inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"character = %@", self.character]];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"position" ascending:YES  selector:nil];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    _fetchedResultsController = theFetchedResultsController;
    
    return _fetchedResultsController;
    
}


@end
