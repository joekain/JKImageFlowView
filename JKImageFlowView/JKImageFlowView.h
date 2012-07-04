//
//  JKImageFlowView.h
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
