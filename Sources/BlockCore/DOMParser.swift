//
//  Parser.swift
//  S8Blocker
//
//  Created by virus1993 on 2018/1/16.
//  Copyright © 2018年 ascp. All rights reserved.
//

import Foundation

/// 顶层标签结构，包含标签名+属性名
public struct ParserTagRule {
    public var tag : String
    public var isTagPaser : Bool
    public var attrubutes : [ParserAttrubuteRule]
    public var inTagRegexString : String
    public var hasSuffix : String?
    public var innerRegex : String?
    public var prefix : String {
        return isTagPaser ? "<\(tag)\(inTagRegexString)>":inTagRegexString
    }
    public var suffix : String {
        return isTagPaser ? "</\(tag)>":(hasSuffix ?? "")
    }
    public var regex : String {
        return "\(prefix)\(innerRegex != nil ? innerRegex!:"[\\s\\S]*?")\(suffix)"
    }
}


/// 属性结构
public struct ParserAttrubuteRule {
    public var key : String
    public var prefix : String {
        return "\(key)=\""
    }
    public var suffix : String {
        return "\""
    }
    public var regex : String {
        return "\(prefix)[^\"]*\(suffix)"
    }
}


/// 解析结果，内层字符串+抓取的属性名
public struct ParserResult {
    public var innerHTML : String
    public var attributes : [String:String]
}


/// 解析HTML字符串并抓取符合正则表达式的标签信息
///
/// - Parameters:
///   - string: HTML字符串
///   - rule: 需要抓取的标签结构
/// - Returns:  解析结果（innerHTML和多个属性值）
public func parse(string: String, rule: ParserTagRule) -> [ParserResult]? {
    var results = [ParserResult]()
    do {
        let tagRegex = try NSRegularExpression(pattern: rule.regex, options: .caseInsensitive)
        let result = tagRegex.matches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, (string as NSString).length))
        if result.count > 0 {
            for checkingRes in result {
                var range = checkingRes.range
                range.length -= (rule.suffix as NSString).length
                if range.length <= 0 {
                    continue
                }
                let str = (string as NSString).substring(with: range)
                var resultX = ParserResult(innerHTML: "", attributes: [:])
                
                let titleRegex = try NSRegularExpression(pattern: rule.prefix, options: .caseInsensitive)
                if let first = titleRegex.firstMatch(in: str, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, (str as NSString).length)) {
                    var subRange = range
                    subRange.location = first.range.length
                    subRange.length = (str as NSString).length - subRange.location
                    resultX.innerHTML = (str as NSString).substring(with: subRange)
                }
                
                var attrs = [String:String]()
                for attr in rule.attrubutes {
                    let attrRegex = try NSRegularExpression(pattern: attr.regex, options: .caseInsensitive)
                    if let attrResult = attrRegex.firstMatch(in: str, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, (str as NSString).length)) {
                        var subRange = attrResult.range
                        subRange.location += (attr.prefix as NSString).length
                        subRange.length -= (attr.prefix as NSString).length + 1
                        attrs[attr.key] = (str as NSString).substring(with: subRange)
                    }
                }
                resultX.attributes = attrs
                
                results.append(resultX)
            }
        }   else    {
            //            print("未查找到内容模块: \(rule.regex)")
        }
        return results
    } catch  {
        print(error)
        return nil
    }
}
