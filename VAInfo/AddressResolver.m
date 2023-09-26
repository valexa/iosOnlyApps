//
//  AddressResolver.m
//  VTrace
//
//  Created by Vlad Alexa on 4/12/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import "AddressResolver.h"

static void HostResolveCallback(CFHostRef theHost, CFHostInfoType typeInfo, const CFStreamError *error, void *info)
{	
	AddressResolver *obj = (AddressResolver *)CFBridgingRelease(info);
	assert([obj isKindOfClass:[AddressResolver class]]);
		
    if ( (error != NULL) && (error->domain != 0) ) {
		NSError *nserr = [obj CFStreamErrorToNSError:*error];
		NSLog(@"HostResolveCallback error %@",[nserr localizedDescription]);		
		if ([obj.delegate respondsToSelector:@selector(addressResolver:didFinishWithStatus:)] ) {
			[obj.delegate addressResolver:obj didFinishWithStatus:nserr];						
		}	
		//[obj stop];	//sent on release
    } else {
		if ([obj getIp] && [obj getName]) {
			//NSLog(@"Resolved %@ %@",obj.name,obj.ip);		
			if ([obj.delegate respondsToSelector:@selector(addressResolver:didFinishWithStatus:)] ) {
				[obj.delegate addressResolver:obj didFinishWithStatus:nil];
			}			
		}else{
			NSLog(@"HostResolveCallback resolution succesfull but getIp/getName failed");			
		}
		//[obj stop];	//sent on release
    }
}

@implementation AddressResolver

@synthesize address,host,name,ip,delegate;

- (id)initWithAddress:(NSString *)theAddress
{
    self = [super init];
    if (self != nil) {
		self.address = theAddress;
		
		Boolean             success;
		CFHostClientContext context = {0, CFBridgingRetain(self), NULL, NULL, NULL};
		CFStreamError       streamError;
		CFHostInfoType		type;
		
		//create the host
		if ([self isIp:address])
        {
			struct sockaddr_in addrPtr = [self stringToSockaddr_in:address];		
			CFDataRef addrDataRef = CFDataCreate(kCFAllocatorDefault, (const UInt8*)&addrPtr, sizeof(addrPtr));	
			host = CFHostCreateWithAddress(kCFAllocatorDefault, addrDataRef);
			CFRelease(addrDataRef);	
     		type = kCFHostNames;
		}else {
			host = CFHostCreateWithName(kCFAllocatorDefault, (CFStringRef)address);
     		type = kCFHostAddresses;			
		}
		if (host == NULL) NSLog(@"Resolving host null for (%@)",address);		
		
		//squedule async resolution
		CFHostSetClient(host, HostResolveCallback, &context);		
		CFHostScheduleWithRunLoop(host,CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);		
		success = CFHostStartInfoResolution(host,type, &streamError);
		if (!success) NSLog(@"Error starting resolution for (%@)",address);
    }
    return self;
}

- (void) dealloc
{
	//NSLog(@"AddressResolver stoped");
    [self stop];
    [super dealloc];
}

-(BOOL) getIp 
{
	
    Boolean     resolved;
    NSArray *   addresses;
    
    // Get the first IPv4 ip    
    addresses = (NSArray *) CFHostGetAddressing(host, &resolved);
    if ( resolved && (addresses != nil) ) {
        resolved = false;
        for (NSData * addr in addresses) {
            const struct sockaddr_in *addrPtr = (const struct sockaddr_in *) [addr bytes];
            if ( [addr length] >= sizeof(struct sockaddr_in) && addrPtr->sin_family == AF_INET) {
                self.ip = [NSString stringWithCString:inet_ntoa((struct in_addr)addrPtr->sin_addr) encoding:NSUTF8StringEncoding];
                resolved = true;
                break;
            }
        }
    }	
	
	if (resolved) {
        //NSLog(@"Resolved ip");
    } else {
        NSLog(@"Error resolving ip");
    }
	return resolved;
}

-(BOOL) getName 
{	
    Boolean     resolved;
    NSArray *   addresses;
    
    // Get the first FQDN name    
    addresses = (NSArray *) CFHostGetNames(host, &resolved);
    if ( resolved && (addresses != nil) ) {
        resolved = false;
        for (id addr in addresses) {
			self.name = (NSString *)addr;
			resolved = true;
			break;
        }
    }	
	
	if (resolved) {
        //NSLog(@"Resolved name");
    } else {
        NSLog(@"Error resolving name");
    }	
	return resolved;	
}

-(BOOL) isIp:(NSString*)string
{
	struct in_addr pin;
	int success = inet_aton([string UTF8String],&pin);
	if (success == 1) return YES;
	return NO;
}

-(const struct sockaddr_in) stringToSockaddr_in:(NSString*)string
{
	struct sockaddr_in addrPtr;	
	memset(&addrPtr, 0, sizeof(addrPtr));	
	addrPtr.sin_len = sizeof(addrPtr);
	addrPtr.sin_family = AF_INET;
	addrPtr.sin_addr.s_addr = inet_addr([string UTF8String]); 	
	return addrPtr;
}

- (NSError*) CFStreamErrorToNSError:(CFStreamError)streamError
{
    NSDictionary *  userInfo;
    NSError *       error;
	
    if (streamError.domain == kCFStreamErrorDomainNetDB) {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
					[NSNumber numberWithInteger:streamError.error], kCFGetAddrInfoFailureKey,
					nil
					];
    } else {
        userInfo = nil;
    }
    error = [NSError errorWithDomain:(NSString *)kCFErrorDomainCFNetwork code:kCFHostErrorUnknown userInfo:userInfo];
    assert(error != nil);
	
    return error;
}

- (void) stop
{
    if (host != NULL) {
        CFHostSetClient(host, NULL, NULL);
        CFHostUnscheduleFromRunLoop(host, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        host = NULL;
    }
}

@end
