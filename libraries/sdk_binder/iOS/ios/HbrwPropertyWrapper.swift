//
//  HbrwPropertyWrapper.swift
//  sdk_binder
//
//  Created by 황기영 on 2023/12/29.
//  Copyright © 2023 PerpleLab. All rights reserved.
//


import Foundation
//#import "PerpleSDK"
/**
 HiveSDK rootViewController에 접근하는 propertyWrapper
 */
@propertyWrapper
struct SharedViewController {
    private var value: UIViewController?
    var wrappedValue: UIViewController? {
        get {
            return PerpleSDK.shared().mViewController;
        }
    }

    init(wrappedValue initialValue: UIViewController? = nil) {
        self.value = initialValue;
    }
}
