# SlatePDF

**A Technical Experiment in AI-Assisted macOS Development**

SlatePDF is a fully offline macOS PDF utility built to rigorously test the real capabilities and limits of AI-assisted software development with native Apple frameworks.

## 🎯 Project Goals

This project aims to:

- **Evaluate AI effectiveness** when working with Apple's native PDF stack (PDFKit, Core Graphics, AppKit/SwiftUI)
- **Test AI reliability** when manipulating structured binary formats without introducing data corruption  
- **Measure time savings** versus where human judgment and intervention remain essential
- **Identify failure modes** such as hallucinated APIs, subtle logic errors, and unsafe file operations
- **Document insights** to establish patterns that improve correctness and maintainability

> **Note:** The primary output is learning and technical insight, not commercial distribution.

## ✨ Features

- **Merge PDFs**: Combine multiple PDF documents into one
- **Reorder Pages**: Drag and drop pages within a document  
- **Delete Pages**: Remove unwanted pages from your PDFs
- **Add Text**: Add text annotations to any page with custom font and color
- **Add Images**: Insert images into your PDFs as stamps
- **Edit Annotations**: Manage and delete text/image annotations
- **100% Offline**: No network access, no telemetry, no cloud dependencies
- **Safe Operations**: Atomic file writes with automatic backups

**Note**: SlatePDF adds text and images as PDF annotations (overlays), not by editing the underlying PDF content streams.

## 🚀 Installation

### Via Homebrew (Coming Soon)

```bash
brew tap kipmyk/slatepdf
brew install --cask slatepdf
```

### Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/kipmyk/SlatePDF.git
cd SlatePDF
```

2. Build with Swift:
```bash
swift build -c release
```

3. Run the application:
```bash
.build/release/SlatePDF
```

## 🏗️ Architecture

SlatePDF follows a three-layer architecture:

```
┌─────────────────────────┐
│   SwiftUI Views         │  UI Layer
│   (ContentView, Grid)   │
├─────────────────────────┤
│   ViewModels            │  State Management
│   (DocumentViewModel)   │
├─────────────────────────┤
│   Core PDF Engine       │  Business Logic
│   (Extensions, Validator)│
└─────────────────────────┘
```

### Core Components

**PDF Operations** (`PDFDocument+Operations.swift`)
- Safe merge, reorder, and delete operations
- Comprehensive validation to prevent corruption
- Detailed error handling

**Safe File I/O** (`FileManager+SafeIO.swift`)
- Atomic write operations
- Automatic backup before modifications
- Rollback on failure

**PDF Validation** (`PDFValidator.swift`)
- Format verification
- Page integrity checks
- Metadata preservation

## 🧪 Testing

Run the test suite:

```bash
swift test
```

Tests cover:
- ✅ Core PDF operations (100% coverage)
- ✅ File I/O safety mechanisms
- ✅ Edge cases and error conditions
- ✅ Performance with large PDFs

## 📊 AI Development Insights

See [AI_INSIGHTS.md](AI_INSIGHTS.md) for detailed observations on:
- AI-generated code that worked perfectly
- Hallucinated APIs and required corrections
- Time savings vs manual development
- Effective prompt patterns
- Where human expertise was essential

## 🔒 Privacy & Security

- **Fully offline**: No network requests, ever
- **Local processing**: All PDF operations run on-device
- **Sandboxed**: macOS App Sandbox enabled
- **Code signed**: (if built for distribution)

## 🛠️ Technology Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **PDF Processing**: PDFKit, Core Graphics
- **Platform**: macOS 13.0+
- **Build System**: Swift Package Manager

## 📝 License

MIT License - See LICENSE file for details

## 🤝 Contributing

While this is primarily a research project, insights and improvements are welcome:

1. Fork the repository
2. Create a feature branch
3. Document your changes in AI_INSIGHTS.md if AI-assisted
4. Submit a pull request

## ⚠️ Limitations

This is an experimental project with intentionally limited scope:
- Basic PDF operations only (no OCR, annotations, forms)
- macOS only (no iOS/iPadOS)
- No advanced features (compression, optimization, encryption)

## 📖 Documentation

- [Implementation Plan](docs/implementation_plan.md)
- [AI Development Insights](AI_INSIGHTS.md)
- [Testing Strategy](docs/testing.md)

---

**Built with AI assistance to explore the future of software development**
