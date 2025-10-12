import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "detail11" asset catalog image resource.
    static let detail11 = DeveloperToolsSupport.ImageResource(name: "detail11", bundle: resourceBundle)

    /// The "detail12" asset catalog image resource.
    static let detail12 = DeveloperToolsSupport.ImageResource(name: "detail12", bundle: resourceBundle)

    /// The "detail6and7" asset catalog image resource.
    static let detail6And7 = DeveloperToolsSupport.ImageResource(name: "detail6and7", bundle: resourceBundle)

    /// The "detail8" asset catalog image resource.
    static let detail8 = DeveloperToolsSupport.ImageResource(name: "detail8", bundle: resourceBundle)

    /// The "detail9" asset catalog image resource.
    static let detail9 = DeveloperToolsSupport.ImageResource(name: "detail9", bundle: resourceBundle)

    /// The "donation_alipay" asset catalog image resource.
    static let donationAlipay = DeveloperToolsSupport.ImageResource(name: "donation_alipay", bundle: resourceBundle)

    /// The "donation_wechat" asset catalog image resource.
    static let donationWechat = DeveloperToolsSupport.ImageResource(name: "donation_wechat", bundle: resourceBundle)

    /// The "issue1" asset catalog image resource.
    static let issue1 = DeveloperToolsSupport.ImageResource(name: "issue1", bundle: resourceBundle)

    /// The "issue10" asset catalog image resource.
    static let issue10 = DeveloperToolsSupport.ImageResource(name: "issue10", bundle: resourceBundle)

    /// The "issue11" asset catalog image resource.
    static let issue11 = DeveloperToolsSupport.ImageResource(name: "issue11", bundle: resourceBundle)

    /// The "issue12" asset catalog image resource.
    static let issue12 = DeveloperToolsSupport.ImageResource(name: "issue12", bundle: resourceBundle)

    /// The "issue13" asset catalog image resource.
    static let issue13 = DeveloperToolsSupport.ImageResource(name: "issue13", bundle: resourceBundle)

    /// The "issue2" asset catalog image resource.
    static let issue2 = DeveloperToolsSupport.ImageResource(name: "issue2", bundle: resourceBundle)

    /// The "issue4" asset catalog image resource.
    static let issue4 = DeveloperToolsSupport.ImageResource(name: "issue4", bundle: resourceBundle)

    /// The "issue5" asset catalog image resource.
    static let issue5 = DeveloperToolsSupport.ImageResource(name: "issue5", bundle: resourceBundle)

    /// The "issue6" asset catalog image resource.
    static let issue6 = DeveloperToolsSupport.ImageResource(name: "issue6", bundle: resourceBundle)

    /// The "issue7" asset catalog image resource.
    static let issue7 = DeveloperToolsSupport.ImageResource(name: "issue7", bundle: resourceBundle)

    /// The "issue8" asset catalog image resource.
    static let issue8 = DeveloperToolsSupport.ImageResource(name: "issue8", bundle: resourceBundle)

    /// The "issue9" asset catalog image resource.
    static let issue9 = DeveloperToolsSupport.ImageResource(name: "issue9", bundle: resourceBundle)

    /// The "issue_3" asset catalog image resource.
    static let issue3 = DeveloperToolsSupport.ImageResource(name: "issue_3", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "detail11" asset catalog image.
    static var detail11: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .detail11)
#else
        .init()
#endif
    }

    /// The "detail12" asset catalog image.
    static var detail12: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .detail12)
#else
        .init()
#endif
    }

    /// The "detail6and7" asset catalog image.
    static var detail6And7: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .detail6And7)
#else
        .init()
#endif
    }

    /// The "detail8" asset catalog image.
    static var detail8: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .detail8)
#else
        .init()
#endif
    }

    /// The "detail9" asset catalog image.
    static var detail9: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .detail9)
#else
        .init()
#endif
    }

    /// The "donation_alipay" asset catalog image.
    static var donationAlipay: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .donationAlipay)
