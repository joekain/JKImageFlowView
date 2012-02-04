//
//  AppDelegate.m
//  JKImageFlowViewTest
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

#import "AppDelegate.h"
#import "FlowItem.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize flowView = _flowView;
@synthesize label = _label;

- (void)fillImages
{
    /* All of the representation types to test */
    NSString *types[] = {
        JKImageBrowserPathRepresentationType,
        JKImageBrowserNSURLRepresentationType,
        JKImageBrowserNSImageRepresentationType,
        //JKImageBrowserCGImageRepresentationType,
        //JKImageBrowserCGImageSourceRepresentationType,
        JKImageBrowserNSDataRepresentationType,
        JKImageBrowserNSBitmapImageRepresentationType,
        //JKImageBrowserQTMovieRepresentationType,
        //JKImageBrowserQTMoviePathRepresentationType,
        //JKImageBrowserQCCompositionRepresentationType,
        //JKImageBrowserQCCompositionPathRepresentationType,
        //JKImageBrowserQuickLookPathRepresentationType,
        //JKImageBrowserIconRefPathRepresentationType,
        //JKImageBrowserIconRefRepresentationType,
        //JKImageBrowserPDFPageRepresentationType,
    };
    int numTypes = sizeof(types) / sizeof(NSString *);
    int index;

    NSArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"jpg"
                                                        inDirectory:@""];
    assert([paths count] >= numTypes);
    
    NSMutableArray *newImages = [NSMutableArray arrayWithCapacity:[paths count]];
    index = 0;
    for (NSString *path in paths) {
        [newImages addObject:[[FlowItem alloc] initWithPath:path
                                                    andType:types[index % numTypes]]];
        index++;
    }
    images = newImages;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self fillImages];
    [self.flowView setDataSource:self];
    [self.flowView setDelegate:self];
}

- (NSUInteger)numberOfItemsInImageFlow:(id)aFlow
{
    return [images count];
}

- (id)imageFlow:(id)aFlow itemAtIndex:(int)index
{
    return [images objectAtIndex:index];
}

#pragma mark - JKImageFlowDelegate

- (void) imageFlow:(JKImageFlowView *) aFlow
         backgroundWasRightClickedWithEvent:(NSEvent *) event
{
    self.label.stringValue = @"Background right clicked";
}

- (void) imageFlow:(JKImageFlowView *) aFlow
         cellWasDoubleClickedAtIndex:(NSUInteger) index
{
    self.label.stringValue = [NSString stringWithFormat:@"Double clicked %d", index];
}

- (void) imageFlow:(JKImageFlowView *) aFlow
         cellWasRightClickedAtIndex:(NSUInteger) index
         withEvent:(NSEvent *) event
{
    self.label.stringValue = [NSString stringWithFormat:@"Right clicked %d", index];
}

- (void) imageFlowSelectionDidChange:(JKImageFlowView *) aFlow
{
    self.label.stringValue = [NSString stringWithFormat:@"Selection changed to %d",
                              self.flowView.selection];
}

@end
