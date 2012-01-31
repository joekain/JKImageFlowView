//
//  JKImageFlowView.m
//  JKImageFlowView
//
//  Created by Joseph Kain on 1/21/12.
//  Copyright (c) 2012 Joseph Kain. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions
//  are met:
// 
//     1. Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
// 
//     2. Redistributions in binary form must reproduce the above
//        copyright notice, this list of conditions and the following
//        disclaimer in the documentation and/or other materials
//        provided with the distribution.
// 
//  THIS SOFTWARE IS PROVIDED BY JOSEPH KAIN ''AS IS'' AND ANY EXPRESS
//  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL JOSEPH KAIN OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
//  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
//  The views and conclusions contained in the software and
//  documentation are those of the authors and should not be interpreted
//  as representing official policies, either expressed or implied, of
//  Joseph Kain.

#import "JKImageFlowView.h"

// JKImageFlowDataSource informal protocol
@interface NSObject (JKImageFlowDataSource)
- (NSUInteger)numberOfItemsInImageFlow:(id)aFlow;
- (id)imageFlow:(id)aFlow itemAtIndex:(int)index;
@end

@implementation JKImageFlowView

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        mLayers = nil;
    }
    return self;
}

#pragma mark - Drawing methods

CGFloat xFromPosition(CGFloat t)
{
    if (t == 0) {
        return 0;
    } else if (t < 0) {
        return t - 0.3;
    } else {
        return t + 0.3;
    }
}

CGFloat yRotationDegreesFromPosition(CGFloat t)
{
    if (t == 0) {
        return 0;
    } else if (t < 0) {
        return -45;
    } else {
        return 45;
    }
}

CGFloat zFromPosition(CGFloat t)
{
    if (t == 0) {
        return 0.25;
    } else {
        return MAX(-fabs(t * 0.25), -1);
    } 
}

CGFloat aFromPosition(CGFloat t)
{
    return 1.0 - fabs(t);
}

- (void)drawCellWithImage:(CGImageRef)image
              withContext:(CGContextRef)context
                  inLayer:(CALayer *)layer
{
    CGRect standard = layer.bounds;
    standard.size.height *= 0.5;
    CGRect reflected = standard;
    //reflected.origin.y = 0;
    standard.origin.y = standard.size.height;

    CGContextSaveGState(context); {
        CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
        CGContextFillRect(context, standard);
        CGContextSetRGBFillColor(context, 0.3, 0.3, 0.3, 1.0);
        CGContextFillRect(context, reflected);

        CGContextSetBlendMode(context, kCGBlendModeMultiply);
        CGContextDrawImage(context, standard, image);
        CGContextScaleCTM (context, 1.0, -1.0);
        reflected.origin.y = -reflected.size.height;
        CGContextDrawImage(context, reflected, image);
    }
    CGContextRestoreGState(context);
}

- (void)drawLayer:(CALayer *)theLayer inContext:(CGContextRef)theContext
{
    CGImageRef image = [[theLayer valueForKey:@"image"] pointerValue];
    [self drawCellWithImage:image withContext:theContext inLayer:theLayer];
}

#pragma mark - NSView methods
- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    for (CALayer *layer in [[self layer] sublayers]) {
        [layer setFrame:NSRectToCGRect([self frame])];
    }
}

#pragma mark - Data Source
- (void)reloadData
{
    NSMutableArray *top = [[NSMutableArray alloc] init]; 
    
    CALayer *rootLayer = [CALayer layer];
    CGColorRef black = CGColorCreateGenericRGB(0.0f, 0.0f, 0.0f, 1.0f);
    rootLayer.backgroundColor = black;
    CGColorRelease(black);
    [rootLayer setFrame:NSRectToCGRect([self frame])];
    CATransform3D sublayerTransform = CATransform3DIdentity;
    sublayerTransform.m34 = 1 / -400.0;
    rootLayer.sublayerTransform = sublayerTransform;

    int index;
    for (index = 0; index < [dataSource numberOfItemsInImageFlow:self]; index++) {
        CALayer *layer;
        
        // XXX Need to support URL as well as path, maybe others
        // XXX Don't assume JPEG
        const char *path = [[dataSource imageFlow:self itemAtIndex:index] 
                            cStringUsingEncoding:NSASCIIStringEncoding];
        CGDataProviderRef provider = CGDataProviderCreateWithFilename(path);
        CGImageRef image = CGImageCreateWithJPEGDataProvider(provider,
                                                             NULL,
                                                             YES,
                                                             kCGRenderingIntentDefault);
        CGImageRetain(image);
        float aspect = (float)CGImageGetWidth(image) / CGImageGetHeight(image);
        
        layer = [CALayer layer];
        [layer setValue:[NSValue valueWithPointer:image] forKey:@"image"];
        layer.delegate = self;
        layer.layoutManager=[CAConstraintLayoutManager layoutManager];
        CGRect rect = CGRectMake(0, 0, 300 * aspect, 300 * 2);
        layer.frame = rect;

        layer.backgroundColor = CGColorCreateGenericRGB(1.0, 1.0, 1.0, 1.0);
        [layer setValue:[NSNumber numberWithFloat:aspect] forKey:@"aspect"];
        [layer setNeedsDisplay];
        [top insertObject:layer atIndex:index];
        [rootLayer addSublayer:layer];
    }
    mLayers = top;
    
    int selection = 3;
    //int index;
    
    for (index = 0; index < [mLayers count]; index++) {
        float t = (index - selection) / (float)[mLayers count];
        float x = xFromPosition(t);
        float yRot = yRotationDegreesFromPosition(t) * M_PI / 180.0;
        float z = zFromPosition(t);
        //float a = aFromPosition(t);

        CALayer *layer;
        CATransform3D t3D;
        
        layer = [mLayers objectAtIndex:index];
        t3D = CATransform3DIdentity;
        t3D = CATransform3DTranslate(t3D, [self frame].size.width / 2, [self frame].size.height / 2, 0);
        t3D = CATransform3DTranslate(t3D, -layer.bounds.size.width / 2, -2 * layer.bounds.size.height / 3.0, 0);
        t3D = CATransform3DTranslate(t3D, x * 300, 0, z * 300);
        t3D = CATransform3DRotate(t3D, -yRot,  0, 1, 0);
        t3D = CATransform3DScale(t3D, 0.5, 0.5, 1);
        layer.transform = t3D;
    }
    
    [self setLayer:rootLayer];
    [self setWantsLayer:YES];
    [self setNeedsDisplayInRect:[self frame]];
}

- (id) dataSource
{
    return dataSource;
}

- (void) setDataSource:(id)newDataSource
{
    dataSource = newDataSource;
    [self reloadData];
}

@end
