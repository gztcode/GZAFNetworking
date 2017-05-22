//
//  GZAFNetworking.m
//  pay
//
//  Created by aten07 on 16/11/30.
//  Copyright © 2016年 aten07. All rights reserved.
//

#import "GZAFNetworking.h"
#import "AFNetworking.h"
#import "GZCache.h"
#import "LoadingView.h"
#import "Reachability.h"

#define IsNilString(__String)   (__String==nil || [__String isEqualToString:@"null"] || [__String isEqualToString:@"<null>"])

@implementation GZAFNetworking


+(AFHTTPSessionManager *)isAccording:(BOOL)acc{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = acc;
    if (acc == YES) {
        AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 30.f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        return manager;
    }else{
        return nil;
    }
}
//同步判断网络状态，可能在部分iOS系统会卡顿iOS9 iOS10没有问题
+(BOOL)interStatus
{
    BOOL status ;
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status22 = [reach currentReachabilityStatus];
    // 判断网络状态
    if (status22 == ReachableViaWiFi) {
        status = YES;
        //无线网
    } else if (status22 == ReachableViaWWAN) {
        status = YES;
        //移动网
    } else {
        status = NO;
    }
    return status;
}


+(void)GZGETOnlineRequest:(NSString *)strURL CacheTime:(NSTimeInterval)CacheTime isLoadingView:(NSString *)loadString blockPro:(blockProgress)blockPro success:(SuccessCallBack)success failure:(FailureCallBack)failure{
    [GZAFNetworking isAccording:NO];
    if (!IsNilString(loadString)) {
        [LoadingView hideProgressHUD];
    }
    //strURL =  [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    strURL = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)strURL, nil, nil, kCFStringEncodingUTF8));
    GZCache * cache = [GZCache globalCache];
    if (![self interStatus]) {
        //无网络
        NSString *interNetError = [strURL stringByAppendingString:@"interNetError"];
        NSData *responseObject = [cache dataForKey:interNetError];
        if (responseObject.length != 0) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            success(responseObject,YES,dict);
            return;
        }
        [LoadingView showAlertHUD:@"网络没有连接上" duration:2];
        return;
    }
    if ([cache hasCacheForKey:strURL]) {
        NSData *responseObject = [cache dataForKey:strURL];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        success(responseObject,YES,dict);
        return;
    }
    if (!IsNilString(loadString)) {
        [LoadingView showProgressHUD:loadString];
    }
    [[self isAccording:YES] GET:strURL parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        float progress = downloadProgress.completedUnitCount*100/downloadProgress.totalUnitCount;
        blockPro(progress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (!IsNilString(loadString)) {
            [LoadingView hideProgressHUD];
        }
         NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        BOOL succe = NO;
        if ([[dict objectForKey:@"code"] isKindOfClass:[NSNumber class]]) {
            if ([[dict valueForKey:@"code"] isEqualToNumber:@100]) {
                succe = YES;
            } else
                succe = NO;;
        } else if ([[dict objectForKey:@"code"] isKindOfClass:[NSString class]]) {
            if ([[dict valueForKey:@"code"] isEqualToString:@"100"]) {
                succe = YES;
            } else
                succe = NO;
        }
        NSString *interNetError = [strURL stringByAppendingString:@"interNetError"];
        [cache setData:responseObject forKey:interNetError];
        if (CacheTime && succe){
            if (CacheTime == -1) {
                [cache setData:responseObject forKey:strURL];
            }else{
                [cache setData:responseObject forKey:strURL withTimeoutInterval:CacheTime];
            }
        }
        [GZAFNetworking isAccording:NO];
        success(responseObject,succe,dict);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [GZAFNetworking isAccording:NO];
        if (!IsNilString(loadString)) {
            [LoadingView hideProgressHUD];
        }
        [LoadingView showAlertHUD:@"网络没有连接上" duration:2];
        failure(error);
    }];
}
+(void)GZPOSTOnlineRequest:(NSString *)strURL parameters:(id)parameters CacheTime:(NSTimeInterval)CacheTime isLoadingView:(NSString *)loadString blockPro:(blockProgress)blockPro success:(SuccessCallBack)success failure:(FailureCallBack)failure{
    [GZAFNetworking isAccording:NO];
    if (!IsNilString(loadString)) {
        [LoadingView hideProgressHUD];
    }
     strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    GZCache * cache = [GZCache globalCache];
    if (![self interStatus]) {
        //无网络
        NSString *interNetError = [strURL stringByAppendingString:@"interNetError"];
        NSData *responseObject = [cache dataForKey:interNetError];
        if (responseObject.length != 0) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            success(responseObject,YES,dict);
            return;
        }
    }
    if ([cache hasCacheForKey:strURL]) {
        NSData *responseObject = [cache dataForKey:strURL];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        success(responseObject,YES,dict);
        return;
    }
    if (!IsNilString(loadString)) {
        [LoadingView showProgressHUD:loadString];
    }
    [[self isAccording:YES] POST:strURL parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        float progress = uploadProgress.completedUnitCount*100/uploadProgress.totalUnitCount;
        blockPro(progress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (!IsNilString(loadString)) {
            [LoadingView hideProgressHUD];
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        BOOL succe = NO;
        if ([[dict objectForKey:@"code"] isKindOfClass:[NSNumber class]]) {
            if ([[dict valueForKey:@"code"] isEqualToNumber:@100]) {
                succe = YES;
            } else
                succe = NO;;
        } else if ([[dict objectForKey:@"code"] isKindOfClass:[NSString class]]) {
            if ([[dict valueForKey:@"code"] isEqualToString:@"100"]) {
                succe = YES;
            } else
                succe = NO;
        }
        NSString *interNetError = [strURL stringByAppendingString:@"interNetError"];
        [cache setData:responseObject forKey:interNetError];
        if (CacheTime && succe){
            if (CacheTime == -1) {
                [cache setData:responseObject forKey:strURL];
            }else{
                [cache setData:responseObject forKey:strURL withTimeoutInterval:CacheTime];
            }
        }
        [GZAFNetworking isAccording:NO];
        success(responseObject,succe,dict);
        [self isAccording:NO];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [GZAFNetworking isAccording:NO];
        if (!IsNilString(loadString)) {
            [LoadingView hideProgressHUD];
        }
        [LoadingView showAlertHUD:@"网络没有连接上" duration:2];
         failure(error);
    }];
}

+(void)GZDownloadTaskWithRequest:(NSString *)strURL File:(NSString *)PathFile{
    strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
     NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL]];
     NSURLSessionDownloadTask *task = [[self isAccording:YES] downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
          DLog(@"%lf",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
     } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
         DLog(@"下载的路径");
          return [NSURL URLWithString:PathFile];
     } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
         DLog(@"下载完成：");
         DLog(@"%@--%@",response,filePath);
         [GZAFNetworking isAccording:NO];
     }];
    [task resume];
}
+(void)GZUploadFileWithRequest:(NSString *)strURL parameters:(id)parameters{
     strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      [[self isAccording:YES] POST:strURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
          //上传文件参数
          UIImage *iamge = [UIImage imageNamed:@"123.png"];
          NSData *data = UIImagePNGRepresentation(iamge);
          //这个就是参数
          [formData appendPartWithFileData:data name:@"file" fileName:@"123.png" mimeType:@"image/png"];
      } progress:^(NSProgress * _Nonnull uploadProgress) {
          DLog(@"%lf",1.0 *uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
      } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          DLog(@"请求成功：%@",responseObject);
          [GZAFNetworking isAccording:NO];
      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          DLog(@"请求失败：%@",error);      }];
    
}

@end
