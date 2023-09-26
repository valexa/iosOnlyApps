//
//  CFHsend.h
//  VAinfo
//
//  Created by Vlad Alexa on 4/1/09.
//  Copyright 2009 __VladAlexa__. All rights reserved.
//

#import <SystemConfiguration/SCNetworkReachability.h>
#include <CFNetwork/CFNetwork.h>
#include <arpa/inet.h>


int doSend (NSString* theStr,NSString* theAddr,NSString* thePort);
CFIndex CFWriteStreamCallback(CFWriteStreamRef outputStream, const uint8_t* buffer, CFIndex length);