#else
        .init()
#endif
    }

    /// The "donation_wechat" asset catalog image.
    static var donationWechat: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .donationWechat)
#else
        .init()
#endif
    }

    /// The "issue1" asset catalog image.
    static var issue1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .issue1)
#else
        .init()
#endif
    }

    /// The "issue10" asset catalog image.
    static var issue10: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .issue10)
#else
        .init()
#endif
    }

    /// The "issue11" asset catalog image.
    static var issue11: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .issue11)
#else
        .init()
#endif
    }

    /// The "issue12" asset catalog image.
    static var issue12: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .issue12)
#else
        .init()
#endif
    }

    /// The "issue13" asset catalog image.
    static var issue13: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .issue13)
#else
        .init()
#endif
    }

    /// The "issue2" asset catalog image.
    static var issue2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .issue2)
#else
        .init()
#endif
    }

    /// The "issue4" asset catalog image.
    static var issue4: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .issue4)
#else
        .init()
#endif
    }

    /// The "issue5" asset catalog image.
    static var issue5: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .issue5)
#else
        .init()
#endif
    }

    /// The "issue6" asset catalog image.
    static var issue6: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .issue6)
#else
        .init()
#endif
    }

    /// The "issue7" asset catalog image.
    static var issue7: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .issue7)
#else
        .init()
#endif
    }

    /// The "issue8" asset catalog image.
    static var issue8: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .issue8)
#else
        .init()
#endif
    }

    /// The "issue9" asset catalog image.
    static var issue9: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .issue9)
#else
        .init()
#endif
    }

    /// The "issue_3" asset catalog image.
    static var issue3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .issue3)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "detail11" asset catalog image.
    static var detail11: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .detail11)
#else
        .init()
#endif
    }

    /// The "detail12" asset catalog image.
    static var detail12: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .detail12)
#else
        .init()
#endif
    }

    /// The "detail6and7" asset catalog image.
    static var detail6And7: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .detail6And7)
#else
        .init()
#endif
    }

    /// The "detail8" asset catalog image.
    static var detail8: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .detail8)
#else
        .init()
#endif
    }

    /// The "detail9" asset catalog image.
    static var detail9: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .detail9)
#else
        .init()
#endif
    }

    /// The "donation_alipay" asset catalog image.
    static var donationAlipay: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .donationAlipay)
#else
        .init()
#endif
    }

    /// The "donation_wechat" asset catalog image.
    static var donationWechat: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .donationWechat)
#else
        .init()
#endif
    }

    /// The "issue1" asset catalog image.
    static var issue1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .issue1)
#else
        .init()
#endif
    }

    /// The "issue10" asset catalog image.
    static var issue10: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .issue10)
#else
        .init()
#endif
    }

    /// The "issue11" asset catalog image.
    static var issue11: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .issue11)
#else
        .init()
#endif
    }

    /// The "issue12" asset catalog image.
    static var issue12: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .issue12)
#else
        .init()
#endif
    }

    /// The "issue13" asset catalog image.
    static var issue13: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .issue13)
#else
        .init()
#endif
    }

    /// The "issue2" asset catalog image.
    static var issue2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .issue2)
#else
        .init()
#endif
    }

    /// The "issue4" asset catalog image.
    static var issue4: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .issue4)
#else
        .init()
#endif
    }

    /// The "issue5" asset catalog image.
    static var issue5: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .issue5)
#else
        .init()
#endif
    }

    /// The "issue6" asset catalog image.
    static var issue6: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .issue6)
#else
        .init()
#endif
    }

    /// The "issue7" asset catalog image.
    static var issue7: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .issue7)
#else
        .init()
#endif
    }

    /// The "issue8" asset catalog image.
    static var issue8: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .issue8)
#else
        .init()
#endif
    }

    /// The "issue9" asset catalog image.
    static var issue9: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .issue9)
#else
        .init()
#endif
    }

    /// The "issue_3" asset catalog image.
    static var issue3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .issue3)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

