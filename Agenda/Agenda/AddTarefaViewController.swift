//
//  AddTarefaViewController.swift
//  Agenda
//
//  Created by Bruno Omella Mainieri on 6/1/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit
import EventKit

class AddTarefaViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tipoSelector: UISegmentedControl!
    
    
    var materia:Materia!
    let em:EventManager = EventManager.sharedInstance;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
                
        if(em.verificaPermissao()){
            em.criaCalendario();
        }
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
        //MAIS REGEXES

		let name : String = textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())

		if Util.nameRegex(name){

			//salva dentro desse metodo
			TarefaManager.sharedInstance.insertNewTarefa(textField.text, disc: materia, data: datePicker.date, tipo: self.tipoSelector.selectedSegmentIndex)


			if(em.verificaPermissao()){
				em.insertEvent(datePicker.date, nome: textField.text, materia: materia.nomeMateria);
			}

			textField.text = ""

			self.navigationController?.popViewControllerAnimated(true)
		}
		else{
			let alert = UIAlertController(title: "A tarefa não foi adicionada", message: "O nome só pode possuir letras, números e espaços", preferredStyle: UIAlertControllerStyle.Alert)
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
