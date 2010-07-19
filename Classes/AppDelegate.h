//
//  AppDelegate.h
//  RealTimeFx
//
//  Created by Greg on 6/27/10.
//  Copyright Brown University 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RealTimeFxViewController;
@class EffectSelectorViewController;
@class ShellViewController;
@class UpgradeTeaserViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow* window;
    RealTimeFxViewController* fxViewController;
    ShellViewController* shellViewController;
    UpgradeTeaserViewController* upgradeTeaserViewController;
    BOOL wasRendering;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ShellViewController* shellViewController;
@property (nonatomic, retain) IBOutlet RealTimeFxViewController *fxViewController;
@property (nonatomic, retain) IBOutlet UpgradeTeaserViewController *upgradeTeaserViewController;

+ (BOOL) showedUpgradeTeaserViewOnLaunch;

@end

