//
//  FlowItem.h
//  JKImageFlowView
//
//  Created by Joseph Kain on 2/1/12.
//  Copyright (c) 2012 Joseph Kain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKImageFlowItem.h"

@interface FlowItem : NSObject <JKImageFlowItem> {
    NSString *filePath;
}

- (id)initWithPath:(NSString *)aPath;
@end
