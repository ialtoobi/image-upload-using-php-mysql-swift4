//
//  ViewController.swift
//  imageUpload
//
//  Created by Mohammed Altoobi on 9/13/18.
//  Copyright © 2018 Mohammed Altoobi. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController{

    var imagePicker:UIImagePickerController!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func takeImage(_ sender: Any) {

        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.isEditing = true
        imagePicker.setEditing(true, animated: true)
        imagePicker.sourceType = .photoLibrary
        //imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)

    }
    
    @IBAction func uploadImage(_ sender: Any) {
        
        self.showActivityIndicator()
        
        //Post URL
        let url = "http://localhost:8888/swift/image-upload/upload.php"
        
        //Getting text from textFiled!
        let name = nameField.text!
        let age = ageField.text!
        
        //Call Parameters
        let params: Parameters = ["name": name,"age": age]
        
        //Checking image place holder
        let image = #imageLiteral(resourceName: "placeholder-image")
        
        //Checking if empty name or age fileds
        if name.isEmpty || age.isEmpty{
            
            self.hideActivityIndicator()
            myAlert(title: "Error", msg: "Make sure you enter all the required information!")
        }
        
        //Checking if image is not selected!!
        else if imageView.image == image
        {
            self.hideActivityIndicator()
            myAlert(title: "Error", msg: "Make sure you choose an image!")

        }else{
            
            let imageToUpload = self.imageView.image!
            
            Alamofire.upload(multipartFormData:
                {
                    (multipartFormData) in
                    
                    multipartFormData.append(UIImageJPEGRepresentation(imageToUpload, 0.8)!, withName: "image", fileName: self.generateBoundaryString(), mimeType: "image/jpeg")
                    for (key, value) in params
                    {
                        multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                    }
            }, to:url,headers:nil)
            { (result) in
                switch result {
                case .success(let upload,_,_ ):
                    upload.uploadProgress(closure: { (progress) in
                        //Print progress
                        self.showActivityIndicator()
                    })
                    upload.responseJSON
                        { response in
                            //print response.result
                            if let result = response.result.value {
                                
                                //Calling response from API
                                let message = (result as AnyObject).value(forKey: "message") as! String
                                let status = (result as AnyObject).value(forKey: "status") as! String
                                
                                //Case Success
                                if status == "1" {
                                    
                                    self.hideActivityIndicator()
                                    print("Your Results are ====> ",result)
                                    self.myAlert(title: "Data Upload", msg: message)
                                    
                                    
                                    self.imageView.image = #imageLiteral(resourceName: "placeholder-image")
                                    self.nameField.text = ""
                                    self.ageField.text = ""
                                    
                                }else{
                                    self.hideActivityIndicator()
                                    self.myAlert(title: "Error Uploading", msg: message)
                                }
                            }
                            
                    }
                case .failure(let encodingError):
                    print(encodingError)
                    break
                }
            }
        }
    }

}

//image Picker Extension
extension ViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
        //picker.showsCameraControls = true
        imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        picker.dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//Another Extension
extension ViewController{
    
    func myAlert(title:String, msg:String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Close", style: .default, handler: nil)
        alertController.addAction(okayAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString).jpeg"
    }
}

//Call ActivityIndicator
extension UIViewController {
    func showActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        activityIndicator.backgroundColor = UIColor(red:0.16, green:0.17, blue:0.21, alpha:1)
        activityIndicator.layer.cornerRadius = 6
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.startAnimating()
        //UIApplication.shared.beginIgnoringInteractionEvents()
        
        activityIndicator.tag = 100 // 100 for example
        
        // before adding it, you need to check if it is already has been added:
        for subview in view.subviews {
            if subview.tag == 100 {
                print("already added")
                return
            }
        }
        
        view.addSubview(activityIndicator)
    }
    
    func hideActivityIndicator() {
        let activityIndicator = view.viewWithTag(100) as? UIActivityIndicatorView
        activityIndicator?.stopAnimating()
        
        // I think you forgot to remove it?
        activityIndicator?.removeFromSuperview()
        //UIApplication.shared.endIgnoringInteractionEvents()
    }
}




