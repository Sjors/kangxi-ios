//
//  AppDelegate.m
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 23-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

#ifndef DEBUG
    #import <Crashlytics/Crashlytics.h>
    #import <Mixpanel/Mixpanel.h>
#endif

#import "RadicalsCharactersViewController.h"


//#define DO_IMPORT YES

#define MIXPANEL_TOKEN @"205327faee0efccec16b37c2db34d98d"

#ifdef DO_IMPORT
#ifdef LITE
    #import "import_lite.h"
#else
    #import "import.h"
#endif
#endif

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifndef DEBUG
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    #ifdef LITE
        [[Mixpanel sharedInstance] registerSuperProperties:@{@"Lite": @YES}];
    #endif
    [[Mixpanel sharedInstance] track:@"Launch"];
#endif
    
#ifndef DEBUG
    // This should be at the top but after all other 3rd party SDK code.
    [Crashlytics startWithAPIKey:@"1e9765b42004724029bbfe36e4c84518c51f7503"];
#endif
    
    

#ifdef DO_IMPORT
    if([[self storeURL] checkResourceIsReachableAndReturnError:nil]) {
        [[NSFileManager defaultManager] removeItemAtPath:[[self storeURL] path] error:NULL];
        
        // In case you start using WAL mode again during either import or normal app mode:
        [[NSFileManager defaultManager] removeItemAtPath:[[[self storeURL] path] stringByAppendingString:@"-shm"] error:NULL];
        [[NSFileManager defaultManager] removeItemAtPath:[[[self storeURL] path] stringByAppendingString:@"-wal"] error:NULL];

    }
    [Populator import:self.managedObjectContext];
    [Populator synonyms:self.managedObjectContext];

    // Copy to project:
    NSError *error;
    NSString *destination = @"/Users/sjors/Dropbox/Kangxi/iOs/Kangxi Radicals/Kangxi Radicals/Kangxi_Radicals.sqlite";
    [[NSFileManager defaultManager] removeItemAtPath:destination error:NULL];
    [[NSFileManager defaultManager] copyItemAtPath:[[self storeURL] path] toPath:destination error:&error];
    if (error) {
        NSLog(@"Could not copy sqlite file to project directory.");
    }
#endif
    
    self.window.tintColor = TINTCOLOR;
    
    RadicalsCharactersViewController *controller = [((UINavigationController *)((RadicalsCharactersViewController *)self.window.rootViewController)).viewControllers objectAtIndex:0];
    controller.managedObjectContext = self.managedObjectContext;
    controller.mode = @"Radical";
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:kEntityRadical inManagedObjectContext:self.managedObjectContext]];
    
    [request setIncludesSubentities:NO];
    
    NSError *activationError = nil;
    BOOL success = [[AVAudioSession sharedInstance] setActive: NO error: &activationError];
    if (!success) {
        NSLog(@"Audio session deactivation error: %@", activationError);
#ifndef DEBUG
        [[Mixpanel sharedInstance] track:@"Audio Session Error" properties:@{@"Method" : @"Deactivate Session",  @"Error" : [activationError description]}];
#endif
    }
    
    NSError *setCategoryError = nil;
    success = [[AVAudioSession sharedInstance]
               setCategory: AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers
               error: &setCategoryError];
    
    if (!success) {
        NSLog(@"Audio session category error: %@", [setCategoryError description]);
#ifndef DEBUG
        [[Mixpanel sharedInstance] track:@"Audio Session Error" properties:@{@"Method" : @"Set Session Category",  @"Error" : [setCategoryError description]}];
#endif    
    }
    
    activationError = nil;
    success = [[AVAudioSession sharedInstance] setActive: NO error: &activationError];
    if (!success) {
        NSLog(@"Audio session deactivation error: %@", activationError);
#ifndef DEBUG
        [[Mixpanel sharedInstance] track:@"Audio Session Error" properties:@{@"Method" : @"Activate Session",  @"Error" : [activationError description]}];
#endif
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
#ifndef DEBUG
    [[Mixpanel sharedInstance] flush]; // Uploads datapoints to the Mixpanel Server.
#endif
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
#ifdef DO_IMPORT
        [_managedObjectContext setUndoManager:nil];
#endif
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Kangxi_Radicals" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

#ifndef DO_IMPORT
//    if(![[self storeURL] checkResourceIsReachableAndReturnError:nil]) {
//        NSURL *bundleURL =[[NSBundle mainBundle] URLForResource:@"Kangxi_Radicals" withExtension:@"sqlite"];
//        
//        [[NSFileManager defaultManager] copyItemAtPath:[bundleURL path] toPath:[[self storeURL] path] error:nil];
//        
//        [self addSkipBackupAttributeToItemAtURL:[self storeURL]];
//    }
#endif
    
#ifdef DO_IMPORT
    // Don't use WAL mode during import or stuff will be lost.
    NSDictionary *options = @{NSSQLitePragmasOption : @{ @"journal_mode" :
                                                             @"DELETE"}};
#else
    // WAL mode is not recommended for a read-only database:
    NSDictionary *options = @{NSReadOnlyPersistentStoreOption : @YES, NSSQLitePragmasOption : @{ @"journal_mode" : @"DELETE"}};
#endif
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:options  error:&error]) {

        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

#pragma mark - Paths

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


-(NSURL *)storeURL {
#ifdef DO_IMPORT
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Kangxi_Radicals.sqlite"];
#else
    return [[NSBundle mainBundle] URLForResource:@"Kangxi_Radicals" withExtension:@"sqlite"];
#endif
}

# pragma mark UI
- (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible {
    static NSInteger NumberOfCallsToSetVisible = 0;
    if (setVisible)
        NumberOfCallsToSetVisible++;
    else
        NumberOfCallsToSetVisible--;
    
#ifdef DEBUG
    // The assertion helps to find programmer errors in activity indicator management.
    // Since a negative NumberOfCallsToSetVisible is not a fatal error,
    // it should probably be removed from production code.
    NSAssert(NumberOfCallsToSetVisible >= 0, @"Network Activity Indicator was asked to hide more often than shown");
#endif
    
    // Display the indicator as long as our static counter is > 0.
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(NumberOfCallsToSetVisible > 0)];
}

@end
