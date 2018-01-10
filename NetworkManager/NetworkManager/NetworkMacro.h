//
//  NetworkMacro.h
//  NetworkManager
//
//  Created by mac on 2018/1/8.
//  Copyright © 2018年 baby. All rights reserved.
//

#pragma mark -- 请求的方式
typedef NS_ENUM(NSUInteger, URLMethod) {
    GET    = 1,
    POST   = 2,
    PUT    = 3,
    DELETE = 4,
};

typedef NS_ENUM(NSUInteger, ParamtersJudgeCode) {
    
    RequestUrlNil          = 11,
    ParamtersObjectNil     = 12,
    UploadPictureDataNil   = 13,
    UploadPictureKeyNil    = 14,
    UploadFailed           = 15,
    RequestFailed          = 16,
    
    
    
};

typedef NS_ENUM(NSUInteger, RequestSerializer) {
    /// 设置请求数据为JSON格式
    RequestSerializerJSON,
    /// 设置请求数据为二进制格式
    RequestSerializerHTTP,
};

typedef NS_ENUM(NSUInteger, ResponseSerializer) {
    /// 设置响应数据为JSON格式
    ResponseSerializerJSON,
    /// 设置响应数据为二进制格式
    ResponseSerializerHTTP,
};



#ifndef NetworkMacro_h
#define NetworkMacro_h


#endif /* NetworkMacro_h */
