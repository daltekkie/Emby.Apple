//
//  MainViewController.swift
//  Emby
//
//  Created by Aaron Alexander on 11/2/15.
//
//

import UIKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

class WelcomeViewController: UIViewController {
    
    private let viewModel = WelcomeViewModel()
    private let disposeBag = DisposeBag()
    
    @IBAction func resetTutorial(sender: UIStoryboardSegue) {
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

