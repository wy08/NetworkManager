

//
//  NetworkManager.m
//  NetworkManager
//
//  Created by mac on 2018/1/8.
//  Copyright © 2018年 baby. All rights reserved.
//

#import "NetworkManager.h"
#import "NetworkMacro.h"
#import "AFNetworking.h"



@implementation NetworkManager

static NetworkManager *_instance;


+ (id)allocWithZone:(struct _NSZone *)zone
{
    //调用dispatch_once保证在多线程中也只被实例化一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)shareNetworkManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[NetworkManager alloc] init];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    
    return self;
}

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
       failure:(void (^) (NSError *error, ParamtersJudgeCode  judgeCode))failure
{
    NSError *error = nil;
    //判断接口是否是空值
    if (url.length == 0 || [url isEqualToString:@""]) {
        failure(error, RequestUrlNil);
    }
    //开始请求内容
    [_sessionManager GET:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        //如果需要填充进度内容，可以直接进行内容添加
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        successful(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error,RequestFailed);
    }];

}

/**
 POST请求接口
 
 @param url 请求接口
 @param parameters 接口传入参数
 @param successful 成功Block返回
 @param failure 失败Block返回  ParamtersJudgeCode 判断参数
 */
- (void)POSTUrl:(NSString *)url
        parameters:(NSDictionary *)parameters
        success:(void (^)(id responseObject))successful
        failure:(void (^) (NSError *error, ParamtersJudgeCode  judgeCode))failure
{
    NSError *error = nil;
    //判断接口是否是空值
    if (url.length == 0 || [url isEqualToString:@""]) {
        failure(error, RequestUrlNil);
    }
    //开始请求内容
    [_sessionManager POST:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        //如果需要填充进度内容，可以直接进行内容添加
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        successful(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error,RequestFailed);
    }];

    
}

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
                failure:(void (^) (NSError *error, ParamtersJudgeCode  judgeCode))failure
{
    NSError *error = nil;
    //接口URL为空
    if (url.length == 0 || [url isEqualToString:@""] ) {
        failure(error, RequestUrlNil);
    }
    //传入参数为空
    if ([self isNullToDictionary:paramters]) {
        failure(error, ParamtersObjectNil);
    }
    //传入上传图片数据为空(NSData)
    if (pictureData.length == 0) {
        failure(error, UploadPictureDataNil);
    }
    //上传图片，服务器端文件名
    if (pictureKey.length == 0 || [pictureKey isEqualToString:@""]) {
        failure(error, UploadPictureKeyNil);
    }
    
    
    [_sessionManager POST:url parameters:paramters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //对上传完文件的配置
        //获取当前时间（int 时间戳转换）
        int nowDate = [[NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]]intValue];
        NSString *fileName = [NSString stringWithFormat:@"%d.jpg",nowDate];
        //参数介绍
        //fileData : 图片资源  name : 预定key   fileName  : 文件名  mimeType    : 资源类型(根据后台进行对应配置)
       [formData appendPartWithFileData:pictureData name:pictureKey fileName:fileName mimeType:@"image/jpeg"];

    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        successful(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //可以将http响应码返回，以便于判断错误
        failure(error,[self showResponseCode:task.response]);
    }];

}


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
        failure:(void (^) (NSError *error, ParamtersJudgeCode  judgeCode))failure
  {
    //下载地址
    NSURL *downloadURL = [NSURL URLWithString:url];
    //设置请求
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    //下载操作
    [_sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(downloadProgress) : nil;
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //拼接缓存目录
        NSString *downloadPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:downloadFilePath ? downloadFilePath : @"Download"];
        //打开文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //创建Download目录
        [fileManager createDirectoryAtPath:downloadPath withIntermediateDirectories:YES attributes:nil error:nil];
        //拼接文件路径
        NSString *filePath = [downloadPath stringByAppendingPathComponent:response.suggestedFilename];
        //返回文件位置的URL路径
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSInteger responseCode = [self showResponseCode:response];
        if (responseCode != 200) {
            successful ? successful(filePath.absoluteString): nil;
        }else {
            failure(error, UploadFailed);
        }
    }];
}

#pragma mark - 初始化AFHTTPSessionManager相关属性
/**
 开始监测网络状态
 */
+ (void)load {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}
/**
 *  所有的HTTP请求共享一个AFHTTPSessionManager
 *  原理参考地址:http://www.jianshu.com/p/5969bbb4af9f
 */
+ (void)initialize {
    _sessionManager = [AFHTTPSessionManager manager];
    _sessionManager.requestSerializer.timeoutInterval = 30.f;
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
    // 此处可添加对应的等待效果
}

#pragma mark - 重置AFHTTPSessionManager相关属性

+ (void)setAFHTTPSessionManagerProperty:(void (^)(AFHTTPSessionManager *))sessionManager {
    sessionManager ? sessionManager(_sessionManager) : nil;
}

+ (void)setRequestSerializer:(RequestSerializer)requestSerializer {
    _sessionManager.requestSerializer = requestSerializer == RequestSerializerHTTP ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
}

+ (void)setResponseSerializer:(ResponseSerializer)responseSerializer {
    _sessionManager.responseSerializer = responseSerializer == ResponseSerializerHTTP ? [AFHTTPResponseSerializer serializer] : [AFJSONResponseSerializer serializer];
}

+ (void)setRequestTimeoutInterval:(NSTimeInterval)time {
    _sessionManager.requestSerializer.timeoutInterval = time;
}

+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    [_sessionManager.requestSerializer setValue:value forHTTPHeaderField:field];
}


+ (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName {
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    // 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    // 如果需要验证自建证书(无效证书)，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    // 是否需要验证域名，默认为YES;
    securityPolicy.validatesDomainName = validatesDomainName;
    securityPolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:cerData, nil];
    
    [_sessionManager setSecurityPolicy:securityPolicy];
}


/**
 输出http响应的状态码

 @param response 响应数据
 */
- (NSUInteger)showResponseCode:(NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSInteger responseStatusCode = [httpResponse statusCode];
    return responseStatusCode;
}
/**
 字典判断是否为空

 @param dict 字典
 @return bool值
 */
- (BOOL)isNullToDictionary:(NSDictionary *)dict {
    if (dict != nil && ![dict isKindOfClass:[NSNull class]] && dict.count != 0){
        return NO;
    }else{
        return YES;
    }
}




@end

#pragma mark - NSDictionary,NSArray的分类
/*
 ************************************************************************************
 *新建NSDictionary与NSArray的分类, 控制台打印json数据中的中文
 ************************************************************************************
 */

#ifdef DEBUG
@implementation NSArray (PP)

- (NSString *)descriptionWithLocale:(id)locale {
    NSMutableString *strM = [NSMutableString stringWithString:@"(\n"];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [strM appendFormat:@"\t%@,\n", obj];
    }];
    [strM appendString:@")"];
    
    return strM;
}

@end

@implementation NSDictionary (PP)

- (NSString *)descriptionWithLocale:(id)locale {
    NSMutableString *strM = [NSMutableString stringWithString:@"{\n"];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [strM appendFormat:@"\t%@ = %@;\n", key, obj];
    }];
    
    [strM appendString:@"}\n"];
    
    return strM;
}
@end
#endif

