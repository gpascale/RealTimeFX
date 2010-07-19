//
//  EffectSelectorViewController.h
//  RealTimeFx
//
//  Created by Greg on 6/27/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EffectManager;
@class UpgradeTeaserViewController;

@interface EffectSelectorViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    EffectManager* effectManager;
    
    UITableView* tableView;
}

@property (nonatomic, retain) EffectManager* effectManager;
@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UpgradeTeaserViewController* upgradeTeaserViewController;
@property (nonatomic, retain) IBOutlet UIButton* moreButton;

- (IBAction) didTapCancelButton: (id) sender;
- (IBAction) didTapMoreButton: (id) sender;

- (void) didSelectEffectWithName: (NSString*) effectName;

@end
