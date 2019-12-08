<#
.SYNOPSIS
Execure all necessary commands in order to prepare kerberos spnego integration.
.DESCRIPTION
Execure all  necessary commands in order to prepare kerberos spnego integration
.PARAMETER SetKeytab
 Prepare Keytab file for kerberos integration and place it under AEROBASE default home. Requires domain administrator rights.
.PARAMETER SetKtab
 Prepare Keytab file for kerberos integration (using java ktab) and place it under AEROBASE default home. Requires domain administrator rights.
.PARAMETER SpnUser
 Service Principal Names (SPN) user for an Active Directory service account.
.PARAMETER SpnPass
 Service Principal Names (SPN) password for an Active Directory service account
.PARAMETER SetSpn
Permanently sets Service Principal Names (SPN) for an Active Directory service account. Requires domain administrator rights.
.PARAMETER SetKrb5
Permanently sets krb5.ini to Windows installation folder. Requires domain administrator rights.
.PARAMETER KeytabDir
 Write keytab (ktpass) command output to directory. Defaults to C:\Aerobase\Configuration.
.PARAMETER JavaDir
 Java Home to run ktab.exe. Defaults to C:\Aerobase\Aerobase\embedded\openjdk\jre\bin.
.PARAMETER SetFqdn
 Override FQDN of this machine, default is HOSTNAME.DOMAIN. 
.PARAMETER Output
Outputs / Execute setspn/keytab/krb5.ini commands. Valid options are Exec, Log. Defaults to Log.
.EXAMPLE
Execute setspn / keytab / krb5.ini commands
aerobase-set-krb.ps1 -SetKeytab -SetSpn -SetKrb5 -SpnUser "SPN Account Name" -SpnPass "SPN Account Password"  -Output "Exec"
.EXAMPLE
Execute keytab / krb5.ini commands using java ktab
aerobase-set-krb.ps1 -SetKtab -SetKrb5 -SpnPass "SPN Account Password" -Output "Exec"
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
    [Switch]$SetKtab,
    [Parameter(HelpMessage = "Write keytab (ktpass) command output to selected directory")][ValidateNotNullOrEmpty()]$KeytabDir=$env:SYSTEMDRIVE + "\Aerobase\Configuration",
	[Parameter(HelpMessage = "Java home dir for ktab.exe command (does not required for SetKeytab)")][ValidateNotNullOrEmpty()]$JavaDir=$env:SYSTEMDRIVE + "\Aerobase\Aerobase\embedded\openjdk\jre\bin",
	[Parameter(HelpMessage = "Override FQDN of this machine, default is HOSTNAME.DOMAIN")][ValidateNotNullOrEmpty()]$SetFqdn = "",
    [Parameter(HelpMessage = "Service Principal Names (SPN) account name for an Active Directory")][ValidateNotNullOrEmpty()]$SpnUser = "",
    [Parameter(HelpMessage = "Service Principal Names (SPN) account password for an Active Directory")][ValidateNotNullOrEmpty()]$SpnPass = "",
    [Switch]$SetSpn,
    [Switch]$SetKrb5,
    [Parameter(HelpMessage = "Outputs / Execute setspn/keytab/krb5.ini commands")][String][ValidateSet("Exec", "Log")]$Output = "Log"
)

$winroot = $env:SYSTEMROOT
$system32 = $winroot + '\System32'


function is_admin {
    $admin = [Security.Principal.WindowsBuiltInRole]::Administrator
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    ([Security.Principal.WindowsPrincipal]($id)).IsInRole($admin)
}

function get_domain {
    (Get-WmiObject Win32_ComputerSystem).Domain
}

function get_dc {
    $getdomain = [System.Directoryservices.Activedirectory.Domain]::GetCurrentDomain() 
   
    foreach ($dc in $getdomain.DomainControllers)
    {
      $lastdc = $dc.Name      
    }
    $lastdc    
 }

function get_compname {
    (Get-WmiObject Win32_ComputerSystem).Name
}

function get_fqdn {
  if (([string]::IsNullOrEmpty($SetFqdn))){
    (get_compname) + '.' + (get_domain)
  }else{
	$SetFqdn
  }
}

function short_path($path){
  $a = New-Object -ComObject Scripting.FileSystemObject 
  $f = $a.GetFolder($path) 
  $f.ShortPath
}

if ($SetSpn) {
    if (-Not (is_admin)) {
        Write-Error "ERROR: You need Administrator rights to run setspn command"
    }
	
    $cmd=$system32 + '\setspn.exe -A HTTP/' + (get_fqdn).ToLower() + ' ' + $SpnUser
	
    if ($Output -eq "Exec"){
        Invoke-Expression $cmd
    }else{
	Write-Verbose -Verbose ('setspn command will output: ' + $cmd)
    }
}

if ($SetKeytab) {
    if (-Not (is_admin)) {
        Write-Error "ERROR: You need Administrator rights to run keytab command"
    }
	
    $cmd=$system32 + '\ktpass -out ' + $KeytabDir + '\aerobase.keytab' + ' -princ HTTP/' + (get_fqdn) + '@' + (get_domain).ToUpper() + ' -mapUser ' + $SpnUser +  ' -mapOp set -pass ' + $SpnPass + ' -kvno 0 -crypto all -pType KRB5_NT_PRINCIPAL'
	
    if ($Output -eq "Exec"){
        Invoke-Expression $cmd
    }else{
	Write-Verbose -Verbose ('ktpass command will output: ' + $cmd)
    }
}

$krb5ini = @'
[libdefaults]
dns_lookup_realm = false
ticket_lifetime = 24h
renew_lifetime = 7d
forwardable = true
rdns = false
default_realm = _DOMAINUPPER_
default_etypes = aes256-cts-hmac-sha1-96
[realms]
_DOMAINUPPER_ = {
  kdc = _DOMAINDC_
  admin_server = _DOMAINDC_
}
[domain_realm]
._DOMAIN_ = _DOMAINUPPER_
_DOMAIN_ = _DOMAINUPPER_
'@

if ($SetKrb5) {
    if (-Not (is_admin)) {
        Write-Error "ERROR: You need Administrator rights to set krb5.ini file"
    }
	
    $krb5ini = $krb5ini.replace("_DOMAINUPPER_",(get_domain).ToUpper())
    $krb5ini = $krb5ini.replace("_DOMAIN_",(get_domain))
    $krb5ini = $krb5ini.replace("_DOMAINDC_", (get_dc))
    
	$outfile = $winroot + '\krb5.ini'
    if ($Output -eq "Exec"){
    	Out-File -FilePath $outfile -InputObject $krb5ini
    }else{
	Write-Verbose -Verbose ('krb5.ini file will output: ' + $krb5ini)
    }
}

if ($SetKtab) {
    if (-Not (is_admin)) {
        Write-Error "ERROR: You need Administrator rights to run keytab command"
    }

    $cmd=(short_path($JavaDir)) + '\ktab.exe -a HTTP/' + (get_fqdn).ToLower() + '@' + (get_domain).ToUpper() + ' ' +  $SpnPass + ' -n 0 -k ' + (short_path($KeytabDir)) + '\aerobase.keytab'

    if ($Output -eq "Exec"){
        Invoke-Expression $cmd
    }else{
	Write-Verbose -Verbose ('ktab command will output: ' + $cmd)
    }
}
