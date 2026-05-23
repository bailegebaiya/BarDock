import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let assets = root.appendingPathComponent("Assets", isDirectory: true)
let iconset = assets.appendingPathComponent("AppIcon.iconset", isDirectory: true)
let icon = assets.appendingPathComponent("BarDock.icns")

try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

let blue = NSColor(red: 0.02, green: 0.42, blue: 0.94, alpha: 1)
let blueSoft = NSColor(red: 0.52, green: 0.78, blue: 1, alpha: 1)
let ink = NSColor(red: 0.12, green: 0.15, blue: 0.18, alpha: 1)

func drawIcon(size pixels: Int) -> NSBitmapImageRep {
    let size = CGFloat(pixels)
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixels,
        pixelsHigh: pixels,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = NSSize(width: size, height: size)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSGraphicsContext.current?.imageInterpolation = .high

    NSColor.clear.setFill()
    NSRect(x: 0, y: 0, width: size, height: size).fill()

    let inset = size * 0.075
    let iconRect = NSRect(x: inset, y: inset, width: size - inset * 2, height: size - inset * 2)
    let radius = size * 0.205

    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.18)
    shadow.shadowBlurRadius = size * 0.055
    shadow.shadowOffset = NSSize(width: 0, height: -size * 0.018)
    shadow.set()

    let background = NSBezierPath(roundedRect: iconRect, xRadius: radius, yRadius: radius)
    NSGradient(colors: [
        NSColor(red: 0.99, green: 1.0, blue: 1.0, alpha: 1),
        NSColor(red: 0.90, green: 0.95, blue: 1.0, alpha: 1)
    ])!.draw(in: background, angle: 90)

    NSGraphicsContext.restoreGraphicsState()
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    let strokeWidth = max(2, size * 0.045)
    let barRect = NSRect(x: size * 0.205, y: size * 0.345, width: size * 0.59, height: size * 0.35)
    let barPath = NSBezierPath(roundedRect: barRect, xRadius: size * 0.045, yRadius: size * 0.045)
    blue.setStroke()
    barPath.lineWidth = strokeWidth
    barPath.stroke()

    let topLine = NSBezierPath()
    topLine.move(to: NSPoint(x: barRect.minX + strokeWidth, y: barRect.maxY - size * 0.09))
    topLine.line(to: NSPoint(x: barRect.maxX - strokeWidth, y: barRect.maxY - size * 0.09))
    topLine.lineWidth = max(1.5, strokeWidth * 0.55)
    blueSoft.setStroke()
    topLine.stroke()

    let dot = NSBezierPath(ovalIn: NSRect(x: size * 0.43, y: size * 0.205, width: size * 0.055, height: size * 0.055))
    ink.withAlphaComponent(0.38).setFill()
    dot.fill()

    let chevron = NSBezierPath()
    chevron.move(to: NSPoint(x: size * 0.60, y: size * 0.21))
    chevron.line(to: NSPoint(x: size * 0.66, y: size * 0.265))
    chevron.line(to: NSPoint(x: size * 0.60, y: size * 0.32))
    chevron.lineWidth = max(2, size * 0.034)
    chevron.lineCapStyle = .round
    chevron.lineJoinStyle = .round
    ink.withAlphaComponent(0.62).setStroke()
    chevron.stroke()

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

let outputs: [(String, Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

for (name, pixels) in outputs {
    let rep = drawIcon(size: pixels)
    let data = rep.representation(using: .png, properties: [:])!
    try data.write(to: iconset.appendingPathComponent(name))
}

func bigEndianData(_ value: UInt32) -> Data {
    var big = value.bigEndian
    return Data(bytes: &big, count: MemoryLayout<UInt32>.size)
}

let icnsChunks: [(String, String)] = [
    ("icp4", "icon_16x16.png"),
    ("icp5", "icon_32x32.png"),
    ("icp6", "icon_32x32@2x.png"),
    ("ic07", "icon_128x128.png"),
    ("ic08", "icon_256x256.png"),
    ("ic09", "icon_512x512.png"),
    ("ic10", "icon_512x512@2x.png")
]

var chunks = Data()
for (type, fileName) in icnsChunks {
    let png = try Data(contentsOf: iconset.appendingPathComponent(fileName))
    chunks.append(type.data(using: .macOSRoman)!)
    chunks.append(bigEndianData(UInt32(png.count + 8)))
    chunks.append(png)
}

var icns = Data()
icns.append("icns".data(using: .macOSRoman)!)
icns.append(bigEndianData(UInt32(chunks.count + 8)))
icns.append(chunks)
try icns.write(to: icon)
