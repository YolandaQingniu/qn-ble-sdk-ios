//
//  QingNiuSDK.h
//  QingNiuSDK
//
//  Created by pengyunfei on 15/12/21.
//  Copyright © 2015年 qingniu. All rights reserved.
//

/*  QingNiuSDKVersion
 *  3.10.4
 *  添加新设备
 */

#import <Foundation/Foundation.h>
#import "QingNiuDevice.h"
@class QingNiuUser;

typedef NS_ENUM(NSInteger,QingNiuRegisterAppState) {//注册app状态
    QingNiuRegisterAppStateSuccess = 0,//成功
    QingNiuRegisterAppStateFailParamsError = 1,//注册失败
    QingNiuRegisterAppStateFailVersionTooLow = 2,//版本号过低或过高，需要新的SDK请联系客服
};


//验证app的block，将状态返回
typedef void(^RegisterAppBlock)(QingNiuRegisterAppState qingNiuRegisterAppState);

@interface QingNiuSDK : NSObject

/*! @brief 设置打印开关。
 *
 * @param logFlag 打印开关
 */
+(void)setLogFlag:(BOOL)logFlag;

/*! @brief 设置体重单位(请在测量之前调用此方法，不设置默认为kg)
 *
 * @param qingNiuWeightUnit 体重单位
 */
+(void)setWeightUnit:(QingNiuWeightUnit)qingNiuWeightUnit;


/**
 设置用户资料，用于在测量过程中，切换用户
 
 @param qingNiuUser 用户资料
 @param block 设置是否成功
 */
+ (void)setUser:(QingNiuUser *)qingNiuUser response:(void (^)(BOOL success, NSError *error))block;

/**
 是否开始体脂率稳定算法,默认为YES开始

 @param enable 启动稳定算法
 */
+ (void)setSteadyBodyfat:(BOOL)enable;

/**
 获取当前设置的体重单位
 
 @param block 获取结果的回调
 */
+ (void)getCurrentWeightUnit:(void (^)(QingNiuWeightUnit qingNiuWeightUnit))block;

/* @brief 向轻牛程序注册第三方应用。
 *
 * @attention 调用此方法时保证网络畅通，如果失败会导致蓝牙连接过程不可用
 * @param appid 轻牛开发者ID
 */
+(void)registerApp:(NSString *)appid registerAppBlock:(RegisterAppBlock)registerAppBlock;

/**
 开始蓝牙扫描。

 @param qingNiuDevice 若要指定扫描某个设备，初始化一个QingNiuDevice并且给name或者macAddress属性赋值，若不需要指定设备，则此参数传nil
 @param scanSuccessBlock 扫描成功之后回调的秤信息
 @param scanFailBlock 扫描失败之后回调的错误原因
 */
+(void)startBleScan:(QingNiuDevice *)qingNiuDevice scanSuccessBlock:(ScanSuccessBlock)scanSuccessBlock scanFailBlock:(ScanFailBlock)scanFailBlock;


/*! @brief 停止蓝牙扫描。
 *
 */
+(void)stopBleScan;

/**
 连接设备

 @param qingNiuDevice 传入之前扫描到的设备
 @param qingNiuUser 传入一个测量的用户资料(传入对象属性说明请参考类：QingNiuUser)
 @param batteryLowBlock 低电压的回调
 @param connectSuccessBlock 连接成功之后回调的数据，实时测量的时候只有一条deviceData，收存储数据时若有多条会回传多条deviceData
 @param connectFailBlock 连接失败之后回调的错误原因
 */
+ (void)connectDevice:(QingNiuDevice *)qingNiuDevice user:(QingNiuUser *)qingNiuUser onLowPowerBlock:(BatteryLowBlock)batteryLowBlock connectSuccessBlock:(ConnectSuccessBlock)connectSuccessBlock connectFailBlock:(ConnectFailBlock)connectFailBlock;

/**
 通过广播连接设备(如果想自己实现设备的扫描，可调用此方法，将扫描到的外设对象和广播包作为参数)

 @param advertisementData 扫描设备成功后得到的广播包
 @param peripheral 扫描到的外设对象
 @param centralManager 中心管理者
 @param qingNiuUser 传入一个测量的用户资料(传入对象属性说明请参考类：QingNiuUser)
 @param batteryLowBlock 低电压的回调
 @param connectSuccessBlock 连接成功之后回调的数据，实时测量的时候只有一条deviceData，收存储数据时若有多条会回传多条deviceData
 @param connectFailBlock 连接失败之后回调的错误原因
 */
+ (void)connectWithAdvertisementData:(NSDictionary *)advertisementData peripheral:(CBPeripheral *)peripheral centralManager:(CBCentralManager *)centralManager user:(QingNiuUser *)qingNiuUser onLowPowerBlock:(BatteryLowBlock)batteryLowBlock connectSuccessBlock:(ConnectSuccessBlock)connectSuccessBlock connectFailBlock:(ConnectFailBlock)connectFailBlock;


/**
 断开与设备的连接

 @param qingNiuDevice 传入需要断开的设备
 @param disconnectFailBlock 断开连接失败
 @param disconnectSuccessBlock 断开连接成功
 */
+ (void)cancelConnect:(QingNiuDevice *)qingNiuDevice disconnectFailBlock:(DisconnectFailBlock)disconnectFailBlock disconnectSuccessBlock:(DisconnectSuccessBlock)disconnectSuccessBlock;

/*! @brief 清除缓存。
 *
 * @attention app切换用户登录时可以调用此方法，确保接收设备存储数据时不会出现数据混乱
 */
+ (void)clearCache;

/**
 连接设备获取数据的简便方法。

 @param qingNiuUser 传入一个测量的用户资料(传入对象属性说明请参考类：QingNiuUser)
 @param scanFailBlock 返回在扫描过程中失败的信息(如果失败则不会进行后续的连接动作)
 @param batteryLowBlock 低电压的回调
 @param connectSuccessBlock 连接成功之后回调的数据，实时测量的时候只有一条deviceData，该方法不接收存储数据
 @param connectFailBlock 连接失败之后回调的错误原因
 */
+ (void)simpleGetData:(QingNiuUser *)qingNiuUser scanFailBlock:(ScanFailBlock)scanFailBlock onLowPowerBlock:(BatteryLowBlock)batteryLowBlock connectSuccessBlock:(ConnectSuccessBlock)connectSuccessBlock connectFailBlock:(ConnectFailBlock)connectFailBlock;

@end
