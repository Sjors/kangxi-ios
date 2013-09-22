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

@interface RadicalsCharactersViewController () {
    UIImageView *instructionsTextImageView;
    UIImageView *instructionsCircleImageView;
    
}

@property NSString *entityName;
@property NSPredicate *predicate;
@property NSString *sectionNameKeyPath;
@property NSString *cacheSuffix;

@property NSArray *sortDescriptors;

@property BOOL justLoaded;
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
    
    
    if ([self.mode isEqualToString:@"Radical"] &&
        ([[NSUserDefaults standardUserDefaults]
         objectForKey:@"didCompleteIntro"] == nil ||
        ![[[NSUserDefaults standardUserDefaults]
           objectForKey:@"didCompleteIntro"] boolValue]) )
    {
        // Show instructions:
        self.collectionView.scrollEnabled = NO;
        instructionsTextImageView = [[UIImageView alloc]
                                     initWithImage:[UIImage imageNamed:@"InstructionText"]];
        instructionsTextImageView.frame = CGRectMake(0, -5, 476 / 2, 152 / 2);
        instructionsTextImageView.alpha = 0;
        [self.collectionView.superview addSubview:instructionsTextImageView];
        [self.collectionView.superview bringSubviewToFront:instructionsTextImageView];
        
        if(self.radical == nil) {
            [self flashInstructions:1];
        } else {
            [self flashInstructions:0];
        }
    }
    
    if([self.mode isEqualToString:@"Radical"]) {
        self.collectionView.pagingEnabled = YES;
    } else {
        self.collectionView.pagingEnabled = NO;
    }
    
    
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
    
    self.justLoaded = YES;
}

