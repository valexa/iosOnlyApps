//
//  XmlParse.m
//  Immersee
//
//  Created by Vlad Alexa on 5/31/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import "XmlParse.h"


@implementation XmlParse


+ (NSDictionary*)simpleParserWithData:(NSData*)theData
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:1];
    NSString *str = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    
    NSArray *lines = [str componentsSeparatedByString:@"\n"];
    
    for (NSString *line in lines) {
        NSArray *parts = [line componentsSeparatedByString:@"</"];
        if ([parts count] == 2) {
            NSArray *values = [[parts objectAtIndex:0] componentsSeparatedByString:@">"];
            if ([values count] == 2) {
                NSString *value = [values objectAtIndex:1];
                if ([value length] > 0){
                    [ret setObject:value forKey:[[parts objectAtIndex:1] stringByReplacingOccurrencesOfString:@">" withString:@""]];
                }
            }
        }
    }
    
    return ret;
}

+(void)parserWithData:(NSData*)theData userInfo:(NSDictionary*)theInfo delegate:(id<XmlParseDelegate>)theDelegate
{
    [[XmlParse alloc] initWithData:theData userInfo:theInfo delegate:theDelegate];
}

- (void)dealloc
{
    //NSLog(@"XmlParse kaput");
}

- (id)initWithData:(NSData*)theData userInfo:(NSDictionary*)theInfo delegate:(id<XmlParseDelegate>)theDelegate
{    
    self = [super init];
    if (self) {
		//NSLog(@"XmlParse alloced with : %@/%@",[theInfo objectForKey:@"type"],[theInfo objectForKey:@"domain"]);
		//NSLog(@"%@",[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding]);
		self.delegate = theDelegate;
		self.userInfo = theInfo;
		parentElement = nil;
		curElement = nil;
		self.array = [NSMutableArray arrayWithCapacity:1];
		_dict = [NSMutableDictionary  dictionaryWithCapacity:1];
		theParser = [[NSXMLParser alloc] initWithData:theData];
		[theParser setDelegate:self];
		[theParser parse];
        
        [_dict setObject:[NSString stringWithFormat:@"%i",(int)(CFAbsoluteTimeGetCurrent()+kCFAbsoluteTimeIntervalSince1970)] forKey:@"parsetimestamp"];
    }
    return self;
    
}	

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if (curElement != nil) {
		parentElement = curElement;
	}
	curElement = elementName;
    
    NSString *type = [self.userInfo objectForKey:@"type"];
    
	if ([type isEqualToString:@"phpsysinfo"]) {
		if ([curElement isEqualToString:@"Generation"]) {
            [_dict addEntriesFromDictionary:attributeDict];
		}
		if ([curElement isEqualToString:@"Vitals"]) {
            [_dict addEntriesFromDictionary:attributeDict];
		}
		if ([curElement isEqualToString:@"CpuCore"]) {
            int oldValue = [[_dict objectForKey:@"CpuSpeed"] intValue];
            int newValue = [[attributeDict objectForKey:@"CpuSpeed"] intValue];
            [_dict setObject:[NSString stringWithFormat:@"%i",oldValue+newValue] forKey:@"CpuSpeed"];
            int counts = [[_dict objectForKey:@"CpuCounts"] intValue]+1;
            [_dict setObject:[NSString stringWithFormat:@"%i",counts] forKey:@"CpuCounts"];
		}
		if ([curElement isEqualToString:@"Memory"]) {
            [_dict setObject:[attributeDict objectForKey:@"Used"] forKey:@"MemoryUsed"];
            [_dict setObject:[attributeDict objectForKey:@"Total"] forKey:@"MemoryTotal"];
		}
		if ([curElement isEqualToString:@"Mount"]) {
            [_dict setObject:[NSString stringWithFormat:@"%lli",[[_dict objectForKey:@"StorageUsed"] longLongValue]+[[attributeDict objectForKey:@"Used"] longLongValue]] forKey:@"StorageUsed"];
            [_dict setObject:[NSString stringWithFormat:@"%lli",[[_dict objectForKey:@"StorageTotal"] longLongValue]+[[attributeDict objectForKey:@"Total"] longLongValue]] forKey:@"StorageTotal"];
		}
		if ([curElement isEqualToString:@"NetDevice"] && ![[attributeDict objectForKey:@"Name"] isEqualToString:@"lo"]) {
            [_dict setObject:[NSString stringWithFormat:@"%lli",[[_dict objectForKey:@"NetworkIn"] longLongValue]+[[attributeDict objectForKey:@"RxBytes"] longLongValue]] forKey:@"NetworkIn"];
            [_dict setObject:[NSString stringWithFormat:@"%lli",[[_dict objectForKey:@"NetworkOut"] longLongValue]+[[attributeDict objectForKey:@"TxBytes"] longLongValue]] forKey:@"NetworkOut"];
            [_dict setObject:[NSString stringWithFormat:@"%lli",[[_dict objectForKey:@"NetworkErr"] longLongValue]+[[attributeDict objectForKey:@"Err"] longLongValue]] forKey:@"NetworkErr"];            
            [_dict setObject:[NSString stringWithFormat:@"%lli",[[_dict objectForKey:@"NetworkDrops"] longLongValue]+[[attributeDict objectForKey:@"Drops"] longLongValue]] forKey:@"NetworkDrops"]; 
		}
	}
    
	if ([type isEqualToString:@"cpanel"]) {
		if ([elementName isEqualToString:@"data"]) {
            [_dict removeAllObjects];
		}
	}

    //NSLog(@"Started %@",curElement);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSString *type = [self.userInfo objectForKey:@"type"];    
    
	if (curElement) {        
        
        if ([type isEqualToString:@"cpanel"]) {
            [_dict setObject:string forKey:curElement];           
        }
        		
        //NSLog(@"%@ - %@",string,curElement);
	}else {
        //NSLog(@"ORPHAN %@",string);
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString *type = [self.userInfo objectForKey:@"type"];
    
	curElement = nil;
    
	if ([type isEqualToString:@"phpsysinfo"]) {	
		if ([elementName isEqualToString:@"tns:phpsysinfo"]) {
			[self.array addObject:_dict];
		}
	}
    
	if ([type isEqualToString:@"cpanel"]) {
		if ([elementName isEqualToString:@"data"]) {
			[self.array addObject:[_dict copy]];//copy not reffer
		}
	}

    //NSLog(@"Ended %@",elementName);
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	[self.delegate parsingDidFinish:self];
	theParser = nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)error
{
	NSLog(@"%@ for %@",[error localizedDescription],[self.userInfo objectForKey:@"type"]);	
	[self.delegate parsingDidFail:self];
	//theParser = nil; causes crash in libxml2.2.dylib`xmlStopParser
}

