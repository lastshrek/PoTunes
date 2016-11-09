//
//  NetworkKit.swift
//  SwiftNetWorkFlow
//
//  Created by TifaTsubasa on 16/4/25.
//  Copyright © 2016年 Upmer Inc. All rights reserved.
//  https://api.douban.com/v2/movie/subject/1764796

import Foundation
import Alamofire



enum HttpRequestType: String {
	case OPTIONS = "OPTIONS"
	case GET     = "GET"
	case HEAD    = "HEAD"
	case POST    = "POST"
	case PUT     = "PUT"
	case PATCH   = "PATCH"
	case DELETE  = "DELETE"
	case TRACE   = "TRACE"
	case CONNECT = "CONNECT"
}
class NetworkKit<Model> {
  
  typealias SuccessHandlerType = ((AnyObject?) -> Void)
  typealias ErrorHandlerType = ((Int, AnyObject?) -> Void)
  typealias FailureHandlerType = ((NSError?) -> Void)
  typealias FinishHandlerType = ((Void) -> Void)
  
  typealias ResultHandlerType = ((Model) -> Void)
  typealias ReflectHandlerType = ((AnyObject?) -> Model)
  
  var type: HttpRequestType!
  var url: String?
  var params: [String: Any]?
  var headers: [String: String]?
  
  var successHandler: SuccessHandlerType?
  var errorHandler: ErrorHandlerType?
  var failureHandler: FailureHandlerType?
  var finishHandler: FinishHandlerType?
  var resultHandler: ResultHandlerType?
  var reflectHandler: ReflectHandlerType?
  
  var httpRequest: Request?
  
  deinit {
    debugPrint("deinit")
  }
  
  func reflect(f: @escaping ReflectHandlerType) -> Self {
    reflectHandler = f
    return self
  }
  
  func fetch(url: String, type: HttpRequestType = .GET) -> Self {
    self.type = type
    self.url = url
    return self
  }
  
  func params(params: [String: Any]) -> Self {
    self.params = params
    return self
  }
  
  func headers(headers: [String: String]) -> Self {
    self.headers = headers
    return self
  }
  
  func finish(handler: @escaping FinishHandlerType) -> Self {
    self.finishHandler = handler
    return self
  }
  
  func success(handler: @escaping SuccessHandlerType) -> Self {
    self.successHandler = handler
    return self
  }
  
  func result(handler: @escaping ResultHandlerType) -> Self {
    self.resultHandler = handler
    return self
  }
  
  func error(handler: @escaping ErrorHandlerType) -> Self {
    self.errorHandler = handler
    return self
  }
  
  func failure(handler: @escaping FailureHandlerType) -> Self {
    self.failureHandler = handler
    return self
  }
  
  func request() -> Self {
    if let url = url {
//			httpRequest = Alamofire.request(url, method: alamofireType, parameters: params, encoding: .URL, headers: headers)
//      httpRequest = Alamofire.request(alamofireType, parameters: params, encoding: .URL, headers: headers)
//        .response { request, response, data, error in
//      }
			httpRequest = Alamofire.request(url, method: .get, parameters: params, encoding: JSONEncoding.default, headers: headers)
				.responseJSON(completionHandler: { response in
					self.finishHandler?()
					print(response)
//					let statusCode = response.statusCode
//					if let statusCode = statusCode {  // request success
//						let json: AnyObject? = response.data.flatMap {
//							return try? NSJSONSerialization.JSONObjectWithData($0, options: .MutableContainers)
//						}
//						
//						if statusCode == 200 {
//							self.successHandler?(json)
//							if let reflectHandler = self.reflectHandler {
//								self.resultHandler?(reflectHandler(json))
//							}
//						} else {
//							self.errorHandler?(statusCode, json)
//						}
//					} else {                          // request failure
//						self.failureHandler?(error)
//					}

				})
		}
    return self
  }
	
  func cancel() {
    httpRequest?.cancel()
  }
}
