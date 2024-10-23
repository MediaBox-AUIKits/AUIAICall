//
//  MainViewController.swift
//  Example
//
//  Created by Bingo on 2024/1/10.
//

import UIKit
import AUIAICall

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
#if DEBUG
        
        
#endif
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showListViewController(ani: false)
        }
    }
    
    func showListViewController(ani: Bool) {
        let vc = AUIAICallMainViewController()
        self.navigationController?.pushViewController(vc, animated: false)
    }
}

