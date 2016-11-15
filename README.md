
#轻牛 蓝牙SDK IOS版

集成该 SDK,可以使用 伊欧乐公司旗下几乎所有的智能人体秤

如需使用 android 版,请点击 [这里](../../../qn-ble-sdk-adnroid)


## 最新版本 `2.3` [下载地址](../../releases/download/2.3/qn-ble-sdk-ios-2.3.zip)
* 增加了几款新型号

[所有版本](../../releases)


### 文件说明
* libQingNiuSDK.a 包含SDK的头文件定义和具体实现。
* QingNiuDevice.h是设备类，QingNiuUser.h是用户类，QingNiuSDK.h包含整个测量过程的所有方法。

### 集成过程
1. 将SDK中的libQingNiuSDK.a和.h文件拷贝到应用开发的目录下。然后添加到工程中即可。
* 添加SDK依赖的系统库文件。分别是 CoreBluetooth.framework,SystemConfiguration.framework,CoreGraphics.Framework,libsqlite3.dylib,MobileCoreServices.framework。
* 修改必要的工程配置属性，在工程配置中的“Build Settings”一栏中找到“Linking”配置区，给“Other Linker Flags”配置项添加属性值“-ObjC”， 如果，某些 Xcode 版本中，出现问题，修改设置为 -all_load，
如果工程已经如此配置则不需重复，若没有，请务必按照步骤配置，否则会影响SDK使用。

### 使用方法
1.registerApp,在使用其它的方法之前，请先调用此方法，并请确保第一次调用时网络畅通(可在登录的时候调用)。每次验证都会有一个过期时间，过期时间到了之后会无法扫描，请重新调用该方法。所以建议每次在didFinishLaunchingWithOptions 方法都调用该方法
 ```objective-c
 //注册轻牛APP
 //appid：申请使用SDK之前由轻牛分配的。
 //releaseModeFlag 传入YES，则代表当前是发布模式，那么appid需要是轻牛官方提供的。传入NO：则代表当前是测试模式，appid可用@"123456789"进行测试
 //registerAppBlock：验证app返回的状态，可根据返回的状态参数做相应的处理。
 [QingNiuSDK registerApp:@"123456789" andReleaseModeFlag:NO registerAppBlock:^(QingNiuRegisterAppState qingNiuRegisterAppState) {
     NSLog(@"%ld",(long)qingNiuRegisterAppState);
 }];
 ```

2. startBleScan,每次称重之前第一个调用的方法，用于扫描周围的设备，成功会依次返回扫描到的设备
```objective-c
//qingNiuDevice 第一次调用的时候可以传nil，将会扫描附近的所有设备。扫描到目标设备之后，可以将macAddress或者name属性保存下来，以后可以指定连接该设备(注意：QingNiuPeripheral属性不支持归档，所以不能将扫描到的qingNiuDevice直接归档，如果想下次指定设备扫描，可将对应的macAddress、name属性保存，以便下次使用)
//scanSuccessBlock：扫描成功之后的回调，扫描到设备之后通过这个block回调qingNiuDevice。
//scanFailBlock：扫描失败的回调，会将扫描失败的原因通过该方式返回。
[QingNiuSDK startBleScan:nil scanSuccessBlock:^(QingNiuDevice *qingNiuDevice) {

 } scanFailBlock:^(QingNiuScanDeviceFail qingNiuScanDeviceFail) {

}];
```

2. connectDevice：调用startBleScan方法成功之后，调用此方法连接设备并且获取设备的测量数据
```objective-c
// qingNiuDevice：将调用startBleScan获取到的qingNiuDevice作为参数传入，请确保该对象的每一个属性都有值。
// qingNiuUser：当前测量用户的信息。该对象的所有参数都是测量必不可少的。userId的值请确保不同的用户有不同的值，height为身高(单位cm)，gender是性别(0:女 1:男)，birthday是出生日期，(格式：yyyy-MM-dd 如：1990-06-23)。对象可调用QingNiuUser类中的初始化方法获得。
	// connectSuccessBlock：测量完成获取数据成功之后，会返回测量数据deviceData和连接状态，如果状态是QingNiuDeviceConnectStateWeightOver，代表正常测量完毕，如果状态是QingNiuDeviceConnectStateSavedData，代表接收到的数据是存储数据，如果存储数据有多条，根据user_id进行区分。
//connectFailBlock：连接或者获取数据失败后的回调信息，可根据信息提示做响应的处理。
[QingNiuSDK connectDevice:qingNiuDevice user:user connectSuccessBlock:^(NSMutableDictionary *deviceData, QingNiuDeviceConnectState qingNiuDeviceConnectState) {

        } connectFailBlock:^(QingNiuDeviceConnectState qingNiuDeviceConnectState) {

        }];
```

3. 可选 connectWithAdvertisementData：如果您想自己实现扫描设备的步骤，那么您可以在扫描到设备后将advertisementData和peripheral对象作为参数
 使用方法同上

4. cancelConnect：如果想断开与当前设备的连接，可以调用此方法。请确保想断开连接的设备qingNiuDevice正是当前连接上的设备，否则会失败。

5. clearCache：清除缓存。app切换用户登录时可以调用此方法此方法。在需要获取存储数据的时候必须调用，确保接收设备存储数据时不会出现数据混乱。

### Block说明

* 验证app的block，将状态返回
```objective-c
typedef void(^RegisterAppBlock)(QingNiuRegisterAppState qingNiuRegisterAppState);
```

* 扫描成功的block，将成功之后的设备qingNiuDevice返回
```objective-c
typedef void(^ScanSuccessBlock)(QingNiuDevice *qingNiuDevice);
```

