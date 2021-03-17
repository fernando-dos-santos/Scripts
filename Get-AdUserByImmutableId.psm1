<#
.Synopsis
   Retrive AD user with ImmutableId.
.DESCRIPTION
   Use this function to retrive an AD on-prem user using the ImmutableId property from Azure AD. It will only work if the Azure AD Connect was configured to use mS-DS-ConsistencyGUID attribute as SourceAnchor.
.EXAMPLE
   Get-AdUserByImmutableId -ImmutableId Onq55xlk8EODYe39VEbB2Q==
.EXAMPLE
    Get-MsolUser -UserPrincipalName usuario1@domain.com | Get-AdUserByImmutableId
.INPUTS
   ImmutableId property
.OUTPUTS
    Microsoft.ActiveDirectory.Management.ADUser  
.NOTES
   contato@fernando-dos-santos.com
#>
function Get-AdUserByImmutableId
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [string]$ImmutableId
    )

    Process{
        if($ImmutableId -match ".+=="){
            $ObjectGuid = $null
            $ADUser = $null
            $ObjectGuid = [Guid]([System.Convert]::FromBase64String($ImmutableId))
            $ADUser = Get-AdUser -Filter "objectGuid -eq '$($ObjectGuid)'"
            if($ADUser){
                $ADUser
            }
            else{
                Write-Warning "User with ImmutableId $($ImmutableId) could not be found."
            }
        }
        else{
            Write-Warning "ImmutableId attribute is null or invalid."
        }
    }
}

