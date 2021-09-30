//
//  XitString.swift
//  MultRepoTool
//
//  Created by harofan on 2021/9/30.
//

import Foundation
import Combine

extension String
{
  init?(data: Data, usedEncoding: inout String.Encoding)
  {
    let encodings: [String.Encoding] = [.utf8, .utf16, .isoLatin1, .isoLatin2,
                                        .macOSRoman, .windowsCP1252]
    
    for encoding in encodings {
      if let string = String(data: data, encoding: encoding) {
        self = string
        return
      }
    }
    return nil
  }

  var trimmingWhitespace: String
  { trimmingCharacters(in: .whitespacesAndNewlines) }
  
  var nilIfEmpty: String?
  { isEmpty ? nil : self }
  
  /// Splits a "refs/*/..." string into prefix and remainder.
  func splitRefName() -> (String, String)?
  {
    guard hasPrefix("refs/")
      else { return nil }
    
    let start = index(startIndex, offsetBy: "refs/".count)
    guard let slashRange = range(of: "/", options: [], range: start..<endIndex,
                                 locale: nil)
      else { return nil }
    let slashIndex = index(slashRange.lowerBound, offsetBy: 1)
    
    return (String(self[..<slashIndex]),
            String(self[slashRange.upperBound...]))
  }
  
  /// Splits the string into an array of lines.
  func lineComponents() -> [String]
  {
    var lines: [String] = []
    
    enumerateLines { (line, _) in lines.append(line) }
    return lines
  }
  
  enum LineEndingStyle: String
  {
    case crlf
    case lf
    case unknown
    
    var string: String
    {
      switch self
      {
        case .crlf: return "\r\n"
        case .lf:   return "\n"
        case .unknown: return "\n"
      }
    }
  }
  
  var lineEndingStyle: LineEndingStyle
  {
    if range(of: "\r\n") != nil {
      return .crlf
    }
    if range(of: "\n") != nil {
      return .lf
    }
    return .unknown
  }
  
  var xmlEscaped: String
  {
    CFXMLCreateStringByEscapingEntities(kCFAllocatorDefault,
                                        self as CFString,
                                        [:] as CFDictionary) as String
  }
  
  var fullNSRange: NSRange
  { NSRange(startIndex..., in: self) }
}

// MARK: Prefixes & Suffixes
extension String
{
  /// Returns the string with the given prefix removed, or returns the string
  /// unchanged if the prefix does not match.
  func droppingPrefix(_ prefix: String) -> String
  {
    guard hasPrefix(prefix)
    else { return self }
    
    return String(self[prefix.endIndex...])
  }
  
  /// Returns the string with the given suffix removed, or returns the string
  /// unchanged if the suffix does not match.
  func droppingSuffix(_ suffix: String) -> String
  {
    guard hasSuffix(suffix)
    else { return self }
    
    return String(dropLast(suffix.count))
  }
  
  /// Returns the string with the given prefix, adding it only if necessary.
  func withPrefix(_ prefix: String) -> String
  {
    if hasPrefix(prefix) {
      return self
    }
    else {
      return prefix.appending(self)
    }
  }
  
  /// Returns the string with the given suffix, adding it only if necessary.
  func withSuffix(_ suffix: String) -> String
  {
    if hasSuffix(suffix) {
      return self
    }
    else {
      return appending(suffix)
    }
  }
}

// MARK: Paths
extension String
{
  func appending(pathComponent component: String) -> String
  {
    return (self as NSString).appendingPathComponent(component)
  }
  
  var pathExtension: String
  { (self as NSString).pathExtension }
  
  var deletingPathExtension: String
  { (self as NSString).deletingPathExtension }

  var pathComponents: [String]
  { (self as NSString).pathComponents }
  
  // TODO: this probably shouldn't be optional
  var firstPathComponent: String?
  { pathComponents.first }
  
  var deletingFirstPathComponent: String
  { NSString.path(withComponents: Array(pathComponents.dropFirst(1))) }
  
  var lastPathComponent: String
  { (self as NSString).lastPathComponent }
  
  var deletingLastPathComponent: String
  { (self as NSString).deletingLastPathComponent }
  
  var expandingTildeInPath: String
  { (self as NSString).expandingTildeInPath }
}

infix operator +/ : AdditionPrecedence

extension String
{
  static func +/ (left: String, right: String) -> String
  {
    return left.appending(pathComponent: right)
  }
}

