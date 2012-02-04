//
//  JKImageFlowDelegate.h
//  JKImageFlowView
//
//  Created by Joseph Kain on 2/4/12.
//  Copyright (c) 2012 Joseph Kain. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JKImageFlowDelegate <NSObject>

@optional
- (void) imageFlow:(JKImageFlowView *) aFlow
         backgroundWasRightClickedWithEvent:(NSEvent *) event;

- (void) imageFlow:(JKImageFlowView *) aFlow
         cellWasDoubleClickedAtIndex:(NSUInteger) index; 

- (void) imageFlow:(JKImageFlowView *) aFlow
         cellWasRightClickedAtIndex:(NSUInteger) index
         withEvent:(NSEvent *) event;
         
- (void) imageFlowSelectionDidChange:(JKImageFlowView *) aFlow;
@end
