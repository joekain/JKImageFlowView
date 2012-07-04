//
//  FlowItem.h
//  JKImageFlowViewTest
//
//  Created by Joseph Kain on 7/3/12.
//  Copyright (c) 2012 Joseph Kain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKImageFlowItem.h"

@interface FlowItem : NSObject <JKImageFlowItem> {
    NSString *type;
    NSString *filePath;
    id representation;
}

- (id)initWithPath:(NSString *)aPath;
- (id)initWithPath:(NSString *)aPath andType:(NSString *)type;
@end