docker run `
--rm `
-e SONAR_HOST_URL="http://192.168.0.11:9000"  `
-v "C:\bprojs\biluca-finances\predict:/usr/src" `
sonarsource/sonar-scanner-cli `
    -D sonar.projectKey="Biluca-Finan-as---Predi-o" `
    -D sonar.sources=src,tests `
    -D sonar.host.url=http://192.168.0.11:9000 `
    -D sonar.token="sqp_67fdfc2944ec8f5e60d74710c92bd1c7fbab5d75"