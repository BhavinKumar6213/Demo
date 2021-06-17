//
//  viewModel.swift
//  DemoOfSqLite3
//
//  Created by Bhavin J kansara on 5/8/21.
//

import UIKit

class viewModel {
    
    var JobResponseData: [JobList]?
    
    
    init(data: Welcome){
        
        self.JobResponseData = data.responseData.jobList
        
    }
}
