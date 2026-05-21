//
//  ExportAppIcon.swift
//  DuneMoon
//
//  Export app icon at all required iOS sizes
//

import SwiftUI
import UIKit

@MainActor
class AppIconExporter {
    static func exportIcons(to directory: URL) async throws {
        let sizes: [(size: CGFloat, name: String)] = [
            (1024, "AppIcon-1024"),
            (180, "AppIcon-180"),  // iPhone 3x
            (167, "AppIcon-167"),  // iPad Pro
            (152, "AppIcon-152"),  // iPad 2x
            (120, "AppIcon-120"),  // iPhone 2x
            (87, "AppIcon-87"),    // iPhone 3x settings
            (80, "AppIcon-80"),    // iPhone 2x settings
            (76, "AppIcon-76"),    // iPad 1x
            (60, "AppIcon-60"),    // iPhone 2x spotlight
            (58, "AppIcon-58"),    // iPhone 2x settings
            (40, "AppIcon-40"),    // iPhone 2x spotlight
            (29, "AppIcon-29"),    // iPhone 1x settings
            (20, "AppIcon-20")     // iPhone 1x notification
        ]
        
        for (size, name) in sizes {
            let image = try await renderIcon(size: size)
            let url = directory.appendingPathComponent("\(name).png")
            
            if let data = image.pngData() {
                try data.write(to: url)
                print("✓ Exported: \(name).png")
            }
        }
        
        print("\n✓ All icons exported to: \(directory.path)")
    }
    
    private static func renderIcon(size: CGFloat) async throws -> UIImage {
        let renderer = ImageRenderer(content: AppIconView())
        renderer.scale = 1.0 // Use 1:1 scale since we're rendering at exact size
        
        // Set the size for rendering
        renderer.proposedSize = ProposedViewSize(width: size, height: size)
        
        guard let image = renderer.uiImage else {
            throw NSError(domain: "AppIconExporter", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to render icon"])
        }
        
        return image
    }
}

// Helper view for exporting icons
struct IconExporterView: View {
    @State private var exportStatus = "Tap button to export all icon sizes"
    @State private var isExporting = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("App Icon Exporter")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.26))
                
                // Preview of icon
                AppIconView()
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 44))
                    .overlay(
                        RoundedRectangle(cornerRadius: 44)
                            .stroke(Color(red: 1.0, green: 0.55, blue: 0.26).opacity(0.5), lineWidth: 2)
                    )
                    .shadow(color: Color(red: 1.0, green: 0.55, blue: 0.26).opacity(0.3), radius: 20)
                
                Text(exportStatus)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .frame(height: 60)
                
                Button(action: {
                    Task {
                        await exportIcons()
                    }
                }) {
                    HStack {
                        if isExporting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        } else {
                            Image(systemName: "square.and.arrow.down")
                        }
                        Text(isExporting ? "Exporting..." : "Export All Icon Sizes")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: 300)
                    .padding()
                    .background(Color(red: 1.0, green: 0.55, blue: 0.26))
                    .foregroundColor(.black)
                    .cornerRadius(12)
                }
                .disabled(isExporting)
            }
            .padding()
        }
    }
    
    private func exportIcons() async {
        isExporting = true
        exportStatus = "Creating icon directory..."
        
        do {
            // Export to Documents directory (iOS compatible)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let iconsURL = documentsURL.appendingPathComponent("DuneMoonIcons")
            
            // Create directory if it doesn't exist
            try FileManager.default.createDirectory(at: iconsURL, withIntermediateDirectories: true)
            
            exportStatus = "Rendering icons at all sizes..."
            
            try await AppIconExporter.exportIcons(to: iconsURL)
            
            exportStatus = "✓ Success! Icons saved to app Documents folder.\nYou can access them via Files app."
        } catch {
            exportStatus = "✗ Error: \(error.localizedDescription)"
        }
        
        isExporting = false
    }
}

#Preview {
    IconExporterView()
}
