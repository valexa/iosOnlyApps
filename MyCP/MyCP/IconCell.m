//
//  IconCell.h
//  MyCP
//
//  Created by Vlad Alexa on 8/9/12.
//  Copyright (c) 2012 Vlad Alexa. All rights reserved.
//

#import "IconCell.h"
#import <QuartzCore/QuartzCore.h>

#import "XmlParse.h"

#define DEG2RAD(angle) angle*M_PI/180.0

@implementation IconCell

- (id)initWithFrame:(CGRect)frame userInfo:(NSDictionary *)userInfo
{
    if ((self = [super initWithFrame:frame]))
    {
        self.userInfo = userInfo;
        
        NSString *title = [self.userInfo objectForKey:@"domain"];
        
        CGSize size = CGSizeMake(frame.size.width, frame.size.height);      
        
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        if ([title isEqualToString:@"+"]) {
            [view setImage:[self imageFromplusRectangle:CGSizeMake(size.width*2, size.height*2)]];
        }else{
            [view setImage:[self imageFromBaseRectangle:CGSizeMake(size.width*2, size.height*2)]];
            view.layer.masksToBounds = NO;
            view.layer.shadowOpacity = 0.5;
            view.layer.shadowOffset = CGSizeMake(3, -3);
            //view.contentMode = UIViewContentModeCenter;
        }
        
        self.contentView = view;
        
        self.deleteButtonIcon = [IconCell UIImageFromPDF:@"x.pdf" size:CGSizeMake(32,32)];
        
        if ([title isEqualToString:@"+"])  return self;      
                
        //top label
        int fontHeight = 18;
        if (INTERFACE_IS_PHONE) fontHeight = 12;
        UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, size.width, fontHeight)];
        topLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        topLabel.text = title;
        topLabel.textAlignment = UITextAlignmentCenter;
        topLabel.backgroundColor = [UIColor clearColor];
        topLabel.textColor = [UIColor blackColor];
        topLabel.highlightedTextColor = [UIColor blackColor];
        topLabel.font = [UIFont boldSystemFontOfSize:fontHeight];
        topLabel.layer.shadowOpacity = 0.1;
        topLabel.layer.shadowRadius = 0.2;
        topLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
        topLabel.layer.shadowOffset = CGSizeMake(0.7, 0.7);
        [self.contentView addSubview:topLabel];
        
        //bottom label
        fontHeight = 14;
        if (INTERFACE_IS_PHONE) fontHeight = 8;
        _label = [[UILabel alloc] initWithFrame:CGRectMake(5,size.height-fontHeight-5, size.width-5, fontHeight)];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _label.textAlignment = UITextAlignmentCenter;
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor darkGrayColor];
        _label.highlightedTextColor = [UIColor darkGrayColor];
        _label.font = [UIFont systemFontOfSize:fontHeight];
        _label.layer.shadowOpacity = 0.8;
        _label.layer.shadowRadius = 0.2;
        _label.layer.shadowColor = [UIColor blackColor].CGColor;
        _label.layer.shadowOffset = CGSizeMake(0.8, 0.8);
        [self.contentView addSubview:_label];
        
        //spinner
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _spinner.frame = CGRectMake(self.contentView.frame.size.width/2-18.5, self.contentView.frame.size.height/2-18.5, 37, 37);
        _spinner.color = [UIColor darkGrayColor];
        [_spinner setHidesWhenStopped:YES];
        [self.contentView addSubview: _spinner];

    }
    return self;
}

- (void)layoutSubviews
{
    
    NSString *title = [self.userInfo objectForKey:@"domain"];
    
    CGSize size = CGSizeMake(self.contentView.frame.size.width,self.contentView.frame.size.height);  
    
    //update frame
    _spinner.frame = CGRectMake(size.width/2-18.5, size.height/2-18.5, 37, 37);
    
    UIImageView *view = (UIImageView *)self.contentView;
    if ([title isEqualToString:@"+"]) {
        [view setImage:[self imageFromplusRectangle:CGSizeMake(size.width*2, size.height*2)]];
    }else{
        [view setImage:[self imageFromBaseRectangle:CGSizeMake(size.width*2, size.height*2)]];
    }
}

-(void) startSpinning
{
    [_spinner startAnimating];
}

