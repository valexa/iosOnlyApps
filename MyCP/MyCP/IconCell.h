//
//  IconCell.h
//  MyCP
//
//  Created by Vlad Alexa on 8/9/12.
//  Copyright (c) 2012 Vlad Alexa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridViewCell.h"

@interface IconCell : GMGridViewCell
{
    UIActivityIndicatorView *_spinner;
    UILabel *_label;
}

@property (strong,nonatomic) NSDictionary *userInfo;
@property (strong,nonatomic) NSDictionary *xmldata;

- (id)initWithFrame:(CGRect)frame userInfo:(NSDictionary *)userInfo;

-(void) startSpinning;
-(void) stopSpinning:(NSDictionary*)data;
-(void) setLabel:(NSString*)label;

-(void)squaresChart:(CGSize)size fill:(float)fill;
-(void)pieChart:(CGSize)size slice:(float)slice;

+(UIImage *)UIImageFromPDF:(NSString*)fileName size:(CGSize)size;

@end
