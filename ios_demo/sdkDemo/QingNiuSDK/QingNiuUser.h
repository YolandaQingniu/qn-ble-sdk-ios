//
//  QingNiuUser.h
//  SDKTest
//
//  Created by pengyunfei on 15/12/27.
//  Copyright © 2015年 qingniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface QingNiuUser : NSObject

//-----------必须参数----------
//用户id(请确保不同的用户userId不同)
@property (nonatomic,strong)NSString *userId;
//身高(单位cm)
@property (nonatomic,assign)CGFloat height;
//性别(0:女 1:男)
@property (nonatomic,assign)int gender;
//生日(格式：yyyy-MM-dd 如：1992-01-10)
@property (nonatomic,strong)NSString *birthday;

//初始化方法
- (id)initUserWithUserId:(NSString *)userId andHeight:(CGFloat)height andGender:(int)gender andBirthday:(NSString *)birthday;

@end
