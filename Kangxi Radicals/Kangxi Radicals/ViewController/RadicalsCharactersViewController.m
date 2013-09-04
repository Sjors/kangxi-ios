//
//  RadicalsCharactersViewController.m
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 23-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import "RadicalsCharactersViewController.h"
#import "CharacterViewController.h"
#import "RadicalCharacterCollectionViewCell.h"

#import "Radical.h"
#import "Character.h"

#ifndef DEBUG
    #import <Mixpanel.h>
#endif

@interface RadicalsCharactersViewController ()
@property NSString *entityName;
@property NSPredicate *predicate;
@property NSString *sectionNameKeyPath;
@property NSString *cacheSuffix;

@property NSArray *sortDescriptors;
@end

@implementation RadicalsCharactersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Appearance and Segues
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if([self.mode isEqualToString:@"Radical"] && self.radical == nil) {
        self.entityName = kEntityRadical;
        self.predicate = [NSPredicate predicateWithFormat:@"isFirstRadical = %@ OR section == 2", @YES];
        self.sectionNameKeyPath = @"section";
        NSSortDescriptor *sortSection = [[NSSortDescriptor alloc]
                                         initWithKey:@"section" ascending:YES  selector:nil];
        NSSortDescriptor *sortPostition = [[NSSortDescriptor alloc]
                                           initWithKey:@"rank" ascending:YES  selector:nil];
        
        self.sortDescriptors = @[sortSection, sortPostition];
        
        self.cacheSuffix = @"FirstRadical";
        
        self.title = @"Which radical do you recognize?";
    } else if([self.mode isEqualToString:@"Radical"]) {
        self.entityName = kEntityRadical;
        self.predicate =[NSPredicate predicateWithFormat:@"firstRadical = %@ AND isFirstRadical = %@ AND section < 2", self.radical, @NO];
        self.sectionNameKeyPath = @"section";
        self.cacheSuffix = [NSString stringWithFormat:@"Radical%@", self.radical.rank];
        
        NSString *title;
        NSString *formattedSynonyms = self.radical.formattedSynonyms;
        if ([self.radical.synonyms length] > 3) {

            title = [NSString stringWithFormat:@"%@%@", ((Radical *)self.radical).simplified, formattedSynonyms];

        } else {
            title = [NSString stringWithFormat:@"%@%@ - Pick one more", ((Radical *)self.radical).simplified, formattedSynonyms];


        }
        
        self.navigationItem.titleView = [self titleViewWithText:title numberOfChineseCharacters:1 + [formattedSynonyms length]];

        NSSortDescriptor *sortSection = [[NSSortDescriptor alloc]
                                         initWithKey:@"section" ascending:YES  selector:nil];
        NSSortDescriptor *sortPostition = [[NSSortDescriptor alloc]
                                           initWithKey:@"rank" ascending:YES  selector:nil];
        
        self.sortDescriptors = @[sortSection, sortPostition];
        
#ifndef DEBUG
        [[Mixpanel sharedInstance] track:@"Lookup Radical" properties:@{@"Radical" : self.radical.simplified}];
#endif
        
    }else if([self.mode isEqualToString:@"Character"]) {
        self.entityName = kEntityCharacter;
        self.predicate =[NSPredicate predicateWithFormat:@"ANY secondRadicals = %@", self.radical];
        
        NSSortDescriptor *sortPostition = [[NSSortDescriptor alloc]
                                           initWithKey:@"rank" ascending:YES  selector:nil];
        
        self.sortDescriptors = @[sortPostition];
        

        
        NSString *title;
        if(self.radical.firstRadical) {
            NSString *formattedSynonyms = self.radical.formattedSynonyms;

            if ([self.radical.synonyms length] > 3) {
                title = [NSString stringWithFormat:@"%@ %@%@", self.radical.firstRadical.simplified, self.radical.simplified, formattedSynonyms];
            } else {
                title = [NSString stringWithFormat:@"%@ %@%@ characters", self.radical.firstRadical.simplified, self.radical.simplified, formattedSynonyms];

            }
            
            self.navigationItem.titleView = [self titleViewWithText:title numberOfChineseCharacters:3 + [formattedSynonyms length]];
#ifndef DEBUG
            [[Mixpanel sharedInstance] track:@"Lookup Characters" properties:@{@"Radical 1" : self.radical.firstRadical.simplified, @"Radical 2" : self.radical.simplified}];
#endif
            self.cacheSuffix = [NSString stringWithFormat:@"Character%@-%@",self.radical.firstRadical.rank, self.radical.rank];
        } else if (self.radical) {
            self.cacheSuffix = [NSString stringWithFormat:@"Character%@", self.radical.rank];


            NSString *formattedSynonyms = self.radical.formattedSynonyms;
            if ([self.radical.synonyms length] > 3) {
                title = [NSString stringWithFormat:@"%@%@",self.radical.simplified, formattedSynonyms];

            } else {
                title = [NSString stringWithFormat:@"%@%@ characters",self.radical.simplified, formattedSynonyms];
            }
            self.navigationItem.titleView = [self titleViewWithText:title numberOfChineseCharacters:1 + [formattedSynonyms length]];
#ifndef DEBUG
            [[Mixpanel sharedInstance] track:@"Lookup Characters" properties:@{@"Radical" : self.radical.simplified}];
#endif
        } else {
            self.title = @"Assorted characters";
            self.cacheSuffix = [NSString stringWithFormat:@"CharacterAssorted"];

#ifndef DEBUG
            [[Mixpanel sharedInstance] track:@"Lookup Characters"];
#endif
        }

        
    } else {
        NSLog(@"Unknown mode, not good...");
    }
    
    [self.fetchedResultsController performFetch:nil];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if([identifier isEqualToString:@"search"] || [identifier isEqualToString:@"searchTall"]) {
        if([self.mode isEqualToString:@"Radical"]) {
            return YES;
        } else if ([self.mode isEqualToString:@"Character"]) {
            [self performSegueWithIdentifier:@"character" sender:self];
            return NO;
        }
    }
    
    return NO;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
    //        [[segue destinationViewController] setDelegate:self];
    //    }
    
    NSIndexPath *indexPath =  [self.collectionView.indexPathsForSelectedItems firstObject];
    if (indexPath.section == 3) {
        if(indexPath.row == 0) {
            // Asorted
            RadicalsCharactersViewController *controller = (RadicalsCharactersViewController *)segue.destinationViewController;
            controller.managedObjectContext = self.managedObjectContext;
            controller.mode = @"Character";
            controller.collectionView.pagingEnabled = NO;
            return;
        } else {
            // About
            return;
        }
    }
    
    if([self.mode isEqualToString:@"Radical"]) {
        RadicalsCharactersViewController *controller = (RadicalsCharactersViewController *)segue.destinationViewController;
        controller.managedObjectContext = self.managedObjectContext;

        
        if (indexPath.section < [self.fetchedResultsController.sections count]) {
            Radical *radical =[self.fetchedResultsController objectAtIndexPath:indexPath];
            controller.radical = radical;
            if([radical.isFirstRadical boolValue]) {
                controller.mode = @"Radical";
            } else {
                controller.mode = @"Character";
                
            }

        } else {
            controller.mode = @"Character";
            if (self.radical) {
                controller.radical = self.radical;
            }
        }
      
        
    } else if([self.mode isEqualToString:@"Character"]) {
        CharacterViewController *controller = (CharacterViewController *)segue.destinationViewController;
        controller.managedObjectContext = self.managedObjectContext;

        controller.character = [self.fetchedResultsController objectAtIndexPath:[self.collectionView.indexPathsForSelectedItems firstObject]];
    }

    // Cool idea, but I have no idea how this is supposed to work:
    // controller.useLayoutToLayoutNavigationTransitions = YES;
}




