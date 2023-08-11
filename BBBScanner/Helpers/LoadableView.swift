//
//  LoadableView.swift
//  BBBScanner
//
//  Created by User on 11.08.2023.
//

import UIKit

enum Maybe<Model> {
  case just(Model)
  case nothing
}

enum ViewState<ViewModel> {
  case loading
  case loaded(ViewModel)
  
  init<Model>(from maybe: Maybe<Model>, transfrom: (Model) -> ViewModel){
    switch maybe {
    case .just(let model):
      self = ViewState.loaded(transfrom(model))
    case .nothing:
      self = ViewState.loading
    }
  }
}


class LoadableView: CodeInitedView {
  override func commonInit() {
    super.commonInit()
    ai.color = UIColor(named: "brand-1") ?? .lightGray
    ai.lineWidth = 4.5
    backgroundColor = UIColor.white.withAlphaComponent(0.7)
    isHidden = true
    
    addSubview(ai)
    ai.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.size.lessThanOrEqualTo(44)
    }
  }
  
  func apply<ViewModel>(viewState: ViewState<ViewModel>, _ closure: (ViewModel) -> Void = { _ in }) {
    switch viewState {
    case let .loaded(viewModel):
      stopAnimating()
      closure(viewModel)
    case .loading:
      startAnimating()
    }
  }
  
  func startAnimating() {
    isHidden = false
    ai.startAnimating()
  }
  
  func stopAnimating() {
    isHidden = true
    ai.stopAnimating()
  }
  
  func addLoader(to view: UIView) {
    view.insertSubview(self, at: 0)
    self.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  // MARK: Private
  private let ai = MaterialIndicatorView()
}


class MaterialIndicatorView: UIView {
  
  var color: UIColor = .red {
    didSet {
      indicator.strokeColor = color.cgColor
      indicator.shadowColor = color.cgColor
    }
  }
  
  var lineWidth: CGFloat = 4.5 {
    didSet {
      indicator.lineWidth = lineWidth
      backGrayCircle.lineWidth = lineWidth
      setNeedsLayout()
    }
  }
  
  private let backGrayCircle = CAShapeLayer()
  private let indicator = CAShapeLayer()
  private let animator = MaterialIndicatorAnimator()
  
  private var isAnimating = false
  
  convenience init() {
    self.init(frame: .zero)
    self.setup()
  }
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
  }
  
  private func setup() {
    backGrayCircle.strokeColor = UIColor(rgb: 0xF7F7F7).cgColor
    backGrayCircle.fillColor = nil
    backGrayCircle.lineWidth = lineWidth
    backGrayCircle.strokeStart = 0.0
    backGrayCircle.strokeEnd = (2.0 * .pi)
    layer.addSublayer(backGrayCircle)
    
    indicator.strokeColor = color.cgColor
    indicator.fillColor = nil
    indicator.lineWidth = lineWidth
    indicator.strokeStart = 0.0
    indicator.strokeEnd = 0.0
    indicator.shadowColor = color.cgColor
    indicator.shadowOffset = CGSize(width: -lineWidth, height: 0)
    indicator.shadowOpacity = 0.4
    indicator.shadowRadius = -lineWidth
    indicator.lineCap = .round
    layer.insertSublayer(indicator, above: backGrayCircle)
    clipsToBounds = true
  }
}

extension MaterialIndicatorView {
  override public var intrinsicContentSize: CGSize {
    return CGSize(width: 44, height: 44)
  }
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    
    indicator.frame = bounds
    backGrayCircle.frame = bounds
    
    let diameter = bounds.size.min - indicator.lineWidth
    let path = UIBezierPath(center: bounds.center, radius: diameter / 2)
    indicator.path = path.cgPath
    backGrayCircle.path = path.cgPath
    layer.cornerRadius = diameter / 2
  }
}

extension MaterialIndicatorView {
  func startAnimating() {
    guard !isAnimating else { return }
    
    animator.addAnimation(to: indicator)
    isAnimating = true
  }
  
  func stopAnimating() {
    guard isAnimating else { return }
    
    animator.removeAnimation(from: indicator)
    isAnimating = false
  }
}

final class MaterialIndicatorAnimator {
  enum Animation: String {
    var key: String {
      return rawValue
    }
    
    case spring = "material.indicator.spring"
    case rotation = "material.indicator.rotation"
  }
  
  func addAnimation(to layer: CALayer) {
    layer.add(rotationAnimation(), forKey: Animation.rotation.key)
    layer.add(springAnimation(), forKey: Animation.spring.key)
  }
  
