read -p "Domain: " D
printf "%s {\n\treverse_proxy backend:8000\n}\n" "$D" > backend/Caddyfile
printf "ENVIRONMENT = local\nBASE_URL_SCHEMA = http\nBASE_URL = 127.0.0.1:8000\n" > ios/Config.Local.xcconfig
printf "ENVIRONMENT = production\nBASE_URL_SCHEMA = https\nBASE_URL = %s\n" "$D" > ios/Config.Production.xcconfig
echo "Done: backend/Caddyfile, ios/Config.Local.xcconfig, ios/Config.Production.xcconfig"