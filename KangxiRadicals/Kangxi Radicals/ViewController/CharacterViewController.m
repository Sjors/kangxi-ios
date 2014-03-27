//
//  CharacterViewController.m
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 24-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import "CharacterViewController.h"
#import "Word.h"
#import "AppDelegate.h"

#ifndef DEBUG
    #import <Mixpanel.h>
#endif

@interface CharacterViewController ()
@property AVSpeechSynthesizer *synthesizer;
@property NSMutableArray *utterances;
@property NSMutableArray *alreadyPlayed;
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
    
    NSUInteger n = [[self.fetchedResultsController fetchedObjects] count];
    
    self.synthesizer = [[AVSpeechSynthesizer alloc]  init];

    self.utterances = [[NSMutableArray alloc] initWithCapacity:n];
    self.alreadyPlayed = [[NSMutableArray alloc] initWithCapacity:n];

    for(int i=0; i < n; i++) {
        [self.utterances addObject:@""];
        [self.alreadyPlayed addObject:@NO];
    }
#ifndef DEBUG
    [[Mixpanel sharedInstance] track:@"Lookup Words" properties:@{@"Character" : self.character.simplified}];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    self.synthesizer.delegate = nil;
    [self.utterances removeAllObjects]; // Can't stop them a.f.a.i.k.
}

# pragma mark Tableview and delegates
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
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
    
    UIImageView *play = (UIImageView *)[cell viewWithTag:3];
    play.image = [play.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    play.hidden = NO;
}

# pragma mark Playback

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView *play = (UIImageView *)[cell viewWithTag:3];
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:4];
    
    play.hidden = YES;
    [spinner startAnimating];

    Word *word = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self playPronunciationUsingVoiceSynthesiser:word  indexPath:indexPath];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Speech Synthesiser

-(void)playPronunciationUsingVoiceSynthesiser:(Word *)word indexPath:(NSIndexPath *)indexPath {
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:word.simplified ];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-cn"];
    utterance.rate = AVSpeechUtteranceMinimumSpeechRate;
    [self.synthesizer speakUtterance:utterance];
    
    self.synthesizer.delegate = self;
    
    [self.utterances setObject:utterance atIndexedSubscript:indexPath.row];
    
    if(![[self.alreadyPlayed objectAtIndex:indexPath.row] boolValue] ) {
#ifndef DEBUG
        [[Mixpanel sharedInstance] track:@"Play Pronunciation" properties:@{@"Word" : ((Word *)[self.fetchedResultsController objectAtIndexPath:indexPath]).simplified}];
#endif
        [self.alreadyPlayed setObject:@YES atIndexedSubscript:indexPath.row];
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    
    NSIndexPath *indexPath = [self indexPathForUtterance:utterance];
    [self restorePlayButton:indexPath];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance {
    NSIndexPath *indexPath = [self indexPathForUtterance:utterance];

    [self restorePlayButton:indexPath];
    
}

-(NSIndexPath *)indexPathForUtterance:(AVSpeechUtterance *)utterance {
    return [NSIndexPath indexPathForRow:[self.utterances indexOfObject:utterance] inSection:0];
}

-(void)restorePlayButton:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView *play = (UIImageView *)[cell viewWithTag:3];
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:4];
    
    play.hidden = NO;
    [spinner stopAnimating];
}

#pragma mark - Error handling

#pragma mark - NSFetchedResultController and delegates
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:kEntityWord inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ANY characters = %@", self.character]];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"wordLength" ascending:YES  selector:nil];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:15];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    _fetchedResultsController = theFetchedResultsController;
    
    return _fetchedResultsController;
    
}




@end
