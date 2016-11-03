//
//  QingNiuDevice.h
//  SDKTest
//
//  Created by pengyunfei on 15/12/24.
//  Copyright © 2015年 qingniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@class QingNiuPeripheral;
@class QingNiuDevice;

typedef NS_ENUM(NSInteger,QingNiuScanDeviceFail) {//扫描设备失败
    QingNiuScanDeviceFailUnsupported = 0,//不支持蓝牙4.0
    QingNiuScanDeviceFailPoweredOff = 1,//蓝牙关闭
    QingNiuScanDeviceFailValidationFailure = 2,//app验证失败(原因可能是之前registerApp失败，或者过期时间已到，需要重新调用registerApp方法)
    QingNiuScanDevicePoweredOn = 3,//蓝牙开启(这不是扫描失败情况下的枚举，为了跟以前的版本兼容，不另外添加枚举)
};

typedef NS_ENUM(NSInteger,QingNiuDeviceConnectState) {//连接过程中的各种状态
    QingNiuDeviceConnectStateParamsError = 0,//传入连接参数错误(重新扫描或重新初始化QingNiuUser再连接)
    QingNiuDeviceConnectStateConnectFail = 1,//连接设备失败(重新连接或重新扫描再连接)
    QingNiuDeviceConnectStateDiscoverFail = 2,//查找设备的服务或者特性失败(重新连接)
    QingNiuDeviceConnectStateDataError = 3,//接收到的数据出错(重新连接)
    QingNiuDeviceConnectStateLowPower = 4,//设备低电
    QingNiuDeviceConnectStateIsWeighting = 5,//正在测量
    QingNiuDeviceConnectStateWeightOver = 6,//测量完毕
    QingNiuDeviceConnectStateIsGettingSavedData = 7,//正在获取存储数据
    QingNiuDeviceConnectStateGetSavedDataOver = 8,//获取完所有的存储数据(此时deviceData的值为nil)
    QingNiuDeviceConnectStateDisConnected = 9,//测量完毕之后自动断开了连接(此时deviceData为nil)
    QingNiuDeviceConnectStateConnectedSuccess = 10,//连接成功时候的回调(此时deviceData为nil)
};

typedef NS_ENUM(NSInteger,QingNiuDeviceDisconnectState) {//断开连接的各种状态
    QingNiuDeviceDisconnectStateDisConnectSuccess = 0,//手动断开断开连接成功
    QingNiuDeviceDisconnectStateParamsError = 1,//传入连接参数错误(比如外设为空)
    QingNiuDeviceDisconnectStateIsDisConnected = 2,//已经处于断开的状态
};

//扫描成功的block，将成功之后的设备返回
typedef void(^ScanSuccessBlock)(QingNiuDevice *qingNiuDevice);
//扫描失败的block，将失败之后的原因返回
typedef void(^ScanFailBlock)(QingNiuScanDeviceFail qingNiuScanDeviceFail);

//连接成功的block，将成功之后的测量数据返回
typedef void(^ConnectSuccessBlock)(NSMutableDictionary *deviceData,QingNiuDeviceConnectState qingNiuDeviceConnectState);
//连接失败的block，将失败之后的原因返回
typedef void(^ConnectFailBlock)(QingNiuDeviceConnectState qingNiuDeviceConnectState);

//断开连接失败
typedef void(^DisconnectFailBlock)(QingNiuDeviceDisconnectState qingNiuDeviceDisconnectState);
//断开连接成功
typedef void(^DisconnectSuccessBlock)(QingNiuDeviceDisconnectState qingNiuDeviceDisconnectState);




typedef NS_ENUM(NSUInteger,QingNiuMethod) {
    QingNiuMethodHealthScale = 1,//体重
    QingNiuMethodTwoElectrode = 2,//两
    QingNiuMethodFourElectrode = 3,//四
};

@interface QingNiuDevice : NSObject

//设备的mac地址(设备的唯一标识)
@property (nonatomic,strong)NSString *macAddress;
//设备的名称
@property (nonatomic,strong)NSString *name;
//设备内部型号
@property (nonatomic,strong)NSString *internalModel;
//设备显示型号
@property (nonatomic,strong)NSString *model;
//设备的对象
@property (nonatomic,strong)CBPeripheral *peripheral;
//方法(内部使用，可不管)
@property (nonatomic,assign)QingNiuMethod method;

@end
