//
//  JKImageFlowDelegate.h
//  JKImageFlowView
//
//  Created by Joseph Kain on 2/4/12.
//  Copyright (c) 2012 Joseph Kain. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JKImageFlowView;
@protocol JKImageFlowDelegate <NSObject>

@optional
- (void) imageFlow:(JKImageFlowView *) aFlow
         backgroundWasRightClickedWithEvent:(JKAEvent *) event;

- (void) imageFlow:(JKImageFlowView *) aFlow
         cellWasDoubleClickedAtIndex:(NSUInteger) index; 

- (void) imageFlow:(JKImageFlowView *) aFlow
         cellWasRightClickedAtIndex:(NSUInteger) index
         withEvent:(JKAEvent *) event;
         
- (void) imageFlowSelectionDidChange:(JKImageFlowView *) aFlow;
@end
