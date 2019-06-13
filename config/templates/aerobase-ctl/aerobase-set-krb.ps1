<#
.SYNOPSIS
Execure all necessary commands in order to prepare kerberos spnego integration.
.DESCRIPTION
Execure all  necessary commands in order to prepare kerberos spnego integration
.PARAMETER SetKeytab
Prepare Keytab file for kerberos integration and place it under AEROBASE default home. Requires domain administrator rights.
.PARAMETER SpnUser
 Service Principal Names (SPN) user for an Active Directory service account.
.PARAMETER SpnPass
 Service Principal Names (SPN) password for an Active Directory service account
.PARAMETER SetSpn
Permanently sets Service Principal Names (SPN) for an Active Directory service account. Requires domain administrator rights.
.PARAMETER SetKrb5
Permanently sets krb5.ini to C:/. Requires domain administrator rights.
.PARAMETER KeytabDir
 Write keytab (ktpass) command output to directory. Defaults to C:/Aerobase/Configuration.
.PARAMETER Output
Outputs / Execute setspn/keytab/krb5.ini commands. Valid options are Exec, Log. Defaults to Log.
.EXAMPLE
Execute setspn / keytab / krb5.ini commands
aerobase-set-krb.ps1 -SetKeytab -SpnUser -SetKrb5 -SpnUser "SPN Account Name" -SpnPass "SPN Account Password"  -Output "Exec"
.EXAMPLE
Only print keytab / krb5.ini commands
aerobase-set-krb.ps1 -SetKeytab -SetKrb5 -SpnUser "SPN Account Name" -SpnPass "SPN Account Password"
.EXAMPLE
Only Execute keytab / krb5.ini commands to an output dir
aerobase-set-krb.ps1 -SetKeytab -SetKrb5 -SpnUser "SPN Account Name" -SpnPass "SPN Account Password" -KeytabDir "C:/Aerobase/Configuration" -Output "Exec"
.EXAMPLE
Only Execute keytab commands
aerobase-set-krb.ps1 -SetKeytab -SpnUser "aerobase" -SpnPass "123456" -Output "Exec"
#>
Param(
    [Switch]$SetKeytab,
    [Parameter(HelpMessage = "Write keytab (ktpass) command output to selected directory.")][ValidateNotNullOrEmpty()]$KeytabDir = "C:\",
    [Parameter(HelpMessage = "Service Principal Names (SPN) account name for an Active Directory")][ValidateNotNullOrEmpty()]$SpnUser = "",
    [Parameter(HelpMessage = "Service Principal Names (SPN) account password for an Active Directory")][ValidateNotNullOrEmpty()]$SpnPass = "",
    [Switch]$SetSpn,
    [Switch]$SetKrb5,
    [Parameter(HelpMessage = "Outputs / Execute setspn/keytab/krb5.ini commands")][String][ValidateSet("Exec", "Log")]$Output = "Log"
)

function is_admin {
    $admin = [Security.Principal.WindowsBuiltInRole]::Administrator
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    ([Security.Principal.WindowsPrincipal]($id)).IsInRole($admin)
}

function get_domain {
    (Get-WmiObject Win32_ComputerSystem).Domain
}

function get_compname {
    (Get-WmiObject Win32_ComputerSystem).Name
}

function get_fqdn {
    (get_compname) + '.' + (get_domain)
}

if ($SetSpn) {
    if (-Not (is_admin)) {
        Write-Error "ERROR: You need Administrator rights to run setspn command"
    }
	
    $cmd='C:\Windows\System32\setspn.exe -A HTTP/' + (get_fqdn) + ' ' + $SpnUser
    Write-Verbose -Verbose ('setspn command will output: ' + $cmd)
	
    if ($Output -eq "Exec"){
        Invoke-Expression $cmd
    }
}

if ($SetKeytab) {
    if (-Not (is_admin)) {
        Write-Error "ERROR: You need Administrator rights to run keytab command"
    }
	
    $cmd='C:\Windows\System32\ktpass -out ' + $KeytabDir + '/aerobase.keytab' + ' -princ HTTP/' + (get_fqdn) + '@' + (get_domain).ToUpper() + ' -mapUser ' + $SpnUser +  ' -mapOp set -pass ' + $SpnPass + ' -kvno 0 -crypto all -pType KRB5_NT_PRINCIPAL'
    Write-Verbose -Verbose ('ktpass command will output: ' + $cmd)
	
    if ($Output -eq "Exec"){
        Invoke-Expression $cmd
    }
}

if ($SetKrb5) {
    if (-Not (is_admin)) {
        Write-Error "ERROR: You need Administrator rights to set krb5.ini file"
    }
	
    $cmd='NOT Implemented Yet'
    Write-Verbose -Verbose ('ktpass command will output: ' + $cmd)
	
    if ($Output -eq "Exec"){
        Invoke-Expression $cmd
    }
}
