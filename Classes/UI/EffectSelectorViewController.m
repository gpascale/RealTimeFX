//
//  EffectSelectorViewController.m
//  RealTimeFx
//
//  Created by Greg on 6/27/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "EffectSelectorViewController.h"
#import "EffectManager.h"
#import "ThreeEffectTableViewCell.h"
#import "UpgradeTeaserViewController.h"
#import "Store.h"

@interface EffectSelectorViewController (private)

- (ThreeEffectTableViewCell*) createCellForRow: (NSInteger) row;
- (void) synchronizeSelectionUI: (NSString*) effectName;
- (void) dismissSelf;

@end

@implementation EffectSelectorViewController

@synthesize effectManager;
@synthesize tableView;
@synthesize upgradeTeaserViewController;
@synthesize moreButton;

- (void) viewWillAppear: (BOOL) animated
{
    // Synchronize Selection UI with the currently active effect
    [self synchronizeSelectionUI: effectManager.activeEffectName];
}

- (void) viewDidLoad
{
    if([Store hasEffectPackOne])
    {
        [self.moreButton removeFromSuperview];
        self.moreButton = nil;
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView*) tableView
  numberOfRowsInSection: (NSInteger) section
{    
    return ceil([effectManager.effectNames count] / 3.0);    
}

- (CGFloat) tableView: (UITableView*) tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath
{
    return 130;
}

// Customize the appearance of table view cells.
- (UITableViewCell*) tableView: (UITableView*) tableV
         cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    return [self createCellForRow: indexPath.row];
}

- (void) synchronizeSelectionUI: (NSString*) effectName
{
    int index = [effectManager.effectNames indexOfObject: effectName];
    int gridRow = index / 3;
    int gridCol = index % 3;
    
    for(int i = 0; i < [tableView numberOfRowsInSection: 0]; ++i)
    {
        UITableViewCell* cell =  [tableView cellForRowAtIndexPath: 
                                  [NSIndexPath indexPathForRow: i
                                                     inSection: 0]];
        
        if([cell isKindOfClass: [ThreeEffectTableViewCell class]])
        {
            if(i != gridRow)
            {
                [(ThreeEffectTableViewCell*)cell clearSelection]; 
            }
            else
            {
                [(ThreeEffectTableViewCell*)cell setSelection: gridCol];
            }
        }
    }
}

- (void) didSelectEffectWithName: (NSString*) effectName
{
    // Timing is important for responsiveness here.
    [self synchronizeSelectionUI: effectName];    
    [effectManager performSelector: @selector(activateEffectWithName:)
                        withObject: effectName
                        afterDelay: 0.05f];
    [self performSelector: @selector(dismissSelf)
                        withObject: nil
                        afterDelay: 0.2f];
}

- (void) dismissSelf
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"SelectedEffectOrTappedCanel"
                                                        object: self];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [effectManager activateEffectWithName: [effectManager.effectNames objectAtIndex: indexPath.row]];
}

- (IBAction) didTapCancelButton: (id) sender
{
    [self dismissSelf];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc
{
    [super dealloc];
}

- (ThreeEffectTableViewCell*) createCellForRow: (NSInteger) row
{
    ThreeEffectTableViewCell* cell = (ThreeEffectTableViewCell*) [tableView dequeueReusableCellWithIdentifier: @"Cell"];
    
    if (cell == nil)
    {
        NSArray* objs = [[NSBundle mainBundle] loadNibNamed: @"ThreeEffectTableViewCell" owner: self options: nil];
        cell = [objs objectAtIndex: 0];
    }
    
    NSString* dummyThumbnailPath = [[NSBundle mainBundle] pathForResource: @"EffectThumbnailPlaceholder"
                                                                   ofType: @"png"];
    
    for(int i = 0; i < 3; ++i)
    {
        const int index = 3 * row + i;
        
        if(index >= [effectManager.effectNames count])
        {
            break;
        }
        
        NSString* effectName = [effectManager.effectNames objectAtIndex: index];
        [cell setEffectForIndex: i
                       withName: effectName
                      thumbnail: dummyThumbnailPath];
        if([effectName isEqualToString: effectManager.activeEffectName])
        {
            [cell setSelection: i];
        }
    }        
    
    return cell;
}

- (IBAction) didTapMoreButton: (id) sender
{
    [UIView transitionWithView: self.view
                      duration: 0.5
                       options: UIViewAnimationOptionTransitionFlipFromRight
                    animations: ^{ [self.view addSubview: upgradeTeaserViewController.view]; }
                    completion: NULL];
}

@end

