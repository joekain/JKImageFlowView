//
//  JKImageFlowItem.h
//  JKImageFlowView
//
//  Created by Joseph Kain on 2/1/12.
//  Copyright (c) 2012 Joseph Kain. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const JKImageBrowserPathRepresentationType;
extern NSString * const JKImageBrowserNSURLRepresentationType;
extern NSString * const JKImageBrowserNSImageRepresentationType;
extern NSString * const JKImageBrowserNSDataRepresentationType;
extern NSString * const JKImageBrowserNSBitmapImageRepresentationType;

@protocol JKImageFlowItem <NSObject>

@required

- (NSString *) imageUID;
- (NSString *) imageRepresentationType;
- (id) imageRepresentation;

@optional

- (NSUInteger) imageVersion;
- (NSString *) imageSubtitle;
- (NSString *) imageTitle;
- (BOOL) isSelectable;

@end
