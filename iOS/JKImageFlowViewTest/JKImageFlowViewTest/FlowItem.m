//
//  FlowItem.m
//  JKImageFlowViewTest
//
//  Created by Joseph Kain on 7/3/12.
//  Copyright (c) 2012 Joseph Kain. All rights reserved.
//

#import "FlowItem.h"

@implementation FlowItem

- (id)initWithPath:(NSString *)aPath
{
    self = [super init];
    if (self) {
        type = JKImageBrowserPathRepresentationType;
        filePath = aPath;
        representation = aPath;
    }
    return self;
}

- (id)initWithPath:(NSString *)aPath andType:(NSString *)aType
{
    self = [super init];
    if (self) {
        filePath = aPath;
        type = aType;
        
        if ([type isEqualToString:JKImageBrowserPathRepresentationType]) {
            representation = aPath;
        } else if ([type isEqualToString:JKImageBrowserNSURLRepresentationType]) {
            representation = [NSURL fileURLWithPath:aPath];
        } else if ([type isEqualToString:JKImageBrowserNSImageRepresentationType]) {
            representation = [UIImage imageWithContentsOfFile:aPath];
        } else if ([type isEqualToString:JKImageBrowserNSDataRepresentationType]) {
            representation = [NSData dataWithContentsOfFile:aPath];
        }
    }
    return self;
}

- (NSString *) imageUID
{
    return filePath;
}

- (NSString *) imageRepresentationType
{
    return type;
}

- (id) imageRepresentation
{
    return representation;
}

- (NSString *) imageTitle
{
    return [filePath lastPathComponent];
}

- (NSString *) imageSubtitle
{
    return [NSString stringWithString:@"A Picture"];
}

- (BOOL) isSelectable
{
    return YES;
}
@end
