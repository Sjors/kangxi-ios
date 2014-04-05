#import "import.h"
@implementation Populator
#ifdef DO_IMPORT
+(void)importRadicalsCharacters:(NSManagedObjectContext *)managedObjectContext {
  // Load JSON from file:
    NSString *path = @"/Users/sjors/Dropbox/Kangxi/iOs/KangxiRadicals/Kangxi Radicals/radicals_characters.json";
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
    
    if (data == nil) {
        abort();
    }

    NSError *jsonError;

    NSArray *firstRadicals = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

    if (jsonError != nil) {
        NSLog(@"Error parsing JSON: %@", [jsonError description]);
    }
   
    for(NSDictionary *firstRadical  in firstRadicals) {
        Radical* r;
        r = [NSEntityDescription insertNewObjectForEntityForName:kEntityRadical
                   inManagedObjectContext:managedObjectContext];
                  
        r.isFirstRadical = @YES;
        r.simplified = [firstRadical valueForKey:@"simplified"];
        r.rank = [firstRadical valueForKey:@"rank"];
        r.section = @0;
        r.trial = [firstRadical valueForKey:@"demo"];
        
        for(NSDictionary *secondRadical in [firstRadical valueForKey:@"second_radicals"]) {
            Radical* r2;

            r2 = [NSEntityDescription insertNewObjectForEntityForName:kEntityRadical
                       inManagedObjectContext:managedObjectContext];
            r2.isFirstRadical = @NO;
            r2.firstRadical = r;
            r2.section = @0;
            r2.simplified = [secondRadical valueForKey:@"simplified"];
            r2.rank = [secondRadical valueForKey:@"rank"];
            r2.trial = [secondRadical valueForKey:@"demo"];
        
            for(NSDictionary *character in [secondRadical valueForKey:@"characters"]) {
                NSString *simplified = [character valueForKey:@"simplified"];
                Character* c;
                c = [Character fetchBySimplified:simplified inManagedObjectContext:managedObjectContext includesPropertyValuesAndSubentities:NO];
                if( c==nil ) {
                  c = [NSEntityDescription insertNewObjectForEntityForName:kEntityCharacter inManagedObjectContext:managedObjectContext];
                  c.simplified = simplified;
                  c.rank = [character valueForKey:@"rank"];
                  c.trial = [character valueForKey:@"demo"];


                }
                [c addSecondRadicalsObject:r2];
            }
        }
        
    }
      
    // Save context:
    NSError *error;
    [managedObjectContext save:&error];
    if(error) { NSLog(@"%@",error); abort();}
}


    
+(void)importCharactersWords:(NSManagedObjectContext *)managedObjectContext {
    NSString *path = @"/Users/sjors/Dropbox/Kangxi/iOs/KangxiRadicals/Kangxi Radicals/characters_words.json";
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
    
    if (data == nil) {
        abort();
    }
    
    NSError *jsonError;
    
    NSArray *characters = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    
    if (jsonError != nil) {
        NSLog(@"Error parsing JSON: %@", [jsonError description]);
    }
    
    for (int k = 0; k < [characters count]; k = k + 50) {
        
        @autoreleasepool {
            for(NSDictionary *character  in [characters subarrayWithRange:NSMakeRange(k, MIN(50, [characters count] - k))]) {


                Character* c;
                c = [Character fetchBySimplified:[character valueForKey:@"simplified"] inManagedObjectContext:managedObjectContext includesPropertyValuesAndSubentities:NO];
                
                for (NSDictionary *word in [character valueForKey:@"words"]) {
                    Word *w = [Word fetchBySimplified:[word valueForKey:@"simplified"] inManagedObjectContext:managedObjectContext includesPropertyValuesAndSubentities:NO];
                    
                    if( w==nil ) {
                        w = [NSEntityDescription insertNewObjectForEntityForName:kEntityWord inManagedObjectContext:managedObjectContext];
                        w.simplified = [word valueForKey:@"simplified"];
                        w.english = [word valueForKey:@"english"];
                        w.wordLength = [NSNumber numberWithInt:[w.simplified length]];
                    }
                    
                    [c addWordsObject:w];
                }
                

            }
            

        }
        // Save context:
        NSError *error;
        [managedObjectContext save:&error];
        if(error) { NSLog(@"%@",error); abort();}
        
        NSLog(@"%d characters processed", k + 50);
    }

}

//*********** 
// Synonyms * 
//*********** 
+(void)importSynonyms:(NSManagedObjectContext *)managedObjectContext {
    NSString *path = @"/Users/sjors/Dropbox/Kangxi/iOs/KangxiRadicals/Kangxi Radicals/synonyms.json";
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
    
    if (data == nil) {
        abort();
    }
    
    NSError *jsonError;
    
    NSArray *synonyms = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    
    if (jsonError != nil) {
        NSLog(@"Error parsing JSON: %@", [jsonError description]);
    }
    
    for(NSDictionary *synonym  in synonyms) {
        NSArray *radicals = [Radical findAllBySimplified:[synonym valueForKey:@"simplified"] inManagedObjectContext:managedObjectContext];
        
        for (Radical *radical in radicals) {
            radical.synonyms = [synonym valueForKey:@"synonyms"];
        }
        
        
    }
    
    // Save context:
    NSError *error;
    [managedObjectContext save:&error];
    if(error) { NSLog(@"%@",error); abort();}
}
#endif
@end
