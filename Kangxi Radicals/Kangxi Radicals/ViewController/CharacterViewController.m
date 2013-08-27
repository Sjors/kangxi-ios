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

@interface CharacterViewController ()
@property NSURLSession *session;
@property NSMutableArray *players;
@property NSMutableArray *hasPronunciation;
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

    NSURLSessionConfiguration *configuration= [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    int n = [[self.fetchedResultsController fetchedObjects] count];
    
    self.players = [[NSMutableArray alloc] initWithCapacity:n];
    self.hasPronunciation = [[NSMutableArray alloc] initWithCapacity:n];

    
    for(int i=0; i < n; i++) {
        [self.players addObject:@""];
        [self.hasPronunciation addObject:@YES];

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    for(AVAudioPlayer *player in self.players) {
        if ([player isKindOfClass:[AVAudioPlayer class]]) {
            if(player.isPlaying) {
                [player stop];
            }
        }
    }
    
    [self.players removeAllObjects];
    
    [self.session invalidateAndCancel];
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
    
    UIImageView *play = (UIImageView *)[cell viewWithTag:3];
    play.image = [play.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    play.hidden = ![[self.hasPronunciation objectAtIndex:indexPath.row] boolValue];
}

# pragma mark Playback

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView *play = (UIImageView *)[cell viewWithTag:3];
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:4];
    
    play.hidden = YES;
    [spinner startAnimating];
    
    AVAudioPlayer *player = [self.players objectAtIndex:indexPath.row];
    
    if([player isKindOfClass:[AVAudioPlayer class]]) {
        [player play];
    } else {
        Word *word = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        
        NSString *wordParam = [word.simplified stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSString *wordParam = @"%E4%BA%BA"; // 人
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://apifree.forvo.com/key/f12f9942d441e46720bcf6543c2d5baa/format/json/action/word-pronunciations/word/%@/language/zh/limit/1/order/rate-desc", wordParam]];
        
        // Debugging:
//        url = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/s/wnfwekbxwc59nse/forvo-result.json?token_hash=AAEyqM_pOKAsJ5Cjqx3mhuYRfZwV9jJb0RDXgOYHaQWqLg&dl=1"];
        
        // Debug connection error:
//        url = [NSURL URLWithString:@"https://nowherffffffffe.com/fjjjdjjj"];
        
        // Debug corrupt JSON file:
//        url = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/s/fkayyju0vcf0lgi/forvo-result-broken.json?token_hash=AAH4htGfh81xiQ0TxcXIJL8aeGr1gdLlzJOdRavt0rZpJA&dl=1"];
        
        // Debug no pronunciations:
//        url = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/s/emeg2it4zzkkp53/forvo-result-no-pronunciations.json?token_hash=AAGMd9hiHBUGoIrifdX3srx4j-AvozQfwJCKxHsoqCbRLQ&dl=1"];

        
//        NSLog(@"URL: %@", url);
        
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
        [[self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];

            
            if(error == nil) {
                NSError *error;
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                
                if (error == nil && [result valueForKey:@"items"]) {
                    if ([[result valueForKey:@"items"] count] > 0) {
                        NSString *pathmp3 = [[[result valueForKey:@"items"] firstObject] valueForKey:@"pathmp3"];
                        
                        // Debug:
//                        pathmp3 = @"https://dl.dropboxusercontent.com/s/7qg1rvgsm4057hj/ren.mp3?token_hash=AAG9qOhLwKrI6KG75BEvUY3qY5JxXF5g4cytZGb9EOA-4A&dl=1";
                        
//                        NSLog(@"MP3: %@", pathmp3);
                        [self downloadAndPlayMP3:[NSURL URLWithString:pathmp3] indexPath:indexPath];
                        
                    } else {
                        [self.hasPronunciation setObject:@NO atIndexedSubscript:indexPath.row];
                        [self errorMessage:@"No pronunciation." indexPath:indexPath disablePlayButton:YES];
                    }
                } else {
                    // Deal with error in JSON
                    [self errorMessage:@"Connection error." indexPath:indexPath disablePlayButton:NO];
                }
            } else {
                // Deal with error in download
                [self errorMessage:@"Connection error." indexPath:indexPath disablePlayButton:NO];
            }
        }] resume];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)downloadAndPlayMP3:(NSURL *)url indexPath:(NSIndexPath *)indexPath {
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    [[self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];

        if(error == nil) {
            NSError *error;
            AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:data error:&error];
   
            if(error == nil) {
                player.delegate = self;
                [self.players setObject:player atIndexedSubscript:indexPath.row];
                [player play];
            } else {
                // Deal with audio file load error
                [self errorMessage:@"Audio file broken" indexPath:indexPath disablePlayButton:YES];
            }
        } else {
            // Deal with MP3 download error
            [self errorMessage:@"Connection error." indexPath:indexPath disablePlayButton:NO];

        }
        
    }] resume];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    [self restorePlayButton:[self indexPathForPlayer:player]];
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    // Deal with error
    [self.players removeObject:player];
    [self errorMessage:@"Audio file broken" indexPath:[self indexPathForPlayer:player] disablePlayButton:YES];
}

-(NSIndexPath *)indexPathForPlayer:(AVAudioPlayer *)player {
    return [NSIndexPath indexPathForRow:[self.players indexOfObject:player] inSection:0];
}

-(void)restorePlayButton:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView *play = (UIImageView *)[cell viewWithTag:3];
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:4];
    
    play.hidden = NO;
    [spinner stopAnimating];
}

#pragma mark - Error handling
- (void)errorMessage:(NSString *)message indexPath:(NSIndexPath *)indexPath disablePlayButton:(BOOL)disablePlayButton {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:4];
    [spinner stopAnimating];
    
    UILabel *errorLabel = (UILabel *)[cell viewWithTag:5];
    errorLabel.text = message;
    errorLabel.hidden = NO;
    errorLabel.alpha = 0.9;
    
    [UIView animateWithDuration:1 delay:5 options:UIViewAnimationTransitionNone | UIViewAnimationOptionCurveLinear animations:^{
        errorLabel.alpha = 0;
    } completion:^(BOOL finished) {
        errorLabel.hidden = YES;
        if (!disablePlayButton) {
            [self restorePlayButton:indexPath];
        }
    }];
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
