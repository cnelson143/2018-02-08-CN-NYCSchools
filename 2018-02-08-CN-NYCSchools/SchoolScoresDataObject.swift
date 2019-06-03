//
//  SchoolScoresDataObject.swift
//  2018-02-08-CN-NYCSchools
//
//  Created by Christopher Nelson on 2/8/18.
//  Copyright © 2018 Odeon Software Inc. All rights reserved.
//

import UIKit

class SchoolScoresDataObject: NSObject {

    public var dbn: String?
    public var schoolName:String?
    public var numOfSATTestTakers:String?
    public var satCriticalReadingAvgScore:String?
    public var satMathAvgScore:String?
    public var satWritingAvgScore:String?

    public init!(schoolScoreDictionary schoolScoreDict: [String : String]!)
    {
        dbn = schoolScoreDict["dbn"];
        schoolName = schoolScoreDict["school_name"];
        numOfSATTestTakers = schoolScoreDict["num_of_sat_test_takers"];
        satCriticalReadingAvgScore = schoolScoreDict["sat_critical_reading_avg_score"];
        satMathAvgScore = schoolScoreDict["sat_math_avg_score"];
        satWritingAvgScore = schoolScoreDict["sat_writing_avg_score"];
    }
    
    open func isValidSchoolScore() -> Bool
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
