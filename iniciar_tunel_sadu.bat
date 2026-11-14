@echo off
title Tunel Cloudflare - SADU (Puerto 8080)
echo ===================================================================
echo INICIANDO TUNEL PUBLICO EN LA NUBE PARA SADU APIS (TOMCAT PUERTO 8080)
echo ===================================================================
echo RECUERDA: Debes tener iniciado SADU en NetBeans o Tomcat primero.
echo Conectando con los servidores seguros de Cloudflare...
echo.
C:\Users\elfra\cloudflared.exe tunnel --url http://localhost:8080
pause
