<#
  run_flutter_tests.ps1

  Background: on this machine, bare `flutter test` (default concurrency)
  silently skips most test files under test/ while still printing "All
  tests passed!" and exiting 0 -- a false-green result. Comparing test
  output across repeated runs showed only a handful of files (e.g.
  compile_check_test.dart, e2e_flow_test.dart, widget_test.dart) actually
  got loaded; the rest never ran. This is a Windows environment quirk
  (likely related to the same loopback-connection issue documented for
  Gradle builds), not a bug in the tests themselves.

  Workaround: `flutter test -j 1` (concurrency = 1) reliably loads and runs
  every file. Always use this script (or `-j 1` directly) instead of bare
  `flutter test` when you need a trustworthy pass/fail signal.

  Usage:
    cd <project root>
    .\scripts\run_flutter_tests.ps1
#>
$ErrorActionPreference = "Stop"
$SourceDir = Split-Path -Parent $PSScriptRoot

Push-Location $SourceDir
try {
    flutter test -j 1
} finally {
    Pop-Location
}
