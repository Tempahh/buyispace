#!/bin/bash

BASE_DIR="/Users/mac/Documents/BUYISPACE/docs"
PDF_OUTPUT_DIR="$BASE_DIR/PDF_Output"
BY_VOLUME_DIR="$PDF_OUTPUT_DIR/By_Volume"
BY_CATEGORY_DIR="$PDF_OUTPUT_DIR/By_Category"
LOG_FILE="$BASE_DIR/LOG.md"

# Clean mode
if [[ "$1" == "--clean" ]]; then
    rm -rf "$PDF_OUTPUT_DIR"
fi

# Create output directories
mkdir -p "$BY_VOLUME_DIR"
mkdir -p "$BY_CATEGORY_DIR/Quick_Reference"
mkdir -p "$BY_CATEGORY_DIR/Executive"
mkdir -p "$BY_CATEGORY_DIR/Requirements"
mkdir -p "$BY_CATEGORY_DIR/Architecture"
mkdir -p "$BY_CATEGORY_DIR/Planning"
mkdir -p "$BY_CATEGORY_DIR/Operations"

# Generate log
cat > "$LOG_FILE" << 'LOGEOF'
# BUYI Documentation PDF Conversion Log

**Generated:** 16 September 2026  
**Platform:** macOS  
**Base Directory:** /Users/mac/Documents/BUYISPACE/docs

## Folder Structure Created

```
PDF_Output/
├── By_Volume/
│   └── (Place PDFs here in sequential order)
│
└── By_Category/
    ├── Quick_Reference/
    ├── Executive/
    ├── Requirements/
    ├── Architecture/
    ├── Planning/
    └── Operations/
```

## Markdown Files Ready for Conversion

- README.md
- vol-1-prd.md
- vol-2-srs.md
- vol-3-ddd-blueprint.md
- vol-4-system-architecture.md
- vol-5-event-catalog.md
- vol-6-build-roadmap.md
- vol-7-financial-implications.md

**Total:** 8 markdown files ready

## How to Convert to PDF

### Option 1: Google Docs (Recommended - Easiest)

For each markdown file:
1. Go to Google Docs: https://docs.google.com
2. Click "Create" → "Blank document"
3. Copy-paste the markdown content
4. File → Download → PDF (.pdf)
5. Save with appropriate name

### Option 2: VS Code + Markdown PDF Extension

Requirements:
- VS Code installed
- Install "Markdown PDF" extension by yzane

Steps:
1. Open any .md file in VS Code
2. Right-click → Select "Markdown PDF: Export (pdf)"
3. Choose save location

### Option 3: Install Pandoc (Command Line)

Prerequisites:
```bash
brew install pandoc
brew install --cask basictex
# or: https://tug.org/mactex/
```

Then run:
```bash
pandoc input.md -o output.pdf --toc --number-sections
```

### Option 4: macOS Print to PDF

For each file:
1. Open in TextEdit or VS Code
2. File → Print
3. Bottom-left: Click "PDF" dropdown
4. Select "Save as PDF"
5. Navigate to PDF_Output/By_Volume/

## File Organization Plan

### By_Volume/ (Sequential Reading Order)
- 00-README.pdf
- 01-vol-1-prd.pdf (Product Requirements)
- 02-vol-2-srs.pdf (Software Requirements)
- 03-vol-3-ddd-blueprint.pdf (DDD Blueprint)
- 04-vol-4-system-architecture.pdf (System Architecture)
- 05-vol-5-event-catalog.pdf (Event Catalog)
- 06-vol-6-build-roadmap.pdf (Build Roadmap)
- 07-vol-7-financial-implications.pdf (Financial Implications)

### By_Category/ (Role-Based Access)

**Quick_Reference/**
- README.pdf

**Requirements/**
- 01-Product-Requirements.pdf (from vol-1-prd.md)
- 02-Software-Requirements.pdf (from vol-2-srs.md)

**Architecture/**
- 01-DDD-Blueprint.pdf (from vol-3-ddd-blueprint.md)
- 02-System-Architecture.pdf (from vol-4-system-architecture.md)
- 03-Event-Catalog.pdf (from vol-5-event-catalog.md)

**Planning/**
- 01-Build-Roadmap.pdf (from vol-6-build-roadmap.md)

**Operations/**
- 01-Financial-Implications.pdf (from vol-7-financial-implications.md)

## Output Locations

**By Volume:**
```
/Users/mac/Documents/BUYISPACE/docs/PDF_Output/By_Volume
```

**By Category:**
```
/Users/mac/Documents/BUYISPACE/docs/PDF_Output/By_Category
```

## Next Steps

1. Choose your preferred conversion method from the options above
2. Convert all 8 markdown files to PDF
3. Organize them in the By_Volume folder
4. Copy/link them to By_Category folders as needed
5. Update this log with completion status

## Script Usage

Regenerate folder structure:
```bash
bash generate-pdf-log.sh
```

Clean and regenerate:
```bash
bash generate-pdf-log.sh --clean
```

---

**Status:** ✓ Folder structure created and ready  
**Completed:** 16 September 2026
LOGEOF

cat "$LOG_FILE"
echo ""
echo "✓ Log file created at: $LOG_FILE"
echo "✓ Folder structure ready at: $PDF_OUTPUT_DIR"
echo ""
echo "Open folder: open \"$PDF_OUTPUT_DIR\""
