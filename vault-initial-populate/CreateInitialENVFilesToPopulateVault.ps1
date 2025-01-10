#!/usr/bin/pwsh

$EnvArray = @{}
$EnvArray.add( "ENV.awsregion", "AWS Region e.g. eu-west-2" )
$EnvArray.add( "ENV.awsaccesskey", "AWS Access Key" )
$EnvArray.add( "ENV.awssecretkey", "AWS Secret Key" )
$EnvArray.add( "ENV.IPs_AllowedAccess_SSH", "IPs allowed to connect to SSH in format of X.X.X.X/32,Y.Y.Y.Y/32,Z.Z.Z.Z/32" )
$EnvArray.add( "ENV.labsshpubkey", "SSH Public key" )
$EnvArray.add( "ENV.labsshprivatekey", "SSH Private key" )
$EnvArray.add( "ENV.githubPATwww", "GitHub Repo URL with PAT Token Readonly" )



Write-Output "***********************************************************************"
Write-Output "Terraform lab examples under other folders use Vault secret values."
Write-Output ""
Write-Output "This script creates & populates ENV.xxx files, then can use"
Write-Output "terraform to populate Vault values using ENV.xxx file contents"
Write-Output "***********************************************************************"

$AnyFileUpdated = $false

foreach($ENV_File in $EnvArray.Keys) {

    if (Test-Path -Path $ENV_File) {
        $title = "$ENV_File already exists";
        $question = "Do you want to replace it?"
        $choices  = '&Yes', '&No', '&Exit'

        $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)

        if ($decision -eq 0) {
            Write-Host "Confirmed, remove $ENV_File"
            Remove-Item -Path $ENV_File
        }
        if ($decision -eq 2) {
            exit
        }
    }
    
    if (-not (Test-Path -Path $ENV_File)) {
        Write-Output "$ENV_File = $EnvArray[$ENV_File]"
        $ENV_FileContent = Read-Host "Enter your value for $ENV_File :" -MaskInput
        New-Item -ItemType File -Path $ENV_File -Force -Value $ENV_FileContent
        Write-Output ""
        Write-Output "$ENV_File Created."
        $AnyFileUpdated = $true
    }

    Write-Output ""
}

Write-Output "***********************************************************************"

if($AnyFileUpdated -eq $true) {
    Write-Output "New ENV files created"
    Write-Output "If you have created the vault entries before you must first 'terraform destroy'"
    Write-Output "then you can 'terraform apply' to populate the vault"
} else {
    Write-Output "No new ENV files created"
}

Write-Output "***********************************************************************"