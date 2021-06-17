//
//  DataModel.swift
//  DemoOfSqLite3
//
//  Created by Bhavin J kansara on 5/8/21.
//

import Foundation
import SwiftyJSON

// MARK: - Welcome
struct Welcome: Codable {
    let responseCode: Int
    let responseText: String
    let responseData: ResponseData

    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case responseText = "ResponseText"
        case responseData = "ResponseData"
    }
}

// MARK: - ResponseData
struct ResponseData: Codable {
    let jobList: [JobList]

    enum CodingKeys: String, CodingKey {
        case jobList = "job_list"
    }
}

// MARK: - JobList
struct JobList: Codable {
    let companyURL: String
    let jobID: Int
    let jobTitle, jobDesc, jobLocation, clientName: String
    let refID: Int
    let urlSlug: String

    enum CodingKeys: String, CodingKey {
        case companyURL = "company_url"
        case jobID = "job_id"
        case jobTitle = "job_title"
        case jobDesc = "job_desc"
        case jobLocation = "job_location"
        case clientName = "client_name"
        case refID = "ref_id"
        case urlSlug = "url_slug"
    }
    
    
}
