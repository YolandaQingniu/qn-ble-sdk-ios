//
//  ViewController.m
//  SDKTest
//
//  Created by pengyunfei on 15/12/22.
//  Copyright © 2015年 qingniu. All rights reserved.
//

#define kScreenBounds [UIScreen mainScreen].bounds

#import "ViewController.h"
#import "QingNiuSDK.h"
#import "QingNiuDevice.h"
#import "QingNiuUser.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UIView *_headView;
    UITextField *_idTextField;
    UITextField *_heightTextField;
    UIButton *_maleButton;
    UIButton *_femaleButton;
    NSString *_gender;
    UITextField *_birthdayTextField;
    //    UITextField *_idTextField;
    
    UIButton *_scanButton;
    
    NSMutableArray *_allScanDevice;
    NSMutableArray *_deviceData;
    NSDictionary *_deviceDataDic;
    UITableView *_tableView;
    BOOL _scanFlag;
    QingNiuWeightUnit _qingNiuWeightUnit;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7 ) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    
    _allScanDevice = [NSMutableArray array];
    _deviceData = [NSMutableArray array];
    
    [self addHeadViews];
    
    [self addTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //一般来说如果该ViewController是测量界面，那么在该方法里面就调用扫描方法
    [self scanBle:_scanButton];
}

#pragma mark 添加头部views
- (void)addHeadViews
{
    _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBounds.size.width, 110)];
    [self.view addSubview:_headView];
    
    CGFloat subViewsHeight = 30;
    UILabel *idLabel = [self createLabelWithFrame:CGRectMake(0, 0, 20, subViewsHeight) andTitle:@"id:" onView:_headView];
    _idTextField = [self createTextFieldWithFrame:CGRectMake(CGRectGetMaxX(idLabel.frame), CGRectGetMinY(idLabel.frame), 60, subViewsHeight) andText:@"pyf" onSuperView:_headView];
    
    UILabel *heightLabel = [self createLabelWithFrame:CGRectMake(CGRectGetMaxX(_idTextField.frame) + 10, CGRectGetMinY(_idTextField.frame), 40, subViewsHeight) andTitle:@"身高:" onView:_headView];
    _heightTextField = [self createTextFieldWithFrame:CGRectMake(CGRectGetMaxX(heightLabel.frame), CGRectGetMinY(heightLabel.frame), 60, subViewsHeight) andText:@"176" onSuperView:_headView];
    
    UILabel *genderLabel = [self createLabelWithFrame:CGRectMake(CGRectGetMaxX(_heightTextField.frame) + 10, CGRectGetMinY(_heightTextField.frame), 40, subViewsHeight) andTitle:@"性别:" onView:_headView];
    _maleButton = [self createButtonWithFrame:CGRectMake(CGRectGetMaxX(genderLabel.frame), CGRectGetMinY(genderLabel.frame) + 5, 40, 20) andTitle:@"男" andSelector:@selector(chooseGender:) onSuperView:_headView];
    _maleButton.tag = 3;
    
    _femaleButton = [self createButtonWithFrame:CGRectMake(CGRectGetMaxX(_maleButton.frame), CGRectGetMinY(_maleButton.frame), 40, 20) andTitle:@"女" andSelector:@selector(chooseGender:) onSuperView:_headView];
    _femaleButton.tag = 4;
    
    [self chooseGender:_maleButton];
    
    UILabel *birthdayLabel = [self createLabelWithFrame:CGRectMake(0, CGRectGetMaxY(idLabel.frame) + 10, 40, subViewsHeight) andTitle:@"生日:" onView:_headView];
    _birthdayTextField = [self createTextFieldWithFrame:CGRectMake(CGRectGetMaxX(birthdayLabel.frame), CGRectGetMinY(birthdayLabel.frame), 110, subViewsHeight) andText:@"1992-01-10" onSuperView:_headView];
    
    CGFloat scanButtonWidth = 80;
    _scanButton = [self createButtonWithFrame:CGRectMake(CGRectGetMaxX(_femaleButton.frame) - scanButtonWidth, CGRectGetMinY(_birthdayTextField.frame), scanButtonWidth, subViewsHeight) andTitle:@"开始扫描" andSelector:@selector(scanBle:) onSuperView:_headView];
    _scanButton.tag = 2;
    
    UILabel *unitChoiceLabel = [self createLabelWithFrame:CGRectMake(0, CGRectGetMaxY(birthdayLabel.frame) + 10, 100, subViewsHeight) andTitle:@"显示的单位:" onView:_headView];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"kg",@"lb",@"斤"]];
    
    [QingNiuSDK getCurrentWeightUnit:^(QingNiuWeightUnit qingNiuWeightUnit) {
        _qingNiuWeightUnit = qingNiuWeightUnit;
        segmentedControl.selectedSegmentIndex = _qingNiuWeightUnit;
    }];
    
    segmentedControl.frame = CGRectMake(CGRectGetMaxX(unitChoiceLabel.frame), CGRectGetMinY(unitChoiceLabel.frame), 200, 20);
    [segmentedControl addTarget:self action:@selector(segmentedControlClick:) forControlEvents:UIControlEventValueChanged];
    [_headView addSubview:segmentedControl];
    
}

