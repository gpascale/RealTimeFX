//
//  Store.h
//  RealTimeFx
//
//  Created by Greg on 7/11/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface Store : NSObject <SKProductsRequestDelegate,
                             SKPaymentTransactionObserver>
{
    BOOL deviceIsAuthorizedToGetFXPackOneForFree;
    
    NSURLConnection* mConnection;
    NSMutableData* mResponseData;
    
    NSMutableDictionary* featurePriceObjects;
    NSMutableDictionary* featurePriceCallbacks;
}

+ (Store*) instance;

+ (BOOL) hasEffectPackOne;

- (void) queryPricesForFeatures: (NSSet*) featureNames;

- (void) makePurchase;

@end
