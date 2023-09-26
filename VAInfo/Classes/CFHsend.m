//
//  CFHsend.m
//  VAinfo
//
//  Created by Vlad Alexa on 4/1/09.
//  Copyright 2009 __VladAlexa__. All rights reserved.
//

#import "CFHsend.h"

int doSend (NSString* theStr,NSString* theAddr,NSString* thePort){

	const char *IP = [theAddr UTF8String];
	int port = [thePort intValue];
	struct sockaddr_in	ipAddress;	
	ipAddress.sin_len = sizeof(ipAddress);
	ipAddress.sin_family = AF_INET;
	ipAddress.sin_addr.s_addr = inet_addr(IP);
	ipAddress.sin_port = htons(port); 

	CFDataRef addrDataRef = NULL;
	CFHostRef host = NULL;
	CFReadStreamRef inStr = NULL;
	CFWriteStreamRef outStr = NULL;
	
	//create host
	addrDataRef = CFDataCreate(kCFAllocatorDefault, (const UInt8*)&ipAddress, sizeof(ipAddress));
	host = CFHostCreateWithAddress (kCFAllocatorDefault, addrDataRef);
	CFRelease(addrDataRef);
	
	//test if host is reachable synchronously
    CFStreamError error;
    Boolean success = CFHostStartInfoResolution(host, kCFHostReachability, &error);
    if (success == FALSE) {	
		CFRelease(host);
		return 0;
	}	
	
	//get reach data 
	CFDataRef data = CFHostGetReachability(host, NULL);
    SCNetworkConnectionFlags  *flags = (SCNetworkConnectionFlags *)CFDataGetBytePtr(data);
    if (flags == NULL){
		CFRelease(host);
		return 0;
	}			

    if (*flags & kSCNetworkFlagsReachable) {
		//open socket
		CFStreamCreatePairWithSocketToCFHost (kCFAllocatorDefault, host, port, &inStr, &outStr);
	}else{	
		NSLog(@"Network not reachable.");
		CFRelease(host);		
		return 0;	
	}
	
	if(CFReadStreamOpen(inStr) == false || inStr == Nil || CFWriteStreamOpen(outStr) == false || outStr == Nil){
		NSLog(@"Couldn't open the input/output stream.");
		CFRelease(host);		
		return 0;		
	}else{
		if (CFWriteStreamCallback((CFWriteStreamRef)outStr, (const uint8_t *)[theStr UTF8String], [theStr lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
		{
			CFReadStreamClose(inStr);
			CFWriteStreamClose(outStr);	
			CFRelease(host);			
			return 0;
		}	
		CFReadStreamClose(inStr);
		CFWriteStreamClose(outStr);	
	}	
	CFRelease(host);	
	return 1;	
}	


CFIndex CFWriteStreamCallback(CFWriteStreamRef outputStream, const uint8_t* buffer, CFIndex length)
{
    CFIndex bufferOffset = 0;
    CFIndex bytesWritten;
	
    while (bufferOffset < length)
    {
        if (CFWriteStreamCanAcceptBytes(outputStream))
        {
            bytesWritten = CFWriteStreamWrite(outputStream, &(buffer[bufferOffset]), length - bufferOffset);
            if (bytesWritten < 0)
            {
				NSLog(@"Negative Bytes Written!");
                return bytesWritten;
            }
            bufferOffset += bytesWritten;
        }
        else if (CFWriteStreamGetStatus(outputStream) == kCFStreamStatusError)
        {
			NSLog(@"Error writing bytes to stream!");
			return -1;
        }
        else
        {
            // Pump the runloop
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.0, true);
        }
    }
    
    return bufferOffset;
}

