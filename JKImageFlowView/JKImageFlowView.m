//
//  JKImageFlowView.m
//  JKImageFlowView
//
//  Created by Joseph Kain on 1/21/12.
//  Copyright (c) 2012 Joseph Kain. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge,
//  publish, distribute, sublicense, and/or sell copies of the Software,
//  and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import "JKImageFlowView.h"
#import "JKImageFlowItem.h"

NSString * const JKImageBrowserPathRepresentationType = @"JKImageBrowserPathRepresentationType";
NSString * const JKImageBrowserNSURLRepresentationType = @"JKImageBrowserNSURLRepresentationType";
NSString * const JKImageBrowserNSImageRepresentationType = @"JKImageBrowserNSImageRepresentationType";
NSString * const JKImageBrowserNSDataRepresentationType = @"JKImageBrowserNSDataRepresentationType";
NSString * const JKImageBrowserNSBitmapImageRepresentationType = @"JKImageBrowserNSBitmapImageRepresentationType";

@implementation JKImageFlowView

- (void)commonInit
{
    mSelection = 0;
    mLayers = nil;
    
#if TARGET_OS_IPHONE
    UITapGestureRecognizer *tap;
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tap];
    
    UITapGestureRecognizer *doubleTap;
    doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    doubleTap.numberOfTouchesRequired = 1;
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    UIPanGestureRecognizer *pan;
    pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    pan.minimumNumberOfTouches = 1;
    pan.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:pan];
#endif
}

