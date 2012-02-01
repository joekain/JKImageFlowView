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
        selection = 0;
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

- (void) redraw
{
    int index;
    
    for (index = 0; index < [mLayers count]; index++) {
        float t = (index - selection) / (float)[mLayers count];
        float x = xFromPosition(t);
        float yRot = yRotationDegreesFromPosition(t) * M_PI / 180.0;
        float z = zFromPosition(t);
        float a = aFromPosition(t);
        
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
        
        // Darken the sublayer
        layer = [layer.sublayers objectAtIndex:0];
        layer.opacity = 1 - a;
    } 
}

#pragma mark - NSView methods
- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    for (CALayer *layer in [[self layer] sublayers]) {
        //[layer setFrame:NSRectToCGRect([self frame])];
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
        layer.edgeAntialiasingMask = kCALayerBottomEdge | kCALayerTopEdge;
        [layer setNeedsDisplay];
        [top insertObject:layer atIndex:index];
        [rootLayer addSublayer:layer];
        
        // Add a black sublayer covering the image.  The opacity of this
        // sublayer will be adjusted to darken or lighten the image.
        CALayer *subLayer = [CALayer layer];
        subLayer.frame = rect;
        subLayer.backgroundColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0);
        subLayer.opacity = 0.0;
        [layer addSublayer:subLayer];
    }
    mLayers = top;
    
    [self redraw];
    
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

#pragma mark - NSResponder

#define kLeftArrowKeyCode 123
#define kRightArrowKeyCode 124

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)wantsScrollEventsForSwipeTrackingOnAxis:(NSEventGestureAxis)axis 
{
    // Inform the underlying view that we want horizontal scroll gesture events
    return (axis == NSEventGestureAxisHorizontal) ? YES : NO;
}

- (void)keyDown:(NSEvent *)theEvent
{
    switch ([theEvent keyCode]) {
        case kLeftArrowKeyCode:
            if (selection > 0) {
                selection--;
                [self redraw];
            }
            break;
        case kRightArrowKeyCode:
            if (selection < [mLayers count] - 1) {
                selection++;
                [self redraw];
            }
            break;
            
        default:
            [super keyDown:theEvent];
            break;
    }
}

- (void)scrollWheel:(NSEvent *)theEvent 
{
    // This works the way I want.  To mimic IKImageFlowView I would need to
    // soften (or slow down) the scroll at the end points.
    // momentumPhase may be useful here
    if ([theEvent deltaX] < 0 && selection < [mLayers count] - 1) {
        selection++;
        [self redraw];
    } else if ([theEvent deltaX] > 0 && selection > 0) {
        selection--;
        [self redraw];
    }
}

- (Boolean)checkPoint:(NSPoint)point inLayerWithIndex:(int)index
{
    CALayer *root = [self layer];
    CALayer *layer = [mLayers objectAtIndex:index];
    CGPoint p = [root convertPoint:[self convertPointToLayer:point]
                           toLayer:layer];
    if ([layer containsPoint:p]) {
        selection = index;
        [self redraw];
        return YES;
    }
    return NO;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    int index;
    
    NSPoint viewPoint = [self convertPoint:[theEvent locationInWindow]
                                  fromView:nil];
    
    // Need to consider the front most cells first.  However, the cells to the
    // left and the right of the selection don't overlap so it works to consider
    // the cells to the right starting with the selection and then go back to 
    // the cells on the left starting with the cell closest to the selection.
    for (index = selection; index < [mLayers count]; index++) {
        if ([self checkPoint:viewPoint inLayerWithIndex:index]) {
            return;
        }
    }
    for (index = selection - 1; index >= 0; index--) {
        if ([self checkPoint:viewPoint inLayerWithIndex:index]) {
            return;
        }
    }
}

@end
