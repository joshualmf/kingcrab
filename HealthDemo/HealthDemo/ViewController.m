//
//  ViewController.m
//  HealthDemo
//
//  Created by Joshua on 2018/3/30.
//  Copyright © 2018年 Octopus. All rights reserved.
//

#import "ViewController.h"

#import <CoreMotion/CoreMotion.h>


@interface ViewController ()
{
//    CMPedometer pedometer;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    UILabel *title1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
    title1.text = @"今日步数";
    title1.font = [UIFont systemFontOfSize:37];
    title1.center = CGPointMake(self.view.frame.size.width/2, 100);
    
    self.totalCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
    self.totalCount.text = @"--";
    self.totalCount.font = [UIFont systemFontOfSize:34];
    self.totalCount.textColor = [UIColor redColor];
    self.totalCount.center = CGPointMake(self.view.frame.size.width/2, 155);

    
    UILabel *title2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
    title2.text = @"iPhone记步";
    title2.font = [UIFont systemFontOfSize:37];
    title2.center = CGPointMake(self.view.frame.size.width/2, 250 + 40);

    self.iPhoneCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
    self.iPhoneCount.text = @"--";
    self.iPhoneCount.font = [UIFont systemFontOfSize:34];
    self.iPhoneCount.textColor = [UIColor redColor];
    self.iPhoneCount.center = CGPointMake(self.view.frame.size.width/2, 360);
    
    [self.view addSubview:title1];
    [self.view addSubview:title2];
    [self.view addSubview:self.iPhoneCount];
    [self.view addSubview:self.totalCount];
    
    [self methodOne];
}

//=================================================
//=================================================
//===================Method 1======================
//=================================================
//=================================================

//需要读权限的集合
- (NSSet *)dataTypesRead
{
    HKQuantityType *stepCountType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *walkingRunningType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKQuantityType *cycleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];
    HKQuantityType *basalEnergyType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBasalEnergyBurned];
    HKQuantityType *activeEnergyType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *flightClimb = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
    HKQuantityType *heartRate = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKCategoryType *standHour = [HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierAppleStandHour];
    HKWorkoutType *workOut = [HKWorkoutType workoutType];
    return [NSSet setWithObjects:stepCountType, walkingRunningType,cycleType,basalEnergyType,activeEnergyType,flightClimb,standHour,heartRate,workOut,nil];
}

//需要写权限的集合
- (NSSet *)dataTypesToWrite
{
    
    HKQuantityType *stepCountType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *walkingRunningType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKQuantityType *cycleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];
    HKQuantityType *activeEnergyType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    
    //    HKQuantityTypeIdentifierStepCount 步数
    //    HKQuantityTypeIdentifierDistanceCycling 骑车距离
    //    HKQuantityTypeIdentifierActiveEnergyBurned 活动能量
    //    HKQuantityTypeIdentifierDistanceWalkingRunning 步行+跑步距离
    return [NSSet setWithObjects:activeEnergyType,stepCountType,walkingRunningType,cycleType,nil];
    
    
}

- (void)methodOne
{
    //查看healthKit在设备上是否可用，ipad不支持HealthKit
    if(![HKHealthStore isHealthDataAvailable])
    {
        NSLog(@"设备不支持healthKit");
    }
    
    //创建healthStore实例对象
    self.healthStore = [[HKHealthStore alloc] init];
    
    //设置需要获取的权限这里仅设置了步数
    HKObjectType *stepCount = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    NSSet *healthSet = [NSSet setWithObjects:stepCount, nil];
    
    //从健康应用中获取权限
    [self.healthStore requestAuthorizationToShareTypes:[self dataTypesToWrite] readTypes:[self dataTypesRead] completion:^(BOOL success, NSError * _Nullable error) {
        if (success)
        {
            NSLog(@"获取步数权限成功");
            //获取步数后我们调用获取步数的方法
            //[self readStepCount];
            [self readStepCountTwo];
        }
        else
        {
            NSLog(@"获取步数权限失败");
        }
    }];
}

//查询数据
- (void)readStepCount
{
    //HKQuantityTypeIdentifierStepCount 计算步数
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    //排序规则
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    //HKObjectQueryNoLimit 数量限制
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:stepType predicate:[self predicateForSamplesToday] limit:HKObjectQueryNoLimit sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if(error)
        {
            //completion(0,error);
        }
        else
        {
            NSInteger totleSteps = 0;
            double sumTime = 0;
            //获取数组
            for(HKQuantitySample *quantitySample in results){
                HKQuantity *quantity = quantitySample.quantity;
                HKUnit *heightUnit = [HKUnit countUnit];
                double usersHeight = [quantity doubleValueForUnit:heightUnit];
                NSLog(@"%f",usersHeight);
                totleSteps += usersHeight;
                
                NSDateFormatter *fm=[[NSDateFormatter alloc]init];
                fm.dateFormat=@"yyyy-MM-dd HH:mm:ss";
                NSString *strNeedStart = [fm stringFromDate:quantitySample.startDate];
                NSLog(@"startDate %@",strNeedStart);
                NSString *strNeedEnd = [fm stringFromDate:quantitySample.endDate];
                NSLog(@"endDate %@",strNeedEnd);
                sumTime += [quantitySample.endDate timeIntervalSinceDate:quantitySample.startDate];
            }
            NSLog(@"当天行走步数 = %ld",(long)totleSteps);
            dispatch_async(dispatch_get_main_queue(), ^{
                //
                self.totalCount.text = [NSString stringWithFormat:@"%ld", totleSteps];
            });
            int h = sumTime / 3600;
            int m = ((long)sumTime % 3600)/60;
            NSLog(@"运动时长：%@小时%@分", @(h), @(m));
            //completion(totleSteps,error);
        }
    }];
    
    [self.healthStore executeQuery:query];
}

