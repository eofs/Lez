//
//  ProfileSetupViewController.swift
//  Lez
//
//  Created by Antonija on 23/12/2017.
//  Copyright © 2017 Antonija. All rights reserved.
//

import UIKit
import KeyboardHelper
import SnapKit

class ProfileSetupViewController: UIViewController {
    
    // MARK: - Properties
    var years = Array(18...100).map { String($0) }
    private var keyboardHelper : KeyboardHelper?
    
    // MARK: - Outlets
    @IBOutlet weak var agePickerView: UIPickerView!
    @IBOutlet weak var ageTextFIeld: UITextField!
    @IBOutlet weak var formStackView: UIStackView!
    
    // MARK: - App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        agePickerView.delegate = self
        agePickerView.dataSource = self
        ageTextFIeld.delegate = self
        keyboardHelper = KeyboardHelper(delegate: self)
    }

    
    // MARK: - Methods
    func fadeOut(layer: UIView, duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            layer.alpha = 0
        }
    }
    
    func fadeIn(layer: UIView, duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            layer.alpha = 1
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}

extension ProfileSetupViewController: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, KeyboardNotificationDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return years.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return years[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(String(years[row]))
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        fadeIn(layer: agePickerView, duration: 1.0)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        fadeOut(layer: agePickerView, duration: 1.0)
    }
    
    func keyboardWillAppear(_ info: KeyboardAppearanceInfo) {
        let defaultFormStackViewHeight = formStackView.layer.bounds.height
        let keyboardHeight = info.endFrame.height
        let x = self.view.bounds.height - defaultFormStackViewHeight // 228
        let final = -((x - keyboardHeight) + 16)
        print(self.view.bounds.height)
        formStackView.transform = CGAffineTransform(translationX: 0.0, y: final)
    }
    
    func keyboardWillDisappear(_ info: KeyboardAppearanceInfo) {
        formStackView.transform = .identity
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
