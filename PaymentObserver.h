//
//  PaymentObserver.h
//  VAinfo
//
//  Created by Vlad Alexa on 6/20/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import <MessageUI/MessageUI.h>

//import iAd.framework StoreKit.framework , MessageUI.framework , change paymentWithProductIdentifier

@protocol PaymentObserverDelegate;

@interface PaymentObserver : NSObject <SKPaymentTransactionObserver,MFMailComposeViewControllerDelegate,SKProductsRequestDelegate> {  
    NSMutableArray *products;
}

@property (nonatomic, assign) id<PaymentObserverDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *products;

- (id) initWithDelegate:(id<PaymentObserverDelegate>)theDelegate;

- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;

- (void)handleTransaction:(SKPaymentTransaction *)transaction;
- (void)sendMail:(NSString*)recipients subject:(NSString*)subject body:(NSString*)body;

- (void) requestProductData:(NSString*)identifier;

@end


@protocol PaymentObserverDelegate<NSObject>

@required
- (void) removedAdsPurchased;
- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;
- (void)dismissModalViewControllerAnimated:(BOOL)animated;

@end