extension URL
{
  static func +/ (left: URL, right: String) -> URL
  {
    return left.appendingPathComponent(right)
  }
}

extension Publisher where Self.Failure == Never
{
  /// Convenience function for `receive(on: DispatchQueue.main).sink()`
  public func sinkOnMainQueue(receiveValue: @escaping ((Self.Output) -> Void))
    -> AnyCancellable
  {
    receive(on: DispatchQueue.main)
      .sink(receiveValue: receiveValue)
  }
}

extension NSObject
{
  func changingValue(forKey key: String, block: () -> Void)
  {
    willChangeValue(forKey: key)
    block()
    didChangeValue(forKey: key)
  }
}

extension String
{
  func firstSix() -> String
  {
    return prefix(6).description
  }
}

//extension NSApplication
//{
//  var currentEventIsDelete: Bool
//  {
//    switch currentEvent?.specialKey {
//      case NSEvent.SpecialKey.delete,
//           NSEvent.SpecialKey.backspace,
//           NSEvent.SpecialKey.deleteCharacter,
//           NSEvent.SpecialKey.deleteForward:
//        return true
//      default:
//        return false
//    }
//  }
//}
//
//extension NSColor
//{
//  var invertingBrightness: NSColor
//  {
//    NSColor(deviceHue: hueComponent,
//            saturation: saturationComponent,
//            brightness: 1.0 - brightnessComponent,
//            alpha: alphaComponent)
//  }
//
//  var cssHSL: String
//  {
//    let converted = usingColorSpace(.deviceRGB)!
//    let hue = converted.hueComponent
//    let sat = converted.saturationComponent
//    let brightness = converted.brightnessComponent
//    
//    return "hsl(\(hue*360.0), \(sat*100.0)%, \(brightness*100.0)%)"
//  }
//  
//  var cssRGB: String
//  {
//    let converted = usingColorSpace(.deviceRGB)!
//    let red = converted.redComponent
//    let green = converted.greenComponent
//    let blue = converted.blueComponent
//    
//    return "rgb(\(Int(red*255)), \(Int(green*255)), \(Int(blue*255)))"
//  }
//  
//  func withHue(_ hue: CGFloat) -> NSColor
//  {
//    guard let converted = usingColorSpace(.deviceRGB)
//    else { return self }
//
//    return NSColor(deviceHue: hue,
//                   saturation: converted.saturationComponent,
//                   brightness: converted.brightnessComponent,
//                   alpha: converted.alphaComponent)
//  }
//}
//
//extension NSError
//{
//  var gitError: git_error_code
//  { git_error_code(Int32(code)) }
//  
//  convenience init(osStatus: OSStatus)
//  {
//    self.init(domain: NSOSStatusErrorDomain, code: Int(osStatus), userInfo: nil)
//  }
//}
//
//extension NSImage
//{
//  func image(coloredWith color: NSColor) -> NSImage
//  {
//    guard isTemplate,
//          let copiedImage = self.copy() as? NSImage
//    else { return self }
//    
//    copiedImage.withFocus {
//      let imageBounds = NSRect(origin: .zero, size: copiedImage.size)
//
//      color.set()
//      imageBounds.fill(using: .sourceAtop)
//    }
//    copiedImage.isTemplate = false
//    return copiedImage
//  }
//  
//  func withFocus<T>(callback: () throws -> T) rethrows -> T
//  {
//    lockFocus()
//    defer {
//      unlockFocus()
//    }
//    
//    return try callback()
//  }
//}
//
//extension NSTreeNode
//{
//  /// Inserts a child node in sorted order based on the given key extractor
//  func insert<T>(node: NSTreeNode, sortedBy extractor: (NSTreeNode) -> T?)
//    where T: Comparable
//  {
//    guard let children = self.children,
//          let key = extractor(node)
//    else {
//      mutableChildren.add(node)
//      return
//    }
//    
//    for (index, child) in children.enumerated() {
//      guard let childKey = extractor(child)
//      else { continue }
//      
//      if childKey > key {
//        mutableChildren.insert(node, at: index)
//        return
//      }
//    }
//    mutableChildren.add(node)
//  }
//
//  func dump(_ level: Int = 0)
//  {
//    if let myObject = representedObject as? CustomStringConvertible {
//      print(String(repeating: "  ", count: level) + myObject.description)
//    }
//    
//    guard let children = self.children
//    else { return }
//    
//    for child in children {
//      child.dump(level + 1)
//    }
//  }
//}
