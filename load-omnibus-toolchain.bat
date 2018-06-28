@ECHO OFF

REM ###############################################################
REM # Load the base Omnibus environment
REM ###############################################################

set HOMEDRIVE=C:\
set HOMEPATH=omnibus-ruby
set PATH=C:\Program Files\7-Zip;C:\Program Files (x86)\WiX Toolset v3.11\bin;C:\Program Files (x86)\Windows Kits\10\bin\x64;C:\opscode\omnibus-toolchain\embedded\bin;C:\opscode\omnibus-toolchain\embedded\bin\mingw64\bin;C:\opscode\omnibus-toolchain\embedded\bin\usr\bin;C:\opscode\omnibus-toolchain\embedded\git\cmd;C:\opscode\omnibus-toolchain\embedded\git\mingw64\libexec\git-core;%PATH%
set MSYSTEM=MINGW64
set OMNIBUS_WINDOWS_ARCH=x64
set BASH_ENV=C:\opscode\omnibus-toolchain\embedded\bin\etc\msys2.bashrc
set OMNIBUS_TOOLCHAIN_INSTALL_DIR=C:\opscode\omnibus-toolchain
set SSL_CERT_FILE=C:\opscode\omnibus-toolchain\embedded\ssl\certs\cacert.pem

ECHO(
ECHO ========================================
ECHO = Environment
ECHO ========================================
ECHO(
 
set

REM ###############################################################
REM # Query tool versions
REM ###############################################################

FOR /F "tokens=*" %%a in ('git --version') do SET GIT_VERSION=%%a
FOR /F "tokens=*" %%a in ('ruby --version') do SET RUBY_VERSION=%%a
FOR /F "tokens=*" %%a in ('gem --version') do SET GEM_VERSION=%%a

FOR /F "tokens=*" %%a in ('gcc --version') do (
  SET GCC_VERSION=%%a
  GOTO :next
)
:next
FOR /F "tokens=*" %%a in ('make --version') do (
  SET MAKE_VERSION=%%a
  GOTO :next
)
:next
FOR /F "tokens=*" %%a in ('tar --version') do (
  SET SEVENZIP_VERSION=%%a
  GOTO :next
)
:next
FOR /F "tokens=*" %%a in ('heat -help') do (
  SET WIX_HEAT_VERSION=%%a
  GOTO :next
)
:next
FOR /F "tokens=*" %%a in ('candle -help') do (
  SET WIX_CANDLE_VERSION=%%a
  GOTO :next
)
:next
FOR /F "tokens=*" %%a in ('light -help') do (
  SET WIX_LIGHT_VERSION=%%a
  GOTO :next
)
:next

ECHO(
ECHO(
ECHO ========================================
ECHO = Tool Versions
ECHO ========================================
ECHO(

ECHO tar............%SEVENZIP_VERSION%
ECHO Bundler........%BUNDLER_VERSION%
ECHO GCC............%GCC_VERSION%
ECHO Git............%GIT_VERSION%
ECHO Make...........%MAKE_VERSION%
ECHO Ruby...........%RUBY_VERSION%
ECHO RubyGems.......%GEM_VERSION%
ECHO WiX:Candle.....%WIX_CANDLE_VERSION%
ECHO WiX:Heat.......%WIX_HEAT_VERSION%
ECHO WiX:Light......%WIX_LIGHT_VERSION%

ECHO(
ECHO ========================================

@ECHO ON