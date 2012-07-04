//
//  ViewController.h
//  JKImageFlowViewTest
//
//  Created by Joseph Kain on 7/3/12.
//  Copyright (c) 2012 Joseph Kain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKImageFlowView.h"

@interface ViewController : UIViewController <JKImageFlowDataSource,
                                              JKImageFlowDelegate> {
    NSArray *images;
}
@property (strong, nonatomic) IBOutlet JKImageFlowView *flowView;
@property (strong, nonatomic) IBOutlet UILabel *label;

@end