-(void) stopSpinning:(NSDictionary*)data
{
    [_spinner stopAnimating];
    if (data) {
        self.xmldata = data;
        CGSize size = CGSizeMake(self.contentView.frame.size.width,self.contentView.frame.size.height);
        UIImageView *view = (UIImageView *)self.contentView;
        [view setImage:[self imageFromBaseRectangle:CGSizeMake(size.width*2, size.height*2)]];
    }
}

-(void) setLabel:(NSString*)label
{
    _label.text = label;
}

-(void)createGraphContents
{
    if (self.xmldata == nil) return;
    
    NSString *type = [self.userInfo objectForKey:@"graph"];
    NSString *metric = [self.userInfo objectForKey:@"metric"];
    float unit = 0.0;
    
    CGSize size = CGSizeMake(self.contentView.frame.size.width,self.contentView.frame.size.height);    

    if ([[self.userInfo objectForKey:@"type"] isEqualToString:@"cpanel"])
    {
        
        NSDictionary *usage = nil;
        if (metric == nil) metric = @"Bandwidth";
        
        if ([metric isEqualToString:@"Bandwidth"])
        {
            usage = [self.xmldata objectForKey:@"bandwidthusage"];
            if (usage) {
                unit = [[usage objectForKey:@"percent"] intValue]/100.0;
                _label.text = [NSString stringWithFormat:@"%@ used %@ of %@",metric,[XmlParse humanizeSize:[usage objectForKey:@"_count"] inUnit:[usage objectForKey:@"units"]],[XmlParse humanizeSize:[usage objectForKey:@"_max"] inUnit:[usage objectForKey:@"units"]]];
            }
        }
        else if ([metric isEqualToString:@"Database"])
        {
            usage = [self.xmldata objectForKey:@"mysqldiskusage"];
            if (usage) {
                unit = [[usage objectForKey:@"percent"] intValue]/100.0;
                _label.text = [NSString stringWithFormat:@"%@ used %@ of %@",metric,[XmlParse humanizeSize:[usage objectForKey:@"count"] inUnit:[usage objectForKey:@"units"]],[XmlParse humanizeSize:[usage objectForKey:@"max"] inUnit:[usage objectForKey:@"units"]]];
            }
        }
        else if ([metric isEqualToString:@"Storage"])
        {
            usage = [self.xmldata objectForKey:@"diskusage"];
            if (usage) {
                unit = [[usage objectForKey:@"percent"] intValue]/100.0;
                _label.text = [NSString stringWithFormat:@"%@ used %@ of %@",metric,[XmlParse humanizeSize:[usage objectForKey:@"_count"] inUnit:[usage objectForKey:@"units"]],[XmlParse humanizeSize:[usage objectForKey:@"_max"] inUnit:[usage objectForKey:@"units"]]];
            }
        }
        
        if ([type isEqualToString:@"Pie chart"] || type == nil)
        {
            [self pieChart:size slice:unit];
        }
        else  if ([type isEqualToString:@"Cluster"])
        {
            [self squaresChart:size fill:unit];
        }
        
    }
    
    if ([[self.userInfo objectForKey:@"type"] isEqualToString:@"phpsysinfo"])
    {
        if (metric == nil) metric = @"CPU";        
        
        if ([metric isEqualToString:@"CPU"])
        {
            NSArray *load = [[self.xmldata objectForKey:@"LoadAvg"] componentsSeparatedByString:@" "];
            if ([load count] == 3) {
                //percent = ([[load objectAtIndex:0] floatValue] + [[load objectAtIndex:1] floatValue] + [[load objectAtIndex:2] floatValue])/3.0;
                unit = [[load objectAtIndex:0] floatValue];
                _label.text = [NSString stringWithFormat:@"%.2fGHz CPU Load %.1f on %i cores",[[self.xmldata objectForKey:@"CpuSpeed"] intValue]/1000.0,unit,[[self.xmldata objectForKey:@"CpuCounts"] intValue]];
            }
        }
        else if ([metric isEqualToString:@"Memory"])
        {
            unit = [[self.xmldata objectForKey:@"MemoryUsed"] floatValue]/[[self.xmldata objectForKey:@"MemoryTotal"] floatValue];            
            _label.text = [NSString stringWithFormat:@"%@ memory used of %@",[XmlParse humanizeSize:[[self.xmldata objectForKey:@"MemoryUsed"] longLongValue]],[XmlParse humanizeSize:[[self.xmldata objectForKey:@"MemoryTotal"] longLongValue]]];
        }
        else if ([metric isEqualToString:@"Storage"])
        {
            unit = [[self.xmldata objectForKey:@"StorageUsed"] floatValue]/[[self.xmldata objectForKey:@"StorageTotal"] floatValue];
            _label.text = [NSString stringWithFormat:@"%@ storage used of %@",[XmlParse humanizeSize:[[self.xmldata objectForKey:@"StorageUsed"] longLongValue]],[XmlParse humanizeSize:[[self.xmldata objectForKey:@"StorageTotal"] longLongValue]]];
        }
        
        
        if ([type isEqualToString:@"Cluster"] || type == nil)
        {
            [self squaresChart:size fill:unit];
        }
        else  if ([type isEqualToString:@"Pie chart"])
        {
            [self pieChart:size slice:unit];
        }
        
    }

}


