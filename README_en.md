
#Yolanda Bluetooth SDK IOS Version

You can use most of yolanda company's scale after integration of this SDK successfully

If you need Android version, please click [here](../../../qn-ble-sdk-ios) file


## The newest version `3.10.4` [please download here](../../releases/download/3.10.4/qn-ios-ble-sdk-3.10.4.zip)  
* add new device


[All version](../../releases)


### File description
* libQingNiuSDK.a Include the Header files define and implement specific of the SDK
* QingNiuDevice.h is device type，QingNiuUser.h is user type，QingNiuSDK.h Contains all the methods of the entire measurement process.

### Integration process
1.Copy the libQingNiuSDK.a and .h file in SDK into application development directory. And then added to the project
* Adding SDK-dependent system library file: CoreBluetooth.framework,SystemConfiguration.framework,CoreGraphics.Framework,libsqlite3.dylib,MobileCoreServices.framework
* Modify the necessary project configuration properties,First open “Build Settings” in project configuration--finding “Linking” configuration --Adding “-ObjC” in “Other Linker Flags” item, please modify into -all_load if there appear some problems in some Xcode version.
  if you had configured as above in your project then skip it, if no please do follow the steps to configure, otherwise it will affect the use of SDK

### Use manual
1. setLogFlag, setting open/turn off printing switch。

    ```objective-c
    //you can checking the callback information when setting into YES
    [QingNiuSDK setLogFlag:YES];
    ```

2. registerApp,Before using other methods, please call this method first we advise you call this method in didFinishLaunchingWithOptions each time

     ```objective-c
     //Register Yolanda App
     //appid： distributed by yolanda before apply to use SDK
     //registerAppBlock：Verify appid, you can processing according to different return parameter
     [QingNiuSDK registerApp:@"123456789" registerAppBlock:^(QingNiuRegisterAppState qingNiuRegisterAppState) {
         NSLog(@"%ld",(long)qingNiuRegisterAppState);
     }];
     ```
     
3. startBleScan, The first step for weighing. its use to find the surrounding device

    ```objective-c
    //qingNiuDevice ：use nil when call first time, it will pair all nearby device, save the macAddress or name attribute after finding the target device so that you can connect to this specific device next time(please note: QingNiuPeripheral property does not support archive which means archive directly for the Device, if you want to pair this specific device please save the macAddress or name attribute for quick use next time, deviceState: judging the switch state of device
    //scanSuccessBlock：Callback after finding successfully
    //scanFailBlock：Callback after fail, it will return the fail reason
    [QingNiuSDK startBleScan:nil scanSuccessBlock:^(QingNiuDevice *qingNiuDevice) {
    
     } scanFailBlock:^(QingNiuScanDeviceFail qingNiuScanDeviceFail) {
    
    }];
    ```
    
4. setWeightUnit

    ```objective-c
    //The default unit is kilograms
    //explam：set the unit to kilograms
    [QingNiuSDK setWeightUnit:QingNiuRegisterWeightUnitKg];
    ```

4. connectDevice：It can connect to device and get the measurement data with this function after call with startBleScan successfully

    ```objective-c
    // qingNiuDevice：use with the qingNiuDevice parameter which call with startBleScan, please make sure each parameter have related value
    // qingNiuUser：The current measurement user's information, it is all necessary parameters under this Item, please make sure different user with different userid, height in cm,Gender( Male: 1 Female: 0),birthday formate :yyyy-MM-dd(example：1990-06-23). you can call the initialization method in the QingNiuUser
    // connectSuccessBlock：It will return the measurement data deviceData together with connect status, QingNiuDeviceConnectStateWeightOver means a normal completed measurement, QingNiuDeviceConnectStateSavedData means: This received data is stored data, if there are multiple stored data, please distinguish according to user_id.
    //connectFailBlock：The return of fail in connect or receiving data, you can operate as the indicate message
    [QingNiuSDK connectDevice:qingNiuDevice user:user connectSuccessBlock:^(NSMutableDictionary *deviceData, QingNiuDeviceConnectState qingNiuDeviceConnectState) {
    
    } connectFailBlock:^(QingNiuDeviceConnectState qingNiuDeviceConnectState) {
    
    }];
    ```

5. If you want to find device yourself, please call this function with advertisementData and peripheral.
steps operate as above

6. cancelConnect：Call this method if you want to disconnect the current device, but please do make sure the device you want to disconnect qingNiuDevice is the device on connection, otherwise it will fail

7. clearCache：call with this method when App toggle user login. It is must be called if you want to obtain storage data to ensure that the receiving store data is right one without data confusion.

### Block Manual

* Verify the app block, it will return status

    ```objective-c
    typedef void(^RegisterAppBlock)(QingNiuRegisterAppState qingNiuRegisterAppState);
    ```

* Block finding successfully, it will return the successfully device qingNiuDevice
 
    ```objective-c
    typedef void(^ScanSuccessBlock)(QingNiuDevice *qingNiuDevice);
    ```

* Block finding fail, it will return the fail device qingNiuDevice and the reason

    ```objective-c
    typedef void(^ScanFailBlock)(QingNiuScanDeviceFail qingNiuScanDeviceFail);
    ```

