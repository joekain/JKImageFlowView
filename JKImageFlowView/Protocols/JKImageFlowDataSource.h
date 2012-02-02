//
//  JKImageFlowDataSource.h
//  JKImageFlowView
//
//  Created by Joseph Kain on 2/1/12.
//  Copyright (c) 2012 Joseph Kain. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JKImageFlowView;
@protocol JKImageFlowDataSource <NSObject>

- (id) imageBrowser:(JKImageFlowView *) aBrowser itemAtIndex:(NSUInteger)index;
- (NSUInteger) numberOfItemsInImageBrowser:(JKImageFlowView *) aBrowser;

@end
