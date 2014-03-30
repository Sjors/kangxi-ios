#import <UIKit/UIKit.h>
#import "Radical.h"
#import "Character.h"
#import "Word.h"

@interface Populator : NSObject
#ifdef DO_IMPORT
+(void)importRadicalsCharacters:(NSManagedObjectContext *)managedObjectContext;
+(void)importCharactersWords:(NSManagedObjectContext *)managedObjectContext;
+(void)importSynonyms:(NSManagedObjectContext *)managedObjectContext;
#endif
@end
