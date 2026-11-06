# Создаем директории, если их нет
$dirs = @("linux-x64", "linux-x64_key", "linux_x64_client")
foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Name $dir
    }
}

# Установка учетных данных
$username = "GuestSupport"
$password = "guest"
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $securePassword)

# URL источника
$baseUrl = "https://download.mps-soft.ru/support/Updates/Installation/MasterSCADA_4D/RunTime/"

# Скачивание содержимого директорий
$folders = @("linux-x64", "linux-x64_key", "linux_x64_client")
foreach ($folder in $folders) {
    $url = "$baseUrl$folder/"
    Write-Host "Проверяю URL: $url"
    try {
        $response = Invoke-WebRequest -Uri $url -Credential $credential -UseBasicParsing
        Write-Host "Ответ сервера получен. Статус: $($response.StatusCode)"
        
        # Парсинг HTML для получения ссылок на файлы
        $links = $response.Links | Where-Object { $_.href -notlike "../" -and $_.href -notlike "" -and $_.href -notlike "Support/"}
        if ($links) {
            Write-Host "Найдено ссылок: $($links.Count)"
            foreach ($link in $links) {
                $fileName = $link.href
                $fileUrl = "$url$fileName"
                $destination = Join-Path $folder $fileName
                Write-Host "Скачиваю: $fileUrl -> $destination"
                Invoke-WebRequest -Uri $fileUrl -Credential $credential -OutFile $destination
            }
        } else {
            Write-Host "Ссылки на файлы не найдены в $folder"
        }
    } catch {
        Write-Host "Ошибка при запросе $url : $_"
    }
}