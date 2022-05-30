//
//  DriverMapView.swift
//  SnappyV2
//
//  Created by Kevin Palser on 25/05/2022.
//

import SwiftUI
import MapKit

struct PinShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.addEllipse(in: CGRect(x: 0.32759*width, y: 0.05172*height, width: 0.34483*width, height: 0.34483*height))
        path.addEllipse(in: CGRect(x: 0.4569*width, y: 0.46121*height, width: 0.08621*width, height: 0.08621*height))
        path.addRect(CGRect(x: 0.48966*width, y: 0.28879*height, width: 0.02155*width, height: 0.21552*height))
        return path
    }
}

struct HomeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.60000 * width, y: 0.20603 * height))
        path.addLine(to: CGPoint(x: 0.60002 * width, y: 0.20604 * height))
        path.addCurve(to: CGPoint(x: 0.60234 * width, y: 0.21801 * height), control1: CGPoint(x: 0.60396 * width, y: 0.20871 * height), control2: CGPoint(x: 0.60500 * width, y: 0.21407 * height))
        path.addCurve(to: CGPoint(x: 0.59037 * width, y: 0.22034 * height), control1: CGPoint(x: 0.59968 * width, y: 0.22196 * height), control2: CGPoint(x: 0.59432 * width, y: 0.22300 * height))
        path.addCurve(to: CGPoint(x: 0.58879 * width, y: 0.21896 * height), control1: CGPoint(x: 0.58979 * width, y: 0.21995 * height), control2: CGPoint(x: 0.58926 * width, y: 0.21948 * height))
        path.addLine(to: CGPoint(x: 0.58017 * width, y: 0.21121 * height))
        path.addLine(to: CGPoint(x: 0.58017 * width, y: 0.27845 * height))
        path.addLine(to: CGPoint(x: 0.58017 * width, y: 0.27869 * height))
        path.addCurve(to: CGPoint(x: 0.55147 * width, y: 0.30690 * height), control1: CGPoint(x: 0.57990 * width, y: 0.29435 * height), control2: CGPoint(x: 0.56713 * width, y: 0.30690 * height))
        path.addLine(to: CGPoint(x: 0.44828 * width, y: 0.30690 * height))
        path.addLine(to: CGPoint(x: 0.44803 * width, y: 0.30689 * height))
        path.addCurve(to: CGPoint(x: 0.41983 * width, y: 0.27819 * height), control1: CGPoint(x: 0.43238 * width, y: 0.30662 * height), control2: CGPoint(x: 0.41983 * width, y: 0.29385 * height))
        path.addLine(to: CGPoint(x: 0.41983 * width, y: 0.21121 * height))
        path.addLine(to: CGPoint(x: 0.41121 * width, y: 0.21897 * height))
        path.addLine(to: CGPoint(x: 0.41122 * width, y: 0.21896 * height))
        path.addCurve(to: CGPoint(x: 0.39925 * width, y: 0.21663 * height), control1: CGPoint(x: 0.40727 * width, y: 0.22162 * height), control2: CGPoint(x: 0.40192 * width, y: 0.22058 * height))
        path.addCurve(to: CGPoint(x: 0.39999 * width, y: 0.20604 * height), control1: CGPoint(x: 0.39704 * width, y: 0.21335 * height), control2: CGPoint(x: 0.39735 * width, y: 0.20898 * height))
        path.addLine(to: CGPoint(x: 0.49483 * width, y: 0.12586 * height))
        path.addLine(to: CGPoint(x: 0.49486 * width, y: 0.12584 * height))
        path.addCurve(to: CGPoint(x: 0.50600 * width, y: 0.12584 * height), control1: CGPoint(x: 0.49813 * width, y: 0.12328 * height), control2: CGPoint(x: 0.50273 * width, y: 0.12328 * height))
        path.addLine(to: CGPoint(x: 0.60000 * width, y: 0.20603 * height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.44828 * width, y: 0.29052 * height))
        path.addLine(to: CGPoint(x: 0.46552 * width, y: 0.29052 * height))
        path.addLine(to: CGPoint(x: 0.46552 * width, y: 0.23621 * height))
        path.addLine(to: CGPoint(x: 0.46552 * width, y: 0.23612 * height))
        path.addCurve(to: CGPoint(x: 0.48009 * width, y: 0.22155 * height), control1: CGPoint(x: 0.46552 * width, y: 0.22807 * height), control2: CGPoint(x: 0.47204 * width, y: 0.22155 * height))
        path.addCurve(to: CGPoint(x: 0.48034 * width, y: 0.22155 * height), control1: CGPoint(x: 0.48017 * width, y: 0.22155 * height), control2: CGPoint(x: 0.48026 * width, y: 0.22155 * height))
        path.addLine(to: CGPoint(x: 0.52069 * width, y: 0.22155 * height))
        path.addLine(to: CGPoint(x: 0.52078 * width, y: 0.22155 * height))
        path.addCurve(to: CGPoint(x: 0.53535 * width, y: 0.23612 * height), control1: CGPoint(x: 0.52882 * width, y: 0.22155 * height), control2: CGPoint(x: 0.53535 * width, y: 0.22807 * height))
        path.addCurve(to: CGPoint(x: 0.53534 * width, y: 0.23637 * height), control1: CGPoint(x: 0.53535 * width, y: 0.23621 * height), control2: CGPoint(x: 0.53534 * width, y: 0.23629 * height))
        path.addLine(to: CGPoint(x: 0.53534 * width, y: 0.29052 * height))
        path.addLine(to: CGPoint(x: 0.55259 * width, y: 0.29052 * height))
        path.addLine(to: CGPoint(x: 0.55261 * width, y: 0.29052 * height))
        path.addCurve(to: CGPoint(x: 0.56379 * width, y: 0.27934 * height), control1: CGPoint(x: 0.55874 * width, y: 0.29041 * height), control2: CGPoint(x: 0.56369 * width, y: 0.28547 * height))
        path.addLine(to: CGPoint(x: 0.56379 * width, y: 0.19741 * height))
        path.addLine(to: CGPoint(x: 0.50000 * width, y: 0.14310 * height))
        path.addLine(to: CGPoint(x: 0.43707 * width, y: 0.19655 * height))
        path.addLine(to: CGPoint(x: 0.43707 * width, y: 0.27845 * height))
        path.addLine(to: CGPoint(x: 0.43707 * width, y: 0.27853 * height))
        path.addCurve(to: CGPoint(x: 0.44846 * width, y: 0.29053 * height), control1: CGPoint(x: 0.43718 * width, y: 0.28488 * height), control2: CGPoint(x: 0.44212 * width, y: 0.29009 * height))
        path.addLine(to: CGPoint(x: 0.44828 * width, y: 0.29052 * height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.48276 * width, y: 0.29052 * height))
        path.addLine(to: CGPoint(x: 0.51724 * width, y: 0.29052 * height))
        path.addLine(to: CGPoint(x: 0.51724 * width, y: 0.23879 * height))
        path.addLine(to: CGPoint(x: 0.48276 * width, y: 0.23879 * height))
        path.addLine(to: CGPoint(x: 0.48276 * width, y: 0.29052 * height))
        path.closeSubpath()
        return path
    }
}

