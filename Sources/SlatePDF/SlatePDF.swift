import SwiftUI

@main
struct SlatePDFApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) {
                // Remove New Window
            }
            
            CommandMenu("Document") {
                Button("Merge Selected") {
                    // Handled in ContentView
                }
                .keyboardShortcut("m", modifiers: [.command])
                
                Divider()
                
                Button("Delete Selected Pages") {
                    // Handled in ContentView
                }
                .keyboardShortcut(.delete, modifiers: [.command])
            }
        }
    }
}
