//
//  Store.m
//  RealTim5eFx
//
//  Created by Greg on 7/11/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "Store.h"

@interface Store (Private)

- (void) checkToSeeIfDeviceIsAuthorizedToGetFXPackOneForFree;
- (void) _activateFXPackOne: (SKPaymentTransaction*) transaction;

@end

@implementation Store

static Store* storeInstance;

static NSString* effectPackOneProductId = @"com.gregpascale.rtfx2.fxp1";

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
        
        if(![Store hasEffectPackOne])
        {
            deviceIsAuthorizedToGetFXPackOneForFree = NO;
            [self checkToSeeIfDeviceIsAuthorizedToGetFXPackOneForFree];
        }
    }
    
    return self;
}

+ (BOOL) hasEffectPackOne
{
    id value = [[NSUserDefaults standardUserDefaults] objectForKey: @"HasEffectPackOne"];
    return [value isKindOfClass: [NSNumber class]] &&
           [(NSNumber*)value boolValue] == YES;
}

- (void) queryPricesForFeatures: (NSSet*) featureNames
{
    for(NSString* s in featureNames)
    {
        NSLog(@"Lookup %@", s);
    }
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:featureNames];
	request.delegate = self;
	[request start];
}

- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response
{
    NSMutableDictionary* priceDictionary = [[NSMutableDictionary alloc] init];
    
    for(SKProduct* product in [response products])
	{
		NSLog(@"Feature: %@, Cost: %f, ID: %@",[product localizedTitle],
			  [[product price] doubleValue], [product productIdentifier]);
                
        NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:product.priceLocale];
        NSString *formattedPriceString = [numberFormatter stringFromNumber:product.price];
        
        [priceDictionary setObject:formattedPriceString forKey:[product productIdentifier]];
	}
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"PricesFound"
                                                        object: self
                                                      userInfo: priceDictionary];
    
	[request autorelease];
}

- (void) makePurchase
{
    NSLog(@"Make purchase called");
    
    if (deviceIsAuthorizedToGetFXPackOneForFree)
    {
        // activate FX Pack 1
        [self _activateFXPackOne: nil];
        return;
    }    
    else if ([SKPaymentQueue canMakePayments])
    {
        SKPayment *payment = [SKPayment paymentWithProductIdentifier: effectPackOneProductId];
        [[SKPaymentQueue defaultQueue] addPayment: payment];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"PurchaseFailed"
                                                            object: nil];
        NSString* errorMessage = @"The iPhone reports that it is unable to make purchases."
                                 @"This could be because you do not have network access or parental controls are enabled";
        UIAlertView* errorView = [[UIAlertView alloc] initWithTitle: @"Error"
                                                            message: errorMessage
                                                           delegate: nil
                                                  cancelButtonTitle: @"Ok"
                                                  otherButtonTitles: nil];
        [errorView show];
    }
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
                [self _activateFXPackOne: transaction];
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

- (void) _activateFXPackOne: (SKPaymentTransaction*) transaction
{
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool: YES]
                                              forKey: @"HasEffectPackOne"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    id value = [[NSUserDefaults standardUserDefaults] objectForKey: @"HasEffectPackOne"];
    NSAssert([value isKindOfClass: [NSNumber class]], @"");
    NSAssert([(NSNumber*)value boolValue] == YES, @"");
    
    if (transaction)
    {
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    }
    
    NSString* successMessage = @"Thanks for buying FX Pack 1. Please restart the app for your purchase to take effect.";
    UIAlertView* successAlert = [[UIAlertView alloc] initWithTitle: @""
                                                           message: successMessage
                                                          delegate: nil
                                                 cancelButtonTitle: @"Ok"
                                                 otherButtonTitles: nil];
    [successAlert show];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"PurchaseSucceeded"
                                                        object: nil];
    
}
         
- (void) checkToSeeIfDeviceIsAuthorizedToGetFXPackOneForFree
{
	NSString *uniqueID = [[UIDevice currentDevice] uniqueIdentifier];
	// check udid and featureid with developer's server
	
	NSURL *url = [NSURL URLWithString: @"http://gregpascale.nfshost.com/fxpack1/checkUDID.php"];
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url 
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                          timeoutInterval:20];
	
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	NSString *postData = [NSString stringWithFormat:@"udid=%@", uniqueID];
	
	NSString *length = [NSString stringWithFormat:@"%d", [postData length]];	
	[theRequest setValue:length forHTTPHeaderField:@"Content-Length"];	
	
	[theRequest setHTTPBody:[postData dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSLog(@"Device id is %@", uniqueID);
    
    mResponseData = [[NSMutableData alloc] init];
    mConnection = [[NSURLConnection alloc] initWithRequest: theRequest delegate: self];
}

#pragma mark NSURLConnectionDelegate methods

- (void) connectionDidFinishLoading: (NSURLConnection *) connection
{    
    NSString *responseString = [[NSString alloc] initWithData:mResponseData encoding:NSASCIIStringEncoding];
    NSString* responseStringClean = [responseString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSLog(@"response was \'%@\'", responseStringClean);
    
	if([responseStringClean isEqualToString:@"YES"])		
	{
		deviceIsAuthorizedToGetFXPackOneForFree = YES;
	}
	
	[responseString release];
    [mResponseData release];
    [connection release];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [mResponseData appendData: data];
}

static int failCount = 0;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{        
    [mResponseData release];
    mResponseData = nil;
    
    if (++failCount < 3)
    {
        [self checkToSeeIfDeviceIsAuthorizedToGetFXPackOneForFree];
    }
}

@end
