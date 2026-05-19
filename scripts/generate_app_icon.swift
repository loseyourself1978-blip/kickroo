import AppKit
import Foundation

struct IconSlot {
    let idiom: String
    let size: Int
    let scale: Int

    var points: String { "\(size)x\(size)" }
    var filename: String { "icon-\(size)@\(scale)x.png" }
    var pixels: Int { size * scale }
}

let slots = [
    IconSlot(idiom: "iphone", size: 20, scale: 2),
    IconSlot(idiom: "iphone", size: 20, scale: 3),
    IconSlot(idiom: "iphone", size: 29, scale: 2),
    IconSlot(idiom: "iphone", size: 29, scale: 3),
    IconSlot(idiom: "iphone", size: 40, scale: 2),
    IconSlot(idiom: "iphone", size: 40, scale: 3),
    IconSlot(idiom: "iphone", size: 60, scale: 2),
    IconSlot(idiom: "iphone", size: 60, scale: 3),
    IconSlot(idiom: "ios-marketing", size: 1024, scale: 1)
]

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let iconDir = root.appendingPathComponent("KickNations/Assets.xcassets/AppIcon.appiconset")

func drawIcon(pixels: Int, to url: URL) throws {
    let bytesPerRow = pixels * 4
    var pixelData = [UInt8](repeating: 0, count: bytesPerRow * pixels)
    guard let cgContext = CGContext(
        data: &pixelData,
        width: pixels,
        height: pixels,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
    ) else {
        throw NSError(domain: "IconGeneration", code: 0)
    }

    NSGraphicsContext.saveGraphicsState()
    let context = NSGraphicsContext(cgContext: cgContext, flipped: false)
    NSGraphicsContext.current = context

    let size = NSSize(width: pixels, height: pixels)
    let rect = NSRect(origin: .zero, size: size)
    NSColor(calibratedRed: 0.04, green: 0.07, blue: 0.12, alpha: 1).setFill()
    rect.fill()

    let fieldRect = rect.insetBy(dx: size.width * 0.09, dy: size.height * 0.09)
    let fieldPath = NSBezierPath(roundedRect: fieldRect, xRadius: size.width * 0.08, yRadius: size.width * 0.08)
    NSColor(calibratedRed: 0.06, green: 0.36, blue: 0.27, alpha: 1).setFill()
    fieldPath.fill()

    NSColor(calibratedWhite: 1, alpha: 0.18).setStroke()
    fieldPath.lineWidth = max(2, size.width * 0.012)
    fieldPath.stroke()

    let net = NSBezierPath(roundedRect: NSRect(
        x: fieldRect.minX + size.width * 0.12,
        y: fieldRect.maxY - size.height * 0.28,
        width: fieldRect.width - size.width * 0.24,
        height: size.height * 0.15
    ), xRadius: size.width * 0.035, yRadius: size.width * 0.035)
    NSColor(calibratedWhite: 1, alpha: 0.14).setFill()
    net.fill()

    let postWidth = size.width * 0.06
    let postHeight = size.height * 0.30
    let postY = fieldRect.maxY - size.height * 0.29
    for x in [fieldRect.minX + size.width * 0.10, fieldRect.maxX - size.width * 0.16] {
        let post = NSBezierPath(
            roundedRect: NSRect(x: x, y: postY, width: postWidth, height: postHeight),
            xRadius: postWidth * 0.45,
            yRadius: postWidth * 0.45
        )
        NSColor(calibratedRed: 0.95, green: 0.76, blue: 0.31, alpha: 1).setFill()
        post.fill()
    }

    let waveCenter = NSPoint(x: size.width * 0.28, y: size.height * 0.58)
    for index in 0..<3 {
        let radius = size.width * (0.18 + CGFloat(index) * 0.09)
        let wave = NSBezierPath(ovalIn: NSRect(x: waveCenter.x - radius, y: waveCenter.y - radius, width: radius * 2, height: radius * 2))
        NSColor(calibratedRed: 0.15, green: 0.35, blue: 0.90, alpha: 0.26 - CGFloat(index) * 0.05).setStroke()
        wave.lineWidth = max(2, size.width * 0.018)
        wave.stroke()
    }

    let ballRadius = size.width * 0.18
    let ballRect = NSRect(
        x: size.width * 0.50 - ballRadius,
        y: size.height * 0.48 - ballRadius,
        width: ballRadius * 2,
        height: ballRadius * 2
    )
    let ball = NSBezierPath(ovalIn: ballRect)
    NSColor(calibratedRed: 0.98, green: 0.96, blue: 0.88, alpha: 1).setFill()
    ball.fill()
    NSColor(calibratedRed: 0.08, green: 0.10, blue: 0.15, alpha: 1).setStroke()
    ball.lineWidth = max(2, size.width * 0.016)
    ball.stroke()

    let seam = NSBezierPath(ovalIn: ballRect.insetBy(dx: ballRadius * 0.34, dy: ballRadius * 0.34))
    seam.lineWidth = max(1, size.width * 0.008)
    seam.stroke()

    for index in 0..<5 {
        let angle = CGFloat(index) * (.pi * 2 / 5) - .pi / 2
        let patchRadius = ballRadius * (index == 0 ? 0.22 : 0.14)
        let patchCenter = NSPoint(
            x: ballRect.midX + cos(angle) * ballRadius * 0.48,
            y: ballRect.midY + sin(angle) * ballRadius * 0.48
        )
        let patch = NSBezierPath(ovalIn: NSRect(
            x: patchCenter.x - patchRadius,
            y: patchCenter.y - patchRadius,
            width: patchRadius * 2,
            height: patchRadius * 2
        ))
        NSColor(calibratedRed: 0.08, green: 0.10, blue: 0.15, alpha: 1).setFill()
        patch.fill()
    }

    NSColor(calibratedRed: 0.94, green: 0.32, blue: 0.31, alpha: 1).setFill()
    let scarf = NSBezierPath(roundedRect: NSRect(x: size.width * 0.34, y: size.height * 0.27, width: size.width * 0.35, height: size.height * 0.08), xRadius: size.width * 0.02, yRadius: size.width * 0.02)
    var transform = AffineTransform(translationByX: size.width * 0.51, byY: size.height * 0.31)
    transform.rotate(byDegrees: -12)
    transform.translate(x: -size.width * 0.51, y: -size.height * 0.31)
    scarf.transform(using: transform)
    scarf.fill()

    NSGraphicsContext.restoreGraphicsState()

    guard let cgImage = cgContext.makeImage() else {
        throw NSError(domain: "IconGeneration", code: 1)
    }
    let bitmap = NSBitmapImageRep(cgImage: cgImage)
    guard let data = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "IconGeneration", code: 2)
    }
    try data.write(to: url)
}

try FileManager.default.createDirectory(at: iconDir, withIntermediateDirectories: true)
for slot in slots {
    try drawIcon(pixels: slot.pixels, to: iconDir.appendingPathComponent(slot.filename))
}

let images = slots.map { slot -> [String: String] in
    [
        "idiom": slot.idiom,
        "size": slot.points,
        "scale": "\(slot.scale)x",
        "filename": slot.filename
    ]
}
let catalog: [String: Any] = [
    "images": images,
    "info": [
        "author": "xcode",
        "version": 1
    ]
]
let data = try JSONSerialization.data(withJSONObject: catalog, options: [.prettyPrinted, .sortedKeys])
try data.write(to: iconDir.appendingPathComponent("Contents.json"))
print("Generated \(slots.count) app icon files")
