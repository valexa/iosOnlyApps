//
//  UrlConnection.m
//  MagicPrefs
//
//  Created by Vlad Alexa on 4/25/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import "UrlConnection.h"


@implementation UrlConnection

@synthesize delegate,url,receivedData,theConnection,name;


- (id) initWithURL:(NSString*)theURL andCookie:(NSString*)cookie delegate:(id<UrlConnectionDelegate>)theDelegate
{
    self = [super init];    
	if (self) {		
		self.delegate = theDelegate;
		self.url = [theURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      
		NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
		if (cookie) [theRequest setValue:cookie forHTTPHeaderField:@"Cookie"];	
		receivedData = [[NSMutableData alloc] initWithLength:0];	
		/* Create the connection with the request and start loading the data. The connection object is owned both by the creator and the loading system. */
		NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
		if (conn){
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];			
		}else {
			NSLog(@"The NSURLConnection could not be made!...");
		}	
		self.theConnection = conn;
		[conn release];			
	}
	
	return self;
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    /* This method is called when the server has determined that it has
	 enough information to create the NSURLResponse. It can be called
	 multiple times, for example in the case of a redirect, so each time
	 we reset the data. */
    [self.receivedData setLength:0];
	//NSLog(@"Got response for %@",[response URL]);
	//[self debugCookies:response];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    /* Append the new data to the received data. */
    [self.receivedData appendData:data];		
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"%@ for %@",[error localizedDescription],url);
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];				
    if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(connectionDidFail:)] ) {	
		[self.delegate connectionDidFail:self];			
	}	
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];	
	[self.delegate connectionDidFinish:self];	
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection 
				   willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
	/* this application does not use a NSURLCache disk or memory cache */
    return nil;
}

-(NSURLRequest *)connection:(NSURLConnection *)connection
            willSendRequest:(NSURLRequest *)request
           redirectResponse:(NSURLResponse *)redirectResponse
{
	if (redirectResponse == nil) {
		//NSLog(@"Cannonical redirect");
	}else {
		//NSLog(@"Redirect from %@ to %@",[redirectResponse URL],[request URL]);		
		//[self debugCookies:redirectResponse];
	}	
    return request;
}

-(void)debugCookies:(NSURLResponse *)response{
	NSLog(@"Cookies for %@",[response URL]);
	NSArray *globalCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[response URL]];
	NSLog(@"%@",[globalCookies description]);		
	NSArray *theseCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[(NSHTTPURLResponse *)response allHeaderFields] forURL:[response URL]];		
	NSLog(@"%@",[theseCookies description]);		
	
	NSLog(@"Headers for %@",[response URL]);	
	NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
	NSLog(@"%@",[headers description]);	
}

- (void)dealloc
{	
	//NSLog(@"UrlConnection freed");
    [theConnection cancel];
    [theConnection release];	
	[receivedData release];
	[url release];
	[super dealloc];
}


@end
