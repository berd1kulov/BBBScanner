//
//  ViewController.swift
//  BBBScanner
//
//  Created by User on 11.08.2023.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    configureProperties()
    layout()
  }

  
  //MARK: Private
  private let button = UIButton()
  
  private func configureProperties() {
    button.setTitle("SCAN", for: .normal)
    button.setTitleColor(.link, for: .normal)
    button.addTarget(self, action: #selector(didScan), for: .touchUpInside)
  }
  
  private func layout() {
    view.addSubview(button)
    button.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.height.equalTo(50)
      $0.width.equalTo(200)
    }
  }
  
  @objc private func didScan() {
    let viewController = ScannerViewController()
    let model = ScannerModel()
    viewController.listener = model
    model.presenter = viewController
    navigationController?.pushViewController(viewController, animated: true)
  }

}

