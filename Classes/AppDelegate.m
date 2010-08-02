//
//  AppDelegate.m
//  RealTimeFx
//
//  Created by Greg on 6/27/10.
//  Copyright Brown University 2010. All rights reserved.
//

#import "AppDelegate.h"
#import "RealTimeFxViewController.h"
#import "EffectSelectorViewController.h"
#import "ShellViewController.h"
#import "UpgradeTeaserViewController.h"
#import "Store.h"
#import "Logger.h"
#import "ThumbnailCache.h"

#import "FlurryAPI.h"
#import "LocalyticsSession.h"

@implementation AppDelegate

@synthesize window;
@synthesize shellViewController;
@synthesize fxViewController;
@synthesize upgradeTeaserViewController;

static BOOL showedUpgradeTeaserViewOnLaunch = NO;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Initialize the store before doing anything else. We may receive a payment notification if
    // a purchase was left unfinished
    [Store instance];
 
// Can't upgrade on simulator, so just make it the full version
#if 0//TARGET_IPHONE_SIMULATOR
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool: YES] 
                                              forKey: @"HasEffectPackOne"];
#endif    
    // Override point for customization after application launch.        

    // Add the view controller's view to the window and display.    
    [window makeKeyAndVisible];
    [window addSubview: shellViewController.view];            
    
    [shellViewController.contentView addSubview: fxViewController.view];
    
    // Log the app being launched
    int numberOfLaunchesSoFar = [Logger logAppLaunch];
    
    // Show the upgrade view on every 3rd launch, starting with the 2nd.
    printf("App has been launched %d times\n", numberOfLaunchesSoFar);
    if(![Store hasEffectPackOne] && (numberOfLaunchesSoFar + 2) % 3 == 0)
    {
        [UIView transitionWithView: fxViewController.view
                          duration: 0.75
                           options: UIViewAnimationOptionTransitionFlipFromRight
                        animations: ^{ [fxViewController.view addSubview: upgradeTeaserViewController.view]; }
                        completion: NULL];
        showedUpgradeTeaserViewOnLaunch = YES;
        [fxViewController stopRendering];
    }
    else
    {
        [fxViewController startRendering];
    }
    
    wasRendering = NO;
    
    @try
    {
        [FlurryAPI startSession: @"CZPJASWUCD4426KDM5RM"];
    }
    @catch (NSException * e)
    {
        NSAssert(NO, @"Failed to start analytics");
    }
        
    return YES;
}

+ (BOOL) showedUpgradeTeaserViewOnLaunch
{
    return showedUpgradeTeaserViewOnLaunch;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    wasRendering = fxViewController.isRendering;
    [fxViewController stopRendering];
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    wasRendering = fxViewController.isRendering;
    [fxViewController stopRendering];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    if (wasRendering)
    {
        [fxViewController startRendering];
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    if (wasRendering)
    {        
        [fxViewController startRendering];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    [fxViewController stopRendering];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[ThumbnailCache sharedCache] clear];
}

- (void)dealloc
{
    [fxViewController release];
    [shellViewController release];
    [window release];
    [super dealloc];
}

@end
