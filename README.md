# mig_cyclemeter
Powershell script to migrate from SQLite3 Cyclemeter database to gpx format

Requirements
You will need SQLite3 module for PowerShell. Google it if you don't know how to download/install it.

What for ?
Since I moved from my iPhone to an Android system, I get some problems migrating my CycleMeter database to Strava, Runtastic or something like these.
So, my goal was to convert that CycleMeter SQLite db to a standard gpx frame.
I did it in Powershell, because I was on a Windows system at this moment :)

How it works ?
Simple : just put mig.ps1 and frame.gpx in a folder with your meter.db from CycleMeter. Edit the first lines of mig.ps1 to match with the path to your folder(s).
You are ready ! Launch a PowerShell window, go to the directory where you put mig.ps1 and make a .\mig.ps1.
The script will echo for each track the id, date and track name, and will create a id.gpx file for each of them.
Just a little thing I brought to the raw datas : in case you started your CycleMeter before you started to move, the script will suppress this 'blank' part of your track.

Just in case ...
Please understand all my english mistakes, I'm from the Camembert country ;)
Cheers !
