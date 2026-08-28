<#
.SYNOPSIS
    Runs the Todoist Robot Framework test suite locally or in CI.

.PARAMETER Suite
    Which layer to run: 'ui', 'api', or 'all' (default).

.PARAMETER Include
    Tags to include (Robot's --include). Multiple tags are OR'd together.

.PARAMETER Exclude
    Tags to exclude (Robot's --exclude).

.PARAMETER ResultsDir
    Output directory for log.html / report.html / output.xml. Default: results

.PARAMETER ExtraArgs
    Any additional raw `robot` CLI arguments, passed through as-is.
    Example: -ExtraArgs '--skiponfailure','known_defect'

.EXAMPLE
    ./run-tests.ps1 -Suite api -Include smoke

.EXAMPLE
    ./run-tests.ps1 -Suite all -Exclude known_defect -ResultsDir results

.EXAMPLE
    ./run-tests.ps1 -Suite ui
#>
[CmdletBinding()]
param(
    [ValidateSet('ui', 'api', 'all')]
    [string]$Suite = 'all',

    [string[]]$Include = @(),

    [string[]]$Exclude = @(),

    [string]$ResultsDir = 'results',

    [string[]]$ExtraArgs = @()
)

$ErrorActionPreference = 'Stop'

if (-not $env:TODOIST_API_TOKEN) {
    Write-Warning "TODOIST_API_TOKEN is not set. API tests, and the API-backed setup/teardown used by UI tests, will fail. See config/credentials.template."
}

$testPath = switch ($Suite) {
    'ui'  { 'tests/ui' }
    'api' { 'tests/api' }
    'all' { 'tests' }
}

$roboArgs = @('--outputdir', $ResultsDir)

foreach ($tag in $Include) {
    $roboArgs += @('--include', $tag)
}

foreach ($tag in $Exclude) {
    $roboArgs += @('--exclude', $tag)
}

$roboArgs += $ExtraArgs
$roboArgs += $testPath

Write-Host "robot $($roboArgs -join ' ')"
robot @roboArgs

exit $LASTEXITCODE
