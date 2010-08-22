    //
//  CapturePreviewViewController.m
//  RealTimeFx
//
//  Created by Greg on 7/10/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "CapturePreviewViewController.h"
#import "FacebookHelper.h"
#import "ShareViewController.h"
#import "SocialInfoViewController.h"
#import "Watermarker.h"
#import "FlurryAPI.h"

@interface CapturePreviewViewController (Private)

- (void) _showShareViewController;
- (void) _hideShareViewController;
- (void) _showActionMenu;
- (void) _hideActionMenu;

@end


@implementation CapturePreviewViewController

@synthesize image;
@synthesize imageView;
@synthesize actionMenuView;
@synthesize shareViewController;
@synthesize socialInfoViewController;

- (UIImage*) image
{
    return image;
}

- (void) setImage: (UIImage*) newImage;
{
    if(image != newImage)
    {
        [image release];
        image = [newImage retain];
        imageView.image = newImage;
    }
}

- (void) viewDidLoad
{
    imageView.image = image;    
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    self.actionMenuView = nil;
    self.shareViewController = nil;
    imageView = nil;
}

- (void)dealloc
{
    self.actionMenuView = nil;
    self.shareViewController = nil;
    imageView = nil;
    [super dealloc];
}

- (void) willShow
{
    UIImage* watermarkedImage = [[Watermarker addWatermarkIfNoUpgrade: image] retain];
    UIImageWriteToSavedPhotosAlbum(watermarkedImage,
                                   self,
                                   @selector(image:didFinishSavingWithError:contextInfo:),
                                   NULL);
    [self _showActionMenu];
}

- (void) willHide
{
    [self _hideActionMenu];
}

- (IBAction) didTapDoneButton
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"didTapDoneButton"
                                                        object: self];
}

- (IBAction) didTapSaveToCameraRollButton
{
    UIImageWriteToSavedPhotosAlbum([image retain],
                                   self,
                                   @selector(image:didFinishSavingWithError:contextInfo:),
                                   NULL);
    [[NSNotificationCenter defaultCenter] postNotificationName: @"didTapDoneButton"
                                                        object: self];    
}

#pragma mark Camera roll save completion handler

- (void) image: (UIImage*) theImage didFinishSavingWithError: (NSError*) error 
   contextInfo: (void*) contextInfo
{
    // Was there an error?
    if (error != NULL)
    {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    else
    {
        NSLog(@"Saved image successfully!");
    }
    
    [theImage release];
}

// ShareViewController delegate method
- (void) shareViewControllerIsDone
{
    [shareViewController.view removeFromSuperview];
}

- (void) _showActionMenu
{
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         actionMenuView.frame = CGRectMake(
                            0, self.view.frame.size.height - actionMenuView.frame.size.height,
                            actionMenuView.frame.size.width, actionMenuView.frame.size.height);
                     }
                     completion: ^( BOOL finished )
                     {
                         actionMenuVisible = YES;
                     }
     ];
}

- (void) _hideActionMenu
{
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         actionMenuView.frame = CGRectMake(
                            0, self.view.frame.size.height - 33,
                            actionMenuView.frame.size.width, actionMenuView.frame.size.height);
                     }
                     completion: ^( BOOL finished )
                     {
                        actionMenuVisible = NO;
                    }
     ];
}

- (void) _showShareViewController
{
    shareViewController.view.alpha = 0.0f;
    [self.view addSubview: shareViewController.view];
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         shareViewController.view.alpha = 1.0f;
                     }
                     completion: ^( BOOL finished ) { } ];
}

- (void) _hideShareViewController
{
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         shareViewController.view.alpha = 0.0f;
                     }
                     completion: ^( BOOL finished )
                     {
                         [shareViewController.view removeFromSuperview];
                     }];
}

- (IBAction) didTapShareOnFacebookButton
{    
    /*[[FacebookHelper sharedInstance] uploadPhoto: image
                                     withCaption: @"Check out this cool photo I took with Realtime FX for iPhone!"];*/
    //[self presentModalViewController:shareViewController animated:YES];
    shareViewController.delegate = self;
    shareViewController.style = ShareViewStyle_Facebook;
    [self _showShareViewController];
    shareViewController.imageView.image = image;
    [shareViewController willShow];
}

- (IBAction) didTapShareOnTwitterButton
{    
    shareViewController.delegate = self;
    shareViewController.style = ShareViewStyle_Twitter;
    [self _showShareViewController];
    shareViewController.imageView.image = image;
    [shareViewController willShow];
}

- (IBAction) didTapEmailButton
{
    if(![MFMailComposeViewController canSendMail])
    {
        static NSString* errorMessage = @"This device is not set up for email. You can"
        " set up a mail account using the builtin mail application";
        UIAlertView* errorView = [[[UIAlertView alloc] initWithTitle: @""
                                                             message: errorMessage
                                                            delegate: nil
                                                   cancelButtonTitle: @"Ok"
                                                   otherButtonTitles: nil] autorelease];
        [errorView show];
        return;
    }
    
    static NSString* messageBody = @"Check out this photo I took with <a href=\""
    "http://gregpascale.com/apps/realtimefx\">Realtime FX</a> for iPhone!";
    NSData* imageData = UIImagePNGRepresentation([Watermarker addWatermarkIfNoUpgrade: imageView.image]);

    MFMailComposeViewController* mailViewController =
        [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    [mailViewController setSubject:@"Cool Photo"];
    [mailViewController setMessageBody:messageBody isHTML:YES];
    [mailViewController addAttachmentData:imageData
                                 mimeType:@"image/png"
                                 fileName:@"photo.png"];
    [self presentModalViewController:mailViewController animated:YES];
}

- (IBAction) didTapSocialInfoButton
{
    //[self.view addSubview: socialInfoViewController.view];
    [self presentModalViewController: socialInfoViewController animated: YES];
    socialInfoViewController.delegate = self;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch(result)
    {
        case MFMailComposeResultSent:
            [FlurryAPI logEvent:@"SharedPhoto"
                 withParameters: [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"Email", @"Method",
                                  [NSNumber numberWithBool: [Store hasEffectPackOne]], @"HasFXPack1",
                                  nil]];
            break;
        case MFMailComposeResultFailed:
            [FlurryAPI logError:@"MailError"
                        message:@""
                          error:error];
            break;
        default:
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void) socialInfoViewControllerIsDone: (SocialInfoViewController*) controller
{
    [self dismissModalViewControllerAnimated: YES];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Only consider single touches on the view itself - not on subviews
    if(actionMenuVisible &&
       ([touches count] > 1 ||
       CGRectContainsPoint(actionMenuView.bounds,
                           [[touches anyObject] locationInView:actionMenuView])))
    {
        return;
    }
    
    if(actionMenuVisible)
    {
        [self _hideActionMenu];
    }
    else
    {
        [self _showActionMenu];
    }

}

@end
