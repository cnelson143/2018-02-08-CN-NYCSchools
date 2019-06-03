//
//  ApplicationDataObject.swift
//  2018-02-08-CN-NYCSchools
//
//  Created by Christopher Nelson on 2/8/18.
//  Copyright © 2018 Odeon Software Inc. All rights reserved.
//

import UIKit

class ApplicationDataObject: NSObject {

    static let shared = ApplicationDataObject.init()
    
    var schoolList: Array<SchoolDataObject> = []
    var schoolScoresList: Array<SchoolScoresDataObject> = []
    var borooghList: Array<String> = []

    open func loadShchoolData(forURL stringURL: String!, withScoresURL scoresURL: String!, boroughs: [String]?, completionHandler: ((Bool, NSError?) -> Swift.Void)!)
    {
        CLNetworkStatusCheck.networkStatusCheck { (available) in
            
            var pass = false
            var error : NSError?
            
            if(available)
            {
                self.schoolList.removeAll()
                self.schoolScoresList.removeAll()
                self.borooghList.removeAll()
                
                var boroughSet = Set<String>.init()
                
                var data : Data?
                
                do
                {
                    data = try Data.init(contentsOf: URL.init(string: stringURL)!)
                    var jsonArray : Array<Dictionary<String, String>> = try JSONSerialization.jsonObject(with: data!, options: []) as! Array<Dictionary<String, String>>
                    for schoolDict in jsonArray
                    {
                        let schoolData = SchoolDataObject.init(schoolDictionary: schoolDict)!
                        var include = true
                        if let borough = schoolData.borough
                        {
                            boroughSet.insert(borough)
                            
                            if let boroughsTest = boroughs
                            {
                                if boroughsTest.index(of: borough) == nil
                                {
                                    include = false
                                }
                            }
                            else
                            {
                                include = true
                            }
                        }
                        
                        if schoolData.isValidSchool() && include
                        {
                            self.schoolList.append(schoolData)
                        }
                    }
                    
                    pass = true
                    
                    self.borooghList = Array(boroughSet)
                    
                    self.borooghList.sort(by: { (borough1, borough2) -> Bool in
                        
                        return borough1 < borough2

                    })

                    self.schoolList.sort(by: { (obj1, obj2) -> Bool in
                        
                        return obj1.schoolName! < obj2.schoolName!
                        
                    })
                    
                    
                    
                    data = try Data.init(contentsOf: URL.init(string: scoresURL)!)
                    jsonArray = try JSONSerialization.jsonObject(with: data!, options: []) as! Array<Dictionary<String, String>>
                    for schoolScoreDict in jsonArray
                    {
                        let schoolScoreData = SchoolScoresDataObject.init(schoolScoreDictionary: schoolScoreDict)!
                        if schoolScoreData.isValidSchoolScore()
                        {
                            self.schoolScoresList.append(schoolScoreData)
                        }
                    }
                    
                    pass = true
                }
                catch
                {
                
                }
                
                
            }
            else
            {
                print("Network Not Available")
                error = NSError(domain:NSCocoaErrorDomain, code:99, userInfo:[NSLocalizedDescriptionKey: "Network not available."])
            }
            
            completionHandler(pass, error)
        }
        
    }
    
    open func resetSchoolData()
    {
        schoolList.removeAll()
    }
}
