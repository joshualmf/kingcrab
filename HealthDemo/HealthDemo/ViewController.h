//
//  ViewController.h
//  HealthDemo
//
//  Created by Joshua on 2018/3/30.
//  Copyright © 2018年 Octopus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) HKHealthStore *healthStore;

@property (nonatomic, strong) UILabel *iPhoneCount;

@property (nonatomic, strong) UILabel *totalCount;
@end

