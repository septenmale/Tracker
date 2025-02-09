//
//  UIColorTransformer.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 09/02/2025.
//

import UIKit

@objc
final class UIColorTransformer: ValueTransformer {
    
    static func register() {
        ValueTransformer.setValueTransformer(
            UIColorTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: UIColorTransformer.self))
        )
    }
    
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let color = value as? UIColor else { return nil }
        return try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data as Data)
    }
    
}
