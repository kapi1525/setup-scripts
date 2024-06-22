@echo off

echo Setting up VirtioFS


:: Required
winget install winfsp -h --accept-package-agreements --accept-source-agreements

:: Enable VirtioFS service
sc.exe config VirtioFsSvc start=auto
sc start VirtioFsSvc