//
//  WebService.swift
//  DemoOfSqLite3
//
//  Created by Bhavin J kansara on 5/8/21.
//

import UIKit
import Alamofire

class WebService: NSObject {

    static var shareInstance = WebService()
    
   
    //MARK: Internet Avilability
    func internetChecker(reachability: Reachability) -> Bool {
        // print("\(reachability.description) - \(reachability.connection)")
        var check:Bool = false
        
        if reachability.connection == .wifi {
            check = true
        }
        else if reachability.connection == .cellular {
            check = true
        }
        else
        {
            check = false
        }
        return check
    }
}
