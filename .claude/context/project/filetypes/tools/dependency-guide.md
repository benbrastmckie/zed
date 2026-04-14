# Filetypes Extension Dependency Guide

Installation instructions for all conversion tools used by the filetypes extension (macOS).

## Quick Install Summary

| Tool | Install Command |
|------|----------------|
| pymupdf | `pip install pymupdf` |
| pymupdf4llm | `pip install pymupdf4llm` |
| markitdown | `pip install markitdown` |
| pandoc | `brew install pandoc` |
| typst | `brew install typst` |
| pandas | `pip install pandas` |
| openpyxl | `pip install openpyxl` |
| python-pptx | `pip install python-pptx` |
| xlsx2csv | `pip install xlsx2csv` |
| pdflatex | `brew install --cask basictex` |

## Installation

### Homebrew

```bash
# Core tools
brew install pandoc typst

# LaTeX (warning: large download)
brew install mactex-no-gui

# Or minimal LaTeX
brew install basictex
```

### Python Packages

```bash
# Using Homebrew Python
pip3 install markitdown pandas openpyxl python-pptx xlsx2csv

# Or with virtual environment
python3 -m venv ~/.venvs/filetypes
source ~/.venvs/filetypes/bin/activate
pip install markitdown pandas openpyxl python-pptx xlsx2csv
```

## Package Details

### pymupdf (fitz)

PDF manipulation and extraction library.

- **Purpose**: Extract text, tables, and images from PDF, EPUB, and image files
- **Python package**: `pymupdf` (imported as `fitz`)
- **Capabilities**: Text extraction, table detection (`find_tables()`), OCR (with Tesseract), image extraction
- **Primary for**: PDF to Markdown conversion, EPUB extraction, image OCR
- **Note**: Decisively outperforms markitdown for PDF quality (structure, tables, formatting)

### pymupdf4llm (optional enhancement)

Enhanced markdown output from PyMuPDF.

- **Purpose**: High-quality PDF-to-markdown conversion optimized for LLM consumption
- **Python package**: `pymupdf4llm`
- **Capabilities**: Structured markdown with headers, lists, tables preserved from PDF layout
- **Note**: Optional enhancement; base pymupdf provides adequate output

### markitdown

Microsoft's document-to-markdown converter.

- **Purpose**: Convert DOCX, XLSX, PPTX, HTML, images to Markdown (primary for Office formats)
- **Python package**: `markitdown`
- **Capabilities**: OCR support, table extraction, embedded content
- **Note**: Installed via pip or uv tool install

### pandoc

Universal document converter.

- **Purpose**: Convert between Markdown, LaTeX, HTML, DOCX, etc.
- **System package**: Available on all major platforms
- **Capabilities**: Beamer slides, citations, templates

### typst

Modern typesetting system (LaTeX alternative).

- **Purpose**: Generate PDFs from Typst markup
- **Capabilities**: Fast compilation, modern syntax, Polylux/Touying slides
- **Note**: Install via `brew install typst`

### pandas

Data analysis library with table I/O.

- **Purpose**: Read spreadsheets, generate LaTeX tables
- **Key function**: `DataFrame.to_latex()`
- **Requires**: openpyxl for .xlsx support

### openpyxl

Excel file handler for Python.

- **Purpose**: Read .xlsx files with full feature support
- **Capabilities**: Formulas, styles, charts (read calculated values)
- **Works with**: pandas for DataFrame creation

### python-pptx

PowerPoint file handler for Python.

- **Purpose**: Extract slides, text, images, speaker notes
- **Capabilities**: Full PPTX structure access
- **Works with**: pandas for tables, Pillow for images

### xlsx2csv

Simple XLSX to CSV converter.

- **Purpose**: Fallback for XLSX extraction
- **Capabilities**: Sheet selection, basic formatting
- **Use when**: pandas/openpyxl unavailable

### pdflatex

LaTeX to PDF compiler.

- **Purpose**: Compile Beamer slides to PDF
- **Part of**: texlive distribution
- **Note**: Large download; consider scheme-basic for minimal install

## Verification Commands

Check if tools are available:

```bash
# CLI tools
command -v markitdown && echo "markitdown: OK"
command -v pandoc && echo "pandoc: OK"
command -v typst && echo "typst: OK"
command -v pdflatex && echo "pdflatex: OK"
command -v xlsx2csv && echo "xlsx2csv: OK"

# Python packages
python3 -c "import fitz" && echo "pymupdf: OK"
python3 -c "import pymupdf4llm" && echo "pymupdf4llm: OK"
python3 -c "import pandas" && echo "pandas: OK"
python3 -c "import openpyxl" && echo "openpyxl: OK"
python3 -c "import pptx" && echo "python-pptx: OK"
python3 -c "import markitdown" && echo "markitdown (Python): OK"
```

## Troubleshooting

### "Package not found" in pip

```bash
# Ensure pip is up to date
pip install --upgrade pip

# Try with --user flag
pip install --user markitdown
```

### "pdflatex command not found"

LaTeX is distributed as texlive. On macOS, install via `brew install --cask basictex` (minimal) or `brew install --cask mactex` (complete, large).

### csv2latex Not Available

The csv2latex tool is not widely packaged. Use pandas instead:
```python
import pandas as pd
df = pd.read_csv("data.csv")
print(df.to_latex(index=False))
```
