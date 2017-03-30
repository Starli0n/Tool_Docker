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
