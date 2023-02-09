If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {   
  $arguments = "& '" + $myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}
$remoteport = bash.exe -c "ifconfig eth0 | grep 'inet '"
$found = $remoteport -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';
if ($found) {
  $remoteport = $matches[0];
}
else {
  Write-Output "IP address could not be found";
  exit;
}
########################################################################
# 8080 - OpenWhisk compatible action docker container (development)
# 9999 - Portainer, admin / 9Lcfb48CByqXVS6
# 8085 - kafka topics ui
# 8001 - kafka schema registry ui
# 8081 - kafka schema registry
# 8082 - kafka rest proxy
# 29092, 9092 - kafka
# 9000 - kafka manager
# 2181 - zookeeper
$ports = @(8080, 9999, 8085, 8001, 8081, 8082, 29092, 9092, 9000, 2181);
for ($i = 0; $i -lt $ports.length; $i++) {
  $port = $ports[$i];
  Invoke-Expression "netsh interface portproxy delete v4tov4 listenport=$port";
  Invoke-Expression "netsh advfirewall firewall delete rule name=$port";
  Invoke-Expression "netsh interface portproxy add v4tov4 listenport=$port connectport=$port connectaddress=$remoteport";
  Invoke-Expression "netsh advfirewall firewall add rule name=$port dir=in action=allow protocol=TCP localport=$port";
}
Invoke-Expression "netsh interface portproxy show v4tov4";
Read-Host -Prompt "Press any key to continue"