* The block connect successfully, it will return the successfully measurement data and qingNiuDeviceConnectState

    ```objective-c
    typedef void(^ConnectSuccessBlock)(NSMutableDictionary *deviceData,QingNiuDeviceConnectState qingNiuDeviceConnectState);
    ```

* The block connect fail, it will return the fail qingNiuDeviceConnectState and the reason

    ```objective-c
    typedef void(^ConnectFailBlock)(QingNiuDeviceConnectState qingNiuDeviceConnectState);
    ```

* Block connect fail，return the fail connect qingNiuDeviceDisconnectState reason(Possible reason: call with disconnect port，use with problem parameter device or had disconnect with current device)

    ```objective-c
    typedef void(^DisconnectFailBlock)(QingNiuDeviceDisconnectState qingNiuDeviceDisconnectState);
    ```

* Disconnect successfully (it will return the status of Disconnect successfully)

    ```objective-c
    typedef void(^DisconnectSuccessBlock)(QingNiuDeviceDisconnectState qingNiuDeviceDisconnectState);
    ```

* the return deviceData meaning:

|Field|explanation|
|:----|:-------|
|user_id|user id(support multiple different user ID)
|measure_time|measure_time(support multiple data stored)
|weight|weight
|bmi|Body mass index
|bodyfat|bodyfat rate
|subfat|subfat rate
|visfat|visfat rate
|water|body water
|bmr|Basal metabolism
|muscle|Skeletal muscle rate
|bone|Bone mass
|protein|protein


#### Example
* Verify information

    ```objective-c
    typedef NS_ENUM(NSInteger,QingNiuRegisterAppState) {// verity appid status
      QingNiuRegisterAppStateSuccess = 0,           //successfully
      QingNiuRegisterAppStateFailParamsError = 1,   //appid fail，make sure recall under right appid
      QingNiuRegisterAppStateFailVersionTooLow = 2, //Version too low or too high, please contact with customer service for new SDK
    };
    ```

* Fail reason of pair device

    ```objective-c
    typedef NS_ENUM(NSInteger,QingNiuScanDeviceFail) {
      QingNiuScanDeviceFailUnsupported = 0,       //device do not support Bluetooth 4.0
      QingNiuScanDeviceFailPoweredOff = 1,        //device turn off(turn on bluetooth on mobile)
      QingNiuScanDeviceFailValidationFailure = 2, //app verify fail(recall registerApp port)
      QingNiuScanDevicePoweredOn = 3,             //Bluetooth is on(This is not fail example，its For compatibility with previous versions)
    };
    ```

* All kinds of status example during connection (0-4 is the example of fail ,5-10 is successfully example )

    ```objective-c
    typedef NS_ENUM(NSInteger,QingNiuDeviceConnectState) {
      QingNiuDeviceConnectStateParamsError = 0,       //connected parameter error ( like:qingNiuUser，qingNiuDevice，please rescan and connect if appears error)
      QingNiuDeviceConnectStateConnectFail = 1,       //Fail to connect device(reconnect or rescan)
      QingNiuDeviceConnectStateDiscoverFail = 2,      //Fail to check the feature or service of this device(reconnect)
      QingNiuDeviceConnectStateDataError = 3,         //Fail to receiving data(reconnect)
      QingNiuDeviceConnectStateLowPower = 4,          //Device Lack of power(lack of power)
      QingNiuDeviceConnectStateIsWeighting = 5,       //measuring(receiving real time data)
      QingNiuDeviceConnectStateWeightOver = 6,        //finish measurement(receiving normal measurement data)
      QingNiuDeviceConnectStateIsGettingSavedData= 7, //Receiving device stored data now
      QingNiuDeviceConnectStateGetSavedDataOver＝8,   //Received all stored data(deviceData value: nil)
      QingNiuDeviceConnectStateDisConnected = 9,      //Auto disconnect after measurement(deviceData: nil)
      QingNiuDeviceConnectStateConnectedSuccess = 10, //callback of connect successfully(deviceData: nil)
    };
    ```

* Disconnected state

    ```objective-c
    typedef NS_ENUM(NSInteger,QingNiuDeviceDisconnectState) {// All kinds of status after disconnect
      QingNiuDeviceDisconnectStateDisConnectSuccess = 0,  //Disconnect successfully
      QingNiuDeviceDisconnectStateParamsError = 1,        //connected parameter error
      QingNiuDeviceDisconnectStateIsDisConnected = 2,     //been in disconnect status
    };
    ```
* WeightUnit state

    ```
    typedef NS_ENUM(NSInteger,QingNiuWeightUnit) {//weightUni
        QingNiuRegisterWeightUnitKg = 0,//kg
        QingNiuRegisterWeightUnitLb = 1,//lb
        QingNiuRegisterWeightUnitJin = 2,//斤
    };
    ```

## please note:

* Testing version APPID：123456789 , the testing ver server may be unstable during testing
* After Use **testing version APPID** debugging successfully, please switch to **release** mode and use **formal APPID** make on line
* **Formal APPID** is distributed by yolanda company
* you can choose a test or release mode in SDK

===================================================

If you have anything question please refer related documents carefully, if you have any questions about API please read our API user manual first

If still can not solve this problem please contact us for technical support, we will arrange SDK technical team to support you, thank you !


