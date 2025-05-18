import SwiftCrossUI
import Foundation

let darkYellow = Color(0.741, 0.741, 0.0)
fileprivate let minHeight = 1 + Int(2 * strokeWidth)
fileprivate let minWidth = 24 + Int(7 * strokeWidth)
fileprivate let idealWidth = 288 + Int(7 * strokeWidth)

#if canImport(GtkBackend)
fileprivate let strokeWidth = 1
fileprivate let maxHeight = 16

struct Meter: View {
    @Environment(\.colorScheme) var colorScheme
    var statName: String
    var width: Float

    var strokeColor: Color {
        switch colorScheme {
        case .dark: .white
        case .light: .black
        }
    }

    var fillColor: Color {
        switch colorScheme {
        case .dark: darkYellow
        case .light: .yellow
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(statName)
                .if(colorScheme == .dark) {
                    $0.foregroundColor(darkYellow)
                }

            VStack(spacing: 0) {
                strokeColor.frame(width: Int(idealWidth), height: strokeWidth)

                HStack(spacing: 0) {
                    Group {
                        strokeColor.frame(width: strokeWidth)

                        fillColor.frame(
                            width: Int(min(width, 1.0) * Float(idealWidth - 7 * strokeWidth) / 6.0)
                        )

                        Color.clear.frame(
                            width: Int(max(1.0 - width, 0.0) * Float(idealWidth - 7 * strokeWidth) / 6.0)
                        )

                        strokeColor.frame(width: strokeWidth)

                        fillColor.frame(
                            width: Int(max(min(width - 1.0, 1.0), 0.0) * Float(idealWidth - 7 * strokeWidth) / 6.0)
                        )

                        Color.clear.frame(
                            width: Int(min(max(2.0 - width, 0.0), 1.0) * Float(idealWidth - 7 * strokeWidth) / 6.0)
                        )

                        strokeColor.frame(width: strokeWidth)

                        fillColor.frame(
                            width: Int(max(min(width - 2.0, 1.0), 0.0) * Float(idealWidth - 7 * strokeWidth) / 6.0)
                        )

                        Color.clear.frame(
                            width: Int(min(max(3.0 - width, 0.0), 1.0) * Float(idealWidth - 7 * strokeWidth) / 6.0)
                        )
                    }

                    strokeColor.frame(width: strokeWidth)

                    Group {
                        fillColor.frame(
                            width: Int(max(min(width - 3.0, 1.0), 0.0) * Float(idealWidth - 7 * strokeWidth) / 6.0)
                        )

                        Color.clear.frame(
                            width: Int(min(max(4.0 - width, 0.0), 1.0) * Float(idealWidth - 7 * strokeWidth) / 6.0)
                        )

                        strokeColor.frame(width: strokeWidth)

                        fillColor.frame(
                            width: Int(max(min(width - 4.0, 1.0), 0.0) * Float(idealWidth - 7 * strokeWidth) / 6.0)
                        )

                        Color.clear.frame(
                            width: Int(min(max(5.0 - width, 0.0), 1.0) * Float(idealWidth - 7 * strokeWidth) / 6.0)
                        )

                        strokeColor.frame(width: strokeWidth)

                        fillColor.frame(
                            width: Int(max(width - 5.0, 0.0) * Float(idealWidth - 7 * strokeWidth) / 6.0)
                        )

                        Color.clear.frame(
                            width: Int(min(6.0 - width, 1.0) * Float(idealWidth - 7 * strokeWidth) / 6.0)
                        )

                        strokeColor.frame(width: strokeWidth)
                    }
                }

                strokeColor.frame(width: Int(idealWidth), height: strokeWidth)
            }
            .frame(
                minHeight: minHeight,
                idealHeight: maxHeight,
                maxHeight: Double(maxHeight)
            )
        }
    }
}
#else
fileprivate let strokeWidth = 1.5
fileprivate let slant = 0.2
fileprivate let maxHeight = 16.0

fileprivate func meterSize(_ proposal: SIMD2<Int>) -> ViewSize {
    ViewSize(
        size: SIMD2(
            x: max(minWidth, proposal.x),
            y: max(minHeight, min(proposal.y, Int(maxHeight)))
        ),
        idealSize: SIMD2(x: idealWidth, y: Int(maxHeight)),
        minimumWidth: minWidth,
        minimumHeight: minHeight,
        maximumWidth: nil,
        maximumHeight: maxHeight
    )
}

