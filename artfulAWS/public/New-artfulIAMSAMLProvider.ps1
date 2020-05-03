#Requires -Modules @{ModuleName="AWS.Tools.Common"; ModuleVersion="4.0.5.0"}, @{ModuleName="AWS.Tools.IdentityManagement"; ModuleVersion="4.0.5.0"}
function New-artfulIAMSAMLProvider {
  <#
    .SYNOPSIS
      Describe purpose of New-artfulIAMSAMLProvider in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .PARAMETER Name
      The name of the provider to create.

      .PARAMETER Id
      The unique identifier (ID) of the account.

      .EXAMPLE
      New-artfulIAMSAMLProvider -Param1 Value
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      New-artfulIAMSAMLProvider (https://artfulbodger.github.io/artfulAWS/New-artfulIAMSAMLProvider)

      .LINK
      Update-artfulIAMSAMLProvider (https://artfulbodger.github.io/artfulAWS/Update-artfulIAMSAMLProvider)
  #>

  [CmdletBinding(SupportsShouldProcess = $true)]
  Param
  (
    [Parameter(Mandatory)][string]$Name,
    [Parameter(Mandatory, ValueFromPipeline)][ValidatePattern('\d{12}')][string]$Id
  )
  Begin {
  }
  Process {
    if ($PSCmdlet.ShouldProcess($Name, "Create new IdP")) {
      $newIdP = @{
        name = $Name
      }
      New-IAMSAMLProvider @newIdP
    }
    else {
      Write-Host ('Create new IdP {0}' -f $Name)
    }
  }
  End {
  }
}
