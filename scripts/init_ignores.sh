read -p "Domain: " D
printf "ENVIRONMENT = local\nBASE_URL_SCHEMA = http\nBASE_URL = 127.0.0.1:8000\n" > ios/Config.Development.xcconfig
printf "ENVIRONMENT = production\nBASE_URL_SCHEMA = https\nBASE_URL = %s\n" "$D" > ios/Config.Production.xcconfig
echo "Done: ios/Config.Development.xcconfig, ios/Config.Production.xcconfig"