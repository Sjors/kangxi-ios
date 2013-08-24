//
//  AppDelegate.m
//  Kangxi Radicals
//
//  Created by Sjors Provoost on 23-08-13.
//  Copyright (c) 2013 Purple Dunes. All rights reserved.
//

#import "AppDelegate.h"

#import "RadicalsCharactersViewController.h"

// Temporary imports for dummy data:
#import "FirstRadical.h"
#import "SecondRadical.h"
#import "Character.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    self.window.tintColor = [UIColor colorWithRed:170.0 / 255.0 green:56.0/ 255.0 blue:30.0/ 255.0 alpha:1];
    
    RadicalsCharactersViewController *controller = [((UINavigationController *)((RadicalsCharactersViewController *)self.window.rootViewController)).viewControllers objectAtIndex:0];
    controller.managedObjectContext = self.managedObjectContext;
    controller.mode = @"FirstRadical";
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:kEntityFirstRadical inManagedObjectContext:self.managedObjectContext]];
    
    [request setIncludesSubentities:NO];
    
    NSError *err;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&err];
    if(count == NSNotFound) {
        //Handle error
    }
    
    if(count == 0) {        // Dummy data:
        int tally = 0;
        for(NSString *radical in @[@"人", @"口",@"亻",@"土",@"扌",@"日", @"月", @"木", @"氵",@"艹",@"讠",@"宀",@"又" ,@"禾" ,@"田" ,@"十" ,@"亠" ,@"厶" ,@"大" ,@"丷"] ) {
            FirstRadical* r = [NSEntityDescription insertNewObjectForEntityForName:kEntityFirstRadical inManagedObjectContext:self.managedObjectContext];
            r.simplified = radical;
            r.position = [NSNumber numberWithInt:tally];
            
            if([radical isEqualToString:@"人"]) {
                int tally2 = 0;
                for(NSString *radical2 in @[@"人", @"口", @"土", @"忄", @"日", @"纟", @"刂", @"⺮", @"车", @"方", @"冫", @"子", @"王", @"⺷", @"卩", @"爫", @"二", @"冂", @"ハ", @"⺈"] ) {
                    SecondRadical* r2 = [NSEntityDescription insertNewObjectForEntityForName:kEntitySecondRadical inManagedObjectContext:self.managedObjectContext];
                    r2.simplified = radical2;
                    r2.position = [NSNumber numberWithInt:tally2];
                    r2.firstRadical = r;
                    
                     if([radical2 isEqualToString:@"口"]) {
                         int tally = 0;
                         for(NSString *character in @[@"喝", @"答", @"给", @"拿", @"容", @"命", @"合", @"拾", @"咳", @"盒", @"吸", @"俗"] ) {
                             Character* c = [NSEntityDescription insertNewObjectForEntityForName:kEntityCharacter inManagedObjectContext:self.managedObjectContext];
                             c.simplified = character;
                             c.position = [NSNumber numberWithInt:tally];
                             c.secondRadical = r2;
                         }
                         tally++;

                     }
                }
                tally2++;
                
            }
            
            tally++;
        }
                                   
       [self.managedObjectContext save:nil];
    }
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Kangxi_Radicals.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
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

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
