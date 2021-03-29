//
//  SchoolDataObject.swift
//  2018-02-08-CN-NYCSchools
//
//  Created by Christopher Nelson on 2/8/18.
//  Copyright © 2018 Odeon Software Inc. All rights reserved.
//

import UIKit

class SchoolDataObject: NSObject {

    public var dbn: String?
    public var schoolName:String?
    public var overviewParagraph:String?
    public var phoneNumber:String?
    public var email:String?
    public var website:String?
    
    public var address:String?
    public var city:String?
    public var state:String?
    public var zip:String?
    
    public var borough:String?
    
    public var latitude:String?
    public var longitude:String?
    
    
    public init!(schoolDict: [String : String]!)
    {
        dbn = schoolDict["dbn"];
        schoolName = schoolDict["school_name"];
        overviewParagraph = schoolDict["overview_paragraph"];
        phoneNumber = schoolDict["phone_number"];
        
        email = schoolDict["school_email"];
        website = schoolDict["website"];
        
        address = schoolDict["primary_address_line_1"];
        city = schoolDict["city"];
        state = schoolDict["state_code"];
        zip = schoolDict["zip"];
        
        borough = schoolDict["borough"];
//        borough = [_borough stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        latitude = schoolDict["latitude"];
        longitude = schoolDict["longitude"];

    }
    
    
    open func isValidSchool() -> Bool
    {
        var pass = false
        
        guard let dbn_local = dbn else {
            return false
        }
        
        guard let schoolName_local = schoolName else {
            return false
        }
        
        if dbn_local.lengthOfBytes(using: String.Encoding.utf8) > 0
        {
            pass = true
        }
        
        if schoolName_local.lengthOfBytes(using: String.Encoding.utf8) > 0
        {
            pass = true
        }
        
        return pass
    }

}
