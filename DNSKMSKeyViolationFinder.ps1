# Задайте доменную зону, для которой вы хотите найти хосты KMS
#$dnsZone = "corp.example.ru" # Замените на вашу доменную зону

# Получение текущего доменного имени с помощью WMI
$dnsZone = (Get-WmiObject -Class Win32_ComputerSystem).Domain

# Имя службы KMS
$kmsServiceName = "_VLMCS._tcp"

# Выполнение запроса DNS SRV для службы KMS в заданной доменной зоне
$dnsRecords = nslookup -type=SRV "$kmsServiceName.$dnsZone" | Select-String "svr hostname"

# Фильтрация записей DNS, исключая определенные хосты
$hostnames = $dnsRecords -replace ".*= " | Where-Object { $_ -notlike "" } #<= Например "f05"

# Добавление сборки System.Windows.Forms для создания формы
Add-Type -AssemblyName System.Windows.Forms

# Создание формы
$form = New-Object System.Windows.Forms.Form
$form.Text = "DNSKMSKeyViolationFinder"
$form.Size = New-Object System.Drawing.Size(800, 600)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle" # Отключение возможности изменения размера
$form.MaximizeBox = $false # Отключение кнопки развернуть
$form.MinimizeBox = $false # Отключение кнопки свернуть

# Увеличение размера шрифта в форме
$form.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 13)

# Создание текстового поля для поиска
$searchBox = New-Object System.Windows.Forms.TextBox
$searchBox.Location = New-Object System.Drawing.Point(10, 10)
$searchBox.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($searchBox)

# Создание таймера
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 2000 # Интервал в миллисекундах (2 секунды)

# Обработчик события Tick таймера
$timer.Add_Tick({
    # Остановка таймера
    $timer.Stop()

    # Получение текста из поля поиска
    $searchText = $searchBox.Text

    # Очистка таблицы
    $dataGridView.Rows.Clear()

    # Заполнение таблицы с отфильтрованной информацией
    foreach ($hostname in $hostnames | Where-Object { $_ -like "*$searchText*" }) {
        $row = New-Object System.Windows.Forms.DataGridViewRow
        $cell = New-Object System.Windows.Forms.DataGridViewTextBoxCell
        $cell.Value = $hostname
        $row.Cells.Add($cell)
        $dataGridView.Rows.Add($row)
    }

    # Сортировка столбца "Хосты" по алфавиту
    $dataGridView.Sort($dataGridView.Columns[0], [System.ComponentModel.ListSortDirection]::Ascending)
})

# Обработчик события TextChanged текстового поля поиска
$searchBox.Add_TextChanged({
    # Остановка таймера (если он уже запущен)
    $timer.Stop()

    # Запуск таймера
    $timer.Start()
})

# Создание таблицы DataGridView
$dataGridView = New-Object System.Windows.Forms.DataGridView
$dataGridView.Location = New-Object System.Drawing.Point(10, 40)
$dataGridView.Size = New-Object System.Drawing.Size(780, 550)
$dataGridView.RowHeadersVisible = $false
$dataGridView.AllowUserToAddRows = $false
$dataGridView.AllowUserToDeleteRows = $false
$dataGridView.AllowUserToResizeRows = $false
$dataGridView.ReadOnly = $true
$dataGridView.AutoSizeColumnsMode = "Fill"
$dataGridView.AlternatingRowsDefaultCellStyle.BackColor = [System.Drawing.Color]::LightGray
$form.Controls.Add($dataGridView)

# Создание столбца и добавление данных в таблицу
$column = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$column.HeaderText = "Хосты/Hosts"
$dataGridView.Columns.Add($column)

# Заполнение таблицы с полученной информацией
foreach ($hostname in $hostnames) {
    $row = New-Object System.Windows.Forms.DataGridViewRow
    $cell = New-Object System.Windows.Forms.DataGridViewTextBoxCell
    $cell.Value = $hostname
    $row.Cells.Add($cell)
    $dataGridView.Rows.Add($row)
}

# Сортировка столбца "Хосты" по алфавиту
$dataGridView.Sort($dataGridView.Columns[0], [System.ComponentModel.ListSortDirection]::Ascending)

# Отображение формы
$form.ShowDialog()
