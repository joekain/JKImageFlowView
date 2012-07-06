//
//  ViewController.m
//  JKImageFlowViewTest
//
//  Created by Joseph Kain on 7/3/12.
//  Copyright (c) 2012 Joseph Kain. All rights reserved.
//

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
