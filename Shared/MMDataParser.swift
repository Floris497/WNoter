//
//  MMDataParser.swift
//  WNoter
//
//  Created by Floris Fredrikze on 25/09/2020.
//

import Foundation

class MMDataParser {
	class func getWeightFromData(_ data: NSData) -> MMWeightData?
	{
        return nil;
	}
}

class MMDataParserOKOK: MMDataParser
{
    class override func getWeightFromData(_ data: NSData) -> MMWeightData? {
        var type: UInt8 = 0
        var weight: Int16 = 0
        
        if (data.length == 21)
        {
            data.getBytes(&type, range: NSMakeRange(8, MemoryLayout<Int8>.size))
            data.getBytes(&weight, range: NSMakeRange(10 ,MemoryLayout<Int16>.size))
            weight = weight.bigEndian
            if (type == 5 || type == 4)
            {
                return MMWeightData(weight: Int(weight) * 10, type: type == 5 ? .kDefiniteWeight : .kTempWeight)
            }
        }
        return nil
    }
}

class MMDataParserSwan: MMDataParser
{
    class override func getWeightFromData(_ data: NSData) -> MMWeightData? {
        var type: UInt8 = 0
        var weight: Int16 = 0
        
        if (data.length == 8)
        {
            data.getBytes(&type, range: NSMakeRange(6, MemoryLayout<Int8>.size))
            data.getBytes(&weight, range: NSMakeRange(2 ,MemoryLayout<Int16>.size))
            weight = weight.bigEndian
            if (type == 0xCE || type == 0xCA)
            {
                return MMWeightData(weight: Int(weight) * 100, type: type == 0xCA ? .kDefiniteWeight : .kTempWeight)
            }
        }
        return nil
    }
}
