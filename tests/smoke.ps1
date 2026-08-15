$source = Get-Content "$PSScriptRoot\..\src\Rere.lua" -Raw
foreach ($marker in @("local function requireModule", "return requireModule(nodes['Iris'])", "Rere executor distribution", "resolveExecutorParent")) {
    if (-not $source.Contains($marker)) { throw "Missing bundle marker: $marker" }
}
if (-not $source.Contains('Iris.Version = "0.1.20"')) { throw "Bundle version is not 0.1.20" }
if (-not $source.Contains('local ArrowHalfTweenInfo = TweenInfo.new(0.125')) { throw "Missing visible arrow flip animation" }
if (-not $source.Contains("function Iris:GetVersion(): string")) { throw "Missing GetVersion API" }
if ([regex]::Matches($source, 'local ArrowRotationFrame = Instance.new\("Frame"\)').Count -ne 2) { throw "Tree and CollapsingHeader must both generate arrow rotation wrappers" }
if (-not (Test-Path "$PSScriptRoot\..\examples\executor_basic.lua")) { throw "Missing executor example" }
if (-not (Test-Path "$PSScriptRoot\..\examples\slider.lua")) { throw "Missing slider example" }
if (-not (Test-Path "$PSScriptRoot\..\examples\settings_demo.lua")) { throw "Missing settings demo" }
if (-not (Test-Path "$PSScriptRoot\..\examples\feature_demo.lua")) { throw "Missing feature demo" }
if (-not (Test-Path "$PSScriptRoot\..\docs\gitbook.md")) { throw "Missing GitBook docs" }
Write-Output "Rere executor bundle smoke test passed."
