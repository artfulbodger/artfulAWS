Write-Host "$PSScriptRoot"
$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psm1")
$moduleName = Split-Path $moduleRoot -Leaf

Describe "General project validation: $moduleName" {

    $scripts = Get-ChildItem $moduleRoot -Include *.ps1, *.psm1, *.psd1 -Recurse

    # TestCases are splatted to the script so we need hashtables
    $testCase = $scripts | Foreach-Object {@{file = $_}}         
    It "Script <file> should be valid powershell" -TestCases $testCase {
        param($file)

        $file.fullname | Should Exist

        $contents = Get-Content -Path $file.fullname -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
        $errors.Count | Should Be 0
    }

    It "Module '$moduleName' can import cleanly" {
        {Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force } | Should Not Throw
    }
}

foreach ($Manifest in $ManifestPath) {

    $ModuleInfo = Import-Module -Name $Manifest -Force -PassThru

    $PS1FileNames = Get-ChildItem -Path "$($ModuleInfo.ModuleBase)\*.ps1" -Exclude *tests.ps1, *profile.ps1 |
                    Select-Object -ExpandProperty BaseName

    $ExportedFunctions = Get-Command -Module $ModuleInfo.Name |
                         Select-Object -ExpandProperty Name
                         
    $manifestfile = Get-Item $manifest
    
    $allfileslist = Get-ChildItem -Path "$($ModuleInfo.ModuleBase)\*.*" -Exclude "$($ModuleInfo.Name).psd1", "$($ModuleInfo.Name).psm1" | Select-Object -ExpandProperty Fullname

  
  Describe "FunctionsToExport for PowerShell module '$($ModuleInfo.Name)'" {
  
        It 'Contains a module in the correct folder name' {
          $manifestfile.BaseName | Should Be $manifestfile.Directory.Name
        }
        
        It 'Contains a root module with the same name as the module' {
          $ModuleInfo.RootModule | Should Be $manifestfile.BaseName
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
        It 'Only contains files listed in the module manifest' {
            Compare-Object -ReferenceObject $ModuleInfo.filelist -DifferenceObject $allfileslist | Should BeNullOrEmpty
        }
    }

}