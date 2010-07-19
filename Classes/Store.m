//
//  Store.m
//  RealTim5eFx
//
//  Created by Greg on 7/11/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "Store.h"

@implementation Store

static Store* storeInstance;

static NSString* effectPackOneProductId = @"com.gregpascale.rtfx.ep1";

+ (void) initialize
{
    storeInstance = [[Store alloc] init];    
}

+ (Store*) instance
{
    return storeInstance;
}

- (id) init
{
    if (self = [super init])
    {
        [[SKPaymentQueue defaultQueue] addTransactionObserver: self];
    }
    
    return self;
}

+ (BOOL) hasEffectPackOne
{
    id value = [[NSUserDefaults standardUserDefaults] objectForKey: @"HasEffectPackOne"];
    return [value isKindOfClass: [NSNumber class]] &&
           [(NSNumber*)value boolValue] == YES;
}

- (void) makePurchase
{
    NSLog(@"Make purchase called");
    if ([SKPaymentQueue canMakePayments])
    {
        SKPayment *payment = [SKPayment paymentWithProductIdentifier: effectPackOneProductId];
        [[SKPaymentQueue defaultQueue] addPayment: payment];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"PurchaseFailed"
                                                            object: nil];
        NSString* errorMessage = @"This iPhone reports that it is unable to make purchases."
                                 @"Are parental controls enabled?";
        UIAlertView* errorView = [[UIAlertView alloc] initWithTitle: @"Error"
                                                            message: errorMessage
                                                           delegate: nil
                                                  cancelButtonTitle: @"Ok"
                                                  otherButtonTitles: nil];
        [errorView show];
    }
}

#pragma mark SKProductsRequestDelegate methods
- (void) productsRequest: (SKProductsRequest*) request
      didReceiveResponse: (SKProductsResponse*) response
{
    NSLog(@"Received response: %@", response);
    NSLog(@"Found %d products", [response.products count]);    
    for(id obj in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@", obj);
    }
    SKPayment *payment = [SKPayment paymentWithProductIdentifier: effectPackOneProductId];
    [[SKPaymentQueue defaultQueue] addPayment: payment];
}

#pragma mark SKPaymentTransactionObserver methods
- (void) paymentQueue: (SKPaymentQueue*) queue 
  updatedTransactions: (NSArray*) transactions
{
    for (SKPaymentTransaction* transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
            {
                [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool: YES]
                                                          forKey: @"HasEffectPackOne"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                id value = [[NSUserDefaults standardUserDefaults] objectForKey: @"HasEffectPackOne"];
                NSAssert([value isKindOfClass: [NSNumber class]], @"");
                NSAssert([(NSNumber*)value boolValue] == YES, @"");
                
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                
                NSString* successMessage = @"You successfully purchased Effect Pack 1. Please restart the app for the changes"
                                           @" to take effect.";
                UIAlertView* successAlert = [[UIAlertView alloc] initWithTitle: @""
                                                                       message: successMessage
                                                                      delegate: nil
                                                             cancelButtonTitle: @"Ok"
                                                             otherButtonTitles: nil];
                [successAlert show];
                
                [[NSNotificationCenter defaultCenter] postNotificationName: @"PurchaseSucceeded"
                                                                    object: nil];
                
                break;
            }
            case SKPaymentTransactionStateFailed:
            {
                if (transaction.error.code != SKErrorPaymentCancelled)
                {
                    NSString* errorMsg = @"Sorry, there was an error processing your purchase. Try checking your network"
                                         @" connection.\n\n You have not been charged.";
                                         
                                                                            
                    UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle: @""
                                                                        message: errorMsg
                                                                       delegate: nil
                                                              cancelButtonTitle: @"Ok"
                                                              otherButtonTitles: nil];
                                        
                    [errorAlert show];                                        
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName: @"PurchaseFailed"
                                                                    object: nil];
                
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            }
            case SKPaymentTransactionStateRestored:
            {
                // take action to restore the app as if it was purchased
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                [self makePurchase];
                break;
            }
            default:
                return;
        }        
    }
}

@end
