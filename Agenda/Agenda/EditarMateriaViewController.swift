//
//  EditarMateriaViewController.swift
//  Agenda
//
//  Created by Bruno Omella Mainieri on 6/10/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit

class EditarMateriaViewController: UIViewController {

    var materia:Materia!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navItem.title = "Editar \(materia.nomeMateria)"
        self.textField.text = materia.nomeMateria
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.textField.resignFirstResponder()
    }
    
    @IBAction func salvar(sender: AnyObject) {
        
        EventManager.sharedInstance.editaMateria(materia.nomeMateria, nomeNovo: textField.text);
        
        //REGEX AQUI
        
        materia.nomeMateria = textField.text
        
        MateriaManager.sharedInstance.save()
        
        self.navigationController?.popViewControllerAnimated(true)
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
