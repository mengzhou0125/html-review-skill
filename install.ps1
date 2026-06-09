# html-review-skill · installer
#
# Usage (from a local clone):
#   .\install.ps1
#
# Idempotent — re-run to update. Copies this skill to ~/.claude/skills/html-review-skill/.

$ErrorActionPreference = 'Stop'

$skillName = 'html-review-skill'
$skillDir = Join-Path $env:USERPROFILE '.claude\skills'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not (Test-Path $skillDir)) {
  New-Item -ItemType Directory -Force -Path $skillDir | Out-Null
}

$target = Join-Path $skillDir $skillName
if (Test-Path $target) {
  Remove-Item -Recurse -Force $target
}
New-Item -ItemType Directory -Force -Path $target | Out-Null

foreach ($item in @('SKILL.md', 'references', 'specs')) {
  $src = Join-Path $scriptDir $item
  if (Test-Path $src) {
    Copy-Item -Recurse -Path $src -Destination $target
  }
}

Write-Host "✓ Installed: $skillName -> $target"
Write-Host ""
Write-Host "Next:"
Write-Host "  - trigger with:  render this doc as a review HTML  /  /html-review"
Write-Host "  - default visual style: DNA1 (bundled at specs/dna1-default.md)"
Write-Host "  - to use a different spec:  pass --spec=<path>  or  drop a design.md into <project>/.claude/"
Write-Host ""
Write-Host "For DNA1-compliance auditing, see:"
Write-Host "  https://github.com/mengzhou0125/evidence-poet-design-system  (install just the auditor: .\install.ps1 auditor)"
