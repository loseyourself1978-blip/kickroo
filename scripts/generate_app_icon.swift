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
let sourceURL = root.appendingPathComponent("icon.png")
let iconDir = root.appendingPathComponent("KickNations/Assets.xcassets/AppIcon.appiconset")

guard let sourceImage = NSImage(contentsOf: sourceURL), sourceImage.size.width > 0, sourceImage.size.height > 0 else {
    throw NSError(
        domain: "KickrooIconGeneration",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Missing or unreadable icon.png at \(sourceURL.path)"]
    )
}

func drawSourceIcon(pixels: Int, to url: URL) throws {
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
        throw NSError(domain: "KickrooIconGeneration", code: 2)
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: cgContext, flipped: false)

    NSColor.black.setFill()
    NSRect(x: 0, y: 0, width: pixels, height: pixels).fill()

    let sourceSize = sourceImage.size
    let cropSide = min(sourceSize.width, sourceSize.height)
    let sourceRect = NSRect(
        x: (sourceSize.width - cropSide) / 2,
        y: (sourceSize.height - cropSide) / 2,
        width: cropSide,
        height: cropSide
    )
    let destinationRect = NSRect(x: 0, y: 0, width: pixels, height: pixels)
    sourceImage.draw(in: destinationRect, from: sourceRect, operation: .copy, fraction: 1.0)

    NSGraphicsContext.restoreGraphicsState()

    guard let cgImage = cgContext.makeImage() else {
        throw NSError(domain: "KickrooIconGeneration", code: 3)
    }
    let bitmap = NSBitmapImageRep(cgImage: cgImage)
    guard let data = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "KickrooIconGeneration", code: 4)
    }
    try data.write(to: url)
}

try FileManager.default.createDirectory(at: iconDir, withIntermediateDirectories: true)
for slot in slots {
    try drawSourceIcon(pixels: slot.pixels, to: iconDir.appendingPathComponent(slot.filename))
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
print("Generated \(slots.count) Kickroo app icon files from icon.png")
