//
//  AppDelegate.h
//  JKImageFlowViewTest
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

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

#import "JKImageFlowView.h"
#import "JKImageFlowDataSource.h"

@interface AppDelegate : NSObject <NSApplicationDelegate,
                                   JKImageFlowDataSource,
                                   JKImageFlowDelegate> {
    NSArray *images;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet JKImageFlowView *flowView;
@property (assign) IBOutlet NSTextField *label;

// JKImageFlowDataSource Protocol (informal)
- (NSUInteger)numberOfItemsInImageFlow:(id)aFlow;
- (id)imageFlow:(JKImageFlowView *)aFlow itemAtIndex:(NSUInteger)index;
@end
