//
//  GZAFNetworking.h
//  pay
//
//  Created by aten07 on 16/11/30.
//  Copyright © 2016年 aten07. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef void (^blockProgress)       (float progress);
typedef void (^SuccessCallBack)     (id responseObject,BOOL succe,NSDictionary *jsonDic);
typedef void (^FailureCallBack)     (NSError *error);


@interface GZAFNetworking : NSObject

/**
 同步判断网络状态，可能在部分iOS系统会卡顿iOS9 iOS10没有问题
 */
+(BOOL)interStatus;

/**
 GET网络请求基于AFNetWorking3.1

 @param strURL     URL
 @param CacheTime  缓存时间，以秒为单位 -1 为永久缓存  0 为不缓存
 @param loadString @""代表只加载风火轮  nil或者null 代表不加载 @“字符串” 代表显示风火轮和下面的文字
 @param blockPro   加载速度
 @param success    成功
 @param failure    失败
 */
+(void)GZGETOnlineRequest:(NSString *)strURL CacheTime:(NSTimeInterval)CacheTime isLoadingView:(NSString *)loadString blockPro:(blockProgress)blockPro success:(SuccessCallBack)success failure:(FailureCallBack)failure;

/**
 POST网络请求基于AFNetWorking3.0

 @param strURL     URL
 @param parameters 参数
 @param CacheTime  缓存时间，以秒为单位 -1 为永久缓存  0 为不缓存
 @param loadString @""代表只加载风火轮  nil或者null 代表不加载 @“字符串” 代表显示风火轮和下面的文字
 @param blockPro   加载速度
 @param success    成功
 @param failure    失败
 */
+(void)GZPOSTOnlineRequest:(NSString *)strURL parameters:(id)parameters CacheTime:(NSTimeInterval)CacheTime isLoadingView:(NSString *)loadString blockPro:(blockProgress)blockPro success:(SuccessCallBack)success failure:(FailureCallBack)failure;

/**
 下载功能

 @param strURL   URL
 @param PathFile 本地地址
 */
+(void)GZDownloadTaskWithRequest:(NSString *)strURL File:(NSString *)PathFile;

/**
 上传

 @param strURL     URL
 @param parameters 对象
 */
+(void)GZUploadFileWithRequest:(NSString *)strURL parameters:(id)parameters;

@end
