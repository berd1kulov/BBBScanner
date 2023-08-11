//
//  ScannerOverlayPreviewLayer.swift
//  BBBScanner
//
//  Created by User on 11.08.2023.
//

import AVFoundation
import UIKit

class ScannerOverlayPreviewLayer: AVCaptureVideoPreviewLayer {
  
  // MARK: - OverlayScannerPreviewLayer
  var cornerLength: CGFloat = 30
  
  var lineWidth: CGFloat = 4
  var lineColor: UIColor = UIColor(named: "brand-1") ?? .white
  
  var maskSize: CGSize = CGSize(width: 200, height: 200)
  
  var rectOfInterest: CGRect {
    metadataOutputRectConverted(fromLayerRect: maskContainer)
  }
  
  override var frame: CGRect {
    didSet {
      setNeedsDisplay()
    }
  }
  
  var maskContainer: CGRect {
    CGRect(x: (bounds.width / 2) - (maskSize.width / 2),
           y: (bounds.height / 2) - (maskSize.height / 2),
           width: maskSize.width, height: maskSize.height)
  }
  
  // MARK: - Drawing
  override func draw(in ctx: CGContext) {
    super.draw(in: ctx)
    
    // MARK: - Background Mask
    let path = CGMutablePath()
    path.addRect(bounds)
    path.addRoundedRect(in: maskContainer, cornerWidth: 20, cornerHeight: 20)
    
    let maskLayer = CAShapeLayer()
    maskLayer.path = path
    maskLayer.fillColor = backgroundColor
    maskLayer.fillRule = .evenOdd
    addSublayer(maskLayer)
    
    let shapePath = UIBezierPath(roundedRect: maskContainer, cornerRadius: 20)
    
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = shapePath.cgPath
    shapeLayer.strokeColor = lineColor.cgColor
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.lineWidth = lineWidth
    addSublayer(shapeLayer)
  }
}
