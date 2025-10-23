//
//  QRCodeView.swift
//  WorldPass
//
//  Created by Assistant on 22/10/25.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    let payload: String
    var size: CGFloat = 240
    var correctionLevel: String = "M" // L, M, Q, H

    private let context = CIContext()

    var body: some View {
        Group {
            if let cgImage = makeQRImage() {
                Image(decorative: cgImage, scale: 1, orientation: .up)
                    .interpolation(.none) // nítido en escalado
                    .resizable()
                    .scaledToFit()
            } else {
                // Fallback si no se pudo generar el QR
                ZStack {
                    Color.secondary.opacity(0.1)
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: size, height: size)
        .background(.white) // fondo blanco para “quiet zone” visible
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }

    private func makeQRImage() -> CGImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(payload.utf8)
        filter.correctionLevel = correctionLevel

        guard let outputImage = filter.outputImage else { return nil }

        // Escalado sin interpolación para que el QR se vea nítido
        let extent = outputImage.extent.integral
        let scale = max(1, Int((size / max(extent.width, extent.height)).rounded(.down)))
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale)))

        return context.createCGImage(scaledImage, from: scaledImage.extent)
    }
}