-(UIImage*)imageFromplusRectangle:(CGSize)size
{
    UIGraphicsBeginImageContext( CGSizeMake(size.width, size.height) );
    [self plusRectangle:size];
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return ret;
}

-(UIImage*)imageFromBaseRectangle:(CGSize)size
{
    UIGraphicsBeginImageContext( CGSizeMake(size.width, size.height) );
    [self baseRectangle:size];
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return ret;
}

-(void)squaresChart:(CGSize)size fill:(float)fill
{
    if (fill > 1.0) fill = 1.0;
    
    CGContextSetAlpha(UIGraphicsGetCurrentContext(),0.2);
    
    int spacing = 6;
    int rows = 5+2;//add 2 invisible padding row at start and end
    int colls = 5+2;//add 2 invisible padding coll at start and end
    int cellWidth = (size.width*2-(spacing*rows))/rows;
    int cellHeight = (size.height*2-(spacing*colls))/colls;
    
    for (int r = 0; r < rows; r++)
    {
        for (int c = 0; c < colls; c++)
        {
            if (r > 0 && r < rows-1 && c > 0 && c < colls-1) //dont draw the padding
            {
                CGRect rect = CGRectMake((cellWidth+spacing)*c+spacing, (cellHeight+spacing)*r+spacing, cellWidth, cellHeight);
                UIBezierPath *cell = [UIBezierPath bezierPathWithRect:rect];
                
                [[UIColor whiteColor] setStroke];
                [cell stroke];
                
                if (r > 5 - ((fill*10)/2) )
                {
                    CGRect rect = CGRectMake((cellWidth+spacing)*c+spacing, (cellHeight+spacing)*r+spacing, cellWidth, cellHeight);
                    UIBezierPath *cell = [UIBezierPath bezierPathWithRect:rect];
                    
                    [[UIColor grayColor] set];
                    [cell fill];
                    
                    [[UIColor whiteColor] setStroke];
                    [cell stroke];
                }
            }
        }        
    }
    
    CGContextSetAlpha(UIGraphicsGetCurrentContext(),1.0);
    
}

-(void)pieChart:(CGSize)size slice:(float)slice
{
    if (slice > 1.0) slice = 1.0;
    
    CGContextSetAlpha(UIGraphicsGetCurrentContext(),0.2);
    
    CGFloat start_angle = DEG2RAD(0.0);
    CGPoint center = CGPointMake(size.width, size.height);
    CGFloat radius = size.width/2;
    
    UIBezierPath *piePath = [UIBezierPath bezierPath];
    [piePath addArcWithCenter:center radius:radius startAngle:DEG2RAD(0.0) endAngle:DEG2RAD(360.0) clockwise:YES];
    piePath.lineWidth = 1.0;
    [[UIColor whiteColor] setStroke];
    [piePath stroke];
    
    UIBezierPath *slicePath = [UIBezierPath bezierPath];
    slicePath.lineWidth = 2.0;
    
    [slicePath moveToPoint:center];
    
    [slicePath addLineToPoint:CGPointMake(center.x + radius * cosf(start_angle), center.y + radius * sinf(start_angle))];
    
    [slicePath addArcWithCenter:center radius:radius startAngle:start_angle endAngle:DEG2RAD(slice*360.0) clockwise:YES];
    
    //[piePath addLineToPoint:center];
    [slicePath closePath]; // this will automatically add a straight line to the center
    
    [[UIColor grayColor] set];
    [slicePath fill];
    
    [[UIColor whiteColor] setStroke];
    [slicePath stroke];
    
    CGContextSetAlpha(UIGraphicsGetCurrentContext(),1.0);
}

