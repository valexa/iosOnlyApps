//
//  MyIPController.m
//  VAinfo
//
//  Created by Vlad Alexa on 3/30/09.
//  Copyright 2009 __VladAlexa__. All rights reserved.
//

#import "MyIPController.h"


@implementation MyIPController

@synthesize delegate,receivedData,theConnection;


- (id) initWithURL:(NSString*)theURL delegate:(id<MyIPControllerDelegate>)theDelegate
{
    self = [super init];
	if (self) {
		
		self.delegate = theDelegate;		
		NSURL *newURL = [NSURL URLWithString:theURL];
		NSURLRequest *theRequest = [NSURLRequest requestWithURL:newURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
		receivedData = [[NSMutableData alloc] initWithLength:0];
		/* Create the connection with the request and start loading the data. The connection object is owned both by the creator and the loading system. */
		NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
		if (conn == nil){
			NSLog(@"The NSURLConnection could not be made!...");
		}else {		
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];			
		}
		self.theConnection = conn;
		[conn release];		
	}
	
	return self;
}

#pragma mark NSURLConnection delegate methods

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    /* This method is called when the server has determined that it has
	 enough information to create the NSURLResponse. It can be called
	 multiple times, for example in the case of a redirect, so each time
	 we reset the data. */
    [self.receivedData setLength:0];
	
}


- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    /* Append the new data to the received data. */
    [self.receivedData appendData:data];
}


- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{

    if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(connectionDidFail:)] ) {	
		[self.delegate connectionDidFail:self];			
	}
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];    
    
}


- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self.delegate connectionDidFinish:self];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];    
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection 
				   willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
	/* this application does not use a NSURLCache disk or memory cache */
    return nil;
}


- (void)dealloc
{  
	//NSLog(@"MyIPController freed");
    [theConnection cancel];
    [theConnection release];	
	[receivedData release];
	[super dealloc];      
}



@end
