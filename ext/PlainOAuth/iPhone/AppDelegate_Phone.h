//
//  AppDelegate_Phone.h
//  Plain2
//
//  Created by Jaanus Kase on 03.05.10.
//  Copyright 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate_Phone : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UINavigationController *nav;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

