@echo off
set HOD_ROOT=%cd%
node --max-old-space-size=4096 tools/extract.js
::python slack.py