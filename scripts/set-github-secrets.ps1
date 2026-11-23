# Copies the current AWS Academy Learner Lab credentials into the repository's
# encrypted GitHub Secrets. Lab credentials expire with each session (~4 h):
# run this script at the start of every lab session, before using the pipeline.
#
# Usage: .\scripts\set-github-secrets.ps1
param(
  [string]$Repo = "rayenmabrouk/terraform-cloud-project",
  [string]$CredentialsFile = "$HOME\.aws\credentials"
)
$ErrorActionPreference = "Stop"

$values = @{}
foreach ($line in Get-Content $CredentialsFile) {
  if ($line -match '^\s*(aws_access_key_id|aws_secret_access_key|aws_session_token)\s*=\s*(\S+)\s*$') {
    $values[$Matches[1]] = $Matches[2]
  }
}
if ($values.Count -ne 3) { throw "Expected 3 values in $CredentialsFile, found $($values.Count). Re-copy the block from AWS Details." }

gh secret set AWS_ACCESS_KEY_ID     --repo $Repo --body $values['aws_access_key_id']
gh secret set AWS_SECRET_ACCESS_KEY --repo $Repo --body $values['aws_secret_access_key']
gh secret set AWS_SESSION_TOKEN     --repo $Repo --body $values['aws_session_token']

Write-Host "3 secrets updated in $Repo"
gh secret list --repo $Repo
