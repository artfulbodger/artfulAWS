#Requires -Modules @{ModuleName="AWS.Tools.Common"; ModuleVersion="4.0.5.0"}, @{ModuleName="AWS.Tools.IdentityManagement"; ModuleVersion="4.0.5.0"}
function Update-artfulIAMSAMLProvider {
  <#
    .SYNOPSIS
      Updates AWS IAM Identity provider using metadata provided by an ADFS endpoint.

      .DESCRIPTION
      Downloads the ADFS metadata document directly from the ADFS endpoint declared, then updates the defined IAM Identity Provide with the metadata from ADFS
      by assuming the rolename provided.

      .PARAMETER id
      The unique identifier (ID) of the account.

      .PARAMETER adfsfqdn
      Fully Qualified domain name for ADFS endpoint to query for metadata.

      .PARAMETER profilename
      The user-defined name of an AWS credentials or SAML-based role profile containing credential information.

      .PARAMETER iamrole
      The name of the IAM role to assume, including any path.

      .PARAMETER Name
      The name of the SAML provider to update

      .PARAMETER region
      The system name of an AWS region or an AWSRegion instance.

      .EXAMPLE
      Update-artfulIAMSAMLProvider -id '012345678912' -adfsfqdn 'adfs.example.com' -profilename awsuser -Name MySSO -iamrole 'OrganizationAccountAccessRole'
      Downloads the metadata document from 'adfs.example.com', connects to account 012345678912 and assumes role 'OrganizationAccountAccessRole'.
      Updates Identity provider 'MySSO' with metadata document retrieved from 'adfs.example.com'

      .LINK
      New-artfulIAMSAMLProvider (https://artfulbodger.github.io/artfulAWS/New-artfulIAMSAMLProvider)

      .LINK
      Update-artfulIAMSAMLProvider (https://artfulbodger.github.io/artfulAWS/Update-artfulIAMSAMLProvider)
  #>

  [CmdletBinding(SupportsShouldProcess = $true)]
  Param
  (
    [Parameter(Mandatory)][string]$Name,
    [Parameter(Mandatory, ValueFromPipeline)][ValidatePattern('\d{12}')][string]$Id,
    [Parameter(Mandatory)][string]$adfsfqdn,
    [Parameter(Mandatory)][string]$profilename,
    [Parameter()][string]$iamrole = 'OrganizationAccountAccessRole',
    [Parameter()][string]$region = 'eu-west-1'
  )

  Begin {
    If ($PSCmdlet.ShouldProcess("AWS Account $Id", "Update ADFS SAML Identity Provider")) {
      Try {
        $metadata = Invoke-Webrequest -uri "https://$($adfsfqdn)/FederationMetadata/2007-06/FederationMetadata.xml"
        $roleargs = @{
          RoleArn           = "arn:aws:iam::$($Id):role/$($iamrole)";
          RoleSessionName   = $Id;
          DurationInSeconds = 900;
          Profilename       = $profilename;
          Region            = $region;
        }
        $role = Use-STSRole @roleargs
        $samlargs = @{
          SAMLProviderArn      = "arn:aws:iam::$($Id):saml-provider/$($Name)";
          SAMLMetadataDocument = $metadata.content;
          Credential           = $role.Credentials;
          Region               = $region;
        }
        Update-IAMSAMLProvider @samlargs
      }
      Catch {
        Write-Verbose $_.exception.message
      }
    }
    else {

    }
  }
  Process {
  }
  End {
  }
}