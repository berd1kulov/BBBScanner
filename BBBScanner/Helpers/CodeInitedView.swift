//
//  CodeInitedView.swift
//  BBBScanner
//
//  Created by User on 11.08.2023.
//

import UIKit

class CodeInitedView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func commonInit() {}
}
