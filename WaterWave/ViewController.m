//
//  ViewController.m
//  WaterWave
//
//  Created by sunhong on 16/6/21.
//  Copyright © 2016年 Sunhong. All rights reserved.
//

#import "ViewController.h"
#import "WaterWaveView.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign) CGFloat       preOffsetX;

@end

@implementation ViewController{
    WaterWaveView *waterView;
    UITableView *scrollTable;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    /**<  滚动试图  >**/
    [self setupScrollView];
}
/**
 *  创建滚动试图
 */
- (void)setupScrollView {
    CGFloat xPiex = 0;
    CGFloat yPiex = 100;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGRect scrollFrame = CGRectMake(xPiex, yPiex, width, height);
    
    scrollTable = [[UITableView alloc] initWithFrame:scrollFrame];
    scrollTable.backgroundColor = [UIColor clearColor];
    scrollTable.delegate = self;
    scrollTable.dataSource = self;
    scrollTable.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:scrollTable];
}

/**
 *   创建水波纹
 */
- (void)setupWaterView {
    CGFloat xPiex = 0;
    CGFloat height = 100;
    CGFloat yPiex = -height;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGRect waterFrame = CGRectMake(xPiex, yPiex, width, height);
    
    waterView = [[WaterWaveView alloc]initWithFrame:waterFrame];
    [scrollTable addSubview:waterView];
//        waterView.layer.cornerRadius  = waterView.frame.size.width / 2;
    waterView.waveSpeed = 3.0f;//根据滑动幅度更改
    waterView.waveAmplitude = 6.0f;//3
}


#pragma mark - tableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld行",indexPath.row];
    return cell;
}

#pragma mark - UIScrollViewDelegate
// 当开始滚动视图时，执行该方法。一次有效滑动（开始滑动，滑动一小段距离，只要手指不松开，只算一次滑动），只执行一次。
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"WillBeginDragging");
    [self setupWaterView];
    [waterView wave];
}

// 滑动视图，当手指离开屏幕那一霎那，调用该方法。一次有效滑动，只执行一次。
// decelerate 手指离开那一瞬后，视图是否还将继续向前滚动（一段距离），经过测试，decelerate=YES
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"DidEndDragging");
    [waterView stop];
    [waterView removeFromSuperview];
    waterView = nil;
}

//scrollView滚动时，就调用该方法。任何offset值改变都调用该方法。即滚动过程中，调用多次
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (waterView == nil) {
        return;
    }
    //改变速度
    CGFloat yOffset = scrollView.contentOffset.y;
    CGFloat interYpiex = yOffset - _preOffsetX;
    _preOffsetX = yOffset;
    
    CGFloat ratio = fabs(interYpiex);
    CGFloat amplitude = ratio;
    CGFloat waveSpeed = ratio * 0.5;
    /**
     *  当waveAmplitude＝6时，波纹比较明显
     *  当waveAmplitude＝3时，波纹趋于平缓（当手指不移动，或者缓慢移动）
     *  需要随着位移&&滑动速度——》改变波动大小
     */
    if (waterView.waveAmplitude > 9.0f) {
        return;
    }
    if (ratio < 3.0f) {
        amplitude = 3.0f;
        waveSpeed = 1.5f;
    } else if (ratio < 6.0) {
        amplitude = 6.0f;
        waveSpeed = 3.0f;
    } else {
        amplitude = 12.0f;
        waveSpeed = 3.0f;
    }
    
    //当偏移量较小时，限制振幅，防止振幅过大，遮挡其他空间
    if (yOffset > -20) {
        amplitude = 1.5f;
        waveSpeed = 1.0f;
    } else if (ratio < 3.0f) {
        amplitude = 6.0f;
        waveSpeed = 3.0f;
    }
    
    waterView.waveAmplitude = amplitude;
    waterView.waveSpeed = waveSpeed;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
