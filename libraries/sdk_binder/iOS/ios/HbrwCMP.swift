//  HbrwCMP.swift
//  sdk_binder
//
//  Created by 김문성 on 2023/12/22.
//  Copyright © 2023 Highbrow. All rights reserved.
//

import Foundation
import UserMessagingPlatform

/*
 * HiveSDK Utilities Class
 */
@objc class HbrwCMP : NSObject {
    @objc static let shared = HbrwCMP()
    private override init() { super.init() }

    @SharedViewController private var viewController: UIViewController?

    /**
     1. update consent information : requestConsentInfoUpdate
     2. load consent form if needed : loadAndPresentIfRequired
     */
    @objc func loadConsentIfNeeded(_ onFinish: @escaping PerpleSDKCallback) {
        let viewController = self.viewController
        if (viewController == nil) {
            return onFinish("fail", "need call after didFinishLaunchingWithOptions.")
        }

        // for testing if needed, check test device id first. see func getTestSettings
        let param = PerpleSDK.isDebug() ? getTestSettings() : nil

        // Request an update for the consent information.
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: param) {
            [weak self] requestConsentError in
            guard let self else { return }

            if let consentError = requestConsentError {
                // Consent gathering failed.
                return onFinish("fail", consentError.localizedDescription)
            }

            UMPConsentForm.loadAndPresentIfRequired(from: viewController!) {
                [weak self] loadAndPresentError in
                guard let self else { return }

                if let consentError = loadAndPresentError {
                    // Consent gathering failed.
                    return onFinish("fail", consentError.localizedDescription)
                }

                // Consent has been gathered.
                onFinish("success", "")
            }
        }
    }

    @objc func canRequestAds() -> Bool {
        return UMPConsentInformation.sharedInstance.canRequestAds
    }

    @objc func requirePrivacyOption() -> Bool {
        return UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus == .required
    }

    @objc func presentPrivacyOptionForm(_ onFinish: @escaping PerpleSDKCallback) {
        let viewController = self.viewController
        if (viewController == nil) {
            return onFinish("fail", "need call after didFinishLaunchingWithOptions.")
        }

        UMPConsentForm.presentPrivacyOptionsForm(from: viewController!) {
            [weak self] formError in
            guard let self, let formError else { return }

            // Handle the error.
            onFinish("fail", formError.localizedDescription)
        }
    }
}

/**
 extension for Test functions
 */
extension HbrwCMP {
    /**
     - to find test device id, search the text below in console.
     - <UMP SDK> To enable debug mode for this device, set: UMPDebugSettings.testDeviceIdentifiers

     Samples :
     - iPhone 11 : B9E98349-243E-4B4B-8571-ADF941C94F35
     */
    private func getTestSettings() -> UMPRequestParameters {
        let parameters = UMPRequestParameters()
        let debugSettings = UMPDebugSettings()

        debugSettings.testDeviceIdentifiers = ["B9E98349-243E-4B4B-8571-ADF941C94F35"]
        debugSettings.geography = .EEA
        parameters.debugSettings = debugSettings
        return parameters
    }

    private func reset() {
        UMPConsentInformation.sharedInstance.reset()
    }
}