* 扫描失败的block，将失败之后的原因通过枚举qingNiuScanDeviceFail返回
```objective-c
typedef void(^ScanFailBlock)(QingNiuScanDeviceFail qingNiuScanDeviceFail);
```

* 连接成功的block，将成功之后的测量数据deviceData和状态qingNiuDeviceConnectState返回
```objective-c
typedef void(^ConnectSuccessBlock)(NSMutableDictionary *deviceData,QingNiuDeviceConnectState qingNiuDeviceConnectState);
```

* 连接失败的block，将失败之后的原因qingNiuDeviceConnectState返回
```objective-c
typedef void(^ConnectFailBlock)(QingNiuDeviceConnectState qingNiuDeviceConnectState);
```

* 断开连接失败的block，将断开连接失败的原因qingNiuDeviceDisconnectState返回(这里产生的失败原因，有可能是调用断开连接接口，传入的设备参数有问题或者当前已经与设备断开了连接)
```objective-c
typedef void(^DisconnectFailBlock)(QingNiuDeviceDisconnectState qingNiuDeviceDisconnectState);
```

* 断开连接成功(会返回断开成功的状态)
```objective-c
typedef void(^DisconnectSuccessBlock)(QingNiuDeviceDisconnectState qingNiuDeviceDisconnectState);
```

* 返回的数据deviceData字典里面各个字段的含义(注意：最后四个指标是拓展指标，只有达成进一步合作协议的SDK接入商才有可能获取其中的某几个指标)

|字段|说明|
|:----|:-------|
|user_id|用户id(多用户存储数据有用)
|measure_time|测量时间(多用户存储数据有用)
|weight|体重
|bmi|身体质量指数
|bodyfat|体脂肪率
|subfat|皮下脂肪率
|visfat|内脏脂肪等级
|water|体水分
|bmr|基础代谢量
|muscle|骨骼肌率
|bone|骨量
|protein|蛋白质

注意：以下四个指标是拓展指标，只有达成合作协议的SDK接入商才有可能获取其中的某几个指标

|字段|说明|
|:----|:-------|
|bodyage|体年龄
|sinew|肌肉量
|fat_free_weight|去脂体重
|body_shape|体型


#### 枚举说明
* 验证信息
```objective-c
typedef NS_ENUM(NSInteger,QingNiuRegisterAppState) {//验证appid状态
  QingNiuRegisterAppStateSuccess = 0,           //成功
  QingNiuRegisterAppStateFailParamsError = 1,   //appid错误，确保appid正确再调用一次
  QingNiuRegisterAppStateFailVersionTooLow = 2, //版本号过低或过高，需要新的SDK请联系客服
};
```

* 扫描设备失败的原因
```objective-c
typedef NS_ENUM(NSInteger,QingNiuScanDeviceFail) {
  QingNiuScanDeviceFailUnsupported = 0,       //设备不支持蓝牙4.0
  QingNiuScanDeviceFailPoweredOff = 1,        //蓝牙关闭(打开手机蓝牙)
  QingNiuScanDeviceFailValidationFailure = 2, //app验证失败(重新调用registerApp接口)
  QingNiuScanDevicePoweredOn = 3,             //蓝牙开启(这不是扫描失败情况下的枚举，为了跟以前的版本兼容，不另外添加枚举)
};
```

* 连接过程中的各种状态枚举(0-4是代表连接过程中失败的枚举，5-10代表连接过程中成功的枚举)
```objective-c
typedef NS_ENUM(NSInteger,QingNiuDeviceConnectState) {
  QingNiuDeviceConnectStateParamsError = 0,       //传入连接参数错误(这里有可能出现的参数错误包括qingNiuUser，qingNiuDevice，出现这种错误要重新扫描再连接)
  QingNiuDeviceConnectStateConnectFail = 1,       //连接设备失败(重新连接或重新扫描再连接)
  QingNiuDeviceConnectStateDiscoverFail = 2,      //查找设备的服务或者特性失败(重新连接)
  QingNiuDeviceConnectStateDataError = 3,         //接收到的数据出错(重新连接)
  QingNiuDeviceConnectStateLowPower = 4,          //设备低电(设备电量不足)
  QingNiuDeviceConnectStateIsWeighting = 5,       //正在测量(接收实时数据)
  QingNiuDeviceConnectStateWeightOver = 6,        //测量完毕(接收正常测量的数据)
  QingNiuDeviceConnectStateIsGettingSavedData= 7, //正在接收存储数据(接收设备存储的数据)
  QingNiuDeviceConnectStateGetSavedDataOver＝8,   //接收到了所有存储数据(此时deviceData的值为nil)
  QingNiuDeviceConnectStateDisConnected = 9,      //测量完毕之后自动断开了连接(此时deviceData为nil)
  QingNiuDeviceConnectStateConnectedSuccess = 10, //连接成功时候的回调(此时deviceData为nil)
};
```

* 断开连接的状态
```objective-c
typedef NS_ENUM(NSInteger,QingNiuDeviceDisconnectState) {//断开连接的各种状态
  QingNiuDeviceDisconnectStateDisConnectSuccess = 0,  //断开连接成功
  QingNiuDeviceDisconnectStateParamsError = 1,        //传入连接参数错误(比如外设为空)
  QingNiuDeviceDisconnectStateIsDisConnected = 2,     //已经处于断开的状态
};
```


## 注意事项

* 测试版 APPID：123456789，测试版版本的服务器可能会不稳定
* 使用**测试版APPID**调试成功后，请切换到**发布**模式，并使用**正式的APPID**上线
* **正式的APPID** 由轻牛公司统一分配
* SDK中有方法可以指定测试或发布模式

===================================================

如有使用问题,请先查阅文档

如果还是无法解决,请 email: huangdunren@yolanda.hk 或者直接在QQ，微信的SDK技术讨论组中咨询
