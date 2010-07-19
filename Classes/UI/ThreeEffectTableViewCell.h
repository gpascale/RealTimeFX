//
//  ThreeEffectTableViewCell.h
//  RealTimeFx
//
//  Created by Greg on 7/5/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum ButtonTag_t
{
    ButtonTag_Left = 0,
    ButtonTag_Center,
    ButtonTag_Right,
    ButtonTag_Sentinel
} ButtonTag;

@class EffectSelectorViewController;

@interface ThreeEffectTableViewCell : UITableViewCell
{
@private
    
    // The parent table view in which this cell resides.
    EffectSelectorViewController* parentView;
    
    // Child UIControls
    UIButton* buttonLeft;
    UIButton* buttonCenter;
    UIButton* buttonRight;
    
    UILabel* labelLeft;
    UILabel* labelCenter;
    UILabel* labelRight;
    
    UIImageView* imageLeft;
    UIImageView* imageCenter;
    UIImageView* imageRight;
    
    // Selection UI
    UIView* selectionView;
}

@property (nonatomic, retain) IBOutlet UIButton* buttonLeft;
@property (nonatomic, retain) IBOutlet UIButton* buttonCenter;
@property (nonatomic, retain) IBOutlet UIButton* buttonRight;
@property (nonatomic, retain) IBOutlet UILabel* labelLeft;
@property (nonatomic, retain) IBOutlet UILabel* labelCenter;
@property (nonatomic, retain) IBOutlet UILabel* labelRight;
@property (nonatomic, retain) IBOutlet UIImageView* imageLeft;
@property (nonatomic, retain) IBOutlet UIImageView* imageCenter;
@property (nonatomic, retain) IBOutlet UIImageView* imageRight;

@property (nonatomic, retain) IBOutlet EffectSelectorViewController* parentView;

- (void) setEffectForIndex: (NSInteger) index
                  withName: (NSString*) effectName
                 thumbnail: (NSString*) thumbnailPath;

- (void) clearSelection;

- (void) setSelection: (int) index;

@end