struct TruckLeftShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.48448 * width, y: 0.16207 * height))
        path.addLine(to: CGPoint(x: 0.48448 * width, y: 0.25517 * height))
        path.addLine(to: CGPoint(x: 0.48448 * width, y: 0.25515 * height))
        path.addCurve(to: CGPoint(x: 0.48958 * width, y: 0.26034 * height), control1: CGPoint(x: 0.48467 * width, y: 0.25790 * height), control2: CGPoint(x: 0.48684 * width, y: 0.26010 * height))
        path.addLine(to: CGPoint(x: 0.52500 * width, y: 0.26034 * height))
        path.addLine(to: CGPoint(x: 0.52491 * width, y: 0.26050 * height))
        path.addCurve(to: CGPoint(x: 0.55153 * width, y: 0.24483 * height), control1: CGPoint(x: 0.53027 * width, y: 0.25083 * height), control2: CGPoint(x: 0.54046 * width, y: 0.24483 * height))
        path.addLine(to: CGPoint(x: 0.55182 * width, y: 0.24483 * height))
        path.addCurve(to: CGPoint(x: 0.56714 * width, y: 0.24908 * height), control1: CGPoint(x: 0.55722 * width, y: 0.24483 * height), control2: CGPoint(x: 0.56251 * width, y: 0.24630 * height))
        path.addLine(to: CGPoint(x: 0.56724 * width, y: 0.23448 * height))
        path.addLine(to: CGPoint(x: 0.58276 * width, y: 0.23448 * height))
        path.addLine(to: CGPoint(x: 0.58276 * width, y: 0.27586 * height))
        path.addLine(to: CGPoint(x: 0.58276 * width, y: 0.27586 * height))
        path.addCurve(to: CGPoint(x: 0.55172 * width, y: 0.30690 * height), control1: CGPoint(x: 0.58276 * width, y: 0.29300 * height), control2: CGPoint(x: 0.56886 * width, y: 0.30690 * height))
        path.addCurve(to: CGPoint(x: 0.52069 * width, y: 0.27586 * height), control1: CGPoint(x: 0.53458 * width, y: 0.30690 * height), control2: CGPoint(x: 0.52069 * width, y: 0.29300 * height))
        path.addLine(to: CGPoint(x: 0.47931 * width, y: 0.27586 * height))
        path.addLine(to: CGPoint(x: 0.47931 * width, y: 0.27586 * height))
        path.addCurve(to: CGPoint(x: 0.44828 * width, y: 0.30690 * height), control1: CGPoint(x: 0.47931 * width, y: 0.29300 * height), control2: CGPoint(x: 0.46542 * width, y: 0.30690 * height))
        path.addCurve(to: CGPoint(x: 0.41724 * width, y: 0.27586 * height), control1: CGPoint(x: 0.43114 * width, y: 0.30690 * height), control2: CGPoint(x: 0.41724 * width, y: 0.29300 * height))
        path.addLine(to: CGPoint(x: 0.40431 * width, y: 0.27586 * height))
        path.addLine(to: CGPoint(x: 0.40431 * width, y: 0.27586 * height))
        path.addCurve(to: CGPoint(x: 0.39655 * width, y: 0.26810 * height), control1: CGPoint(x: 0.40003 * width, y: 0.27586 * height), control2: CGPoint(x: 0.39655 * width, y: 0.27239 * height))
        path.addCurve(to: CGPoint(x: 0.40431 * width, y: 0.26034 * height), control1: CGPoint(x: 0.39655 * width, y: 0.26382 * height), control2: CGPoint(x: 0.40003 * width, y: 0.26034 * height))
        path.addLine(to: CGPoint(x: 0.40690 * width, y: 0.26034 * height))
        path.addLine(to: CGPoint(x: 0.40690 * width, y: 0.22069 * height))
        path.addLine(to: CGPoint(x: 0.40690 * width, y: 0.22068 * height))
        path.addCurve(to: CGPoint(x: 0.41215 * width, y: 0.20768 * height), control1: CGPoint(x: 0.40673 * width, y: 0.21580 * height), control2: CGPoint(x: 0.40864 * width, y: 0.21107 * height))
        path.addLine(to: CGPoint(x: 0.44224 * width, y: 0.17759 * height))
        path.addLine(to: CGPoint(x: 0.44216 * width, y: 0.17767 * height))
        path.addCurve(to: CGPoint(x: 0.45517 * width, y: 0.17241 * height), control1: CGPoint(x: 0.44556 * width, y: 0.17415 * height), control2: CGPoint(x: 0.45028 * width, y: 0.17224 * height))
        path.addLine(to: CGPoint(x: 0.46897 * width, y: 0.17241 * height))
        path.addLine(to: CGPoint(x: 0.46897 * width, y: 0.16207 * height))
        path.addLine(to: CGPoint(x: 0.46897 * width, y: 0.16196 * height))
        path.addCurve(to: CGPoint(x: 0.48991 * width, y: 0.14138 * height), control1: CGPoint(x: 0.46917 * width, y: 0.15054 * height), control2: CGPoint(x: 0.47849 * width, y: 0.14138 * height))
        path.addLine(to: CGPoint(x: 0.56207 * width, y: 0.14138 * height))
        path.addLine(to: CGPoint(x: 0.56218 * width, y: 0.14138 * height))
        path.addCurve(to: CGPoint(x: 0.58276 * width, y: 0.16233 * height), control1: CGPoint(x: 0.57360 * width, y: 0.14158 * height), control2: CGPoint(x: 0.58276 * width, y: 0.15090 * height))
        path.addLine(to: CGPoint(x: 0.58276 * width, y: 0.17241 * height))
        path.addLine(to: CGPoint(x: 0.59828 * width, y: 0.17241 * height))
        path.addLine(to: CGPoint(x: 0.59828 * width, y: 0.17241 * height))
        path.addCurve(to: CGPoint(x: 0.60345 * width, y: 0.17759 * height), control1: CGPoint(x: 0.60113 * width, y: 0.17241 * height), control2: CGPoint(x: 0.60345 * width, y: 0.17473 * height))
        path.addCurve(to: CGPoint(x: 0.59828 * width, y: 0.18276 * height), control1: CGPoint(x: 0.60345 * width, y: 0.18044 * height), control2: CGPoint(x: 0.60113 * width, y: 0.18276 * height))
        path.addLine(to: CGPoint(x: 0.52586 * width, y: 0.18276 * height))
        path.addLine(to: CGPoint(x: 0.52586 * width, y: 0.18276 * height))
        path.addCurve(to: CGPoint(x: 0.52069 * width, y: 0.17759 * height), control1: CGPoint(x: 0.52301 * width, y: 0.18276 * height), control2: CGPoint(x: 0.52069 * width, y: 0.18044 * height))
        path.addCurve(to: CGPoint(x: 0.52586 * width, y: 0.17241 * height), control1: CGPoint(x: 0.52069 * width, y: 0.17473 * height), control2: CGPoint(x: 0.52301 * width, y: 0.17241 * height))
        path.addLine(to: CGPoint(x: 0.56724 * width, y: 0.17241 * height))
        path.addLine(to: CGPoint(x: 0.56724 * width, y: 0.16207 * height))
        path.addLine(to: CGPoint(x: 0.56724 * width, y: 0.16209 * height))
        path.addCurve(to: CGPoint(x: 0.56214 * width, y: 0.15690 * height), control1: CGPoint(x: 0.56705 * width, y: 0.15934 * height), control2: CGPoint(x: 0.56489 * width, y: 0.15714 * height))
        path.addLine(to: CGPoint(x: 0.48966 * width, y: 0.15690 * height))
        path.addLine(to: CGPoint(x: 0.48968 * width, y: 0.15689 * height))
        path.addCurve(to: CGPoint(x: 0.48449 * width, y: 0.16200 * height), control1: CGPoint(x: 0.48693 * width, y: 0.15709 * height), control2: CGPoint(x: 0.48473 * width, y: 0.15925 * height))
        path.addLine(to: CGPoint(x: 0.48448 * width, y: 0.16207 * height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.42328 * width, y: 0.21897 * height))
        path.addLine(to: CGPoint(x: 0.46897 * width, y: 0.21897 * height))
        path.addLine(to: CGPoint(x: 0.46897 * width, y: 0.18793 * height))
        path.addLine(to: CGPoint(x: 0.45517 * width, y: 0.18793 * height))
        path.addCurve(to: CGPoint(x: 0.45345 * width, y: 0.18879 * height), control1: CGPoint(x: 0.45431 * width, y: 0.18793 * height), control2: CGPoint(x: 0.45431 * width, y: 0.18793 * height))
        path.addLine(to: CGPoint(x: 0.42328 * width, y: 0.21897 * height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.53621 * width, y: 0.27586 * height))
        path.addLine(to: CGPoint(x: 0.53621 * width, y: 0.27586 * height))
        path.addCurve(to: CGPoint(x: 0.55172 * width, y: 0.29138 * height), control1: CGPoint(x: 0.53621 * width, y: 0.28443 * height), control2: CGPoint(x: 0.54315 * width, y: 0.29138 * height))
        path.addCurve(to: CGPoint(x: 0.56724 * width, y: 0.27586 * height), control1: CGPoint(x: 0.56029 * width, y: 0.29138 * height), control2: CGPoint(x: 0.56724 * width, y: 0.28443 * height))
        path.addCurve(to: CGPoint(x: 0.55172 * width, y: 0.26034 * height), control1: CGPoint(x: 0.56724 * width, y: 0.26729 * height), control2: CGPoint(x: 0.56029 * width, y: 0.26034 * height))
        path.addLine(to: CGPoint(x: 0.55164 * width, y: 0.26034 * height))
        path.addCurve(to: CGPoint(x: 0.53621 * width, y: 0.27578 * height), control1: CGPoint(x: 0.54312 * width, y: 0.26034 * height), control2: CGPoint(x: 0.53621 * width, y: 0.26725 * height))
        path.addCurve(to: CGPoint(x: 0.53621 * width, y: 0.27604 * height), control1: CGPoint(x: 0.53621 * width, y: 0.27587 * height), control2: CGPoint(x: 0.53621 * width, y: 0.27596 * height))
        path.addLine(to: CGPoint(x: 0.53621 * width, y: 0.27586 * height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.46379 * width, y: 0.27586 * height))
        path.addLine(to: CGPoint(x: 0.46379 * width, y: 0.27586 * height))
        path.addCurve(to: CGPoint(x: 0.44828 * width, y: 0.26034 * height), control1: CGPoint(x: 0.46379 * width, y: 0.26729 * height), control2: CGPoint(x: 0.45685 * width, y: 0.26034 * height))
        path.addCurve(to: CGPoint(x: 0.43276 * width, y: 0.27586 * height), control1: CGPoint(x: 0.43971 * width, y: 0.26034 * height), control2: CGPoint(x: 0.43276 * width, y: 0.26729 * height))
        path.addCurve(to: CGPoint(x: 0.44828 * width, y: 0.29138 * height), control1: CGPoint(x: 0.43276 * width, y: 0.28443 * height), control2: CGPoint(x: 0.43971 * width, y: 0.29138 * height))
        path.addLine(to: CGPoint(x: 0.44836 * width, y: 0.29138 * height))
        path.addCurve(to: CGPoint(x: 0.46379 * width, y: 0.27595 * height), control1: CGPoint(x: 0.45688 * width, y: 0.29138 * height), control2: CGPoint(x: 0.46379 * width, y: 0.28447 * height))
        path.addCurve(to: CGPoint(x: 0.46379 * width, y: 0.27568 * height), control1: CGPoint(x: 0.46379 * width, y: 0.27586 * height), control2: CGPoint(x: 0.46379 * width, y: 0.27577 * height))
        path.addLine(to: CGPoint(x: 0.46379 * width, y: 0.27586 * height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.58793 * width, y: 0.19310 * height))
        path.addLine(to: CGPoint(x: 0.58793 * width, y: 0.19310 * height))
        path.addCurve(to: CGPoint(x: 0.59310 * width, y: 0.19828 * height), control1: CGPoint(x: 0.59079 * width, y: 0.19310 * height), control2: CGPoint(x: 0.59310 * width, y: 0.19542 * height))
        path.addCurve(to: CGPoint(x: 0.58793 * width, y: 0.20345 * height), control1: CGPoint(x: 0.59310 * width, y: 0.20113 * height), control2: CGPoint(x: 0.59079 * width, y: 0.20345 * height))
        path.addLine(to: CGPoint(x: 0.51552 * width, y: 0.20345 * height))
        path.addLine(to: CGPoint(x: 0.51552 * width, y: 0.20345 * height))
        path.addCurve(to: CGPoint(x: 0.51034 * width, y: 0.19828 * height), control1: CGPoint(x: 0.51266 * width, y: 0.20345 * height), control2: CGPoint(x: 0.51034 * width, y: 0.20113 * height))
        path.addCurve(to: CGPoint(x: 0.51552 * width, y: 0.19310 * height), control1: CGPoint(x: 0.51034 * width, y: 0.19542 * height), control2: CGPoint(x: 0.51266 * width, y: 0.19310 * height))
        path.addLine(to: CGPoint(x: 0.58793 * width, y: 0.19310 * height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.59828 * width, y: 0.21379 * height))
        path.addLine(to: CGPoint(x: 0.59828 * width, y: 0.21379 * height))
        path.addCurve(to: CGPoint(x: 0.60345 * width, y: 0.21897 * height), control1: CGPoint(x: 0.60113 * width, y: 0.21379 * height), control2: CGPoint(x: 0.60345 * width, y: 0.21611 * height))
        path.addCurve(to: CGPoint(x: 0.59828 * width, y: 0.22414 * height), control1: CGPoint(x: 0.60345 * width, y: 0.22182 * height), control2: CGPoint(x: 0.60113 * width, y: 0.22414 * height))
        path.addLine(to: CGPoint(x: 0.52586 * width, y: 0.22414 * height))
        path.addLine(to: CGPoint(x: 0.52586 * width, y: 0.22414 * height))
        path.addCurve(to: CGPoint(x: 0.52069 * width, y: 0.21897 * height), control1: CGPoint(x: 0.52301 * width, y: 0.22414 * height), control2: CGPoint(x: 0.52069 * width, y: 0.22182 * height))
        path.addCurve(to: CGPoint(x: 0.52586 * width, y: 0.21379 * height), control1: CGPoint(x: 0.52069 * width, y: 0.21611 * height), control2: CGPoint(x: 0.52301 * width, y: 0.21379 * height))
        path.addLine(to: CGPoint(x: 0.59828 * width, y: 0.21379 * height))
        path.closeSubpath()
        return path
    }
}

