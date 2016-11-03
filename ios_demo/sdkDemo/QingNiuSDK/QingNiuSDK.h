//
//  QingNiuSDK.h
//  QingNiuSDK
//
//  Created by pengyunfei on 15/12/21.
//  Copyright © 2015年 qingniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QingNiuDevice.h"
@class QingNiuUser;

typedef NS_ENUM(NSInteger,QingNiuRegisterAppState) {//注册app状态
    QingNiuRegisterAppStateSuccess = 0,//成功
    QingNiuRegisterAppStateFailParamsError = 1,//appid错误
    QingNiuRegisterAppStateFailVersionTooLow = 2,//版本号过低或过高，需要新的SDK请联系客服
};

//验证app的block，将状态返回
typedef void(^RegisterAppBlock)(QingNiuRegisterAppState qingNiuRegisterAppState);

@interface QingNiuSDK : NSObject

/*! @brief 向轻牛程序注册第三方应用。
 *
 * @attention 调用此方法时保证网络畅通，如果失败会导致蓝牙连接过程不可用
 * @param appid 轻牛开发者ID
 * @param releaseModeFlag 传入YES，则代表当前是发布模式，那么appid需要是轻牛官方提供的。传入NO：则代表当前是测试模式，appid可用@"123456789"进行测试
 */
+(void)registerApp:(NSString *)appid andReleaseModeFlag:(BOOL)releaseModeFlag registerAppBlock:(RegisterAppBlock)registerAppBlock;


/*! @brief 开始蓝牙扫描。
 *
 * @attention 如果不指定设备扫描，参数qingNiuDevice置为nil
 * @param qingNiuDevice：若要指定扫描某个设备，初始化一个QingNiuDevice并且给name或者macAddress属性赋值，若不需要指定设备，则此参数传nil
 * @param scanSuccessBlock 扫描成功之后回调的秤信息
 * @param scanFailBlock 扫描失败之后回调的错误原因
 */
+(void)startBleScan:(QingNiuDevice *)qingNiuDevice scanSuccessBlock:(ScanSuccessBlock)scanSuccessBlock scanFailBlock:(ScanFailBlock)scanFailBlock;


/*! @brief 停止蓝牙扫描。
 *
 */
+(void)stopBleScan;


/*! @brief 连接设备。
 *
 * @param qingNiuDevice：传入之前扫描到的设备
 * @param qingNiuUser：传入一个测量的用户资料(传入对象属性说明请参考类：QingNiuUser)
 * @param connectSuccessBlock 连接成功之后回调的数据，实时测量的时候只有一条deviceData，收存储数据时若有多条会回传多条deviceData
 * @param connectFailBlock 连接失败之后回调的错误原因
 */
+ (void)connectDevice:(QingNiuDevice *)qingNiuDevice user:(QingNiuUser *)qingNiuUser connectSuccessBlock:(ConnectSuccessBlock)connectSuccessBlock connectFailBlock:(ConnectFailBlock)connectFailBlock;

/*! @brief 通过广播连接设备(如果想自己实现设备的扫描，可调用此方法，将扫描到的外设对象和广播包作为参数)
 *
 * @param advertisementData：扫描设备成功后得到的广播包
 * @param peripheral：扫描到的外设对象
 * @param centralManager：中心管理者
 * @param qingNiuUser：传入一个测量的用户资料(传入对象属性说明请参考类：QingNiuUser)
 * @param connectSuccessBlock 连接成功之后回调的数据，实时测量的时候只有一条deviceData，收存储数据时若有多条会回传多条deviceData
 * @param connectFailBlock 连接失败之后回调的错误原因
 */
+ (void)connectWithAdvertisementData:(NSDictionary *)advertisementData peripheral:(CBPeripheral *)peripheral centralManager:(CBCentralManager *)centralManager user:(QingNiuUser *)qingNiuUser connectSuccessBlock:(ConnectSuccessBlock)connectSuccessBlock connectFailBlock:(ConnectFailBlock)connectFailBlock;

/*! @brief 断开与设备的连接。
 *
 * @param qingNiuDevice：传入需要断开的设备
 * @param disconnectFailBlock：断开连接失败
 * @param disconnectSuccessBlock：断开连接成功
 */
+ (void)cancelConnect:(QingNiuDevice *)qingNiuDevice disconnectFailBlock:(DisconnectFailBlock)disconnectFailBlock disconnectSuccessBlock:(DisconnectSuccessBlock)disconnectSuccessBlock;

/*! @brief 清除缓存。
 *
 * @attention app切换用户登录时可以调用此方法，确保接收设备存储数据时不会出现数据混乱
 */
+ (void)clearCache;


/*! @brief 连接设备获取数据的简便方法。
 *
 * @param qingNiuUser：传入一个测量的用户资料(传入对象属性说明请参考类：QingNiuUser)
 * @param scanFailBlock 返回在扫描过程中失败的信息(如果失败则不会进行后续的连接动作)
 * @param connectSuccessBlock 连接成功之后回调的数据，实时测量的时候只有一条deviceData，该方法不接收存储数据
 * @param connectFailBlock 连接失败之后回调的错误原因
 */
+ (void)simpleGetData:(QingNiuUser *)qingNiuUser scanFailBlock:(ScanFailBlock)scanFailBlock connectSuccessBlock:(ConnectSuccessBlock)connectSuccessBlock connectFailBlock:(ConnectFailBlock)connectFailBlock;

@end