- (void)readStepCountTwo
{
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = 1;
    HKStatisticsCollectionQuery *collectionQuery = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:[self predicateForSamplesToday] options: HKStatisticsOptionCumulativeSum | HKStatisticsOptionSeparateBySource anchorDate:[NSDate dateWithTimeIntervalSince1970:0] intervalComponents:dateComponents];
    collectionQuery.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection * __nullable result, NSError * __nullable error) {
        double totalSum = 0.0f;
        double iPhoneSum = 0.0f;
        for (HKStatistics *statistic in result.statistics) {
            NSLog(@"\n%@ 至 %@", statistic.startDate, statistic.endDate);
            for (HKSource *source in statistic.sources) {
                if ([source.name isEqualToString:[UIDevice currentDevice].name]) {
                    //NSLog(@"%@ -- %f",source, [[statistic sumQuantityForSource:source] doubleValueForUnit:[HKUnit countUnit]]);
                    iPhoneSum += [[statistic sumQuantityForSource:source] doubleValueForUnit:[HKUnit countUnit]];
                    
                }
                totalSum += [[statistic sumQuantityForSource:source] doubleValueForUnit:[HKUnit countUnit]];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //
            self.iPhoneCount.text = [NSString stringWithFormat:@"%ld", (long)iPhoneSum];
            self.totalCount.text = [NSString stringWithFormat:@"%ld", (long)totalSum];
        });

    };
    [self.healthStore executeQuery:collectionQuery];
}

- (NSPredicate *)predicateForSamplesToday {
    //获取日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //获取当前时间
    NSDate *now = [NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:now];
    //设置为0
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    //设为开始时间
    NSDate *startDate = [calendar dateFromComponents:components];
    //把开始时间之后推一天为结束时间
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    //设置开始时间和结束时间为一段时间
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    return predicate;
}

- (IBAction)buttonPressed
{
    [self readStepCount];
    //[self saveStepCount:10000];
//    [self saveWalkingDis:9000];
}

//=================================================
//=================================================
//=================================================
//=================================================

//=================================================
//=================Mehtod 2========================
//=================================================
//=================================================

//- (void)methodTwo
//{
//    if ([CMPedometer isStepCountingAvailable]) {
//        //      NSLog(@"%f",[self dateCreat]);
//        NSInteger number = [self dateCreat];
//        NSLog(@"%ld",(long)number);
//        [pedometer queryPedometerDataFromDate:[NSDate dateWithTimeIntervalSinceNow:[self dateCreat]] toDate:[NSDate date] withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
//
//            NSLog(@"步数====%@",pedometerData.numberOfSteps);
//            NSLog(@"距离====%@",pedometerData.distance);
//            NSLog(@"开始时间====%@",pedometerData.startDate);
//        }
//         }];
//    } else {
//        NSLog(@"记步功能不可用");
//    }
//}
//
//- (void)dateCreat
//{
//
//}


- (void)saveStepCount:(double)stepCount {
    
    //create sample
    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantity *stepQuantity = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:stepCount];
    
    //sample date
    NSDate *today = [NSDate date];
    
    //create sample
    HKQuantitySample *stepSample = [HKQuantitySample quantitySampleWithType:stepType quantity:stepQuantity startDate:today endDate:today];
    
    //save objects to health kit
    [self.healthStore saveObject:stepSample withCompletion:^(BOOL success, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success) {
                
                NSLog(@"Successfully saved objects to health kit");
                
            } else {
                
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                
            }
            
        });
        
    }];
}

- (void)saveWalkingDis:(double)dis {
    
    
    //create sample
    HKQuantityType *disType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKQuantity *disQuantity = [HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue:dis];
    
    //sample date
    NSDate *today = [NSDate date];
    
    //create sample
    HKQuantitySample *stepSample = [HKQuantitySample quantitySampleWithType:disType quantity:disQuantity startDate:today endDate:today];
    
    //save objects to health kit
    [self.healthStore saveObject:stepSample withCompletion:^(BOOL success, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success) {
                
                NSLog(@"Successfully saved objects to health kit");
                
            } else {
                
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                
            }
            
        });
        
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
