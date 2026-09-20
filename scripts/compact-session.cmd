@echo off
REM Unified One-Shot Runner untuk Chat Context Compactor
powershell -ExecutionPolicy Bypass -File "%~dp0compact-session.ps1" %*