-(void)plusRectangle:(CGSize)size
{
    CGRect rect = CGRectMake(5,5, size.width-10, size.height-10);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    
    [[UIColor clearColor] set];
    
    //base rectangle    
    UIBezierPath *baseShape = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius: 14.0];
    baseShape.lineWidth = 6.0;
    [[UIColor colorWithWhite:0.3 alpha:1.0] setStroke];
    const float p[2] = {6, 6};
    [baseShape setLineDash:p count:2 phase:6];
    CGContextSetAlpha(context,0.8);
    [baseShape stroke];
    
    UIImage *image = [IconCell UIImageFromPDF:@"plus.pdf" size:CGSizeMake(size.width/2,size.height/2)];
    
    CGRect imageRect = CGRectMake(size.width/4, size.height/4, size.width/2,size.height/2);
    CGContextSetAlpha(context,0.7);
    CGContextDrawImage(context, imageRect, image.CGImage);
    
}

-(void)baseRectangle:(CGSize)size
{
    CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);  
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    
    [[UIColor clearColor] set];
    
    //base rectangle
    UIBezierPath *baseShape = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius: 14.0];    
    UIRectFill( CGRectMake(0.0, 0.0, size.width, size.width) );
    [[UIColor viewFlipsideBackgroundColor] set];
    [baseShape fill];
    
    [self createGraphContents];
    
    //clip anything outside base rectangle
    CGContextSaveGState(context);
    CGContextAddPath(context, baseShape.CGPath);
    CGContextClip(context);
    
    //create triangle path
    CGMutablePathRef substractTriangle  = CGPathCreateMutable();
    CGPathMoveToPoint(substractTriangle, NULL,size.width,0);
    CGPathAddLineToPoint(substractTriangle, NULL,0,size.width/1.5);
    CGPathAddLineToPoint(substractTriangle, NULL,0,0);
    
    //clip anything outside triangle
    CGContextBeginPath (context);
    CGContextAddPath(context, substractTriangle);
    CGContextClosePath (context);
    CGContextClip (context);
    CGPathRelease(substractTriangle);
    
    //create gradient
    CGGradientRef gradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 1.0, 1.0, 0.2,  // Start color
        1.0, 1.0, 1.0, 0.0 }; // End color
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    gradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    CGPoint start = CGPointMake(CGRectGetMaxX(rect), 0.0f);
    CGPoint end = CGPointMake(CGRectGetMidX(rect), size.width/1.5);
    
    //draw gradient
    CGContextDrawLinearGradient(context, gradient, start, end, 0);
    
    //clean up
    CGGradientRelease(gradient);
    CGColorSpaceRelease(rgbColorspace);

}

+(UIImage *)UIImageFromPDF:(NSString*)fileName size:(CGSize)size
{
	CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), (__bridge CFStringRef)fileName, NULL, NULL);
	if (pdfURL) {
		CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL(pdfURL);
		CFRelease(pdfURL);
		//create context with scaling 0.0 as to get the main screen's
        UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
		CGContextRef context = UIGraphicsGetCurrentContext();
		//translate the content
		CGContextTranslateCTM(context, 0.0, size.height);
		CGContextScaleCTM(context, 1.0, -1.0);
		CGContextSaveGState(context);
		//scale to our desired size
		CGPDFPageRef page = CGPDFDocumentGetPage(pdf, 1);
		CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, CGRectMake(0, 0, size.width, size.height), 0, true);
		CGContextConcatCTM(context, pdfTransform);
		CGContextDrawPDFPage(context, page);
		CGContextRestoreGState(context);
		//return autoreleased UIImage
		UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		CGPDFDocumentRelease(pdf);
		return ret;
	}else {
		NSLog(@"Could not load %@",fileName);
	}
	return nil;
}

@end
