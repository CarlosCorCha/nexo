@echo off
chcp 65001 >nul
title Nexo - Oficinas hibridas
pushd "%~dp0"
echo Iniciando Nexo. Manten esta ventana abierta mientras utilices la aplicacion.
"%~dp0Nexo.Web.exe"
set "NEXO_EXIT=%ERRORLEVEL%"
if not "%NEXO_EXIT%"=="0" (
  echo.
  echo No se ha podido iniciar Nexo. Revisa el mensaje anterior.
  pause
)
popd
exit /b %NEXO_EXIT%
