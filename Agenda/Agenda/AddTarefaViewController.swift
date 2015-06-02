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

        // Do any additional setup after loading the view.
        
        //Se o usuário não permitiu que usassem o calendário anteriormente, pergunta de novo lol.
        if(!em.verificaPermissao()){
            em.eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion:
                {[weak self] (granted: Bool, error: NSError!) -> Void in
                    if granted {
                        println("porra ligo");
                    } else {
                        println("Access denied")
                    }
                })
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func salvar(sender: AnyObject) {
        //MAIS REGEXES
        
        TarefaManager.sharedInstance.insertNewTarefa(textField.text, disc: materia, data: datePicker.date, tipo: self.tipoSelector.selectedSegmentIndex)
        
        
        if(em.verificaPermissao()){
            em.insertEvent(datePicker.date, nome: textField.text)
        }
        
        textField.text = ""
        
        //POPUP E TAL
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
