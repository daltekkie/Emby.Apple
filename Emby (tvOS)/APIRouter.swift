//
//  APIRouter.swift
//  Emby
//
//  Created by Aaron Alexander on 11/25/15.
//
//

import Alamofire
/*
let baseURLString = "http://example.com"
var OAuthToken: String?

protocol RouterObject {
    func createObjectPath() -> String
    func readObjectPath(identifier: String) -> String
    func updateObjectPath(identifier: String) -> String
    func destroyObjectPath(identifier: String) -> String
}

enum APIRouter<T where T: RouterObject>: URLRequestConvertible {
    case CreateObject(T, [String: AnyObject])
    case ReadObject(T, String)
    case UpdateObject(T, String, [String: AnyObject])
    case DestroyObject(T, String)
    
    var method: Alamofire.Method {
        switch self {
        case .CreateObject:
            return .POST
        case .ReadObject:
            return .GET
        case .UpdateObject:
            return .PUT
        case .DestroyObject:
            return .DELETE
        }
    }
    
    var path: String {
        switch self {
        case .CreateObject(let object, _):
            return object.createObjectPath()
        case .ReadObject(let object, let identifier):
            return object.readObjectPath(identifier)
        case .UpdateObject(let object, let identifier, _):
            return object.updateObjectPath(identifier)
        case .DestroyObject(let object, let identifier):
            return object.destroyObjectPath(identifier)
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if let token = OAuthToken {
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        switch self {
        case .CreateObject(_, let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .UpdateObject(_, _, let parameters):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
        default:
            return mutableURLRequest
        }
    }
}
*/

class APIManager {
    
    struct SingleInstance {
        static let sharedManager: APIManager = {
            let manager = APIManager()
            
            return manager
        }()
    }
    
    class var sharedManager: APIManager {
        return SingleInstance.sharedManager
    }
}


