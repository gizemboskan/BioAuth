//
//  ViewController.swift
//  BioAuth
//
//  Created by Gizem Boskan on 13.04.2022.
//

import UIKit
import LocalAuthentication

final class ViewController: UIViewController {
    
    var context = LAContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context.localizedCancelTitle = "Cancel!"
        // If you don't want to fallback, give an empty string!
        context.localizedFallbackTitle = "Fallback!"
        context.localizedReason = "The app needs your authentication"
        // To give a resuable duration for touchID. Here the maximum is 5 min.
        context.touchIDAuthenticationAllowableReuseDuration = 2.0
        evaluatePolicy()
    }
    
    private func evaluatePolicy() {
        var errorCanEval: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &errorCanEval) {
            
            switch context.biometryType {
            case .faceID:
                print("faceID")
            case .touchID:
                print("touchID")
            case .none:
                print("none")
            @unknown default:
                print("unknown default")
            }
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: "Fallback title - override reason") { (success, error) in
                print(success)
                if let err = error {
                    let evalErrCode = LAError(_nsError: err as NSError)
                    switch evalErrCode.code {
                    case LAError.Code.userCancel:
                        print("user cancelled")
                    case LAError.Code.appCancel:
                        print("app cancelled")
                    case LAError.Code.userFallback:
                        print("fallback")
                        self.promptToCode()
                    case LAError.Code.authenticationFailed:
                        print("authentication failed")
                    default:
                        print("other error")
                    }
                }
            }
            //            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { (t) in
            //                self.context.invalidate()
            //            }
        } else {
            print("can't evaluate")
            print(errorCanEval?.localizedDescription ?? "no error desc.")
            if let err = errorCanEval {
                let evalErrCode = LAError(_nsError: err as NSError)
                switch evalErrCode.code {
                case LAError.Code.biometryNotEnrolled:
                    print("Not Enrolled")
                    self.sendToSettings()
                default:
                    print("other error")
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func sendToSettings() {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Bio Enrollment",
                                       message: "Would you like to enroll now?",
                                       preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
            
            ac.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            self.present(ac, animated: true, completion: nil)
        }
    }
    
    private func promptToCode() {
        DispatchQueue.main.async {
            
            let ac = UIAlertController(title: "Enter Code",
                                       message: "Enter your user code",
                                       preferredStyle: .alert)
            ac.addTextField { (textField) in
                textField.placeholder = "Enter User Code"
                textField.keyboardType = .numberPad
                textField.isSecureTextEntry = true
            }
            
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                print(ac.textFields?.first?.text ?? "no value")
            }))
            
            self.present(ac, animated: true, completion: nil)
        }
    }
}
