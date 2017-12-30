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
import GooglePlaces
import GooglePlacePicker
import GoogleMaps
import Firebase

class ProfileSetupViewController: UIViewController {
    
    // MARK: - Properties
    var years = Array(18...100).map { String($0) }
    private var keyboardHelper : KeyboardHelper?
    var keyboardHeight = CGFloat()
    var location = String()
    var name = String()
    var email = String()
    
    // MARK: - Outlets
    @IBOutlet weak var agePickerView: UIPickerView!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var formStackView: UIStackView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var nextButton: PrimaryButton!
    @IBOutlet weak var nameTextField: UITextField!
    
    // MARK: - App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        agePickerView.delegate = self
        agePickerView.dataSource = self
        ageTextField.delegate = self 
        keyboardHelper = KeyboardHelper(delegate: self)
        nameTextField.text = name
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
    
    func showPicker() {
        if ageTextField.isEditing {
            let defaultFormStackViewHeight = formStackView.layer.bounds.height
            let x = self.view.bounds.height - defaultFormStackViewHeight
            let final = -((x - keyboardHeight) + 24 + 64)
            formStackView.transform = CGAffineTransform(translationX: 0.0, y: final)
        }
    }
    
    @IBAction func locationTapped(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.city
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func nextButton(_ sender: Any) {
        guard let name = nameTextField.text, let age = ageTextField.text else {
            return
        }
        
        if name.isEmpty || location.isEmpty || age.isEmpty {
            // Display error
            print("Error")
        } else {
            // Go to ProfileImageController
            print("Will go to ProfileImageController")
            guard let ageAsInt = Int(age) else {
                return
            }
            
            // Create user
            let lesbian = Lesbian(name: name, email: email, age: ageAsInt, location: location)
            print(lesbian)
            FirestoreManager.sharedInstance.createUser(email: email, user: lesbian)

            // Go to profile image setup
            performSegue(withIdentifier: profileImageSegue, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
}

extension ProfileSetupViewController: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, KeyboardNotificationDelegate, GMSAutocompleteViewControllerDelegate {
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
        ageTextField.text = String(years[row])
        ageTextField.resignFirstResponder()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        fadeIn(layer: agePickerView, duration: 1.0)
        showPicker()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        fadeOut(layer: agePickerView, duration: 1.0)
    }
    
    func keyboardWillAppear(_ info: KeyboardAppearanceInfo) {
        keyboardHeight = info.endFrame.height
    }
    
    func keyboardWillDisappear(_ info: KeyboardAppearanceInfo) {
        formStackView.transform = .identity
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print(place)
        locationButton.setTitle("\(place.name)", for: .normal)
        locationButton.setTitleColor(UIColor.black, for: .normal)
        location = place.name
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}