struct TruckRightShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.51034 * width, y: 0.15690 * height))
        path.addLine(to: CGPoint(x: 0.43793 * width, y: 0.15690 * height))
        path.addLine(to: CGPoint(x: 0.43796 * width, y: 0.15689 * height))
        path.addCurve(to: CGPoint(x: 0.43276 * width, y: 0.16200 * height), control1: CGPoint(x: 0.43521 * width, y: 0.15709 * height), control2: CGPoint(x: 0.43300 * width, y: 0.15925 * height))
        path.addLine(to: CGPoint(x: 0.43276 * width, y: 0.17241 * height))
        path.addLine(to: CGPoint(x: 0.47414 * width, y: 0.17241 * height))
        path.addLine(to: CGPoint(x: 0.47414 * width, y: 0.17241 * height))
        path.addCurve(to: CGPoint(x: 0.47931 * width, y: 0.17759 * height), control1: CGPoint(x: 0.47699 * width, y: 0.17241 * height), control2: CGPoint(x: 0.47931 * width, y: 0.17473 * height))
        path.addCurve(to: CGPoint(x: 0.47414 * width, y: 0.18276 * height), control1: CGPoint(x: 0.47931 * width, y: 0.18044 * height), control2: CGPoint(x: 0.47699 * width, y: 0.18276 * height))
        path.addLine(to: CGPoint(x: 0.40172 * width, y: 0.18276 * height))
        path.addLine(to: CGPoint(x: 0.40172 * width, y: 0.18276 * height))
        path.addCurve(to: CGPoint(x: 0.39655 * width, y: 0.17759 * height), control1: CGPoint(x: 0.39887 * width, y: 0.18276 * height), control2: CGPoint(x: 0.39655 * width, y: 0.18044 * height))
        path.addCurve(to: CGPoint(x: 0.40172 * width, y: 0.17241 * height), control1: CGPoint(x: 0.39655 * width, y: 0.17473 * height), control2: CGPoint(x: 0.39887 * width, y: 0.17241 * height))
        path.addLine(to: CGPoint(x: 0.41724 * width, y: 0.17241 * height))
        path.addLine(to: CGPoint(x: 0.41724 * width, y: 0.16207 * height))
        path.addLine(to: CGPoint(x: 0.41724 * width, y: 0.16196 * height))
        path.addCurve(to: CGPoint(x: 0.43819 * width, y: 0.14138 * height), control1: CGPoint(x: 0.41744 * width, y: 0.15054 * height), control2: CGPoint(x: 0.42676 * width, y: 0.14138 * height))
        path.addLine(to: CGPoint(x: 0.51034 * width, y: 0.14138 * height))
        path.addLine(to: CGPoint(x: 0.51045 * width, y: 0.14138 * height))
        path.addCurve(to: CGPoint(x: 0.53104 * width, y: 0.16233 * height), control1: CGPoint(x: 0.52188 * width, y: 0.14158 * height), control2: CGPoint(x: 0.53104 * width, y: 0.15090 * height))
        path.addLine(to: CGPoint(x: 0.53103 * width, y: 0.17241 * height))
        path.addLine(to: CGPoint(x: 0.54483 * width, y: 0.17241 * height))
        path.addLine(to: CGPoint(x: 0.54483 * width, y: 0.17241 * height))
        path.addCurve(to: CGPoint(x: 0.55784 * width, y: 0.17767 * height), control1: CGPoint(x: 0.54972 * width, y: 0.17224 * height), control2: CGPoint(x: 0.55444 * width, y: 0.17415 * height))
        path.addLine(to: CGPoint(x: 0.58793 * width, y: 0.20776 * height))
        path.addLine(to: CGPoint(x: 0.58785 * width, y: 0.20768 * height))
        path.addCurve(to: CGPoint(x: 0.59310 * width, y: 0.22068 * height), control1: CGPoint(x: 0.59136 * width, y: 0.21107 * height), control2: CGPoint(x: 0.59327 * width, y: 0.21580 * height))
        path.addLine(to: CGPoint(x: 0.59310 * width, y: 0.26034 * height))
        path.addLine(to: CGPoint(x: 0.59569 * width, y: 0.26034 * height))
        path.addLine(to: CGPoint(x: 0.59569 * width, y: 0.26034 * height))
        path.addCurve(to: CGPoint(x: 0.60345 * width, y: 0.26810 * height), control1: CGPoint(x: 0.59997 * width, y: 0.26034 * height), control2: CGPoint(x: 0.60345 * width, y: 0.26382 * height))
        path.addCurve(to: CGPoint(x: 0.59569 * width, y: 0.27586 * height), control1: CGPoint(x: 0.60345 * width, y: 0.27239 * height), control2: CGPoint(x: 0.59997 * width, y: 0.27586 * height))
        path.addLine(to: CGPoint(x: 0.58276 * width, y: 0.27586 * height))
        path.addLine(to: CGPoint(x: 0.58276 * width, y: 0.27586 * height))
        path.addCurve(to: CGPoint(x: 0.55172 * width, y: 0.30690 * height), control1: CGPoint(x: 0.58276 * width, y: 0.29300 * height), control2: CGPoint(x: 0.56886 * width, y: 0.30690 * height))
        path.addCurve(to: CGPoint(x: 0.52069 * width, y: 0.27586 * height), control1: CGPoint(x: 0.53458 * width, y: 0.30690 * height), control2: CGPoint(x: 0.52069 * width, y: 0.29300 * height))
        path.addLine(to: CGPoint(x: 0.47931 * width, y: 0.27586 * height))
        path.addLine(to: CGPoint(x: 0.47931 * width, y: 0.27586 * height))
        path.addCurve(to: CGPoint(x: 0.44828 * width, y: 0.30690 * height), control1: CGPoint(x: 0.47931 * width, y: 0.29300 * height), control2: CGPoint(x: 0.46542 * width, y: 0.30690 * height))
        path.addCurve(to: CGPoint(x: 0.41724 * width, y: 0.27586 * height), control1: CGPoint(x: 0.43114 * width, y: 0.30690 * height), control2: CGPoint(x: 0.41724 * width, y: 0.29300 * height))
        path.addLine(to: CGPoint(x: 0.41724 * width, y: 0.23448 * height))
        path.addLine(to: CGPoint(x: 0.43276 * width, y: 0.23448 * height))
        path.addLine(to: CGPoint(x: 0.43276 * width, y: 0.24914 * height))
        path.addLine(to: CGPoint(x: 0.43286 * width, y: 0.24908 * height))
        path.addCurve(to: CGPoint(x: 0.44818 * width, y: 0.24483 * height), control1: CGPoint(x: 0.43749 * width, y: 0.24630 * height), control2: CGPoint(x: 0.44278 * width, y: 0.24483 * height))
        path.addLine(to: CGPoint(x: 0.44847 * width, y: 0.24483 * height))
        path.addCurve(to: CGPoint(x: 0.47509 * width, y: 0.26050 * height), control1: CGPoint(x: 0.45954 * width, y: 0.24483 * height), control2: CGPoint(x: 0.46973 * width, y: 0.25083 * height))
        path.addLine(to: CGPoint(x: 0.51034 * width, y: 0.26034 * height))
        path.addLine(to: CGPoint(x: 0.51032 * width, y: 0.26035 * height))
        path.addCurve(to: CGPoint(x: 0.51551 * width, y: 0.25525 * height), control1: CGPoint(x: 0.51307 * width, y: 0.26015 * height), control2: CGPoint(x: 0.51527 * width, y: 0.25799 * height))
        path.addLine(to: CGPoint(x: 0.51552 * width, y: 0.16207 * height))
        path.addLine(to: CGPoint(x: 0.51552 * width, y: 0.16209 * height))
        path.addCurve(to: CGPoint(x: 0.51042 * width, y: 0.15690 * height), control1: CGPoint(x: 0.51533 * width, y: 0.15934 * height), control2: CGPoint(x: 0.51316 * width, y: 0.15714 * height))
        path.addLine(to: CGPoint(x: 0.51034 * width, y: 0.15690 * height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.54655 * width, y: 0.18879 * height))
        path.addCurve(to: CGPoint(x: 0.54483 * width, y: 0.18793 * height), control1: CGPoint(x: 0.54569 * width, y: 0.18793 * height), control2: CGPoint(x: 0.54569 * width, y: 0.18793 * height))
        path.addLine(to: CGPoint(x: 0.53103 * width, y: 0.18793 * height))
        path.addLine(to: CGPoint(x: 0.53103 * width, y: 0.21897 * height))
        path.addLine(to: CGPoint(x: 0.57672 * width, y: 0.21897 * height))
        path.addLine(to: CGPoint(x: 0.54655 * width, y: 0.18879 * height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.44828 * width, y: 0.26034 * height))
        path.addLine(to: CGPoint(x: 0.44828 * width, y: 0.26034 * height))
        path.addCurve(to: CGPoint(x: 0.43276 * width, y: 0.27586 * height), control1: CGPoint(x: 0.43971 * width, y: 0.26034 * height), control2: CGPoint(x: 0.43276 * width, y: 0.26729 * height))
        path.addCurve(to: CGPoint(x: 0.44828 * width, y: 0.29138 * height), control1: CGPoint(x: 0.43276 * width, y: 0.28443 * height), control2: CGPoint(x: 0.43971 * width, y: 0.29138 * height))
        path.addCurve(to: CGPoint(x: 0.46379 * width, y: 0.27586 * height), control1: CGPoint(x: 0.45685 * width, y: 0.29138 * height), control2: CGPoint(x: 0.46379 * width, y: 0.28443 * height))
        path.addLine(to: CGPoint(x: 0.46379 * width, y: 0.27578 * height))
        path.addCurve(to: CGPoint(x: 0.44836 * width, y: 0.26034 * height), control1: CGPoint(x: 0.46379 * width, y: 0.26725 * height), control2: CGPoint(x: 0.45688 * width, y: 0.26034 * height))
        path.addCurve(to: CGPoint(x: 0.44809 * width, y: 0.26035 * height), control1: CGPoint(x: 0.44827 * width, y: 0.26034 * height), control2: CGPoint(x: 0.44818 * width, y: 0.26035 * height))
        path.addLine(to: CGPoint(x: 0.44828 * width, y: 0.26034 * height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.55172 * width, y: 0.29138 * height))
        path.addLine(to: CGPoint(x: 0.55172 * width, y: 0.29138 * height))
        path.addCurve(to: CGPoint(x: 0.56724 * width, y: 0.27586 * height), control1: CGPoint(x: 0.56029 * width, y: 0.29138 * height), control2: CGPoint(x: 0.56724 * width, y: 0.28443 * height))
        path.addCurve(to: CGPoint(x: 0.55172 * width, y: 0.26034 * height), control1: CGPoint(x: 0.56724 * width, y: 0.26729 * height), control2: CGPoint(x: 0.56029 * width, y: 0.26034 * height))
        path.addCurve(to: CGPoint(x: 0.53621 * width, y: 0.27586 * height), control1: CGPoint(x: 0.54315 * width, y: 0.26034 * height), control2: CGPoint(x: 0.53621 * width, y: 0.26729 * height))
        path.addLine(to: CGPoint(x: 0.53621 * width, y: 0.27595 * height))
        path.addCurve(to: CGPoint(x: 0.55164 * width, y: 0.29138 * height), control1: CGPoint(x: 0.53621 * width, y: 0.28447 * height), control2: CGPoint(x: 0.54312 * width, y: 0.29138 * height))
        path.addCurve(to: CGPoint(x: 0.55191 * width, y: 0.29138 * height), control1: CGPoint(x: 0.55173 * width, y: 0.29138 * height), control2: CGPoint(x: 0.55182 * width, y: 0.29138 * height))
        path.addLine(to: CGPoint(x: 0.55172 * width, y: 0.29138 * height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.48448 * width, y: 0.19310 * height))
        path.addLine(to: CGPoint(x: 0.48448 * width, y: 0.19310 * height))
        path.addCurve(to: CGPoint(x: 0.48966 * width, y: 0.19828 * height), control1: CGPoint(x: 0.48734 * width, y: 0.19310 * height), control2: CGPoint(x: 0.48966 * width, y: 0.19542 * height))
        path.addCurve(to: CGPoint(x: 0.48448 * width, y: 0.20345 * height), control1: CGPoint(x: 0.48966 * width, y: 0.20113 * height), control2: CGPoint(x: 0.48734 * width, y: 0.20345 * height))
        path.addLine(to: CGPoint(x: 0.41207 * width, y: 0.20345 * height))
        path.addLine(to: CGPoint(x: 0.41207 * width, y: 0.20345 * height))
        path.addCurve(to: CGPoint(x: 0.40690 * width, y: 0.19828 * height), control1: CGPoint(x: 0.40921 * width, y: 0.20345 * height), control2: CGPoint(x: 0.40690 * width, y: 0.20113 * height))
        path.addCurve(to: CGPoint(x: 0.41207 * width, y: 0.19310 * height), control1: CGPoint(x: 0.40690 * width, y: 0.19542 * height), control2: CGPoint(x: 0.40921 * width, y: 0.19310 * height))
        path.addLine(to: CGPoint(x: 0.48448 * width, y: 0.19310 * height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.47414 * width, y: 0.21379 * height))
        path.addLine(to: CGPoint(x: 0.47414 * width, y: 0.21379 * height))
        path.addCurve(to: CGPoint(x: 0.47931 * width, y: 0.21897 * height), control1: CGPoint(x: 0.47699 * width, y: 0.21379 * height), control2: CGPoint(x: 0.47931 * width, y: 0.21611 * height))
        path.addCurve(to: CGPoint(x: 0.47414 * width, y: 0.22414 * height), control1: CGPoint(x: 0.47931 * width, y: 0.22182 * height), control2: CGPoint(x: 0.47699 * width, y: 0.22414 * height))
        path.addLine(to: CGPoint(x: 0.40172 * width, y: 0.22414 * height))
        path.addLine(to: CGPoint(x: 0.40172 * width, y: 0.22414 * height))
        path.addCurve(to: CGPoint(x: 0.39655 * width, y: 0.21897 * height), control1: CGPoint(x: 0.39887 * width, y: 0.22414 * height), control2: CGPoint(x: 0.39655 * width, y: 0.22182 * height))
        path.addCurve(to: CGPoint(x: 0.40172 * width, y: 0.21379 * height), control1: CGPoint(x: 0.39655 * width, y: 0.21611 * height), control2: CGPoint(x: 0.39887 * width, y: 0.21379 * height))
        path.addLine(to: CGPoint(x: 0.47414 * width, y: 0.21379 * height))
        path.closeSubpath()
        return path
    }
}