struct MeterShape: Shape {
    func path(in bounds: Path.Rect) -> Path {
        let radius = bounds.height / 7.0

        return Path()
            .move(to: SIMD2(x: bounds.maxX - radius, y: bounds.y))
            .addArc(
                center: SIMD2(x: bounds.maxX - radius, y: bounds.y + radius),
                radius: radius,
                startAngle: 1.5 * .pi,
                endAngle: atan(slant),
                clockwise: true
            )
            .addArc(
                center: SIMD2(
                    x: bounds.maxX - radius - slant * (bounds.height - 2.0 * radius),
                    y: bounds.maxY - radius
                ),
                radius: radius,
                startAngle: atan(slant),
                endAngle: .pi / 2.0,
                clockwise: true
            )
            .addArc(
                center: SIMD2(x: bounds.x + radius, y: bounds.maxY - radius),
                radius: radius,
                startAngle: .pi / 2.0,
                endAngle: atan(slant) + .pi,
                clockwise: true
            )
            .addArc(
                center: SIMD2(
                    x: bounds.x + radius + slant * (bounds.height - 2.0 * radius),
                    y: bounds.y + radius
                ),
                radius: radius,
                startAngle: atan(slant) + .pi,
                endAngle: 1.5 * .pi,
                clockwise: true
            )
            .addLine(to: SIMD2(x: bounds.maxX - radius, y: bounds.y))
    }
}

struct MeterForeground: StyledShape {
    @Environment(\.colorScheme) var colorScheme

    let fillColor: Color? = nil
    var strokeColor: Color? {
        switch colorScheme {
        case .dark: .white
        case .light: .black
        }
    }
    var strokeStyle: StrokeStyle? = StrokeStyle(width: strokeWidth)

    func path(in bounds: Path.Rect) -> Path {
        let radius = (bounds.height - strokeWidth) / 7.0

        var path = MeterShape()
            .path(
                in: Path.Rect(
                    x: bounds.x + strokeWidth / 2.0,
                    y: bounds.y + strokeWidth / 2.0,
                    width: bounds.width - strokeWidth,
                    height: bounds.height - strokeWidth
                )
            )

        let offset = bounds.x + strokeWidth / 2.0
        let width = bounds.width - strokeWidth - (bounds.height - radius - strokeWidth) * slant

        for i in 1..<6 {
            path = path
                .move(
                    to: SIMD2(
                        x: offset + width * Double(i) / 6.0,
                        y: bounds.maxY - strokeWidth / 2.0
                    )
                )
                .addLine(
                    to: SIMD2(
                        x: offset + width * Double(i) / 6.0 + (bounds.height - strokeWidth) * slant,
                        y: bounds.y + strokeWidth / 2.0
                    )
                )
        }

        return path
    }

    func size(fitting proposal: SIMD2<Int>) -> ViewSize {
        meterSize(proposal)
    }
}

struct MeterBackground: StyledShape {
    @Environment(\.colorScheme) var colorScheme

    var width: Float

    var fillColor: Color? {
        switch colorScheme {
        case .dark: darkYellow
        case .light: .yellow
        }
    }
    let strokeColor: Color? = nil
    let strokeStyle: StrokeStyle? = nil

    func path(in bounds: Path.Rect) -> Path {
        MeterShape()
            .path(
                in: Path.Rect(
                    x: bounds.x + strokeWidth / 2.0,
                    y: bounds.y + strokeWidth / 2.0,
                    // This expression was derived experimentally and I have no logical explanation for it.
                    width: (bounds.width - 7.0 * strokeWidth) * Double(width / 6.0) + strokeWidth * Double(2.375 + width / 2.0),
                    height: bounds.height - strokeWidth
                )
            )
    }

    func size(fitting proposal: SIMD2<Int>) -> ViewSize {
        meterSize(proposal)
    }
}

struct Meter: View {
    @Environment(\.colorScheme) var colorScheme
    var statName: String
    var width: Float

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(statName)
                .if(colorScheme == .dark) {
                    $0.foregroundColor(darkYellow)
                }
                .padding(.leading, Int(slant * maxHeight))

            ZStack {
                MeterBackground(width: width)

                MeterForeground()
            }
        }
    }
}
#endif