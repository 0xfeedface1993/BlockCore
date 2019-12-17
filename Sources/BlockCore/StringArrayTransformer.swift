//
//  StringArrayTransformer.swift
//  Sex8BlockExtension
//
//  Created by virus1994 on 2019/12/16.
//  Copyright © 2019 ascp. All rights reserved.
//

#if os(macOS)
import Cocoa
#endif

#if canImport(UIKit)
import UIKit
#endif

@objc(StringArrayTransformer)
public class StringArrayTransformer: ValueTransformer {
    override public class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    override public class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override public func transformedValue(_ value: Any?) -> Any? {
        guard let value = value as? Data else { return nil }
        do {
            let items = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(value)
            return items
        } catch {
            print(error)
            return nil
        }
    }
    
    override public func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let value = value as? [String] else { return nil }
        do {
            let items = try NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false)
            return items
        } catch {
            print(error)
            return nil
        }
    }
}
 
