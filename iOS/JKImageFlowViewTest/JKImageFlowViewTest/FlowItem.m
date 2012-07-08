//
//  FlowItem.m
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