- (void)flashInstructions:(NSInteger)delay {
    [UIView animateWithDuration:1 delay:delay options:UIViewAnimationTransitionNone | UIViewAnimationOptionCurveLinear animations:^{
        instructionsTextImageView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 delay:10 options:UIViewAnimationTransitionNone | UIViewAnimationOptionCurveLinear animations:^{
            instructionsTextImageView.alpha = 0;
        } completion:^(BOOL finished) {
            self.collectionView.scrollEnabled = YES;
        }];
        
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    if (
        !self.justLoaded && ([[NSUserDefaults standardUserDefaults]
         objectForKey:@"didCompleteIntro"] == nil ||
        ![[[NSUserDefaults standardUserDefaults]
           objectForKey:@"didCompleteIntro"] boolValue] ))
    {
        [self flashInstructions:0];
        [self.collectionView reloadData];
    }
    
    self.justLoaded = NO;
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
//        return [sectionInfo numberOfObjects];
        if([self.mode isEqualToString:@"Radical"]) {
            // Always display 20 results in radical mode, to keep pagination working
            return 20;
        } else {
             return [sectionInfo numberOfObjects];
        }
    } else {
//        if([self.mode isEqualToString:@"Radical"] && self.radical == nil) {
//            return 2;
//        } else {
//            return 1;
//        }
        
        if(IS_WIDESCREEN) {
            return 10;
        } else {
            return 8;
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
        if((!IS_WIDESCREEN && indexPath.row < 7) || (IS_WIDESCREEN && indexPath.row < 9)) {
            return CGSizeMake(320, 44);
        } else {
            // Navbar: 10 points
            // Navigationbar: 44 points
            // 7 or 9 rows: 44 points
            // section header : 47 points
            // vertical margin between rows & headers: ? points
            // Screen height: 480 / 560 points
            // Last row should be: .... points
            
            return CGSizeMake(320, 20);
        }

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

        UIImageView *disclosureIndicator = (UIImageView *)[cell viewWithTag:2];
        
        switch (indexPath.row) {
            case 0:
                label.text = @"Assorted Characters...";
                disclosureIndicator.hidden = NO;
                break;
            case 1:
                if ([self.mode isEqualToString:@"Radical"] && self.radical == nil) {
                    label.text = @"About this app...";
                    disclosureIndicator.hidden = NO;
                } else {
                    label.text = @"";
                    disclosureIndicator.hidden = YES;

                }
                break;
            default:
                label.text = @"";
                disclosureIndicator.hidden = YES;
                break;
        }
    }
    
    return cell;
}

-(void)configureCell:(RadicalCharacterCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    UILabel *simplified = (UILabel *)[cell viewWithTag:1];
    
    UILabel *synonyms = (UILabel *)[cell viewWithTag:2];

    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][indexPath.section];

    
    
    if(indexPath.row < [sectionInfo numberOfObjects]) {
    
        id<Chinese> chinese = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSString *title = chinese.simplified;
        


        
    //    NSArray *theArray = @[@"人",@"口",@"木",@"雨",@"头",@"透",@"阿",@"于",@"鱼",@"预",@"上",@"咳",@"咳",@"木",@"目",@"日",@"馹"];
    //    NSUInteger randomIndex = arc4random() % [theArray count];
    //    NSString *title = [theArray objectAtIndex:randomIndex];
        
        simplified.text = title;
        
        if (
            [[NSUserDefaults standardUserDefaults]
              objectForKey:@"didCompleteIntro"] == nil ||
            ![[[NSUserDefaults standardUserDefaults]
                  objectForKey:@"didCompleteIntro"] boolValue] )
        {
            if([self.mode isEqualToString:@"Radical"]) {
                Radical *radical = (Radical *)chinese;
                
                if ( [radical.isFirstRadical boolValue] && [radical.simplified isEqualToString:@"月"] ) {
                    [self showCircleForCell:cell delay:4];
                }
                
                if ( ![radical.isFirstRadical boolValue] && [radical.simplified isEqualToString:@"日"] ) {
                    [self showCircleForCell:cell delay:2];
                }
                
            } else {
                if([title isEqualToString:@"明"]) {
                    [self showCircleForCell:cell delay:0];
                    [[NSUserDefaults standardUserDefaults]
                     setObject:@YES forKey:@"didCompleteIntro"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            
        }
         
        
        if(IS_WIDESCREEN) {

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
    } else {
        simplified.text = @"";
        
        if(IS_WIDESCREEN) {
            synonyms.text = @"";
        }
    }
}

-(void)showCircleForCell:(UICollectionViewCell *)cell delay:(NSInteger)delay {
    
    // Show circle:
    instructionsCircleImageView = [[UIImageView alloc]
                                   initWithImage:[UIImage imageNamed:@"InstructionCircle"]];
    //        instructionsCircleImageView.frame = CGRectMake(0, 2, 476 / 2, 152 / 2);
    instructionsCircleImageView.alpha = 0;
    [cell addSubview:instructionsCircleImageView];
    
    self.collectionView.scrollEnabled = NO;
    
    [UIView animateWithDuration:1 delay:delay options:UIViewAnimationTransitionNone | UIViewAnimationOptionCurveLinear animations:^{
        instructionsCircleImageView.alpha = 0.8;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 delay:5 options:UIViewAnimationTransitionNone | UIViewAnimationOptionCurveLinear animations:^{
            instructionsCircleImageView.alpha = 0;
        } completion:^(BOOL finished) {
            self.collectionView.scrollEnabled = YES;
        }];
        
    }];

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

            // Don't show header during intro phase:
            if (
                [[NSUserDefaults standardUserDefaults]
                 objectForKey:@"didCompleteIntro"] == nil ||
                ![[[NSUserDefaults standardUserDefaults]
                   objectForKey:@"didCompleteIntro"] boolValue] )
            {

                [view viewWithTag:1].alpha = 0;

              [UIView animateWithDuration:1 delay:10 options:UIViewAnimationTransitionNone | UIViewAnimationOptionCurveLinear animations:^{
                [view viewWithTag:1].alpha = 0.8;
                } completion:nil
               ];
            }
            
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
    if (indexPath.section == 3 || ([self.mode isEqualToString:@"Radical"] && self.radical != nil && indexPath.section == 2)) {
        switch (indexPath.row) {
            case 0:
                if(IS_WIDESCREEN) {
                    [self performSegueWithIdentifier:@"searchTall" sender:self];
                } else {
                    [self performSegueWithIdentifier:@"search" sender:self];
                }
                break;
            case 1:
                if ([self.mode isEqualToString:@"Radical"] && self.radical == nil) {
                    [self performSegueWithIdentifier:@"aboutSegue" sender:self];
                }
                break;
            default:
                break;
        }
    }
    
}

#pragma mark - Scrollview delegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // End the demo if the user scrolled down
    if (
        [[NSUserDefaults standardUserDefaults]
         objectForKey:@"didCompleteIntro"] == nil ||
        ![[[NSUserDefaults standardUserDefaults]
           objectForKey:@"didCompleteIntro"] boolValue] )
    {
        [[NSUserDefaults standardUserDefaults]
         setObject:@YES forKey:@"didCompleteIntro"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Flipside View

//- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
//

@end
