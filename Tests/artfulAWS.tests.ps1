Write-Host "$PSScriptRoot"
$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psm1")
$moduleName = Split-Path $moduleRoot -Leaf
$gittag = git describe --tags $(git rev-list --tags --max-count=1)
Describe "General project validation: $moduleName" {
    $scripts = Get-ChildItem $moduleRoot -Include *.ps1, *.psm1, *.psd1 -Recurse
    # TestCases are splatted to the script so we need hashtables
    $testCase = $scripts | Foreach-Object { @{file = $_ } }
    It "Script <file> should be valid powershell" -TestCases $testCase {
        param($file)
        $file.fullname | Should Exist
        $contents = Get-Content -Path $file.fullname -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
        $errors.Count | Should Be 0
    }
    It "Module '$moduleName' can import cleanly" {
        { Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force } | Should Not Throw
    }
    It 'Module version matches git tag' {
        Import-Module (Join-Path $moduleRoot "$moduleName.psd1") -force
        $mod = Get-Module -Name $moduleName
        $version = [string]$mod.version
        $gittag | Should Be $version
    }
    It "Module '$moduleName' HelpURI is accessible" {
        Import-Module (Join-Path $moduleRoot "$moduleName.psd1") -force
        $module = Get-Module -Name $moduleName
        $statuscode = (Invoke-Webrequest -Uri $($module.helpinfouri) -UseBasicParsing).StatusCode
        $statuscode | Should Be 200
    }
}

$ManifestPath = Get-ChildItem $moduleRoot -Include *.psd1 -Recurse
foreach ($Manifest in $ManifestPath) {
    $ModuleInfo = Import-Module -Name $Manifest -Force -PassThru
    $PS1FileNames = Get-ChildItem -Path "$($ModuleInfo.ModuleBase)\*.ps1" -Exclude *tests.ps1, *profile.ps1 -Recurse | Select-Object -ExpandProperty BaseName
    $ExportedFunctions = Get-Command -Module $ModuleInfo.Name | Select-Object -ExpandProperty Name
    $manifestfile = Get-Item $manifest
    $allfileslist = Get-ChildItem -Path "$($ModuleInfo.ModuleBase)\*.*" -Exclude "$($ModuleInfo.Name).psd1", "$($ModuleInfo.Name).psm1" -Recurse | Select-Object -ExpandProperty Fullname

    Describe "FunctionsToExport for PowerShell module '$($ModuleInfo.Name)'" {
        It 'Contains a module in the correct folder name' {
            $manifestfile.BaseName | Should Be $manifestfile.Directory.Name
        }
        It 'Contains a root module with the same name as the module' {
            $moduleinfo.rootmodule.split(".")[0] | Should Be $manifestfile.BaseName
        }
        It 'Exports one function in the module manifest per PS1 file' {
            $ModuleInfo.ExportedFunctions.Values.Name.Count |
            Should Be $PS1FileNames.Count
        }
        It 'Exports functions with names that match the PS1 file base names' {
            Compare-Object -ReferenceObject $ModuleInfo.ExportedFunctions.Values.Name -DifferenceObject $PS1FileNames |
            Should BeNullOrEmpty
        }
        It 'Only exports functions listed in the module manifest' {
            $ExportedFunctions.Count |
            Should Be $ModuleInfo.ExportedFunctions.Values.Name.Count
        }
        It 'Contains the same function names as base file names' {
            Compare-Object -ReferenceObject $PS1FileNames -DifferenceObject $ExportedFunctions |
            Should BeNullOrEmpty
        }
    }
    $ExportedFunctions = Get-Command -Module $ModuleInfo.Name
    Foreach ($Function in $ExportedFunctions) {
        Describe "Function '$($Function.Name)'" {
            It 'Has a valid Online help' {
                (Invoke-Webrequest -Uri $($Function.HelpUri) -UseBasicParsing).StatusCode | Should Be 200
            }
        }
        Describe "Function '$($Function.Name)' help metadata" {
            Import-Module (Join-Path $moduleRoot "$moduleName.psd1") -force
            $functionhelp = Get-Help $($Function.Name)
            It 'Has a custom Synopsis' {
                $functionhelp.synopsis |
                Should Not Be "Describe purpose of $($Function.Name) in 1-2 sentences."
            }
            It 'Has a custom Description' {
                $functionhelp.description |
                Should Not Be "Add a more complete description of what the function does."
            }
        }
    }
}