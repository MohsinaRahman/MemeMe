//
//  ViewController.swift
//  MemeMe
//
//  Created by mohsina rahman on 7/9/18.
//  Copyright © 2018 mohsina rahman. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate
{
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextView: UITextField!
    @IBOutlet weak var bottomTextView: UITextField!
    
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var topNavigation: UINavigationBar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var topTextFieldCleared = false
    var bottomTextFieldCleared = false
    var lastTextFieldSelected:UITextField? = nil
    
    let memeTextAttributes:[String: Any] =
        [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue: -3.0
    ]
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        unsubscribeToKeyboardNotifications()
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configure(topTextView, with: "TOP")
        configure(bottomTextView, with: "BOTTOM")
    }
    
    @IBAction func shareMeme(_ sender: Any)
    {
        let image = generateMemedImage()
        let controller = UIActivityViewController(activityItems:[image], applicationActivities: nil)
        controller.completionWithItemsHandler = activityViewControllerCompletion
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImage(_ sender: Any)
    {
        pickAnImage(from: .photoLibrary)
    }
    
    @IBAction func pickImageFromCamera(_ sender: Any)
    {
        pickAnImage(from: .camera)
    }
    
    func configure(_ textField: UITextField, with defaultText: String)
    {
        textField.text = defaultText
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.delegate = self
    }
    
    func pickAnImage(from source: UIImagePickerControllerSourceType)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = source
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ imagePickerController: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            imagePickerView.image = image
        }
    }
    
    func imagePickerControllerDidCancel(_ imagePickerController: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    func subscribeToKeyboardNotifications()
    {
        NotificationCenter.default.addObserver(self, selector: #selector (keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications()
    {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification)
    {
        if (lastTextFieldSelected! == bottomTextView)
        {
            view.frame.origin.y -= getKeyBoardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification)
    {
        if(lastTextFieldSelected! == bottomTextView)
        {
            view.frame.origin.y = 0
            
        }
    }
    
    func getKeyBoardHeight(_ notification: Notification)->CGFloat
    {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if (topTextFieldCleared == false && textField == topTextView)
        {
            textField.text = ""
            topTextFieldCleared = true
        }
        if (bottomTextFieldCleared == false && textField == bottomTextView)
        {
            textField.text = ""
            bottomTextFieldCleared = true
        }
        lastTextFieldSelected = textField
    }
    
    func generateMemedImage() -> UIImage
    {
        showHideToolbars(hide: true)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        showHideToolbars(hide: false)
        
        return memedImage
    }
    
    func showHideToolbars(hide:Bool)
    {
        self.bottomToolBar.isHidden = hide
        self.topNavigation.isHidden = hide
    }
    
    func save()
    {
        let memedImage = generateMemedImage()
        let _ = Meme(topText: topTextView.text!, bottomText: bottomTextView.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    }
    
    func activityViewControllerCompletion(activity: UIActivityType?, completed: Bool, returnItems: [Any]?, activityError: Error?)
    {
        if completed
        {
            save()
        }
    }
}

