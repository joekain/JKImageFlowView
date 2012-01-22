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
        qcview = [[QCView alloc] initWithFrame:frameRect];
        [qcview setEventForwardingMask:NSAnyEventMask];
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        [qcview loadCompositionFromFile:[bundle pathForResource:@"JKImageFlowView"
                                                         ofType:@"qtz"]];
        [qcview startRendering];
        
        [self addSubview:qcview];
    }
    return self;
}

#pragma mark - NSView methods
- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [qcview setFrame:frameRect];
}

#pragma mark - Data Source
- (void)reloadData
{
    arrayFromDataSource = [[NSMutableArray alloc] init];

    int index;
    for (index = 0; index < [dataSource numberOfItemsInImageFlow:self]; index++) {
        NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];

        [tmp setValue:[dataSource imageFlow:self itemAtIndex:index] forKey:@"url"];
        [arrayFromDataSource insertObject:tmp atIndex:index];
    }
    [qcview setValue:arrayFromDataSource forInputKey:@"Image_List"];
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
