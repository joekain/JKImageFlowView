//
//  AppDelegate.h
//  JKImageFlowViewTest
//
//  Created by Joseph Kain on 7/3/12.
//  Copyright (c) 2012 Joseph Kain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKImageFlowView.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    NSArray *images;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@property (strong, nonatomic) IBOutlet JKImageFlowView *flowView;
@property (strong, nonatomic) IBOutlet UILabel *label;

@end
