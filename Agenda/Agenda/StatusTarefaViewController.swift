//
//  StatusTarefaViewController.swift
//  Agenda
//
//  Created by Bruno Omella Mainieri on 6/2/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit

class StatusTarefaViewController: UIViewController {
    
    var tarefa:Atividade!

    @IBOutlet weak var labelEntregue: UILabel!
    @IBOutlet weak var switchEntregue: UISwitch!
    @IBOutlet weak var labelAvaliado: UILabel!
    @IBOutlet weak var switchAvaliado: UISwitch!
    
    @IBOutlet weak var labelNota: UILabel!
    
    @IBOutlet weak var textNota: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchAvaliado.setOn((tarefa.avaliado == 1), animated: true)
        switchEntregue.setOn((tarefa.entregue == 1), animated: true)
        
        //se for tarefa passada
        if tarefa.dataEntrega.compare(NSDate()) == NSComparisonResult.OrderedAscending {
            labelAvaliado.hidden = false
            switchAvaliado.hidden = false
            
            if switchAvaliado.on && switchEntregue.on {
                labelNota.hidden = false
                textNota.text = tarefa.nota.stringValue;
                textNota.hidden = false
            }
        }
        //se ainda estiver para ser entregue
        else{
            labelEntregue.hidden = false
            switchEntregue.hidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.textNota.resignFirstResponder()
    }
    
    @IBAction func switchEntregueAc(sender: AnyObject) {
        if switchAvaliado.on && switchEntregue.on{
            labelNota.hidden = false
            textNota.hidden = false
        }
        else{
            labelNota.hidden = true
            textNota.hidden = true
        }
    }

    @IBAction func switchAvaliadoAc(sender: AnyObject) {
        if switchAvaliado.on && switchEntregue.on{
            labelNota.hidden = false
            textNota.hidden = false
        }
        else{
            labelNota.hidden = true
            textNota.hidden = true
        }
    }
    
    @IBAction func salvar(sender: AnyObject) {
        if switchEntregue.on {
            tarefa.entregue = 1
        }
        else{
            tarefa.entregue = 0
        }
        
        if switchAvaliado.on {
            tarefa.avaliado = 1
            tarefa.nota = (textNota.text as NSString).floatValue
        }
        else{
            tarefa.avaliado = 0
        }
        TarefaManager.sharedInstance.save();

        
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