- (void)segmentedControlClick:(UISegmentedControl *)segmentedControl{
    NSInteger index = segmentedControl.selectedSegmentIndex;
    switch (index) {
        case 0:
            _qingNiuWeightUnit = QingNiuRegisterWeightUnitKg;
            break;
        case 1:
            _qingNiuWeightUnit = QingNiuRegisterWeightUnitLb;
            break;
        case 2:
            _qingNiuWeightUnit = QingNiuRegisterWeightUnitJin;
            break;
        default:
            break;
    }
    //设置测量单位
    [QingNiuSDK setWeightUnit:_qingNiuWeightUnit];
}

- (void)chooseGender:(UIButton *)button
{
    button.backgroundColor = [UIColor lightGrayColor];
    if (button.tag == 3) {
        _femaleButton.backgroundColor = [UIColor whiteColor];
        _gender = @"1";
    }else {
        _maleButton.backgroundColor = [UIColor whiteColor];
        _gender = @"0";
    }
}

#pragma mark 添加tableView
- (void)addTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headView.frame), kScreenBounds.size.width, kScreenBounds.size.height - CGRectGetMaxY(_headView.frame) - 64) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

#pragma mark 扫描
- (void)scanBle:(UIButton *)button
{
    if (button.tag == 1) {
        [button setTitle:@"停止扫描" forState:UIControlStateNormal];
        button.tag = 2;
        [QingNiuSDK startBleScan:nil scanSuccessBlock:^(QingNiuDevice *qingNiuDevice) {
            if (qingNiuDevice.deviceState == QingNiuDeviceStatePoweredOff) {
                NSLog(@"关机");
            }else {
                NSLog(@"开机");
            }
            NSLog(@"%@",qingNiuDevice);
            if (_allScanDevice.count == 0) {
                [_allScanDevice insertObject:qingNiuDevice atIndex:0];
            }else {
                for (int i = 0; i<_allScanDevice.count; i++) {
                    QingNiuDevice *savedDevice = _allScanDevice[i];
                    if ([savedDevice.macAddress isEqualToString:qingNiuDevice.macAddress]) {
                        break;
                    }else if (i == _allScanDevice.count - 1){
                        [_allScanDevice insertObject:qingNiuDevice atIndex:0];
                        break;
                    }
                }
            }
            _scanFlag = YES;
            [_tableView reloadData];
        } scanFailBlock:^(QingNiuScanDeviceFail qingNiuScanDeviceFail) {
            NSLog(@"%ld",(long)qingNiuScanDeviceFail);
            //            if (qingNiuScanDeviceFail == QingNiuScanDeviceFailValidationFailure) {
            //                [QingNiuSDK registerApp:@"123456789" andReleaseModeFlag:NO registerAppBlock:^(QingNiuRegisterAppState qingNiuRegisterAppState) {
            //                    NSLog(@"%ld",(long)qingNiuRegisterAppState);
            //                }];
            //            }
        }];
    }else {//申明：在实际开发过程当中，如果扫描到设备就连接的话，停止扫描方法可不调用，因为连接方法会停止扫描
        [button setTitle:@"开始扫描" forState:UIControlStateNormal];
        button.tag = 1;
        [QingNiuSDK stopBleScan];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_scanFlag) {
        return _allScanDevice.count;
    }else {
        return _deviceData.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_scanFlag) {
        static NSString *deviceCell = @"DeviceCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:deviceCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:deviceCell];
        }
        QingNiuDevice *qingNiuDevice = _allScanDevice[indexPath.row];
        cell.textLabel.text = qingNiuDevice.name;
        cell.detailTextLabel.text = qingNiuDevice.macAddress;
        return cell;
    } else {
        static NSString *deviceDataCell = @"DeviceDataCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:deviceDataCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:deviceDataCell];
        }
        NSDictionary *oneIndex = _deviceData[indexPath.row];
        cell.textLabel.text = oneIndex[@"name"];
        
        if (oneIndex[@"unit"] == nil) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",oneIndex[@"value"]];
        }else{
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@",oneIndex[@"value"],oneIndex[@"unit"]];
        }
        
        return cell;
    }
}

