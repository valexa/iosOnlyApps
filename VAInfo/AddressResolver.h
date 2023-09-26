//
//  AddressResolver.h
//  VTrace
//
//  Created by Vlad Alexa on 4/12/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>
#include <netdb.h> //for gethostbyname
#include <arpa/inet.h> //for inet_ntoa

@protocol AddressResolverDelegate;

@interface AddressResolver : NSObject {

	NSString *address;
	CFHostRef host;
	NSString *name;
	NSString *ip;	
	__unsafe_unretained id<AddressResolverDelegate> delegate;
}

@property (nonatomic, retain, readwrite) NSString *address;
@property (nonatomic, assign, readwrite) CFHostRef host;
@property (nonatomic, retain, readwrite) NSString *name;
@property (nonatomic, retain, readwrite) NSString *ip;
@property (nonatomic, assign, readwrite) id<AddressResolverDelegate> delegate;

-(id)initWithAddress:(NSString *)theAddress;
-(BOOL) getIp;
-(BOOL) getName;
-(BOOL) isIp:(NSString*)string;
-(const struct sockaddr_in) stringToSockaddr_in:(NSString*)string;
-(NSError*) CFStreamErrorToNSError:(CFStreamError)streamError;
-(void) stop;

@end

@protocol AddressResolverDelegate <NSObject>

@required

- (void)addressResolver:(AddressResolver *)resolver didFinishWithStatus:(NSError *)error;
@end