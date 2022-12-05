//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by Krishna Prakash on 05/12/22.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var ImageView: UIImageView!
    
    
    @IBOutlet weak var NameText: UITextField!
    
    @IBOutlet weak var ArtistText: UITextField!
    
    @IBOutlet weak var YearText: UITextField!
    
    @IBOutlet weak var SaveBTN: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingID: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            SaveBTN.isHidden = true
            // Retrive Data from Core Data
//            let stringUUID = chosenPaintingID!.uuidString
//            print(stringUUID)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = chosenPaintingID?.uuidString
            //predicate
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String {
                            NameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            ArtistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            YearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            ImageView.image = image
                        }
                    }
                }
            }catch{
                print("Error")
            }
            
        } else {
            //if chosen painting is empty these all are empty
            SaveBTN.isHidden = false
            SaveBTN.isEnabled = false
            NameText.text = ""
            ArtistText.text = ""
            YearText.text = ""
        }

       
        
        // Recognizers
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        ImageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        ImageView.addGestureRecognizer(imageTapRecognizer)
        
    }
    
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        ImageView.image = info[.originalImage] as? UIImage
        SaveBTN.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    
    @IBAction func SaveBTNClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //Attributes
        newPainting.setValue(NameText.text!, forKey: "name")
        newPainting.setValue(ArtistText.text!, forKey: "artist")
        
        if let year = Int(YearText.text!){
            newPainting.setValue(year, forKey: "year")
        }
        
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = ImageView.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("Success")
        } catch {
            print("Error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
}