#pragma mark 点击其中一行开始连接
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_scanFlag) {
        QingNiuDevice *qingNiuDevice = _allScanDevice[indexPath.row];
        if (qingNiuDevice.deviceState == QingNiuDeviceStatePoweredOff) {
            NSLog(@"秤处于关机状态");
        }
        QingNiuUser *user = [[QingNiuUser alloc] init];
        user.userId = _idTextField.text;
        user.height = [_heightTextField.text intValue];
        user.gender = [_gender intValue];
        user.birthday = _birthdayTextField.text;
        [QingNiuSDK connectDevice:qingNiuDevice user:user connectSuccessBlock:^(NSMutableDictionary *deviceData, QingNiuDeviceConnectState qingNiuDeviceConnectState) {
            if (qingNiuDeviceConnectState == QingNiuDeviceConnectStateConnectedSuccess) {
                [self scanBle:_scanButton];
                NSLog(@"连接成功%@",deviceData);
            }
            else if (qingNiuDeviceConnectState == QingNiuDeviceConnectStateIsWeighting) {
                NSLog(@"实时体重：%@",deviceData[@"weight"]);
            }else if (qingNiuDeviceConnectState == QingNiuDeviceConnectStateWeightOver){
                NSLog(@"测量完毕：%@",deviceData);
            }else if (qingNiuDeviceConnectState == QingNiuDeviceConnectStateIsGettingSavedData){
                NSLog(@"正在获取存储数据：%@",deviceData);
            }else if (qingNiuDeviceConnectState == QingNiuDeviceConnectStateGetSavedDataOver){
                NSLog(@"存储数据接收完毕：%@",deviceData);
            }else if (qingNiuDeviceConnectState == QingNiuDeviceConnectStateDisConnected) {
                /*
                 1、如果用户需要连续测量，那么就在这里开启一个定时器启动扫描，该方法是在轻牛app里面采用的方式
                 [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(scanBleAgain) userInfo:nil repeats:NO];
                 2、如果确保qingNiuDevice对象没有改变，那么可以直接调用connectDevice:方法
                 */
                NSLog(@"自动断开连接%@",deviceData);
            }
            if (qingNiuDeviceConnectState == QingNiuDeviceConnectStateIsWeighting || qingNiuDeviceConnectState == QingNiuDeviceConnectStateWeightOver || qingNiuDeviceConnectState == QingNiuDeviceConnectStateIsGettingSavedData) {
                [self getShowDeviceData:deviceData];
                _scanFlag = NO;
                [_tableView reloadData];
            }
        } connectFailBlock:^(QingNiuDeviceConnectState qingNiuDeviceConnectState) {
            NSLog(@"%ld",(long)qingNiuDeviceConnectState);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"连接失败" message:[NSString stringWithFormat:@"%@%ld",@"错误码：",(long)qingNiuDeviceConnectState] delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alertView show];
        }];
    }
}

