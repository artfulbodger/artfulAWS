---
external help file: artfulAWS-help.xml
Module Name: artfulAWS
online version:
schema: 2.0.0
---

# Update-artfulIAMSAMLProvider

## SYNOPSIS
Updates AWS IAM Identity provider using metadata provided by an ADFS endpoint.

## SYNTAX

```
Update-artfulIAMSAMLProvider [-Name] <String> [-Id] <String> [-adfsfqdn] <String> [-profilename] <String>
 [[-iamrole] <String>] [[-region] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Downloads the ADFS metadata document directly from the ADFS endpoint declared, then updates the defined IAM Identity Provide with the metadata from ADFS
by assuming the rolename provided.

## EXAMPLES

### EXAMPLE 1
```
Update-artfulIAMSAMLProvider -id '012345678912' -adfsfqdn 'adfs.example.com' -profilename awsuser -Name MySSO -iamrole 'OrganizationAccountAccessRole'
Downloads the metadata document from 'adfs.example.com', connects to account 012345678912 and assumes role 'OrganizationAccountAccessRole'.
Updates Identity provider 'MySSO' with metadata document retrieved from 'adfs.example.com'
```

## PARAMETERS

### -Name
The name of the SAML provider to update

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
The unique identifier (ID) of the account.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -adfsfqdn
Fully Qualified domain name for ADFS endpoint to query for metadata.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -profilename
The user-defined name of an AWS credentials or SAML-based role profile containing credential information.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -iamrole
The name of the IAM role to assume, including any path.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: OrganizationAccountAccessRole
Accept pipeline input: False
Accept wildcard characters: False
```

### -region
The system name of an AWS region or an AWSRegion instance.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: Eu-west-1
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
