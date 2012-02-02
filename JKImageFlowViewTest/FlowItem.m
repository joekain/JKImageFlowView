//
//  FlowItem.m
//  JKImageFlowView
//
//  Created by Joseph Kain on 2/1/12.
//  Copyright (c) 2012 Joseph Kain. All rights reserved.
//

#import "FlowItem.h"

@implementation FlowItem

- (id)initWithPath:(NSString *)aPath
{
    self = [super init];
    if (self) {
        filePath = aPath;
    }
    return self;
}

- (NSString *) imageUID
{
    return filePath;
}

- (NSString *) imageRepresentationType
{
    return JKImageBrowserPathRepresentationType;
}

- (id) imageRepresentation
{
    return filePath;
}

- (NSString *) imageTitle
{
    return [filePath lastPathComponent];
}

- (BOOL) isSelectable
{
    return YES;
}
@end
