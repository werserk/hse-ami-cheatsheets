# LaTeXmk configuration for HSE AMI Cheatsheets
# This file configures latexmk to keep temporary files organized

# Set output directory for temporary files
$out_dir = 'build';

# Ensure the build directory exists
system("mkdir -p $out_dir");

# PDF generation settings
$pdf_mode = 1;
$postscript_mode = 0;
$dvi_mode = 0;

# Clean up settings
$cleanup_includes_generated = 1;
$cleanup_includes_patterns = [
    '*.aux',
    '*.bbl',
    '*.bcf',
    '*.blg',
    '*.fdb_latexmk',
    '*.fls',
    '*.log',
    '*.out',
    '*.run.xml',
    '*.synctex.gz',
    '*.toc',
    '*.nav',
    '*.snm',
    '*.vrb',
    '*.idx',
    '*.ilg',
    '*.ind',
    '*.lof',
    '*.lot',
    '*.maf',
    '*.mtc',
    '*.mtc0',
    '*.slf',
    '*.slt',
    '*.stc',
    '*.thm',
    '*.toc',
    '*.xdy'
];

# Compilation settings
$pdflatex = 'pdflatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=%O %S';
$pdf_previewer = 'start xdg-open';
$pdf_previewer = 'open' if $^O eq 'darwin';

# Force compilation if needed
$force_mode = 0;

# Verbose output
$verbose = 0;

# Print summary
$print_type = 'pdf';