#pragma mark tools

+(NSString *)humanizeSize:(NSString*)value inUnit:(NSString*)unit
{
    
    //fix stupid bug with cpanel datasets
    if ([value rangeOfString:unit].location != NSNotFound) value = [value stringByReplacingOccurrencesOfString:[@" " stringByAppendingString:unit] withString:@""];
    
    long long val = [value longLongValue];
    
    if ([unit isEqualToString:@"TB"]) val = val * 1099511627776;
    if ([unit isEqualToString:@"GB"]) val = val * 1073741824;
    if ([unit isEqualToString:@"MB"]) val = val * 1048576;
    if ([unit isEqualToString:@"KB"]) val = val * 1024;
    
    return [XmlParse humanizeSize:val];
}

+(NSString *)humanizeSize:(long long)value
{
    float ret = 0.0;
	NSString *sizeType = @"";
    
	if (value >= 1099511627776){
		ret = value / 1099511627776.0; sizeType = @"TB";
	}else if (value >= 1073741824){
		ret = value / 1073741824.0; sizeType = @"GB";
	}else if (value >= 1048576)	{
		ret = value / 1048576.0; sizeType = @"MB";
	}else if (value >= 1024) {
		ret = value / 1024.0; sizeType = @"KB";
	}else if (value >= 0){
		ret = (float)value; sizeType = @"B";
	}
	
	return [NSString stringWithFormat:@"%.1f %@",ret,sizeType];
}


@end