- (id)initWithFrame:(JKARect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)encoder
{
    self = [super initWithCoder:encoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (int) selection
{
    return mSelection;
}

- (void) setSelection:(int)selection
{
    mSelection = selection;
    
    if ([mDelegate respondsToSelector:@selector(imageFlowSelectionDidChange:)]) {
        [mDelegate imageFlowSelectionDidChange:self];
    }
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

- (CATransform3D) rootTransform
{
    // This formula is computes 1.0 for iPhone and 1.5 for iPad in JKImageFlowViewTest.
    // Scale linearly between the values to handle any view size.
    float factor = [self frame].size.width / (2 * 644.0) + (1.0 - (480.0 / (2 * 644)));
    CATransform3D transform = CATransform3DMakeScale(factor, factor, factor);
    transform.m34 =  1 / -400.0;
    
    return transform;
}

- (void) redraw
{
    int index;
    CALayer *layer;
    float scale;
    float xlateY;
    
#if TARGET_OS_IPHONE
    scale = -1.0;
    xlateY = -1.125;
#else
    scale = 1.0;
    xlateY = -2;
#endif
    
    // Redraw as a single transaction
#if TARGET_OS_IPHONE
    [UIView beginAnimations:nil context:NULL];
#endif
    [CATransaction begin];
    
    [self layer].sublayerTransform = [self rootTransform];

    for (index = 0; index < [mLayers count]; index++) {
        float t = (index - self.selection) / (float)[mLayers count];
        float x = xFromPosition(t);
        float yRot = yRotationDegreesFromPosition(t) * M_PI / 180.0;
        float z = zFromPosition(t);
        float a = aFromPosition(t);
        
        CATransform3D t3D;
        
        layer = [mLayers objectAtIndex:index];
        
        t3D = CATransform3DIdentity;
        t3D = CATransform3DTranslate(t3D, [self frame].size.width / 2, [self frame].size.height / 2, 0);
        
        t3D = CATransform3DTranslate(t3D, -layer.bounds.size.width / 2, xlateY * layer.bounds.size.height / 3.0, 0);
        t3D = CATransform3DTranslate(t3D, x * 300, 0, z * 300);
        t3D = CATransform3DRotate(t3D, -yRot,  0, 1, 0);
        t3D = CATransform3DScale(t3D, 0.5, scale * 0.5, 1);
        layer.transform = t3D;
        
        // Darken the sublayer
        layer = [layer.sublayers objectAtIndex:0];
        layer.opacity = 1 - a;
    }

    layer = [mLayers objectAtIndex:self.selection];
    mTitleLayer.string = [mTitles objectAtIndex:self.selection];
    mTitleLayer.frame = CGRectMake(0, 0, [self frame].size.width, 25);
    mTitleLayer.zPosition = 100;
    CGPoint position = 
        CGPointMake([self frame].size.width / 2.0,
                    [self frame].size.height / 2.0 - scale * 50);
    mTitleLayer.position = position;

    mSubtitleLayer.string = [mSubtitles objectAtIndex:self.selection];
    mSubtitleLayer.frame = CGRectMake(0, 0, [self frame].size.width, 25);
    mSubtitleLayer.zPosition = 100;
    position.y -= scale * 25;
    mSubtitleLayer.position = position;

    [CATransaction commit];
#if TARGET_OS_IPHONE
    [UIView commitAnimations];
#endif
}

#pragma mark - NSView methods
- (void)setFrame:(JKARect)frameRect
{
    [super setFrame:frameRect];
    
    // Redraw so that the positions are recalculated and the flow stays in
    // the in ceter of the view.  But, make the animations instant during
    // the resize so it feels snapier
    [CATransaction begin]; {
        [CATransaction setValue:[NSNumber numberWithFloat:0.00f]
                         forKey:kCATransactionAnimationDuration];
        [self redraw];
    }
    [CATransaction commit];
}

#if TARGET_OS_IPHONE
- (CGImageRef)newImageFromItem:(NSObject <JKImageFlowItem> *)item
{
    NSString *type = [item imageRepresentationType];
    UIImage *nsImage = nil;
    
    if ([type isEqualToString:JKImageBrowserPathRepresentationType]) {
        nsImage = [[UIImage alloc] initWithContentsOfFile:[item imageRepresentation]];
    } else if ([type isEqualToString:JKImageBrowserNSURLRepresentationType]) {
        NSData *data = [NSData dataWithContentsOfURL:[item imageRepresentation]];
        nsImage = [[UIImage alloc] initWithData:data];
    } else if ([type isEqualToString:JKImageBrowserNSImageRepresentationType]) {
        nsImage = [item imageRepresentation];
    } else if ([type isEqualToString:JKImageBrowserNSDataRepresentationType]) {
        nsImage = [[UIImage alloc] initWithData:[item imageRepresentation]];
    } else if ([type isEqualToString:JKImageBrowserNSBitmapImageRepresentationType]) {
        return CGImageRetain([[item imageRepresentation] CGImage]);
    }
    
    if (nsImage) {
        return CGImageRetain(nsImage.CGImage);
    } else {
        return nil;
    }
}
#elif TARGET_OS_MAC
- (CGImageRef)newImageFromItem:(NSObject <JKImageFlowItem> *)item
{
    NSString *type = [item imageRepresentationType];
    JKAImage *nsImage = nil;

    if ([type isEqualToString:JKImageBrowserPathRepresentationType]) {
        nsImage = [[JKAImage alloc] initByReferencingFile:[item imageRepresentation]];
    } else if ([type isEqualToString:JKImageBrowserNSURLRepresentationType]) {
        nsImage = [[JKAImage alloc] initWithContentsOfURL:[item imageRepresentation]];
    } else if ([type isEqualToString:JKImageBrowserNSImageRepresentationType]) {
        nsImage = [item imageRepresentation];
    } else if ([type isEqualToString:JKImageBrowserNSDataRepresentationType]) {
        nsImage = [[JKAImage alloc] initWithData:[item imageRepresentation]];
    } else if ([type isEqualToString:JKImageBrowserNSBitmapImageRepresentationType]) {
        return [[item imageRepresentation] CGImage];
    }

    if (nsImage) {
        CGImageRef cgImage = [nsImage CGImageForProposedRect:nil
                                                     context:[NSGraphicsContext currentContext]
                                                       hints:nil];
        return CGImageRetain(cgImage);
    } else {
        return nil;
    }
}
#endif

#pragma mark - Data Source
- (void)reloadData
{
    NSMutableArray *top = [[NSMutableArray alloc] init]; 
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    NSMutableArray *subtitles = [[NSMutableArray alloc] init];
    
    CALayer *rootLayer = [CALayer layer];
    const CGFloat blackArray[] = {0.0f, 0.0f, 0.0f, 1.0f};
    const CGFloat whiteArray[] = {1.0f, 1.0f, 1.0f, 1.0f};
    CGColorRef black = CGColorCreate(CGColorSpaceCreateDeviceRGB(),
                                     blackArray);
    CGColorRef white = CGColorCreate(CGColorSpaceCreateDeviceRGB(),
                                     whiteArray);
    rootLayer.backgroundColor = black;

#if TARGET_OS_IPHONE
    [rootLayer setFrame:[self frame]];
#else
    [rootLayer setFrame:NSRectToCGRect([self frame])];
#endif
    CATransform3D sublayerTransform = [self rootTransform];    
    rootLayer.sublayerTransform = sublayerTransform;

    int index;
    for (index = 0; index < [dataSource numberOfItemsInImageFlow:self]; index++) {
        CALayer *layer;
        
        CGImageRef image = [self newImageFromItem:[dataSource imageFlow:self
                                                            itemAtIndex:index]];
        float aspect = (float)CGImageGetWidth(image) / CGImageGetHeight(image);

        layer = [CALayer layer];
        [layer setValue:[NSValue valueWithPointer:image] forKey:@"image"];
        layer.delegate = self;
#if !TARGET_OS_IPHONE
        layer.layoutManager=[CAConstraintLayoutManager layoutManager];
#endif
        CGRect rect = CGRectMake(0, 0, 300 * aspect, 300 * 2);
        layer.frame = rect;

        layer.backgroundColor = white;
        layer.edgeAntialiasingMask = kCALayerBottomEdge | kCALayerTopEdge;
        [layer setNeedsDisplay];
        [top insertObject:layer atIndex:index];
        [rootLayer addSublayer:layer];
        
        // Add a black sublayer covering the image.  The opacity of this
        // sublayer will be adjusted to darken or lighten the image.
        CALayer *subLayer = [CALayer layer];
        subLayer.frame = rect;
        subLayer.backgroundColor = black;
        subLayer.opacity = 0.0;
        [layer addSublayer:subLayer];
        
        id <JKImageFlowItem> item = [dataSource imageFlow:self itemAtIndex:index];
        
        if ([item respondsToSelector:@selector(imageTitle)]) {
            NSString *title = item.imageTitle;
            if (title) {
                [titles insertObject:title atIndex:index];
            } else {
                [titles insertObject:[NSString stringWithString:@""] atIndex:index];
            }
        }
        if ([item respondsToSelector:@selector(imageSubtitle)]) {
            NSString *title = item.imageSubtitle;
            if (title) {
                [subtitles insertObject:title atIndex:index];
            } else {
                [subtitles insertObject:[NSString stringWithString:@""] atIndex:index];
            }
        }
    }
    CGColorRelease(black);
    CGColorRelease(white);
    
    mLayers = top;
    mTitles = titles;
    mSubtitles = subtitles;
    
    mTitleLayer = [CATextLayer layer];
#if !TARGET_OS_IPHONE
    mTitleLayer.layoutManager = [CAConstraintLayoutManager layoutManager];
#endif
    mTitleLayer.frame = CGRectMake(0, 0, [self frame].size.width, 25);
    mTitleLayer.string = [titles objectAtIndex:0];
    mTitleLayer.fontSize = 12.0;
    mTitleLayer.font = (void *)@"Menlo";
    mTitleLayer.alignmentMode = kCAAlignmentCenter;
    [rootLayer addSublayer:mTitleLayer];
    
    mSubtitleLayer = [CATextLayer layer];
#if !TARGET_OS_IPHONE
    mSubtitleLayer.layoutManager = [CAConstraintLayoutManager layoutManager];
#endif
    mSubtitleLayer.frame = CGRectMake(0, 0, [self frame].size.width, 25);
    mSubtitleLayer.string = [subtitles objectAtIndex:0];
    mSubtitleLayer.fontSize = 12.0;
    mSubtitleLayer.font = (void *)@"Menlo";
    mSubtitleLayer.alignmentMode = kCAAlignmentCenter;
    [rootLayer addSublayer:mSubtitleLayer];
    
    [self redraw];
#if TARGET_OS_IPHONE
    [self.layer addSublayer:rootLayer];
#else
    [self setLayer:rootLayer];
    [self setWantsLayer:YES];
#endif
    [self setNeedsDisplayInRect:[self frame]];
}

- (id) dataSource
{
    return dataSource;
}

- (void) setDataSource:(id <JKImageFlowDataSource>)newDataSource
{
    dataSource = newDataSource;
    [self reloadData];
}

- (id) delegate
{
    return mDelegate;
}

- (void) setDelegate:(id<JKImageFlowDelegate>)delegate
{
    mDelegate = delegate;
}

#pragma mark - NSResponder

#define kLeftArrowKeyCode 123
#define kRightArrowKeyCode 124

- (BOOL)acceptsFirstResponder
{
    return YES;
}

#if TARGET_OS_IPHONE
- (Boolean)checkPoint:(CGPoint)pointInRoot inLayerWithIndex:(int)index
{
    CALayer *root = [self layer];
    CALayer *layer = [mLayers objectAtIndex:index];
    CGPoint pointInLayer = [root convertPoint:pointInRoot toLayer:layer];
    if ([layer containsPoint:pointInLayer]) {
        return YES;
    }
    return NO;
}

- (int)selectionFromPoint:(CGPoint)point
{
    int index;
    
    // Need to consider the front most cells first.  However, the cells to the
    // left and the right of the selection don't overlap so it works to consider
    // the cells to the right starting with the selection and then go back to 
    // the cells on the left starting with the cell closest to the selection.
    for (index = self.selection; index < [mLayers count]; index++) {
        if ([self checkPoint:point inLayerWithIndex:index]) {
            
            return index;
        }
    }
    for (index = self.selection - 1; index >= 0; index--) {
        if ([self checkPoint:point inLayerWithIndex:index]) {
            return index;
        }
    }
    return -1;
}

- (int)updateIndexFromTapGesture:(UIGestureRecognizer *)sender
{
    if (sender.state != UIGestureRecognizerStateEnded) {
        return -1;
    }

    int index;
    CGPoint viewPoint = [sender locationInView:self];    
    index = [self selectionFromPoint:viewPoint];
    
    if (index != -1) {
        self.selection = index;
        [self redraw];
    }
    
    return index;
}

- (void)handleTapGesture:(UIGestureRecognizer *)sender
{    
    [self updateIndexFromTapGesture:sender];
}

- (void)handleDoubleTapGesture:(UIGestureRecognizer *)sender
{
    int index = [self updateIndexFromTapGesture:sender];
    if (index != -1) {
        if ([mDelegate respondsToSelector:@selector(imageFlow:cellWasDoubleClickedAtIndex:)]) {
            [mDelegate imageFlow: self cellWasDoubleClickedAtIndex:index];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        mAccumulatedPan = 0;
    } else {
        // This works the way I want.  To mimic IKImageFlowView I would need to
        // soften (or slow down) the scroll at the end points.
        CGPoint delta = [sender translationInView:self];
        float pan = (delta.x - mAccumulatedPan) / self.frame.size.width;
        
        float threshold = 0.3 / [mLayers count];
        
        if (pan < -threshold) {
            if (self.selection < [mLayers count] - 1) {
                self.selection++;
                [self redraw];
            }
            mAccumulatedPan = delta.x;
        } else if (pan > threshold) {
            if (self.selection > 0) {
                self.selection--;
                [self redraw];
            }
            mAccumulatedPan = delta.x;
        }
    }
}

#else
- (BOOL)wantsScrollEventsForSwipeTrackingOnAxis:(NSEventGestureAxis)axis 
{
    // Inform the underlying view that we want horizontal scroll gesture events
    return (axis == NSEventGestureAxisHorizontal) ? YES : NO;
}

- (void)keyDown:(JKAEvent *)theEvent
{
    switch ([theEvent keyCode]) {
        case kLeftArrowKeyCode:
            if (self.selection > 0) {
                self.selection--;
                [self redraw];
            }
            break;
        case kRightArrowKeyCode:
            if (self.selection < [mLayers count] - 1) {
                self.selection++;
                [self redraw];
            }
            break;
            
        default:
            [super keyDown:theEvent];
            break;
    }
}

- (void)scrollWheel:(JKAEvent *)theEvent 
{
    // This works the way I want.  To mimic IKImageFlowView I would need to
    // soften (or slow down) the scroll at the end points.
    // momentumPhase may be useful here
    if ([theEvent deltaX] < 0 && self.selection < [mLayers count] - 1) {
        self.selection++;
        [self redraw];
    } else if ([theEvent deltaX] > 0 && self.selection > 0) {
        self.selection--;
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
        return YES;
    }
    return NO;
}

- (int)selectionFromPoint:(NSPoint)point
{
    int index;
    
    // Need to consider the front most cells first.  However, the cells to the
    // left and the right of the selection don't overlap so it works to consider
    // the cells to the right starting with the selection and then go back to 
    // the cells on the left starting with the cell closest to the selection.
    for (index = self.selection; index < [mLayers count]; index++) {
        if ([self checkPoint:point inLayerWithIndex:index]) {
            
            return index;
        }
    }
    for (index = self.selection - 1; index >= 0; index--) {
        if ([self checkPoint:point inLayerWithIndex:index]) {
            return index;
        }
    }
    return -1;
}

- (void)mouseDown:(JKAEvent *)theEvent
{
    int index;
    
    NSPoint viewPoint = [self convertPoint:[theEvent locationInWindow]
                                  fromView:nil];

    index = [self selectionFromPoint:viewPoint];
    if (index == -1)
        return;
        
    self.selection = index;
    [self redraw];
        
    if ([mDelegate respondsToSelector:@selector(imageFlow:cellWasDoubleClickedAtIndex:)] &&
        [theEvent clickCount] == 2) {
        [mDelegate imageFlow: self cellWasDoubleClickedAtIndex:index];
    }
}

- (void)rightMouseDown:(JKAEvent *)theEvent
{
    NSPoint viewPoint = [self convertPoint:[theEvent locationInWindow]
                                  fromView:nil];
    int index = [self selectionFromPoint:viewPoint];
    if (index == -1) {
        if ([mDelegate respondsToSelector:
             @selector(imageFlow:backgroundWasRightClickedWithEvent:)]) {
            [mDelegate imageFlow:self backgroundWasRightClickedWithEvent:theEvent];
        }
    } else {
        if ([mDelegate respondsToSelector:
             @selector(imageFlow:cellWasRightClickedAtIndex:withEvent:)]) {
            [mDelegate imageFlow:self cellWasRightClickedAtIndex:index withEvent:theEvent];
        }
    }
}
#endif

@end