- (NSMutableArray *)getShowDeviceData:(NSDictionary *)deviceData
{
    _deviceDataDic = deviceData;
    //其中 体年龄、肌肉量、去脂体重、体型不是一定会返回的 是某些第三方SDK接入商才有的
    [_deviceData removeAllObjects];
    if (deviceData[@"weight"] != nil) {
        [_deviceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"体重",@"name",deviceData[@"weight"],@"value",deviceData[@"weight_unit"],@"unit", nil]];
    }
    if (deviceData[@"bmi"] != nil) {
        [_deviceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"bmi",@"name",deviceData[@"bmi"],@"value",@"",@"unit", nil]];
    }
    if (deviceData[@"bodyfat"] != nil) {
        [_deviceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"脂肪率",@"name",deviceData[@"bodyfat"],@"value",@"%",@"unit", nil]];
    }
    if (deviceData[@"subfat"] != nil) {
        [_deviceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"皮下脂肪率",@"name",deviceData[@"subfat"],@"value",@"%",@"unit", nil]];
    }
    if (deviceData[@"visfat"] != nil) {
        [_deviceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"内脏脂肪等级",@"name",deviceData[@"visfat"],@"value",@"",@"unit", nil]];
    }
    if (deviceData[@"water"] != nil) {
        [_deviceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"体水分",@"name",deviceData[@"water"],@"value",@"%",@"unit", nil]];
    }
    if (deviceData[@"bmr"] != nil) {
        [_deviceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"基础代谢量",@"name",deviceData[@"bmr"],@"value",@"kcal",@"unit", nil]];
    }
    if (deviceData[@"muscle"] != nil) {
        [_deviceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"骨骼肌率",@"name",deviceData[@"muscle"],@"value",@"%",@"unit", nil]];
    }
    if (deviceData[@"bone"] != nil) {
        [_deviceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"骨量",@"name",deviceData[@"bone"],@"value",deviceData[@"weight_unit"],@"unit", nil]];
    }
    if (deviceData[@"protein"] != nil) {
        [_deviceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"蛋白质",@"name",deviceData[@"protein"],@"value",@"%",@"unit", nil]];
    }
    if (deviceData[@"bodyage"] != nil) {
        [_deviceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"体年龄",@"name",deviceData[@"bodyage"],@"value",@"岁",@"unit", nil]];
    }
    if (deviceData[@"sinew"] != nil) {
        if ([deviceData[@"sinew"] length] > 0) {
            [_deviceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"肌肉量",@"name",deviceData[@"sinew"],@"value",deviceData[@"weight_unit"],@"unit", nil]];
        }else{
            [_deviceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"肌肉量",@"name",deviceData[@"sinew"],@"value", nil]];
        }
    }
    if (deviceData[@"fat_free_weight"] != nil) {
        if ([deviceData[@"fat_free_weight"] length] > 0) {
            [_deviceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"去脂体重",@"name",deviceData[@"fat_free_weight"],@"value",deviceData[@"weight_unit"],@"unit", nil]];
        }else{
            [_deviceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"去脂体重",@"name",deviceData[@"fat_free_weight"],@"value", nil]];
        }
        
    }
    if (deviceData[@"body_shape"] != nil) {
        if ([deviceData[@"body_shape"] length] > 0) {
            [_deviceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"体型",@"name",[self getBodyShapeDescriptionWithBodyShape:deviceData[@"body_shape"]],@"value",@"",@"unit", nil]];
        }else{
            [_deviceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"体型",@"name",[self getBodyShapeDescriptionWithBodyShape:deviceData[@"body_shape"]],@"value", nil]];
        }
    }
    if (deviceData[@"score"] != nil) {
        if ([deviceData[@"score"] length] > 0) {
            [_deviceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"分数",@"name",deviceData[@"score"],@"value",@"",@"unit", nil]];
        }else{
            [_deviceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"分数",@"name",deviceData[@"score"],@"value", nil]];
        }
    }
    if (deviceData[@"resistance"] != nil) {
        if ([deviceData[@"resistance"] length] > 0) {
            [_deviceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"电阻",@"name",deviceData[@"resistance"],@"value",@"",@"unit", nil]];
        }else{
            [_deviceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"电阻",@"name",deviceData[@"resistance"],@"value", nil]];
        }
    }
    return _deviceData;
    
}

