# Установка учетных данных
$username = "GuestSupport"
$password = "guest"
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $securePassword)

# URL файла
$fileUrl = "https://download.mps-soft.ru/support/Updates/Installation/MasterSCADA_4D/DesignTime/MasterSCADA4D_x64.exe"

# Путь для сохранения файла (в корневую директорию скрипта)
$destination = "MasterSCADA4D_x64.exe"

# Скачивание файла
Invoke-WebRequest -Uri $fileUrl -Credential $credential -OutFile $destination