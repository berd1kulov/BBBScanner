//
//  ScannerViewController.swift
//  BBBScanner
//
//  Created by User on 11.08.2023.
//

import UIKit

protocol ScannerPresentableListener: AnyObject {
  func openProduct(with code: String)
}

final class ScannerViewController: BaseViewController<ScannerView>, ScannerPresentable {
  
  weak var listener: ScannerPresentableListener?
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    title = "Сканер"
    navigationController?.setNavigationBarHidden(false, animated: true)
    
    if isScanned {
      isScanned = false
      rootView.rescan()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    rootView.delegate = self
    
    ai.addLoader(to: rootView)
  }
  
  func startLoading() {
    ai.startAnimating()
  }
  
  func stopLoading() {
    ai.stopAnimating()
  }
  
  func showAlert(with text: String) {
    let ac = UIAlertController(
      title: text,
      message: nil,
      preferredStyle: .alert
    )
    ac.addAction(UIAlertAction(title: "Отправить", style: .default, handler: { action in
      self.showShareProduct(code: text)
    }))
    
    ac.addAction(UIAlertAction(title: "Добавить в список", style: .default, handler: { action in
      self.codeList.insert(text)
      self.rootView.updateStack(codes: self.codeList)
      self.isScanned = false
      self.rootView.rescan()
    }))
    
    ac.addAction(UIAlertAction(title: "Скопировать", style: .default, handler: { action in
      UIPasteboard.general.string = text
      self.isScanned = false
      self.rootView.rescan()
    }))
    
    ac.addAction(UIAlertAction(title: "Повторно сканировать", style: .default, handler: { action in
      self.isScanned = false
      self.rootView.rescan()
    }))
    
    ac.addAction(UIAlertAction(title: "Отменить", style: .default, handler: { action in
      self.navigationController?.popViewController(animated: true)
    }))
    present(ac, animated: true)
  }
  
  //MARK: Private
  private let ai = LoadableView()
  private var isScanned = false
  private var codeList: Set<String> = Set<String>()
  
  private func showShareProduct(code: String) {
    let activityViewController = UIActivityViewController(activityItems: [code], applicationActivities: nil)
    activityViewController.popoverPresentationController?.sourceView = self.view
    activityViewController.completionWithItemsHandler = { activity, success, items, error in
      self.showAlert(with: code)
    }
    self.present(activityViewController, animated: true, completion: nil)
  }
}

extension ScannerViewController: ScannerViewDelegate {
  func onViewEvent(_ event: ScannerViewEvent) {
    switch event {
    case .scannedCode(let code):
      self.isScanned = true
      self.showAlert(with: code)
    case .sendAll:
      let activityViewController = UIActivityViewController(activityItems: Array(codeList), applicationActivities: nil)
      activityViewController.popoverPresentationController?.sourceView = self.view
      activityViewController.completionWithItemsHandler = { activity, success, items, error in
        self.isScanned = false
        self.rootView.rescan()
      }
      self.present(activityViewController, animated: true, completion: nil)
    }
  }
}
