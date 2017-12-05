//
//  UIColor+colorDict.swift
//  Bow Ties
//
//  Created by Luis  Costa on 05/12/17.
//  Copyright © 2017 Razeware. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
  static func color(dict: [String: Any]) -> UIColor? {
    guard let red = dict["red"] as? NSNumber, let green = dict["green"] as? NSNumber, let blue = dict["blue"] as? NSNumber else {
        return nil
    }
    return UIColor(red: CGFloat(truncating: red) / 255 , green: CGFloat(truncating: green) / 255, blue: CGFloat(truncating: blue) / 255, alpha: 1)
  }
}
