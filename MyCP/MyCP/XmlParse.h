//
//  XmlParse.h
//  Immersee
//
//  Created by Vlad Alexa on 5/31/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XmlParseDelegate;

@interface XmlParse : NSObject <NSXMLParserDelegate>{
	NSXMLParser *theParser;
	NSString *curElement;
	NSString *parentElement;
	NSMutableDictionary *_dict;
}

@property (weak,nonatomic) id<XmlParseDelegate> delegate;
@property (weak,nonatomic) NSDictionary *userInfo;
@property (strong,nonatomic) NSMutableArray *array;


+ (NSDictionary*)simpleParserWithData:(NSData*)theData;

+ (void)parserWithData:(NSData*)theData userInfo:(NSDictionary*)theInfo delegate:(id<XmlParseDelegate>)theDelegate;
- (id)initWithData:(NSData*)theData userInfo:(NSDictionary*)theInfo delegate:(id<XmlParseDelegate>)theDelegate;

+(NSString *)humanizeSize:(NSString*)value inUnit:(NSString*)unit;
+(NSString *)humanizeSize:(long long)value;

@end


@protocol XmlParseDelegate<NSObject>
@required

- (void) parsingDidFinish:(XmlParse *)xmlParse;
- (void) parsingDidFail:(XmlParse *)xmlParse;

@end

