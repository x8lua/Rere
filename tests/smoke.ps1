$source = Get-Content "$PSScriptRoot\..\src\Rere.lua" -Raw
foreach ($marker in @("local function requireModule", "return requireModule(nodes['Iris'])", "Rere executor distribution", "resolveExecutorParent")) {
    if (-not $source.Contains($marker)) { throw "Missing bundle marker: $marker" }
}
if (-not (Test-Path "$PSScriptRoot\..\examples\executor_basic.lua")) { throw "Missing executor example" }
if (-not (Test-Path "$PSScriptRoot\..\examples\slider.lua")) { throw "Missing slider example" }
if (-not (Test-Path "$PSScriptRoot\..\docs\gitbook.md")) { throw "Missing GitBook docs" }
Write-Output "Rere executor bundle smoke test passed."
