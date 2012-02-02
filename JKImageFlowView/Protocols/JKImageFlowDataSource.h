//
//  JKImageFlowDataSource.h
//  JKImageFlowView
//
//  Created by Joseph Kain on 2/1/12.
//  Copyright (c) 2012 Joseph Kain. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JKImageFlowDataSource <NSObject>

- (id) imageBrowser:(IKImageBrowserView *) aBrowser itemAtIndex:(NSUInteger)index;
- (NSUInteger) numberOfItemsInImageBrowser:(IKImageBrowserView *) aBrowser;

@end
