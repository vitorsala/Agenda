//
//  AddMateriaViewController.swift
//  Agenda
//
//  Created by Bruno Omella Mainieri on 6/1/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit

class AddMateriaViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.textField.resignFirstResponder()
    }
    
    @IBAction func salvarMateria(sender: AnyObject) {
        
        //COLOCAR UM REGEX BEM LEGAL AQUI
		let regexString = "^[a-zA-Z]([a-z0-9]| )*$"

		var error : NSError? = nil

		let regex = NSRegularExpression(pattern: regexString, options: NSRegularExpressionOptions.CaseInsensitive, error: &error)

		if (error != nil){
			println("Error: \(error?.localizedDescription)")
			return
		}

		let name : String = textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())

		if regex!.numberOfMatchesInString(name, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, count(name))) > 0{

			if MateriaManager.sharedInstance.jaExisteMateria(self.textField.text) {
				//nao deixa inserir com nome repetido
				let alert = UIAlertController(title: "A matéria não foi adicionada", message: "Já existe uma matéria de nome \(self.textField.text)", preferredStyle: UIAlertControllerStyle.Alert)
				alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
					
				}))
				self.presentViewController(alert, animated: true, completion: nil)
				self.textField.text = ""
				return
			}
			
			//salva dentro deste metodo
			MateriaManager.sharedInstance.insertNewMateria(textField.text)
			self.textField.text = ""
			
			self.navigationController?.popViewControllerAnimated(true)
		}
		else{
			let alert = UIAlertController(title: "A matéria não foi adicionada", message: "O nome só pode possuir letras, números e espaços", preferredStyle: UIAlertControllerStyle.Alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in

			}))
			self.presentViewController(alert, animated: true, completion: nil)
		}
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
