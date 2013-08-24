//
//  RadicalsCharactersViewController.m
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 23-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import "RadicalsCharactersViewController.h"
#import "FirstRadical.h"
#import "SecondRadical.h"

@interface RadicalsCharactersViewController ()
@property NSString *entityName;
@property NSPredicate *predicate;
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
    
    
    if([self.mode isEqualToString:@"FirstRadical"]) {
        self.entityName = kEntityFirstRadical;
        self.predicate = nil;
        self.title = @"Which radical do you recognize?";
    } else if([self.mode isEqualToString:@"SecondRadical"]) {
        self.entityName = kEntitySecondRadical;
        self.predicate =[NSPredicate predicateWithFormat:@"firstRadical = %@", self.radical];
        
        NSString *title = [NSString stringWithFormat:@"%@ - Pick one more", ((FirstRadical *)self.radical).simplified];
        
        NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:title];
        
        UIFont *font=[UIFont fontWithName:@"STKaiti" size:20.0f];
        [attString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, 1)];
        

        UIView *customTitleView = [[UIView alloc] init];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 30.0f)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
        
        titleLabel.attributedText = attString;
        [titleLabel sizeToFit];
        
        customTitleView.frame = CGRectMake(self.navigationItem.titleView.frame.size.width/2 - titleLabel.frame.size.width/2, self.navigationItem.titleView.frame.size.height/2 - titleLabel.frame.size.height/2, titleLabel.frame.size.width, titleLabel.frame.size.height);
        
        [customTitleView addSubview:titleLabel];
        

        
        self.navigationItem.titleView =   customTitleView;
        

        
//        self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"STKaiti" size:30.0f]};
        
        
    } else {
        NSLog(@"Unknown mode, not good...");
    }
    
    [self.fetchedResultsController performFetch:nil];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if([identifier isEqualToString:@"search"]) {
        return [self.mode isEqualToString:@"FirstRadical"];
    }
    
    return false;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
    //        [[segue destinationViewController] setDelegate:self];
    //    }
    
    RadicalsCharactersViewController *controller = (RadicalsCharactersViewController *)segue.destinationViewController;
    
    controller.managedObjectContext = self.managedObjectContext;
    controller.mode = @"SecondRadical";
    FirstRadical *radical = [self.fetchedResultsController objectAtIndexPath:[self.collectionView.indexPathsForSelectedItems firstObject]];
    controller.radical = radical;
    
    // Cool idea, but I have no idea how this is supposed to work:
    // controller.useLayoutToLayoutNavigationTransitions = YES;
}




#pragma mark - UICollectionView and delegates

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self.fetchedResultsController fetchedObjects] count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;
    static NSString *CellIdentifier = @"firstRadicalCell";

    cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
       
    return cell;
}

-(void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    FirstRadical *radical = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UIButton *simplified = (UIButton *)[cell viewWithTag:1];
    simplified.titleLabel.font = [UIFont fontWithName:@"STKaiti" size:50];
    
    [simplified setTitle:radical.simplified forState:UIControlStateNormal];
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if([kind isEqualToString:@"UICollectionElementKindSectionHeader"]) {
        return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
    } else {
        return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];
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

#pragma mark - Flipside View

//- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
//

@end