#pragma mark - UICollectionView and delegates

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if([self.mode isEqualToString:@"Radical"]) {
        if (self.radical && [self.radical.section intValue] == 1) {
            // Second screen radicals do not have assorter characters
            return [self.fetchedResultsController.sections count];

        } else {
            return [self.fetchedResultsController.sections count] + 1;
        }
    } else {
        return [self.fetchedResultsController.sections count];

    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if([self sectionWithChineseCells:section]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        return [sectionInfo numberOfObjects];
    } else {
        if([self.mode isEqualToString:@"Radical"] && self.radical == nil) {
            return 2;
        } else {
            return 1;
        }
    }
}

-(BOOL)sectionWithChineseCells:(NSInteger)section {
    return [self.mode isEqualToString:@"Character"] || section < [self.fetchedResultsController.sections count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if([self sectionWithChineseCells:indexPath.section]) {
        if(IS_WIDESCREEN && [self.mode isEqualToString:@"Radical"]) {
            return CGSizeMake(70, 88);
        } else {
            return CGSizeMake(70, 70);
        }
    } else {
        return CGSizeMake(320, 44);

    }
}


-(RadicalCharacterCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RadicalCharacterCollectionViewCell *cell;
    
    if([self sectionWithChineseCells:indexPath.section]) {
        static NSString *CellIdentifier;
        
        if(IS_WIDESCREEN && [self.mode isEqualToString:@"Radical"]) {
            CellIdentifier = @"chineseTallCell";
        } else {
            CellIdentifier = @"chineseCell";
        }
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        [self configureCell:cell atIndexPath:indexPath];
    } else {
        static NSString *CellIdentifier = @"otherCell";
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        UILabel *label = (UILabel *)[cell viewWithTag:1];
    //        label.textColor = TINTCOLOR;
        
        switch (indexPath.row) {
            case 0:
                label.text = @"Assorted Characters...";
                break;
            case 1:
                label.text = @"About this app...";
                break;
            default:
                label.text = @"";
                break;
        }
    }
    
    return cell;
}

-(void)configureCell:(RadicalCharacterCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    
    id<Chinese> chinese = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *title = chinese.simplified;
    
//    NSArray *theArray = @[@"人",@"口",@"木",@"雨",@"头",@"透",@"阿",@"于",@"鱼",@"预",@"上",@"咳",@"咳",@"木",@"目",@"日",@"馹"];
//    NSUInteger randomIndex = arc4random() % [theArray count];
//    NSString *title = [theArray objectAtIndex:randomIndex];
    
    UILabel *simplified = (UILabel *)[cell viewWithTag:1];
    simplified.text = title;
    
    
    if(IS_WIDESCREEN) {
        UILabel *synonyms = (UILabel *)[cell viewWithTag:2];

        if([chinese isKindOfClass:[Radical class]]) {
            UILabel *synonyms = (UILabel *)[cell viewWithTag:2];
            
            NSString *synonymsString = ((Radical *)chinese).synonyms;
            
            // define the range you're interested in
            NSRange stringRange = {0, MIN([synonymsString length], 5)};
            
            // adjust the range to include dependent chars
            stringRange = [synonymsString rangeOfComposedCharacterSequencesForRange:stringRange];
            
            // Now you can create the short string
            NSString *shortString = [synonymsString substringWithRange:stringRange];
            
            synonyms.text = shortString;
        } else {
            synonyms.text = @"";
        }
    }
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if([kind isEqualToString:@"UICollectionElementKindSectionHeader"]) {
        return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
    } else {
        UICollectionReusableView *view =[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];
        if([self.mode isEqualToString:@"Character"] || indexPath.section == [self.fetchedResultsController.sections count] || (self.radical && [self.radical.section intValue] == 1)) {
            [view viewWithTag:1].hidden = YES;
        } else {
            [view viewWithTag:1].hidden = NO;

        }
        return view;

    }
}

#pragma mark - NSFetchedResultController and delegates
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:self.predicate];
    
    [fetchRequest setSortDescriptors:self.sortDescriptors];
    
    [fetchRequest setFetchBatchSize:30];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext sectionNameKeyPath:self.sectionNameKeyPath
                                                   cacheName:[NSString stringWithFormat:@"RadicalsCharactersCache%@", self.cacheSuffix]];
    _fetchedResultsController = theFetchedResultsController;
    
    return _fetchedResultsController;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        switch (indexPath.row) {
            case 0:
                if(IS_WIDESCREEN) {
                    [self performSegueWithIdentifier:@"searchTall" sender:self];
                } else {
                    [self performSegueWithIdentifier:@"search" sender:self];
                }
                break;
            case 1:
                [self performSegueWithIdentifier:@"aboutSegue" sender:self];
                break;
            default:
                break;
        }
    }
    
}
#pragma mark - Flipside View

//- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
//

@end
