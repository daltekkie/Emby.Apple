//
//  ServerSelectionViewController.swift
//  Emby
//
//  Created by Aaron Alexander on 11/5/15.
//
//

import UIKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

class ServerSelectionViewController: UIViewController {
    
    private let viewModel = ServerSelectionViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}