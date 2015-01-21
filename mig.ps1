import-module SQLite
$frame = "D:\Perso\redis_mig_cyclemeter\frame.gpx";
$save_folder = "D:\Perso\redis_mig_cyclemeter"
$db_data_source = "D:\Perso\redis_mig_cyclemeter\Meter.db"
$db_query = "SELECT runID, routeID, startTime FROM run"
$db_dataset = New-Object System.Data.DataSet
$db_data_adapter = New-Object System.Data.SQLite.SQLiteDataAdapter($db_query,"Data Source=$db_data_source")
[void]$db_data_adapter.Fill($db_dataset)

#Pour chaque id de run
Foreach($valeur in $db_dataset.Tables[0]){
	#Création fichier xml (gpx)	
	$xmlDoc = [System.Xml.XmlDocument](Get-Content $frame);

	#Récupération du nom du parcours
	$parcours_query = "SELECT name FROM route WHERE routeID = '"+$valeur['routeID']+"'"
	$parcours_dataset = New-Object System.Data.DataSet
	$parcours_data_adapter = New-Object System.Data.SQLite.SQLiteDataAdapter($parcours_query,"Data Source=$db_data_source")
	[void]$parcours_data_adapter.Fill($parcours_dataset)
	Foreach($parcours_row in $parcours_dataset.Tables[0]){
		$parcours = $parcours_row['name']
	}
	
	#Ajout de l'heure de départ
	$startTime = [String]$valeur['startTime']
	$startTime = $startTime.replace('-', '').replace(' ', '').replace(':', '')+'000+000'
	$formattedStartTime = [Management.ManagementDateTimeConverter]::ToDateTime($startTime)	
	$XmlMetadata = $xmlDoc.gpx.AppendChild($xmlDoc.CreateElement("metadata"))
	$XmlTime = $XmlMetadata.AppendChild($xmlDoc.CreateElement("time"))
	$XmlParcours = $XmlMetadata.AppendChild($xmlDoc.CreateElement("name"))
	$XmlParcoursName = $XmlParcours.AppendChild($xmlDoc.CreateTextNode($parcours))
	#$TimeTextNode = $XmlTime.AppendChild($xmlDoc.CreateTextNode($formattedStartTime.ToString("yyyy-MM-ddTHH:mm:ss.000Z")));
	
	#Ajout de la track
	$XmlTrk = $xmlDoc.gpx.AppendChild($xmlDoc.CreateElement("trk"));
	$XmlTrkseg = $XmlTrk.AppendChild($xmlDoc.CreateElement("trkseg"));
	
	#Récupération des points - table coordinate - sequenceID, latitude, longitude, distanceDelta, speed - table altitude - sequenceID, timeOffset, altitude
	$coor_query = "SELECT * FROM (SELECT latitude, longitude, distanceDelta, speed, null as elevation, timeOffset from coordinate where runID = '"+$valeur['runID']+"' and distanceDelta > 0 UNION SELECT null, null, null, null, altitude, timeOffset from altitude where runID = '"+$valeur['runID']+"' ) entries ORDER BY timeOffset ASC"
	$coor_dataset = New-Object System.Data.DataSet
	$coor_data_adapter = New-Object System.Data.SQLite.SQLiteDataAdapter($coor_query,"Data Source=$db_data_source")
	[void]$coor_data_adapter.Fill($coor_dataset)
	$firstPoint = 0
	Foreach($coor_row in $coor_dataset.Tables[0]){
		if ([String]$coor_row['elevation']) {
			$elevation = $coor_row['elevation']
		}		
		else {
			if ($firstPoint -eq 0){
				$TimeTextNode = $XmlTime.AppendChild($xmlDoc.CreateTextNode($formattedStartTime.AddSeconds($coor_row['timeOffset']).ToString("yyyy-MM-ddTHH:mm:ss.000Z")));
				$firstPoint = 1
			}
			$Xmltrkpt = $XmlTrkseg.AppendChild($xmlDoc.CreateElement("trkpt"));
			$Xmltrkpt.SetAttribute("lon",$coor_row['longitude']);
			$Xmltrkpt.SetAttribute("lat",$coor_row['latitude']);
			$Xmlele = $Xmltrkpt.AppendChild($xmlDoc.CreateElement("ele"));
			$EleTextNode = $Xmlele.AppendChild($xmlDoc.CreateTextNode($elevation));
			$Xmltime = $Xmltrkpt.AppendChild($xmlDoc.CreateElement("time"));
			$TimeTextNode = $XmlTime.AppendChild($xmlDoc.CreateTextNode($formattedStartTime.AddSeconds($coor_row['timeOffset']).ToString("yyyy-MM-ddTHH:mm:ss.000Z")));
		}
	}
	
	"Run "+$valeur['runID']+" - "+$valeur['startTime']+" - "+$parcours
	$xmlDoc.Save($save_folder+'\run'+$valeur['runID']+'.gpx');
	
}