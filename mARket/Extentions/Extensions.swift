//
//  Extensions.swift
//  mARket
//
//  Created by Michael Benton on 4/16/18.
//  Copyright © 2018 Michael Benton. All rights reserved.
//

import UIKit

extension UIView{
    func addConstraintsWithFormat(format: String, views: UIView...){
        
        var viewsDictionary = [String: UIView]()
        
        for (index, view) in views.enumerated(){
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
        
    }
}

extension Double{
    var metersToMiles: Double {
        return self/1609.34
    }
}
