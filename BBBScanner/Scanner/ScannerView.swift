//
//  ScannerView.swift
//  BBBScanner
//
//  Created by User on 11.08.2023.
//

import UIKit
import AVFoundation
import SnapKit

enum ScannerViewEvent {
  case scannedCode(String)
  case sendAll
}

protocol ScannerViewDelegate: AnyObject {
  func onViewEvent(_ event: ScannerViewEvent)
}

class ScannerView: CodeInitedView {
  //MARK: Public
  weak var delegate: ScannerViewDelegate?
  
  override func commonInit() {
    super.commonInit()
    
    configureProperties()
    layout()
  }
  
  func rescan() {
    guard let captureSession else { return }
    DispatchQueue.global(qos: .background).async {
      captureSession.startRunning()
    }
  }
  
  func updateStack(codes: Set<String>) {
    codesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    codes.forEach { code in
      let label = UILabel()
      label.font = .systemFont(ofSize: 8)
      label.textColor = .black
      label.text = code
      codesStack.addArrangedSubview(label)
    }
  }
  
  //MARK: Private
  private var captureSession: AVCaptureSession?
  private var previewLayer: ScannerOverlayPreviewLayer?
  
  private let send = UIButton()
  private let codesStack = UIStackView()
  
  private func configureProperties() {
    backgroundColor = .white
    
    send.setTitle("Отправить все", for: .normal)
    send.setTitleColor(UIColor.black, for: .normal)
    send.titleLabel?.font = .systemFont(ofSize: 14)
    send.addTarget(self, action: #selector(didCancelTapped), for: .touchUpInside)
    
    codesStack.axis = .vertical
    codesStack.spacing = 4
    
    getCameraPreview()
  }
  
  private func layout() {
    
    addSubview(send)
    send.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(safeAreaLayoutGuide).inset(40)
    }
    
    addSubview(codesStack)
    codesStack.snp.makeConstraints { make in
      make.leading.top.equalTo(safeAreaLayoutGuide).inset(16)
      make.width.equalTo(200)
    }
  }
  
  private func getCameraPreview() {
    captureSession = AVCaptureSession()
    guard let captureSession else { return }
    
    guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
    
    let videoInput: AVCaptureDeviceInput
    do {
      videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
    } catch { return }
    
    if (captureSession.canAddInput(videoInput)){
      captureSession.addInput(videoInput)
    } else { return }
    
    let metadataOutput = AVCaptureMetadataOutput()
    if (captureSession.canAddOutput(metadataOutput)) {
      captureSession.addOutput(metadataOutput)
      metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
      metadataOutput.metadataObjectTypes = [.code128]
    } else { return }
    
    previewLayer = ScannerOverlayPreviewLayer(session: captureSession)
    guard let previewLayer else { return }
    
    previewLayer.frame = layer.bounds
    previewLayer.maskSize = CGSize(width: UIScreen.main.bounds.width - 64, height: 150)
    previewLayer.backgroundColor = UIColor.white.cgColor
    previewLayer.videoGravity = .resizeAspectFill
    layer.addSublayer(previewLayer) // add preview layer to your view
    metadataOutput.rectOfInterest = previewLayer.rectOfInterest
    
    DispatchQueue.global(qos: .background).async {
      captureSession.startRunning() // start capturing
    }
  }
  
  @objc private func didCancelTapped() {
    delegate?.onViewEvent(.sendAll)
  }
}

extension ScannerView: AVCaptureMetadataOutputObjectsDelegate {
  func metadataOutput(
    _ output: AVCaptureMetadataOutput,
    didOutput metadataObjects: [AVMetadataObject],
    from connection: AVCaptureConnection
  ) {
    guard let captureSession else { return }
    DispatchQueue.global(qos: .background).async {
      captureSession.stopRunning() // stop scanning after receiving metadata output
    }
    if let metadataObject = metadataObjects.first {
      guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
      guard let codeString = readableObject.stringValue else { return }
      AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
      self.delegate?.onViewEvent(.scannedCode(codeString))
    }
  }
}
