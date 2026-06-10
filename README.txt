# Eventora - Event Management System v2.0

============================================================
  IMPORTANT: READ THIS FIRST TO FIX THE EXE ERROR
============================================================

If you see error: "The debug executable does not exist"
That means Visual Studio needs to BUILD the project first.

FIX - Do this EVERY time you open the project:
  1. Press Ctrl+Shift+B   (Build Solution)
  2. Wait for "Build succeeded" in the output window
  3. THEN press F5 to run

OR use the menu:
  Build > Build Solution > then Debug > Start Debugging

============================================================
  STEP 1: SETUP DATABASE IN SSMS
============================================================
1. Open SQL Server Management Studio (SSMS)
2. Connect to your SQL Server
3. Click File > Open > File
4. Select: Eventora_Database.sql
5. Press F5 to execute
6. Wait for: "Eventora Database v2.0 created successfully!"

============================================================
  STEP 2: OPEN IN VISUAL STUDIO
============================================================
1. Open Visual Studio Community 2022
2. Click: File > Open > Project/Solution
3. Browse to the Eventora folder
4. Select: Eventora.csproj  (NOT the .sln)
5. Click Open

============================================================
  STEP 3: BUILD AND RUN (IMPORTANT ORDER!)
============================================================
1. Press Ctrl+Shift+B  --> Build Solution
2. Wait for "Build: 1 succeeded"
3. Press F5  --> Start Debugging

============================================================
  STEP 4: CONNECT TO DATABASE
============================================================
A connection dialog will appear:
  - Server Name: localhost
    (if SQL Express use: localhost\SQLEXPRESS)
  - Database: EventoraDB
  Click Connect

============================================================
  LOGIN CREDENTIALS
============================================================
  Admin:  ayesha@eventora.com  |  Admin@123
  User:   ali@eventora.com     |  User@123

============================================================
  TROUBLESHOOTING
============================================================
Problem: "Build failed" errors
Fix: Make sure .NET 8 SDK is installed
     Download: https://dotnet.microsoft.com/download/dotnet/8.0

Problem: Cannot connect to database
Fix: Open SQL Server Configuration Manager
     Make sure "SQL Server (MSSQLSERVER)" service is Running
     Or try server name: .\SQLEXPRESS  or  (local)

Problem: NuGet package error
Fix: Right-click solution > Restore NuGet Packages
     Then Ctrl+Shift+B to build again
