//
//  RadicalsCharactersViewController.m
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 23-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import "RadicalsCharactersViewController.h"
#import "CharacterViewController.h"

#import "Radical.h"
#import "Character.h"

@interface RadicalsCharactersViewController ()
@property NSString *entityName;
@property NSPredicate *predicate;
@property NSString *sectionNameKeyPath;
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
                                           initWithKey:@"position" ascending:YES  selector:nil];
        
        self.sortDescriptors = @[sortSection, sortPostition];
        
        self.title = @"Which radical do you recognize?";
    } else if([self.mode isEqualToString:@"Radical"]) {
        self.entityName = kEntityRadical;
        self.predicate =[NSPredicate predicateWithFormat:@"firstRadical = %@ AND isFirstRadical = %@ AND section < 2", self.radical, @NO];
        self.sectionNameKeyPath = @"section";
        
        NSString *title = [NSString stringWithFormat:@"%@ - Pick one more", ((Radical *)self.radical).simplified];
        
        self.navigationItem.titleView = [self titleViewWithText:title numberOfChineseCharacters:1];

        NSSortDescriptor *sortSection = [[NSSortDescriptor alloc]
                                         initWithKey:@"section" ascending:YES  selector:nil];
        NSSortDescriptor *sortPostition = [[NSSortDescriptor alloc]
                                           initWithKey:@"position" ascending:YES  selector:nil];
        
        self.sortDescriptors = @[sortSection, sortPostition];
        
    }else if([self.mode isEqualToString:@"Character"]) {
        self.entityName = kEntityCharacter;
        self.predicate =[NSPredicate predicateWithFormat:@"ANY secondRadicals = %@", self.radical];
        
        NSSortDescriptor *sortPostition = [[NSSortDescriptor alloc]
                                           initWithKey:@"position" ascending:YES  selector:nil];
        
        self.sortDescriptors = @[sortPostition];
        
        NSString *title;
        if(self.radical.firstRadical) {
            title = [NSString stringWithFormat:@"%@ %@ characters", self.radical.firstRadical.simplified, self.radical.simplified];
            self.navigationItem.titleView = [self titleViewWithText:title numberOfChineseCharacters:3];

        } else if (self.radical) {
            title = [NSString stringWithFormat:@"%@ characters",self.radical.simplified];
            self.navigationItem.titleView = [self titleViewWithText:title numberOfChineseCharacters:1];
        } else {
            self.title = @"Assorted characters";
        }

        
    } else {
        NSLog(@"Unknown mode, not good...");
    }
    
    [self.fetchedResultsController performFetch:nil];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if([identifier isEqualToString:@"search"]) {
        if([self.mode isEqualToString:@"Radical"]) {
            return YES;
        } else if ([self.mode isEqualToString:@"Character"]) {
            [self performSegueWithIdentifier:@"character" sender:self];
            return NO;
        }
    }
    if([identifier isEqualToString:@"assortedCharactersSegue"]) {
        return YES;
    }
    
    return NO;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
    //        [[segue destinationViewController] setDelegate:self];
    //    }
    
    
    
    if([self.mode isEqualToString:@"Radical"]) {
        RadicalsCharactersViewController *controller = (RadicalsCharactersViewController *)segue.destinationViewController;
        controller.managedObjectContext = self.managedObjectContext;

        NSIndexPath *indexPath =  [self.collectionView.indexPathsForSelectedItems firstObject];
        
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
        return [self.fetchedResultsController.sections count] + 1;
    } else {
        return [self.fetchedResultsController.sections count];

    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if([self sectionWithChineseCells:section]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        return [sectionInfo numberOfObjects];
    } else {
        return 1;
    }
}

-(BOOL)sectionWithChineseCells:(NSInteger)section {
    return [self.mode isEqualToString:@"Character"] || section < [self.fetchedResultsController.sections count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if([self sectionWithChineseCells:indexPath.section]) {
        return CGSizeMake(70, 70);
    } else {
        return CGSizeMake(320, 44);

    }
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;
    
    if([self sectionWithChineseCells:indexPath.section]) {
        static NSString *CellIdentifier = @"chineseCell";

        cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        [self configureCell:cell atIndexPath:indexPath];
    } else {
        static NSString *CellIdentifier = @"assortedCharactersCell";
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    
    return cell;
}

-(void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    id<Chinese> chinese = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UIButton *simplified = (UIButton *)[cell viewWithTag:1];
    simplified.titleLabel.font = [UIFont fontWithName:@"STKaiti" size:50];
    
    [simplified setTitle:chinese.simplified forState:UIControlStateNormal];
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if([kind isEqualToString:@"UICollectionElementKindSectionHeader"]) {
        return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
    } else {
        UICollectionReusableView *view =[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];
        if([self.mode isEqualToString:@"Character"] || indexPath.section == [self.fetchedResultsController.sections count]) {
            [view viewWithTag:1].hidden = YES;
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
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext sectionNameKeyPath:self.sectionNameKeyPath
                                                   cacheName:nil];
    _fetchedResultsController = theFetchedResultsController;
    
    return _fetchedResultsController;
    
}

#pragma mark - Flipside View

//- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
//

@end