struct DriverMapAnnotationView: View {
    
    let type: DriverMapViewModel.DriverMapLocationType
    
    var body: some View {
        if type == .destination {
            ZStack {
                PinShape()
                    .fill(Color.blue)
                    .frame(width: 88, height: 88)
                HomeShape()
                    .fill(Color.white)
                    .frame(width: 88, height: 88)
            }
        } else {
            ZStack {
                PinShape()
                    .fill(Color.blue)
                    .frame(width: 88, height: 88)
                TruckLeftShape()
                    .fill(Color.white)
                    .frame(width: 88, height: 88)
            }
        }
    }
}

struct DriverMapView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: DriverMapViewModel
    
    @ViewBuilder
    private var DriverMapView: some View {
        Map(coordinateRegion: $viewModel.mapRegion, annotationItems: viewModel.locations) { location in
            MapAnnotation(coordinate: location.coordinate) {
                DriverMapAnnotationView(type: location.type)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            // adopt the more modern alert style sytnax pattern where the OS allows
            if #available(iOS 15.0, *) {
                
                //completedDeliveryAlertTitle = ""
                //@Published var completedDeliveryAlertMessage
                
                DriverMapView
                    .alert(viewModel.completedDeliveryAlertTitle, isPresented: $viewModel.showCompletedAlert, actions: {
                        if viewModel.canCallStore {
                            Button(Strings.General.callStore.localized) {
                                viewModel.callStoreAndDismissMap()
                            }
                        }
                        Button(Strings.General.close.localized, role: .cancel) {
                            viewModel.dismissMap()
                        }
                    }, message: {
                        Text(verbatim: viewModel.completedDeliveryAlertMessage)
                    })
            } else {
                DriverMapView
                    .alert(isPresented: $viewModel.showCompletedAlert) {
                        
                        if viewModel.canCallStore {
                        
                            return Alert(
                                title: Text(viewModel.completedDeliveryAlertTitle),
                                message: Text(viewModel.completedDeliveryAlertMessage),
                                primaryButton: .default(
                                    Text(Strings.General.callStore.localized),
                                    action: { viewModel.callStoreAndDismissMap() }
                                ),
                                secondaryButton: .default(
                                    Text(Strings.General.close.localized),
                                    action: { viewModel.dismissMap() }
                                )
                            )
                        
                        } else {
                        
                            return Alert(
                                title: Text(viewModel.completedDeliveryAlertTitle),
                                message: Text(viewModel.completedDeliveryAlertMessage),
                                dismissButton: .default(
                                    Text(Strings.General.close.localized),
                                    action: {
                                        viewModel.dismissMap()
                                    }
                                )
                            )
                            
                        }
                    }
            }
        }
    }
}

