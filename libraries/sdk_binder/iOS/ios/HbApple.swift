//
//  HbApple.swift
//  PerpleSDK
//
//  Created by mskim on 2020/09/08.
//  Copyright © 2020 PerpleLab. All rights reserved.
//

import Foundation
import AuthenticationServices
import CommonCrypto
import Firebase

@objc class HbApple : NSObject {
    static let shared = HbApple()
    
    var window: UIWindow?
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    fileprivate var authorizeHanlder: (String, String) -> Void = {_,_ in }
    fileprivate var isLink: Bool = false
    
    public var userInfo: NSDictionary?
    
    // Initialization ------------------------------------------------
    @objc public func initApple(window: UIWindow) -> HbApple {
        print("[Hb] Initialize Apple.")
        self.window = window
        return self
    }
    
    // Public ------------------------------------------------
    @available(iOS 13, *)
    @objc public func signIn(isLink: Bool, handler: @escaping (String, String) -> Void) {
        let nonce = randomNonceString()
        
        self.currentNonce = nonce
        self.authorizeHanlder = handler
        self.isLink = isLink;
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        // delegate를 사용하여 link를 않고 또한 내부에서 firebase 처리를 하게 됨
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc public func signOut() {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }
}

// 인증 처리
extension HbApple: ASAuthorizationControllerDelegate {
    
    // 인증 관련 핵심 로직
    // 다른 로그인 방법들과는 다르게 클래스 내부에서 Firebase 로직도 처리함
    @available(iOS 13, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            
            self.userInfo = self.getProfileJsonStr(appleIDCredential: appleIDCredential)
            
            if (self.isLink) {
                (PerpleSDK.sharedInstance() as! PerpleSDK).mFirebase.link(with: credential, providerId: "apple.com") { (result: String?, info: String?) in
                    self.authorizationLink(authResult: result, info: info)
                }
            }
            else {
                (PerpleSDK.sharedInstance() as! PerpleSDK).mFirebase.signIn(with: credential, providerId: "apple.com") { (result: String?, info: String?) in
                    self.authorizationSignIn(authResult: result, info: info)
                }
            }
        }
    }
    
    @available(iOS 13, *)
    private func authorizationSignIn(authResult: String?, info: String?) {
        if (authResult == "success") {
            self.authorizeHanlder("success", self.getLoginInfo(baseInfo: info ?? ""))
        }
        else {
            self.authorizeHanlder("fail", info ?? "")
        }
    }

    @available(iOS 13, *)
    private func authorizationLink(authResult: String?, info: String?) {
        if (authResult == "success") {
            self.authorizeHanlder("success", self.getLoginInfo(baseInfo: info ?? ""))
        }
        else {
            do {
                guard let jsonData = info?.data(using: .utf8) else {
                    return
                }
                let decoder = JSONDecoder()
                let dict = try decoder.decode(Dictionary<String, String>.self, from: jsonData)
                
                let subcode = dict["subcode"]
                if (subcode == "CREDENTIAL_ALREADY_IN_USE") {
                    self.authorizeHanlder("already_in_use", self.getLoginInfo(baseInfo: info ?? ""))
                }
                else {
                    self.authorizeHanlder("fail", info ?? "")
                }
            }
            catch {
                self.authorizeHanlder("fail", info ?? "")
            }
        }
    }
    
    @available(iOS 13, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
        let authError = error as! ASAuthorizationError
        if (authError.code == ASAuthorizationError.canceled) {
            self.authorizeHanlder("cancel", error.localizedDescription)
        }
        else {
            self.authorizeHanlder("fail", error.localizedDescription)
        }
    }
    
    func getLoginInfo(baseInfo: String) -> String {
        do {
            var dict: [String:Any]
            
            // baseInfo를 dictionary로 변환
            let jsonData = baseInfo.data(using: .utf8)!
            dict = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:Any]
            
            dict["apple"] = self.userInfo
            
            let retJsonData = try JSONSerialization.data(withJSONObject: dict, options:[])
            return String(data: retJsonData, encoding: .utf8)!
        }
        catch {
            return ""
        }
    }
    
    @available(iOS 13, *)
    private func getProfileJsonStr(appleIDCredential: ASAuthorizationAppleIDCredential) -> NSDictionary {
        let userIdentifier = appleIDCredential.user
        let email = appleIDCredential.email
        
        return [
            "id" : userIdentifier,
            "name" : email ?? "anonymous@apple.com", // platform server에 저장함
            "providerId" : "apple.com",
        ]
    }
}

extension HbApple: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return window ?? UIWindow()
    }
}

// 암호화, 노티 처리
extension HbApple {
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("fci21038vbnek100ekvmc0838dj0oozz3513kd-dkfnjdbq0df-d3n3mdpdfqzdf235")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }

        // @mskim : Deploy target 11.0 이상이어야 CryptoKit를 사용할 수 있다.
    //    @available(iOS 13, *)
    //    private func sha256(_ input: String) -> String {
    //      let inputData = Data(input.utf8)
    //      let hashedData = SHA256.hash(data: inputData)
    //      let hashString = hashedData.compactMap {
    //        return String(format: "%02x", $0)
    //      }.joined()
    //
    //      return hashString
    //    }

    /**
     * Example SHA 256 Hash using CommonCrypto
     * CC_SHA256 API exposed from from CommonCrypto-60118.50.1:
     * https://opensource.apple.com/source/CommonCrypto/CommonCrypto-60118.50.1/include/CommonDigest.h.auto.html
     **/
    func sha256(_ str: String) -> String {
        if let strData = str.data(using: String.Encoding.utf8) {
            /// #define CC_SHA256_DIGEST_LENGTH     32
            /// Creates an array of unsigned 8 bit integers that contains 32 zeros
            var digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
     
            /// CC_SHA256 performs digest calculation and places the result in the caller-supplied buffer for digest (md)
            /// Takes the strData referenced value (const unsigned char *d) and hashes it into a reference to the digest parameter.
            _ = strData.withUnsafeBytes {
                // CommonCrypto
                // extern unsigned char *CC_SHA256(const void *data, CC_LONG len, unsigned char *md)  -|
                // OpenSSL                                                                             |
                // unsigned char *SHA256(const unsigned char *d, size_t n, unsigned char *md)        <-|
                CC_SHA256($0.baseAddress, UInt32(strData.count), &digest)
            }
     
            var sha256String = ""
            /// Unpack each byte in the digest array and add them to the sha256String
            for byte in digest {
                sha256String += String(format:"%02x", UInt8(byte))
            }
     
            return sha256String
        }
        return ""
    }
    
    private func postNotificationSignInSuccess() {
        NotificationCenter.default.post(name: FirebaseAuthenticationNotification.signInSuccess.notificationName, object: nil)
    }

    private func postNotificationSignInError() {
        NotificationCenter.default.post(name: FirebaseAuthenticationNotification.signInError.notificationName, object: nil)
    }

    private func postNotificationSignOutSuccess() {
        NotificationCenter.default.post(name: FirebaseAuthenticationNotification.signOutSuccess.notificationName, object: nil)
    }

    private func postNotificationSignOutError() {
        NotificationCenter.default.post(name: FirebaseAuthenticationNotification.signOutError.notificationName, object: nil)
    }
}

enum FirebaseAuthenticationNotification: String {
    case signOutSuccess
    case signOutError
    case signInSuccess
    case signInError

    var notificationName: NSNotification.Name {
        return NSNotification.Name(rawValue: self.rawValue)
    }
}