- (NSString *)getBodyShapeDescriptionWithBodyShape:(NSString *)bodyShape
{
    NSString *bodyShapeDescription = @"";
    if ([bodyShape intValue] == 1) {
        bodyShapeDescription = @"隐形肥胖型";
    }else if ([bodyShape intValue] == 2) {
        bodyShapeDescription = @"运动不足型";
    }else if ([bodyShape intValue] == 3) {
        bodyShapeDescription = @"偏瘦型";
    }else if ([bodyShape intValue] == 4) {
        bodyShapeDescription = @"标准型";
    }else if ([bodyShape intValue] == 5) {
        bodyShapeDescription = @"偏瘦肌肉型";
    }else if ([bodyShape intValue] == 6) {
        bodyShapeDescription = @"肥胖型";
    }else if ([bodyShape intValue] == 7) {
        bodyShapeDescription = @"偏胖型";
    }else if ([bodyShape intValue] == 8) {
        bodyShapeDescription = @"标准肌肉型";
    }else if ([bodyShape intValue] == 9) {
        bodyShapeDescription = @"非常肌肉型";
    }
    return bodyShapeDescription;
}

#pragma mark 再次扫描秤
- (void)scanBleAgain
{
    [self scanBle:_scanButton];
}

#pragma mark 创建Label
- (UILabel *)createLabelWithFrame:(CGRect)frame andTitle:(NSString *)title onView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = title;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    [view addSubview:label];
    return label;
}

#pragma mark 创建button
- (UIButton *)createButtonWithFrame:(CGRect)frame andTitle:(NSString *)title andSelector:(SEL)selectorName onSuperView:(UIView *)superView
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.backgroundColor = [UIColor lightGrayColor];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:selectorName forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:button];
    return button;
}

#pragma mark 创建textField
- (UITextField *)createTextFieldWithFrame:(CGRect)frame andText:(NSString *)text onSuperView:(UIView *)superView
{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.backgroundColor = [UIColor clearColor];
    textField.text = text;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [superView addSubview:textField];
    return textField;
}

#pragma mark 切换用户登录的时候，请调用该方法清除缓存(在轻牛app里面是不需要调用该方法的，因为切换用户会清楚所有数据)
- (void)clearCache
{
    [QingNiuSDK clearCache];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

/*
 轻牛app不调用该方法，直接等自动断开，除非工程中有中断连接的需求才调用该方法
 */
#pragma mark 断开连接
- (void)disconnect
{
    //_qingNiuDevice：连接的设备
    //    [QingNiuSDK cancelConnect:_qingNiuDevice disconnectFailBlock:^(QingNiuDeviceDisconnectState qingNiuDeviceDisconnectState) {
    //        NSLog(@"%ld",(long)qingNiuDeviceDisconnectState);
    //    } disconnectSuccessBlock:^(QingNiuDeviceDisconnectState qingNiuDeviceDisconnectState) {
    //        NSLog(@"%ld",(long)qingNiuDeviceDisconnectState);
    //    }];
}

#pragma mark - 以下两个方法是某个别公司的特殊要求，可不理会
#pragma mark 快速连接
- (void)simpleGetData
{
    QingNiuUser *user = [[QingNiuUser alloc] initUserWithUserId:@"pyf" andHeight:176 andGender:1 andBirthday:@"1992-01-10"];
    
    [QingNiuSDK simpleGetData:user scanFailBlock:^(QingNiuScanDeviceFail qingNiuScanDeviceFail) {
        NSLog(@"%ld",(long)qingNiuScanDeviceFail);
    } connectSuccessBlock:^(NSMutableDictionary *deviceData, QingNiuDeviceConnectState qingNiuDeviceConnectState) {
        if (qingNiuDeviceConnectState == QingNiuDeviceConnectStateIsWeighting) {
            NSLog(@"实时体重：%@",deviceData[@"weight"]);
        }else if (qingNiuDeviceConnectState == QingNiuDeviceConnectStateWeightOver){
            NSLog(@"完成：%@",deviceData);
        }
    } connectFailBlock:^(QingNiuDeviceConnectState qingNiuDeviceConnectState) {
        NSLog(@"%ld",(long)qingNiuDeviceConnectState);
    }];
}



@end
