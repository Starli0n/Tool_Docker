# Tool_Docker
Tools for Docker

## Proxy Settings

1. Edit `$HOME\.docker\machine\machines\default\config.json`

```json
"HostOptions": {
	"Driver": "",
	...
	"EngineOptions": {
		...
		"Env": [
			"HTTP_PROXY=http://host_name:port",
			"HTTPS_PROXY=http://host_name:port",
			"NO_PROXY=host_name"
		],
```

2. Execute `docker-machine provision`

## Web Server

The server is composed of

	-	PHP-FPM
	-	NGINX
	-	MariaDB

It can be run with `docker-compose -f web.yml up`

Forward the port `8080` on the VirtualBox VM to have the `localhost` working.

Otherwise, use the `docker-machine ip` to know the IP address of the VM.

Give a try with [http://localhost:8080/admin/info.php]
