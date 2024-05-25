//  Created by Timofey Privalov MobileDesk
import SwiftUI
import UIKit

extension Color {
    static let theme = MobileDeskTheme()
    static let gradient = MobileDeskGradient()
}

struct MobileDeskTheme {
    let textColor = Color("FontColor")
    let background = Color("background")
    let surface = Color("surface")
    let primary = Color("primaryDesk")
    let secondary = Color("secondaryDesk")
    let vibrant = Color("vibrant")
    let muted = Color("muted")
    let selected = Color("selected")
    let highContrast = Color("highContrast")
    let mediumContrast = Color("mediumContrast")
    let lowContrast = Color("lowContrast")
    let extraLowContrast = Color("extraLowContrast")
    let primaryFire = Color("primaryFire")
    let secondaryFire = Color("secondaryFire")
    let mutedFire = Color("mutedFire")
    let primaryAmber = Color("primaryAmber")
    let mutedAmber = Color("mutedAmber")
    let positivePrimary = Color("positivePrimary")
    let positiveSecondary = Color("positiveSecondary")
    let negativePrimary = Color("negativePrimary")
    let negativeSecondary = Color("negativeSecondary")
    let negativeMuted = Color("negativeMuted")
    let tabBarBG = Color("tabBarBG")
    let gradientMedLightColor = Color("gradientMedLightColor")
    let mutedPlum = Color("mutedPlum")
}

struct MobileDeskGradient {
    
    let gradientHigh = LinearGradient(
        stops: [
            Gradient.Stop(color: Color(red: 1, green: 0.5, blue: 0.08), location: 0.00),
            Gradient.Stop(color: Color(red: 0.97, green: 0.47, blue: 0.11), location: 0.14),
            Gradient.Stop(color: Color(red: 0.91, green: 0.39, blue: 0.18), location: 0.35),
            Gradient.Stop(color: Color(red: 0.8, green: 0.27, blue: 0.31), location: 0.59),
            Gradient.Stop(color: Color(red: 0.65, green: 0.1, blue: 0.48), location: 0.86),
            Gradient.Stop(color: Color(red: 0.56, green: 0, blue: 0.58), location: 1.00),
        ],
        startPoint: UnitPoint(x: 0.89, y: 0.85),
        endPoint: UnitPoint(x: 0.11, y: 0.15)
    )
    
    let gradientLowLight = LinearGradient(
        stops: [
            Gradient.Stop(color: Color(red: 0.97, green: 0.91, blue: 0.97), location: 0.00),
            Gradient.Stop(color: Color(red: 0.99, green: 0.94, blue: 0.89), location: 1.00),
        ],
        startPoint: UnitPoint(x: 0, y: 0),
        endPoint: UnitPoint(x: 0.98, y: 1))
    
    let gradientLight = LinearGradient(
        stops: [
            Gradient.Stop(color: Color(red: 0.980392157, green: 0.980392157, blue: 0.980392157), location: 0.00),
            Gradient.Stop(color: Color(red: 0.941176471, green: 0.937254902, blue: 0.941176471), location: 1.00),
        ],
        startPoint: UnitPoint(x: 0, y: 0),
        endPoint: UnitPoint(x: 0.98, y: 1)
    )
    
    let gradientDark = LinearGradient(
        stops: [
            Gradient.Stop(color: Color(red: 0.1333, green: 0.1059, blue: 0.1333), location: 0.00),
            Gradient.Stop(color: Color(red: 0.0902, green: 0.0706, blue: 0.0902), location: 1.00),
        ],
        startPoint: UnitPoint(x: 0, y: 0),
        endPoint: UnitPoint(x: 0.98, y: 1)
    )
    
    
    let gradientLowDark = LinearGradient(
        stops: [
            Gradient.Stop(color: Color(red: 0.18, green: 0.12, blue: 0.18), location: 0.00),
            Gradient.Stop(color: Color(red: 0.16, green: 0.12, blue: 0.08), location: 1.00),
        ],
        startPoint: UnitPoint(x: 0, y: 0),
        endPoint: UnitPoint(x: 0.98, y: 1)
    )
    
    let bkGradientLightToExtraLowContrast = LinearGradient(
        stops: [
            Gradient.Stop(color: Color(red: 0.98, green: 0.98, blue: 0.98), location: 0.00),
            Gradient.Stop(color: Color(red: 0.94, green: 0.94, blue: 0.94), location: 1.00),
        ],
        startPoint: UnitPoint(x: 0.5, y: 0),
        endPoint: UnitPoint(x: 0.5, y: 1)
    )
    let bkGradientDarkToExtraLowContrast = LinearGradient(
        stops: [
            Gradient.Stop(color: Color(red: 0.13, green: 0.11, blue: 0.13), location: 0.00),
            Gradient.Stop(color: Color(red: 0.09, green: 0.07, blue: 0.09), location: 1.00),
        ],
        startPoint: UnitPoint(x: 0.5, y: 0),
        endPoint: UnitPoint(x: 0.5, y: 1)
    )
}



