$CSS = "/css/style.css"
$CSSPath = "css/style.css"
$OUTDIR_RELATIVE = "../rabbitrabbitcottage-dot-com"
# Resolve $OUTDIR to a full path so string comparisons and path operations work reliably
$OUTDIR = (Get-Item $OUTDIR_RELATIVE).FullName

# Calculate MD5 hash using native PowerShell (truncated to 8 hex chars)
if (Test-Path $CSSPath) {
    $CssHash = (Get-FileHash -Path $CSSPath -Algorithm MD5).Hash.Substring(0, 8).ToLower()
} else {
    $CssHash = "1" # Fallback
}

Write-Host "Calculated CSS Hash: $CssHash" -ForegroundColor Cyan

foreach ($file in (ls content\*.md -Recurse)) {
	$outfile = ($file -replace ".md", ".html") 
	pandoc $file --standalone --output $outfile -f markdown-smart -M css=$CSS -M css_hash=$CssHash --template=template.html --lua=fix-ids.lua --lua-filter=inline-variables.lua --lua-filter=cache-bust.lua --lua-filter=clean-links.lua

}

Get-ChildItem -Path $OUTDIR -Force |
    Where-Object { $_.Name -ne '.git' } |
    Remove-Item -Recurse -Force

# Copy all files from content, excluding .md files
Copy-Item .\content\* -Destination "$OUTDIR\" -Recurse -Exclude *.md -Force

# Copy CSS assets
if (-not (Test-Path "$OUTDIR\css")) { New-Item -ItemType Directory -Path "$OUTDIR\css" | Out-Null }
Copy-Item .\css\* -Destination "$OUTDIR\css" -Recurse -Force

# copy robots.txt
Copy-Item .\robots.txt -Destination "$OUTDIR\" -Force

# copy CNAME
Copy-Item .\CNAME -Destination "$OUTDIR\" -Force

# Clean up generated HTML files from content folder
Get-ChildItem -Path .\content\ -Filter *.html -Recurse | Remove-Item -Force