//
//  PaymentObserver.m
//  VAinfo
//
//  Created by Vlad Alexa on 6/20/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import "PaymentObserver.h"

@implementation PaymentObserver

@synthesize delegate,products;

- (id) initWithDelegate:(id<PaymentObserverDelegate>)theDelegate
{
    self = [super init];    
	if (self) {				
		self.delegate = theDelegate;
		products = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {
    [products release];
    [super dealloc];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
	//NSLog(@"paymentQueueRestoreCompletedTransactionsFinished");
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
	NSLog(@"restoreCompletedTransactionsFailed : %@",[error localizedDescription]);	
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
	NSLog(@"%lu transactions canceled",(unsigned long)[transactions count]);
	for (SKPaymentTransaction *transaction in transactions) {
		NSLog(@"-- %@",transaction.payment.productIdentifier);
	}
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	// handle the payment transaction actions for each state
	for (SKPaymentTransaction *transaction in transactions)
	{
		switch (transaction.transactionState)
		{
			case SKPaymentTransactionStatePurchased:
				[self completeTransaction:transaction];        
				break;
			case SKPaymentTransactionStateFailed:
				[self failedTransaction:transaction];        
				break;
			case SKPaymentTransactionStateRestored:
				[self restoreTransaction:transaction];        
			default:
				break;
		}		
	}
}


- (void) completeTransaction: (SKPaymentTransaction *)transaction;
{
	NSLog(@"completeTransaction: %@",transaction.payment.productIdentifier);	
    [self handleTransaction: transaction];	
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];	
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
	NSLog(@"restoreTransaction: %@",transaction.originalTransaction.payment.productIdentifier);	
    [self handleTransaction:transaction.originalTransaction];
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];	
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{  
	if (transaction.error.code != SKErrorPaymentCancelled){
		NSLog(@"failedTransaction : %@ -- %@",[transaction.error localizedDescription],transaction.payment.productIdentifier);
	}else {
		NSLog(@"failedTransaction canceled : %@ -- %@",[transaction.error localizedDescription],transaction.payment.productIdentifier);		
	}
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];	
}

#pragma mark implementations

- (void)handleTransaction:(SKPaymentTransaction *)transaction{
	
	if ([transaction.payment.productIdentifier rangeOfString:@".removeads"].location != NSNotFound) {
		//record the transaction
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setBool:YES forKey:@"removedAds"];
		[defaults synchronize];
		//remove the ads form the ui
		if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(removedAdsPurchased)] ) {	
			[self.delegate removedAdsPurchased];		
			NSLog(@"Removed ads from the interface");			
		} else {
			NSLog(@"Failed to remove ads from the interface");
		}		
	}else {
		NSString *body = [NSString stringWithFormat:@"Model: %@ %@ \n Add any other relevant information.",[UIDevice currentDevice].model,[UIDevice currentDevice].systemVersion];
		[self sendMail:@"valexa@gmail.com" subject:[NSString stringWithFormat:@"Unhandled transaction with id:%@",transaction.payment.productIdentifier] body:body];	
	}	
}

- (void)sendMail:(NSString*)recipients subject:(NSString*)subject body:(NSString*)body{
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));	
	if (mailClass != nil){	
		if ([mailClass canSendMail]){			
			MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];		
			controller.mailComposeDelegate = self;
			[controller setToRecipients:[recipients componentsSeparatedByString:@","]];
			[controller setSubject:subject];
			[controller setMessageBody:body isHTML:NO];	
			if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(presentModalViewController:animated:)] ) {					
				[self.delegate presentModalViewController:controller animated:YES];					
			}				
			[controller release];				
		}else {
			NSLog(@"Device can not send mail");			
		}		
	}else {	
		NSLog(@"Using workaround to send mail");		
		NSString *email = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@",recipients,subject,body];
		email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];		
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];	
	}	
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Mail result: canceled");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Mail result: saved");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Mail result: sent");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Mail result: failed");
			break;
		default:
			NSLog(@"Mail result: not sent");
			break;
	}
	if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(dismissModalViewControllerAnimated:)] ) {	
		[self.delegate dismissModalViewControllerAnimated:YES];		
	}	
}

#pragma mark products

- (void) requestProductData:(NSString*)identifier
{
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:identifier]];
    request.delegate = self;
    [request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [products setArray:response.products];
    NSLog(@"Got %lu products",(unsigned long)[products count]);
    [request autorelease];
}


@end
