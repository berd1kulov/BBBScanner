//
//  ScannerModel.swift
//  BBBScanner
//
//  Created by User on 11.08.2023.
//

import Foundation

protocol ScannerPresentable: AnyObject {
  
  func startLoading()
  func stopLoading()
}

final class ScannerModel: ScannerPresentableListener {
  
  weak var presenter: ScannerPresentable?
  
  func openProduct(with code: String) {
    print(code)
  }
}