struct DriverMapView_Previews: PreviewProvider {
    static var previews: some View {
        DriverMapView(
            viewModel: .init(
                container: .preview,
                mapParameters: DriverLocationMapParameters(
                    businessOrderId: 0,
                    driverLocation: DriverLocation(
                        orderId: 1966430,
                        pusher: PusherConfiguration(
                            clusterServer: "eu",
                            appKey: "dd1506734a87e7be40d9"
                        ),
                        store: StoreLocation(
                            latitude: 56.4087526,
                            longitude: -5.487593
                        ),
                        delivery: OrderDeliveryLocationAndStatus(
                            latitude: 56.410598,
                            longitude: -5.47583,
                            status: 5
                        ),
                        driver: DeliveryDriverLocationAndName(
                            name: "Test",
                            latitude: 56.497526,
                            longitude: -5.47783
                        )
                    ),
                    lastDeliveryOrder: LastDeliveryOrderOnDevice(
                        businessOrderId: 12345,
                        storeName: "Master Test",
                        storeContactNumber: "01381 12345456",
                        deliveryPostcode: "PA34 4AG"
                    ),
                    placedOrder: nil
                ),
                dismissDriverMapHandler: {}
            )
        )
    }
}


struct DriverMapShapesView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            PinShape()
                .fill(Color.blue)
                .frame(width: 88, height: 88)
            TruckRightShape()
                .fill(Color.white)
                .frame(width: 88, height: 88)
        }
    }
}
