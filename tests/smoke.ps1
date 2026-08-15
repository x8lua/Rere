$source = Get-Content "$PSScriptRoot\..\src\Rere.lua" -Raw
foreach ($marker in @("local function requireModule", "return requireModule(nodes['Iris'])", "Rere executor distribution", "resolveExecutorParent")) {
    if (-not $source.Contains($marker)) { throw "Missing bundle marker: $marker" }
}
if (-not $source.Contains('Iris.Version = "0.1.22"')) { throw "Bundle version is not 0.1.22" }
if (-not $source.Contains('local OpenTweenInfo = TweenInfo.new(0.15')) { throw "Dropdown duration is not 0.15 seconds" }
if ([regex]::Matches($source, 'ArrowGlyph\.Rotation = TargetRotation').Count -ne 1) { throw "Missing arrow glyph rotation initialization" }
if ([regex]::Matches($source, 'TweenService:Create\(ArrowGlyph, OpenTweenInfo, \{ Rotation = TargetRotation \}\):Play\(\)').Count -ne 1) { throw "Missing arrow glyph rotation tween" }
if (-not $source.Contains("function Iris:GetVersion(): string")) { throw "Missing GetVersion API" }
if ([regex]::Matches($source, 'local ArrowRotationFrame = Instance.new\("Frame"\)').Count -ne 2) { throw "Tree and CollapsingHeader must both generate arrow rotation wrappers" }
if (-not (Test-Path "$PSScriptRoot\..\examples\executor_basic.lua")) { throw "Missing executor example" }
if (-not (Test-Path "$PSScriptRoot\..\examples\slider.lua")) { throw "Missing slider example" }
if (-not (Test-Path "$PSScriptRoot\..\examples\settings_demo.lua")) { throw "Missing settings demo" }
if (-not (Test-Path "$PSScriptRoot\..\examples\feature_demo.lua")) { throw "Missing feature demo" }
if (-not (Test-Path "$PSScriptRoot\..\docs\gitbook.md")) { throw "Missing GitBook docs" }
Write-Output "Rere executor bundle smoke test passed."
