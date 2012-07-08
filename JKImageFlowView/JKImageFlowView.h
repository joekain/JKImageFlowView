//
//  JKImageFlowView.h
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


#ifdef __APPLE__
#include "TargetConditionals.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <UIKit/UIImage.h>
#import <QuartzCore/QuartzCore.h>
#define JKAView UIView
#define JKARect CGRect
#define JKAEvent UIEvent
#define JKAImage UIImage

#elif TARGET_OS_MAC
#import <Quartz/Quartz.h>
#define JKAView NSView
#define JKARect NSRect
#define JKAEvent NSEvent
#define JKAImage NSImage

#endif
#endif

#import "JKImageFlowDelegate.h"
#import "JKImageFlowDataSource.h"

@interface JKImageFlowView : JKAView {
    int mSelection;
    float mAccumulatedPan;
    id dataSource;
    id <JKImageFlowDelegate> mDelegate;
    NSArray *mLayers;
    CATextLayer *mTitleLayer;
    CATextLayer *mSubtitleLayer;
    NSArray *mTitles;
    NSArray *mSubtitles;
}

@property int selection;

- (id)initWithFrame:(CGRect)frameRect;
- (void)reloadData;
- (void)setFrame:(CGRect)frameRect;
@property (retain) id <JKImageFlowDataSource> dataSource;
@property (retain) id <JKImageFlowDelegate> delegate;
@end
