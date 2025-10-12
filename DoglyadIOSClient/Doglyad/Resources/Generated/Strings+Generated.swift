// swiftlint:disable all
// Generated from Localizable.xcstrings
// Do not edit manually

import Foundation

public enum L10n: Equatable, Hashable {
  #warning("Unused key: buttonNext")
  /// Next
  case buttonNext
  #warning("Unused key: buttonStart")
  /// Let’s start!
  case buttonStart
  #warning("Unused key: buttonUpdate")
  /// Update
  case buttonUpdate
  /// Please check camera permission for taking scan photos and try again
  case errorNoCameraPermissionDescription
  /// Camera permission denied
  case errorNoCameraPermissionTitle
  /// Please check your internet connection and try again
  case errorNoInternetConnectionDescription
  /// No intenet connection
  case errorNoInternetConnectionTitle
  /// Please try again later
  case errorUnknownDescription
  /// Unknown error
  case errorUnknownTitle
}

extension L10n: CustomStringConvertible {
  public var description: String { return self.string }

  public var string: String {
    switch self {
    case .buttonNext:
      return L10n.tr(key: "button_next")
    case .buttonStart:
      return L10n.tr(key: "button_start")
    case .buttonUpdate:
      return L10n.tr(key: "button_update")
    case .errorNoCameraPermissionDescription:
      return L10n.tr(key: "error_no_camera_permission_description")
    case .errorNoCameraPermissionTitle:
      return L10n.tr(key: "error_no_camera_permission_title")
    case .errorNoInternetConnectionDescription:
      return L10n.tr(key: "error_no_internet_connection_description")
    case .errorNoInternetConnectionTitle:
      return L10n.tr(key: "error_no_internet_connection_title")
    case .errorUnknownDescription:
      return L10n.tr(key: "error_unknown_description")
    case .errorUnknownTitle:
      return L10n.tr(key: "error_unknown_title")
    }
  }

  private static func tr(key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, comment: key)
    return String(format: format, arguments: args)
  }
}
