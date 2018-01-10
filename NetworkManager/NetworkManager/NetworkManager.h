//
//  NetworkManager.h
//  NetworkManager
//
//  Created by mac on 2018/1/8.
//  Copyright © 2018年 baby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "NetworkMacro.h"

static AFHTTPSessionManager *_sessionManager;


@interface NetworkManager : NSObject



@property(nonatomic, strong)NSURLSessionDownloadTask *sessionDownloadTask;


/// 上传或者下载的进度, Progress.completedUnitCount:当前大小 - Progress.totalUnitCount:总大小
typedef void (^HttpProgress)(NSProgress *progress);


+ (NetworkManager *)shareNetworkManager;


/**
 GET请求接口

 @param url 请求接口
 @param parameters 接口传入参数内容
 @param successful 成功Block返回
 @param failure 失败Block返回
 */

- (void)GETUrl:(NSString *)url
        parameters:(NSDictionary *)parameters
        success:(void (^)(id responseObject))successful
        failure:(void (^) (NSError *error, ParamtersJudgeCode  judgeCode))failure;


/**
 POST请求接口

 @param url 请求接口
 @param parameters 接口传入参数
 @param successful 成功Block返回
 @param failure 失败Block返回
 */
- (void)POSTUrl:(NSString *)url
        parameters:(NSDictionary *)parameters
        success:(void (^)(id responseObject))successful
        failure:(void (^) (NSError *error, ParamtersJudgeCode  judgeCode))failure;



/**
 图片上传接口(上传音频与图片是一致的，需要更改的只是 mimeType类型，根据要求设置对应的格式即可)
 
 @param url 请求接口
 @param paramters 请求参数
 @param pictureData 图片数据
 @param pictureKey 与后台约定的 文件key
 @param progress 上传进度
 @param successful 成功返回
 @param failure 失败返回
 */
- (void)HeaderUploadUrl:(NSString *)url parameters:(NSDictionary *)paramters
            pictureData:(NSData *)pictureData
             pictureKey:(NSString *)pictureKey
               progress:(HttpProgress)progress
                success:(void (^) (id responseObject))successful
                failure:(void (^) (NSError *error, ParamtersJudgeCode  judgeCode))failure;

/**
 下载文件接口
 
 @param url 请求接口
 @param progress 下载进度
 @param downloadFilePath 文件保存路径
 @param successful  返回路径内容
 @param failure 失败返回
 */
- (void)downloadUrl:(NSString *)url
           progress:(HttpProgress)progress
   downloadFilePath:(NSString *)downloadFilePath
            success:(void (^) (id responseObject))successful
            failure:(void (^) (NSError *error, ParamtersJudgeCode  judgeCode))failure;




#pragma mark - 设置AFHTTPSessionManager相关属性
#pragma mark 注意: 因为全局只有一个AFHTTPSessionManager实例,所以以下设置方式全局生效
/**
 在开发中,如果以下的设置方式不满足项目的需求,就调用此方法获取AFHTTPSessionManager实例进行自定义设置
 @param sessionManager AFHTTPSessionManager的实例
 */
+ (void)setAFHTTPSessionManagerProperty:(void(^)(AFHTTPSessionManager *sessionManager))sessionManager;

/**
 *  设置网络请求参数的格式:默认为二进制格式
 *
 *  @param requestSerializer PPRequestSerializerJSON(JSON格式),PPRequestSerializerHTTP(二进制格式),
 */
+ (void)setRequestSerializer:(RequestSerializer)requestSerializer;

/**
 *  设置服务器响应数据格式:默认为JSON格式
 *
 *  @param responseSerializer PPResponseSerializerJSON(JSON格式),PPResponseSerializerHTTP(二进制格式)
 */
+ (void)setResponseSerializer:(ResponseSerializer)responseSerializer;

/**
 *  设置请求超时时间:默认为30S
 *
 *  @param time 时长
 */
+ (void)setRequestTimeoutInterval:(NSTimeInterval)time;

/// 设置请求头
+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;


/**
 配置自建证书的Https请求, 参考链接: http://blog.csdn.net/syg90178aw/article/details/52839103
 
 @param cerPath 自建Https证书的路径
 @param validatesDomainName 是否需要验证域名，默认为YES. 如果证书的域名与请求的域名不一致，需设置为NO; 即服务器使用其他可信任机构颁发
 的证书，也可以建立连接，这个非常危险, 建议打开.validatesDomainName=NO, 主要用于这种情况:客户端请求的是子域名, 而证书上的是另外
 一个域名。因为SSL证书上的域名是独立的,假如证书上注册的域名是www.google.com, 那么mail.google.com是无法验证通过的.
 */
+ (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName;



@end
