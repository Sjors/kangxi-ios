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
@property NSURLSession *session;
@property NSMutableArray *players;
@property NSMutableArray *utterances;
@property NSMutableArray *hasPronunciation;
@property NSMutableArray *alreadyPlayed;
@property NSMutableArray *hasMultiplePronunciations;
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
    
    if([self.character.simplified isEqualToString:@"肥"]) {
        [[NSUserDefaults standardUserDefaults]
         setObject:@YES forKey:@"didCompleteIntro"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSString *titleText = [NSString stringWithFormat:@"%@ %@",self.character.simplified, self.character.pinyin];
    self.navigationItem.titleView = [self titleViewWithText:titleText numberOfChineseCharacters:1];
    
    [self.fetchedResultsController performFetch:nil];

    NSURLSessionConfiguration *configuration= [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // Fall back to speech synthesiser if connection is too slow:
    configuration.timeoutIntervalForRequest = 2;
    
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSUInteger n = [[self.fetchedResultsController fetchedObjects] count];
    
    self.players = [[NSMutableArray alloc] initWithCapacity:n];
    self.utterances = [[NSMutableArray alloc] initWithCapacity:n];
    self.alreadyPlayed = [[NSMutableArray alloc] initWithCapacity:n];
    self.hasPronunciation = [[NSMutableArray alloc] initWithCapacity:n];
    self.hasMultiplePronunciations = [[NSMutableArray alloc] initWithCapacity:n];

    
    for(int i=0; i < n; i++) {
        [self.players addObject:@""];
        [self.utterances addObject:@""];
        [self.alreadyPlayed addObject:@NO];
        [self.hasPronunciation addObject:@YES];
        [self.hasMultiplePronunciations addObject:@NO];
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
    for(AVAudioPlayer *player in self.players) {
        if ([player isKindOfClass:[AVAudioPlayer class]]) {
            if(player.isPlaying) {
                [player stop];
            }
        }
    }
    
    [self.players removeAllObjects];
    [self.utterances removeAllObjects]; // Can't stop them a.f.a.i.k.

    
    [self.session invalidateAndCancel];
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
    
    AVAudioPlayer *player = [self.players objectAtIndex:indexPath.row];
    
    Word *word = [self.fetchedResultsController objectAtIndexPath:indexPath];

    
    if([player isKindOfClass:[AVAudioPlayer class]]) {
        [player play];
    } else if ( ![[self.hasPronunciation objectAtIndex:indexPath.row] boolValue] ) {
        [self playPronunciationUsingVoiceSynthesiser:word indexPath:indexPath];
    } else {
        NSString *wordParam = [word.simplified stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSString *wordParam = @"%E4%BA%BA"; // 人
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://apipremium.forvo.com/key/f12f9942d441e46720bcf6543c2d5baa/format/json/action/word-pronunciations/word/%@/language/zh/limit/10/order/rate-desc", wordParam]];
        
        // Debugging:
//        url = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/s/wnfwekbxwc59nse/forvo-result.json?token_hash=AAEyqM_pOKAsJ5Cjqx3mhuYRfZwV9jJb0RDXgOYHaQWqLg&dl=1"];
        
        // Debug connection error:
//        url = [NSURL URLWithString:@"https://nowherffffffffe.com/fjjjdjjj"];
        
        // Debug corrupt JSON file:
//        url = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/s/fkayyju0vcf0lgi/forvo-result-broken.json?token_hash=AAH4htGfh81xiQ0TxcXIJL8aeGr1gdLlzJOdRavt0rZpJA&dl=1"];
        
        // Debug no pronunciations:
//        url = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/s/emeg2it4zzkkp53/forvo-result-no-pronunciations.json?token_hash=AAGMd9hiHBUGoIrifdX3srx4j-AvozQfwJCKxHsoqCbRLQ&dl=1"];
        
        // Debug API limit:
//        url = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/s/jxlzydq3q2pmkkp/forvo-api-limit.json?token_hash=AAG8KXGvJn6ADPhCHiPKGqtkwnWrZYHuZIUNudqxk-INTQ&dl=1"];

//        NSLog(@"URL: %@", url);
        
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
        [[self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];

            
            if(error == nil) {
                NSError *error;
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                
                if (error == nil && [result respondsToSelector:@selector(objectForKey:)] && [result objectForKey:@"items"]) {
                    NSArray *items = [result valueForKey:@"items"];
                    if ([items count] == 1) {
                        NSString *pathmp3 = [[[result valueForKey:@"items"] firstObject] valueForKey:@"pathmp3"];
                        
                        // Debug:
//                        pathmp3 = @"https://dl.dropboxusercontent.com/s/7qg1rvgsm4057hj/ren.mp3?token_hash=AAG9qOhLwKrI6KG75BEvUY3qY5JxXF5g4cytZGb9EOA-4A&dl=1";
                        
//                        NSLog(@"MP3: %@", pathmp3);
                        [self downloadAndPlayMP3:[NSURL URLWithString:pathmp3] indexPath:indexPath];
                        [self.hasMultiplePronunciations setObject:@NO atIndexedSubscript:indexPath.row];
                    } else if ([items count] > 1) {
                        // Pick one at random and don't cache it:
                        [self.hasMultiplePronunciations setObject:@YES atIndexedSubscript:indexPath.row];
                        NSUInteger length = (unsigned long)[items count];
#ifdef DEBUG
                        NSLog(@"%lu pronunciations", length);
#endif

                        NSString *pathmp3 = [[items objectAtIndex:random() % length] valueForKey:@"pathmp3"];
                        
                        [self downloadAndPlayMP3:[NSURL URLWithString:pathmp3] indexPath:indexPath];
                    } else {
                        [self.hasPronunciation setObject:@NO atIndexedSubscript:indexPath.row];
                        [self playPronunciationUsingVoiceSynthesiser:word indexPath:indexPath];
#ifdef DEBUG
                        NSLog(@"Pronunciation Missing");
#else
                        [[Mixpanel sharedInstance] track:@"Pronunciation Missing" properties:@{@"Word" : ((Word *)[self.fetchedResultsController objectAtIndexPath:indexPath]).simplified}];
#endif
                    }
                } else {
                    // Deal with error in JSON
                    BOOL limitReached = NO;
                    
                    if(![result respondsToSelector:@selector(objectForKey:)] && [result respondsToSelector:@selector(firstObject)]) {
                        // It's an array.
                        NSArray *resultA = (NSArray *)result;
                        NSString *message = [resultA firstObject];
                        if([message respondsToSelector:@selector(stringByAppendingString:) ]) {
                            NSRange range;
                            range = [message rangeOfString:@"limit"];
                            if (range.location != NSNotFound) { limitReached = YES;  }
                            range = [message rangeOfString:@"Limit"];
                            if (range.location != NSNotFound) { limitReached = YES;  }
                        }
                    }
                    
                    if (limitReached) {
                        [self playPronunciationUsingVoiceSynthesiser:word  indexPath:indexPath];

//                        [self errorMessage:@"Try again tomorrow" indexPath:indexPath disablePlayButton:YES];
                        [self.hasPronunciation setObject:@NO atIndexedSubscript:indexPath.row];

                    } else {
                        [self playPronunciationUsingVoiceSynthesiser:word  indexPath:indexPath];

//                        [self errorMessage:@"Connection error." indexPath:indexPath disablePlayButton:NO];
                        #ifndef DEBUG
                        [[Mixpanel sharedInstance] track:@"Pronunciation Error" properties:@{@"Word" : ((Word *)[self.fetchedResultsController objectAtIndexPath:indexPath]).simplified,@"Method" : @"NSJSONSerialization",  @"Error" : [error description]}];
                        #endif
                    }
                }
            } else {
                [self playPronunciationUsingVoiceSynthesiser:word indexPath:indexPath];

                if(error.code == NSURLErrorTimedOut) {
                    // Timeout for JSON download
#ifdef DEBUG
                    NSLog(@"Download Timeout for JSON");
#else
                    [[Mixpanel sharedInstance] track:@"Download Timeout for JSON" properties:@{@"Word" : ((Word *)[self.fetchedResultsController objectAtIndexPath:indexPath]).simplified}];
#endif
                } else {
                    NSLog(@"%@", [error description]);

                    // Other JSON download error
                    //                [self errorMessage:@"Connection error." indexPath:indexPath disablePlayButton:NO];
#ifdef DEBUG
                    NSLog(@"Download error for JSON: %@", error);
#else
                    [[Mixpanel sharedInstance] track:@"Pronunciation Error" properties:@{@"Word" : ((Word *)[self.fetchedResultsController objectAtIndexPath:indexPath]).simplified,@"Method" : @"Download JSON",  @"Error" : [error description]}];
#endif

                }
             }
        }] resume];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)downloadAndPlayMP3:(NSURL *)url indexPath:(NSIndexPath *)indexPath {
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    
    Word *word = [self.fetchedResultsController objectAtIndexPath:indexPath];


    [[self.session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
        
        if(error == nil) {
            NSError *error;
//            AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:data error:&error];
            AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:location fileTypeHint:AVFileTypeMPEGLayer3 error:&error];
            
            if(error == nil) {
                player.delegate = self;
                [self.players setObject:player atIndexedSubscript:indexPath.row];
                [player play];
            } else {
                
                [self playPronunciationUsingVoiceSynthesiser:word indexPath:indexPath];
                
                // Deal with audio file load error
                if ([error code] == 1954115647) { //  Unsupported File Type
                    // http://stackoverflow.com/questions/4901709/iphone-avaudioplayer-unsupported-file-type
#ifdef DEBUG
                    NSLog(@"Pronunciation Unsupported File Type: %@", url);
#else
                    
                    [[Mixpanel sharedInstance] track:@"Pronunciation Unsupported File Type" properties:@{@"Word" : ((Word *)[self.fetchedResultsController objectAtIndexPath:indexPath]).simplified}];
#endif
                    
                } else {
#ifdef DEBUG
                    NSLog(@"Pronunciation Error: %@ for %@", error, url);
#else
                    [[Mixpanel sharedInstance] track:@"Pronunciation Error" properties:@{@"Word" : ((Word *)[self.fetchedResultsController objectAtIndexPath:indexPath]).simplified,@"Method" : @"AVAudioPlayer initWithData",  @"Error" : [error description]}];
#endif
                }
                
                //                [self errorMessage:@"Audio file broken" indexPath:indexPath disablePlayButton:YES];
                [self.hasPronunciation setObject:@NO atIndexedSubscript:indexPath.row];
                
            }
        } else {
            // Deal with MP3 download error
            //            [self errorMessage:@"Connection error." indexPath:indexPath disablePlayButton:NO];
            [self playPronunciationUsingVoiceSynthesiser:word indexPath:indexPath];
            
            if(error.code == NSURLErrorTimedOut) {
#ifdef DEBUG
                NSLog(@"Download Timeout for MP3");
#else
                [[Mixpanel sharedInstance] track:@"Download Timeout for MP3" properties:@{@"Word" : ((Word *)[self.fetchedResultsController objectAtIndexPath:indexPath]).simplified}];
#endif
            } else {
                // Other MP3 downlnoad error
#ifdef DEBUG
                NSLog(@"MP3 download error: %@", [error description]);
#else
                [[Mixpanel sharedInstance] track:@"Pronunciation Error" properties:@{@"Word" : ((Word *)[self.fetchedResultsController objectAtIndexPath:indexPath]).simplified,@"Method" : @"Download MP3",  @"Error" : [error description]}];
#endif
            }
            
            
        }
        
    }] resume];
 
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSIndexPath *indexPath = [self indexPathForPlayer:player];
    
    [self restorePlayButton:indexPath];
    
    if(![[self.alreadyPlayed objectAtIndex:indexPath.row] boolValue] ) {
#ifndef DEBUG
        [[Mixpanel sharedInstance] track:@"Play Pronunciation" properties:@{@"Word" : ((Word *)[self.fetchedResultsController objectAtIndexPath:indexPath]).simplified}];
#endif
        [self.alreadyPlayed setObject:@YES atIndexedSubscript:indexPath.row];
    }
    
    // Cache audio player if playback was succesful, but not if there were multiple pronunciations available at Forvo.

    if([[self.hasMultiplePronunciations objectAtIndex:indexPath.row] boolValue]) {
        [self.players setObject:@"" atIndexedSubscript:indexPath.row];
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    
    NSIndexPath *indexPath = [self indexPathForUtterance:utterance];
    [self restorePlayButton:indexPath];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance {
    
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSIndexPath *indexPath = [self indexPathForPlayer:player];
    Word *word = [self.fetchedResultsController objectAtIndexPath:indexPath];

    [self.players setObject:@"" atIndexedSubscript:indexPath.row];
    
    [self playPronunciationUsingVoiceSynthesiser:word indexPath:indexPath];
    [self.hasPronunciation setObject:@NO atIndexedSubscript:indexPath.row];
    
//    [self errorMessage:@"Audio file broken" indexPath:indexPath disablePlayButton:YES];
#ifndef DEBUG
    [[Mixpanel sharedInstance] track:@"Pronunciation Error" properties:@{@"Word" : ((Word *)[self.fetchedResultsController objectAtIndexPath:indexPath]).simplified,@"Method" : @"audioPlayerDecodeErrorDidOccur",  @"Error" : [error description]}];
#endif
}

-(NSIndexPath *)indexPathForPlayer:(AVAudioPlayer *)player {
    return [NSIndexPath indexPathForRow:[self.players indexOfObject:player] inSection:0];
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
//- (void)errorMessage:(NSString *)message indexPath:(NSIndexPath *)indexPath disablePlayButton:(BOOL)disablePlayButton {
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:4];
//    [spinner stopAnimating];
//    
//    UILabel *errorLabel = (UILabel *)[cell viewWithTag:5];
//    errorLabel.text = message;
//    errorLabel.hidden = NO;
//    errorLabel.alpha = 0.9;
//    
//    [UIView animateWithDuration:1 delay:5 options:UIViewAnimationTransitionNone | UIViewAnimationOptionCurveLinear animations:^{
//        errorLabel.alpha = 0;
//    } completion:^(BOOL finished) {
//        errorLabel.hidden = YES;
//        if (!disablePlayButton) {
//            [self restorePlayButton:indexPath];
//        }
//    }];
//}

 


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

-(void)playPronunciationUsingVoiceSynthesiser:(Word *)word indexPath:(NSIndexPath *)indexPath {
    
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]  init];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:word.simplified ];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-cn"];
    utterance.rate = AVSpeechUtteranceMinimumSpeechRate;
    [synthesizer speakUtterance:utterance];
    
    synthesizer.delegate = self;
    
    [self.utterances setObject:utterance atIndexedSubscript:indexPath.row];
}


@end
