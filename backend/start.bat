@echo off
cd /d %~dp0
mvn spring-boot:run -s .mvn/settings.xml
