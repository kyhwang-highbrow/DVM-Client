//
//  HBAppTrackingTransparency.swift
//  DragonVillageM iOS
//
//  Created by mskim on 2020/09/04.
//

import Foundation
import AppTrackingTransparency

@objc class HBAppTrackingTransparency : NSObject
{
    @objc static func isAuthorized() -> Bool
    {
        if #available(iOS 14, *) {
            //return true;
            return ATTrackingManager.trackingAuthorizationStatus == ATTrackingManager.AuthorizationStatus.authorized
        } else {
            // 이전 버전에서는 인증 된 것과 같다.
            return true
        }
    }
    
    @objc static func isNotDetermined() -> Bool
    {
        if #available(iOS 14, *) {
            //return true;
            return ATTrackingManager.trackingAuthorizationStatus == ATTrackingManager.AuthorizationStatus.notDetermined
        } else {
            return true
        }
    }
    
    @available(iOS 14, *)
    @objc static func requestTrackingAuthorization(handler: @escaping (UInt) -> Void)
    {
        // @mskim
        // Objective-C <--> Swift 간 enum 전달이 안되기 때문에 Int값을 받아온 후 익명 클로저를 사용하여 enum으로 변환하여 사용하도록 함
        ATTrackingManager.requestTrackingAuthorization(
            completionHandler: {
                (status:ATTrackingManager.AuthorizationStatus) -> () in
                handler(status.rawValue)
            })
    }
}
