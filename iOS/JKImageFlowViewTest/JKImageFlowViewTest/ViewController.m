//
//  ViewController.m
//  JKImageFlowViewTest
//
//  Created by Joseph Kain on 7/3/12.
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

#import "ViewController.h"
#import "FlowItem.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize flowView = _flowView;
@synthesize label = _label;


- (void)fillImages
{
    /* All of the representation types to test */
    NSString *types[] = {
        JKImageBrowserPathRepresentationType,
        JKImageBrowserNSURLRepresentationType,
        JKImageBrowserNSImageRepresentationType,
        JKImageBrowserNSDataRepresentationType,
    };
    int numTypes = sizeof(types) / sizeof(NSString *);
    int index;
    
    NSArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"jpg" inDirectory:nil];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
  
    [self fillImages];
    [self.flowView setDataSource:self];
    [self.flowView setDelegate:self];
}

- (void)viewDidUnload
{
    [self setFlowView:nil];
    [self setLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (UIInterfaceOrientationIsLandscape(interfaceOrientation));
    } else {
        return YES;
    }
}

#pragma mark - JKImageFlowDataSource

- (NSUInteger)numberOfItemsInImageFlow:(id)aFlow
{
    return [images count];
}

- (id)imageFlow:(id)aFlow itemAtIndex:(int)index
{
    return [images objectAtIndex:index];
}

#pragma mark - JKImageFlowViewDelegate

- (void) imageFlowSelectionDidChange:(JKImageFlowView *) aFlow;
{
    self.label.text = [NSString stringWithFormat:@"Selection changed to %d", self.flowView.selection];
}

- (void) imageFlow:(JKImageFlowView *) aFlow
cellWasDoubleClickedAtIndex:(NSUInteger) index
{
    self.label.text = [NSString stringWithFormat:@"Double clicked %d", index];
}

@end