  func removeAnimation(from layer: CALayer) {
    layer.removeAnimation(forKey: Animation.rotation.key)
    layer.removeAnimation(forKey: Animation.spring.key)
  }
}

extension MaterialIndicatorAnimator {
  private func rotationAnimation() -> CABasicAnimation {
    let animation = CABasicAnimation(key: .rotationZ)
    animation.duration = 4
    animation.fromValue = 0
    animation.toValue = (2.0 * .pi)
    animation.repeatCount = .infinity
    animation.isRemovedOnCompletion = false
    
    return animation
  }
  
  private func springAnimation() -> CAAnimationGroup {
    let animation = CAAnimationGroup()
    animation.duration = 1.5
    animation.animations = [
      strokeStartAnimation(),
      strokeEndAnimation(),
      strokeCatchAnimation(),
      strokeFreezeAnimation()
    ]
    animation.repeatCount = .infinity
    animation.isRemovedOnCompletion = false
    
    return animation
  }
  
  private func strokeStartAnimation() -> CABasicAnimation {
    let animation = CABasicAnimation(key: .strokeStart)
    animation.duration = 1
    animation.fromValue = 0
    animation.toValue = 0.15
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    
    return animation
  }
  
  private func strokeEndAnimation() -> CABasicAnimation {
    let animation = CABasicAnimation(key: .strokeEnd)
    animation.duration = 1
    animation.fromValue = 0
    animation.toValue = 1
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    
    return animation
  }
  
  private func strokeCatchAnimation() -> CABasicAnimation {
    let animation = CABasicAnimation(key: .strokeStart)
    animation.beginTime = 1
    animation.duration = 0.5
    animation.fromValue = 0.15
    animation.toValue = 1
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    
    return animation
  }
  
  private func strokeFreezeAnimation() -> CABasicAnimation {
    let animation = CABasicAnimation(key: .strokeEnd)
    animation.beginTime = 1
    animation.duration = 0.5
    animation.fromValue = 1
    animation.toValue = 1
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    
    return animation
  }
}


///Extensions
extension UILabel {
  func set(font: UIFont?, color: UIColor?) {
    self.font = font
    self.textColor = color
  }
}

struct NamedColor {
  let name: String
  
  var value: UIColor {
    guard let hex = dict[name] else {
      return .gray
    }
    
    return UIColor(rgb: hex)
  }
  
  private let dict = [
    "черный"      : 0xFF332D40,
    "серый"       : 0xFFC8C9CA,
    "красный"     : 0xFFF94B55,
    "розовый"     : 0xFFFA65A3,
    "фиолетовый"  : 0xFFB865E8,
    "синий"       : 0xFF378BCE,
    "голубой"     : 0xFF6BD9F0,
    "зеленый"     : 0xFF7DD75E,
    "желтый"       : 0xFFFFD400,
    "оранжевый"   : 0xFFFC9D45,
    "коричневый"  : 0xFF855D38,
    "бежевый"     : 0xFFEECBA2,
    "серебристый" : 0xFFEDE7E7,
    "золотой"      : 0xFFF5B658,
    "белый"        : 0xFFFFFFFF
  ]
}

extension UIColor {
  convenience init(red: Int, green: Int, blue: Int) {
    self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
  }
  
  convenience init(rgb: Int) {
    self.init(
      red: (rgb >> 16) & 0xFF,
      green: (rgb >> 8) & 0xFF,
      blue: rgb & 0xFF
    )
  }
}

extension UIColor {
  static func hexStringToUIColor (hex: String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
      cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
      return UIColor.gray
    }
    
    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)
    
    return UIColor(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }
}

extension UIBezierPath {
  convenience init(center: CGPoint, radius: CGFloat) {
    self.init(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(.pi * 2.0), clockwise: true)
  }
}

extension CGSize {
  var min: CGFloat {
    return CGFloat.minimum(width, height)
  }
}

extension CGRect {
  var center: CGPoint {
    return CGPoint(x: midX, y: midY)
  }
}

extension CAPropertyAnimation {
  enum Key: String {
    var path: String {
      return rawValue
    }
    
    case strokeStart = "strokeStart"
    case strokeEnd = "strokeEnd"
    case strokeColor = "strokeColor"
    case rotationZ = "transform.rotation.z"
    case scale = "transform.scale"
  }
  
  convenience init(key: Key) {
    self.init(keyPath: key.path)
  }
}




