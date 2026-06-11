Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic

$ErrorActionPreference = 'Continue'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = if ((Split-Path -Leaf $Root) -eq 'app') { Split-Path -Parent $Root } else { $Root }
$BypassDir = Join-Path $Root 'bypasses'
$SettingsFile = Join-Path $Root 'app-settings.json'
$SiteCheckFile = Join-Path $Root 'site-check-results.txt'
$EditionFile = Join-Path $Root 'app-edition.txt'
$AppVersion = '1.1.1'
$Edition = 'Public'
$script:HelpFontCollection = $null
$script:HelpFontFamily = 'Segoe UI'
try {
    $helpFontPath = Join-Path (Join-Path $Root 'assets\help') 'JetBrainsMono-Regular.ttf'
    if (Test-Path -LiteralPath $helpFontPath) {
        $script:HelpFontCollection = New-Object System.Drawing.Text.PrivateFontCollection
        $script:HelpFontCollection.AddFontFile($helpFontPath)
        if ($script:HelpFontCollection.Families.Count -gt 0) { $script:HelpFontFamily = $script:HelpFontCollection.Families[0].Name }
    }
} catch {}
try {
    $currentPid = $PID
    $scriptPath = $MyInvocation.MyCommand.Path
    Get-CimInstance Win32_Process -Filter "name = 'powershell.exe' OR name = 'pwsh.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.ProcessId -ne $currentPid -and $_.CommandLine -and $_.CommandLine.Contains($scriptPath) } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
} catch {}
if (Test-Path -LiteralPath $EditionFile) {
    $Edition = (Get-Content -LiteralPath $EditionFile -TotalCount 1).Trim()
}

$script:Lang = 'ru'
$script:Settings = [ordered]@{
    language = 'ru'
    lastBypass = ''
    lastBypassFile = ''
    stopBeforeStart = $true
    startWithWindows = $false
    theme = 'dark'
    firstRunGuideShown = $false
    tgProxySecret = ''
    tgProxyPort = 1443
    tgProxyAutostart = $false
}
$script:IsNetworkChecking = $false
$script:CancelNetworkCheck = $false

$script:T = @{
    ru = @{
        appFull = 'Azapret'
        appPublic = 'Azapret - Public'
        brand = 'AZAPRET'
        main = 'Главное меню'
        settings = 'Настройки'
        language = 'Язык'
        siteCheck = 'Проверка сайтов'
        tg = 'Телеграм'
        faq = 'Список обхода'
        help = 'Инструкция'
        titleFull = 'Azapret'
        titlePublic = 'Azapret'
        subtitle = 'Портативный запуск без установщика'
        bypass = 'Обход'
        checkNetwork = 'Проверка сети'
        fastCheckNetwork = 'Быстрая проверка'
        stopNetworkCheck = 'Стоп проверка'
        checkUpdates = 'Проверить обновления'
        start = 'Старт'
        restartBypass = 'Перезапустить обход'
        restartBypassAsk = 'Перезапустить обход сейчас?'
        copyLog = 'Скопировать журнал'
        copyLogDone = 'Журнал скопирован в буфер обмена.'
        copyLogEmpty = 'Журнал пуст.'
        stop = 'Стоп'
        autostart = 'Автостарт'
        removeAutostart = 'Отключить автозапуск'
        autostartRemoved = 'Автозапуск приложения отключен. Если был установлен автозапуск обхода как службы, подтвердите удаление службы.'
        extra = 'Tools'
        service = 'Сервисные действия'
        log = 'Журнал'
        install = 'Установить службу'
        remove = 'СТОП ВСЕ'
        status = 'Проверить статус'
        game = 'Игровой фильтр'
        ipset = 'IPSet фильтр'
        autoUpdate = 'Автопроверка обновлений'
        updateIp = 'Обновить список IPSet'
        updateHosts = 'Обновить файл Hosts'
        serviceUpdates = 'Проверить обновления'
        diagnostics = 'Запустить диагностику'
        runTest = 'Запустить тесты'
        csQuickCheck = 'CS/Faceit check'
        csStopTtl = 'Стоп FACEIT TTL'
        dnsRepair = 'Инст и Фейсбук'
        dnsRestore = 'Стоп инст и ф.'
        tgAppFix = 'Прокси для TG'
        tgProxyChannel = 'Все прокси для TG'
        tgProxyPopupTitle = 'Все прокси для Telegram'
        tgProxyOpenChannel = 'Открыть канал'
        tgDownload = 'Скачать TG'
        tgStopProxy = 'Стоп TG прокси'
        tgProxyScreensHint = 'Скриншоты появятся здесь. Положите PNG/JPG в папку app\telegram-proxy-screens.'
        tgProxyChannelOpen = 'Открываю Telegram-канал с proxy.'
        tgProxyChannelAsk = 'Открыть Telegram и перейти в канал с proxy?'
        tgDownloadOpen = 'Открываю страницу загрузки Telegram Desktop.'
        runSiteCheck = 'Проверить сайты'
        checkOneSite = 'Проверить сайт'
        siteInputPlaceholder = 'Вставьте ссылку или домен'
        siteCheckTitle = 'Проверка доступности сайтов'
        siteCheckHint = 'После запуска обхода нажмите проверку. ICMP ping не используется: многие сайты его блокируют, поэтому проверяем DNS, TCP 443 и HTTPS.'
        siteCheckStart = 'Проверка сайтов запущена.'
        siteCheckDone = 'Проверка сайтов завершена.'
        clearCache = 'Очистить кеш браузера'
        cacheConfirm = 'Chrome и Edge будут закрыты, кеш сайтов будет очищен. Продолжить?'
        stopBeforeStart = 'Останавливать старый обход перед запуском нового'
        startWithWindows = 'Запускать Azapret вместе с Windows'
        save = 'Сохранить'
        selectLanguage = 'Выберите язык интерфейса'
        faqTitle = 'Список обхода'
        helpTitle = 'Как пользоваться Azapret'
        firstRunTitle = 'Первый запуск'
        firstRunStep1Title = '1. Проверка сети'
        firstRunStep1Body = 'Нажмите «Проверка сети», чтобы Azapret сам подобрал лучший обход для вашей сети.'
        firstRunStep2Title = '2. Старт'
        firstRunStep2Body = 'Нажмите «Старт». Если браузер уже открыт, перезапустите вкладку или сам браузер.'
        firstRunStep3Title = '3. Автостарт'
        firstRunStep3Body = 'Если обход работает, нажмите «Автостарт» - выбранный обход будет запускаться сам вместе с Windows.'
        firstRunDontShow = 'Больше не показывать'
        firstRunOk = 'Понятно'
        faqTextVip = 'Версия включает обход сайтов:'
        faqTextPublic = 'Версия включает обход сайтов:'
        faqApps = 'Обход приложений:'
        settingsSaved = 'Настройки сохранены.'
        networkStart = 'Старт проверки сети.'
        networkStopped = 'Проверка сети остановлена.'
        noBypassSelected = 'Сначала выберите обход из списка.'
        stoppingOld = 'Останавливаю старый обход перед запуском нового.'
        stopMissing = 'Файл аварийной остановки не найден, пропускаю остановку.'
        startDone = 'Обход включен. Если браузер был открыт, перезапустите вкладку или браузер.'
        startHidden = 'Обход запущен в фоне, окно командной строки скрыто.'
        statusStopped = 'Не запущено'
        statusStarting = 'Запускается...'
        statusRunning = 'Запущено'
        statusFailed = 'Не запустилось'
        processStarted = 'Обход запущен. PID:'
        processMissing = 'Не вижу запущенный обход после старта. Попробуйте нажать Старт ещё раз или запустите от имени администратора.'
        accessCheckStart = 'Проверяю доступность сайтов после запуска обхода.'
        accessReady = 'Готово. Доступные сайты проверены, можно открывать их в браузере.'
        accessProblems = 'Обход запущен, но часть сайтов пока не ответила. Подождите 10-20 секунд и обновите страницу.'
        autostartInstalling = 'Устанавливаю выбранный обход в автозапуск Windows.'
        autostartDone = 'Автостарт установлен. Больше не нужно каждый раз запускать приложение: выбранный обход будет запускаться сам вместе с Windows. Приложение можно закрыть и пользоваться интернетом как обычно.'
        fileMissing = 'Файл не найден'
        saveFailed = 'Не удалось сохранить настройки'
        adminFailed = 'Не удалось запустить от администратора'
        checkError = 'ошибка проверки'
        bestChoice = 'Проверка завершена. Для вашей сети лучший выбор'
        checkBad = 'Проверка завершена с ошибками'
        recommended = 'Рекомендуемый обход'
        noBypasses = 'Проверка завершена, но обходы не найдены.'
        updatesStart = 'Проверяю доступность обновлений zapret.'
        updatesOk = 'Проверка обновлений отключена в этой сборке.'
        updatesFail = 'Проверка обновлений отключена'
        launching = 'Запускаю'
        serviceOpen = 'Открываю меню service.bat. Выберите нужное действие в консоли.'
        serviceActionStart = 'Запускаю сервисное действие'
        serviceActionDone = 'Сервисное действие выполнено'
        stopAllDone = 'Остановлены процессы обхода и удалены службы автозапуска zapret/WinDivert.'
        gameFilterAsk = 'Выберите режим игрового фильтра'
        gameFilterDone = 'Игровой фильтр обновлен. Перезапустите обход, чтобы применить изменения.'
        ipsetDone = 'IPSet фильтр переключен.'
        ipsetUpdateDone = 'Список IPSet обновлен.'
        diagnosticsDone = 'Диагностика запущена. Если будут вопросы в консоли, ответьте вручную.'
        clearCacheStart = 'Запускаю очистку кеша браузера.'
        dnsRepairStart = 'Применяю фикс сайтов. Подтвердите права администратора, если Windows спросит.'
        dnsRepairDone = 'Фикс применён. Закройте и откройте браузер, затем повторите проверку сайтов.'
        dnsRestoreStart = 'Удаляю фикс сайтов и возвращаю настройки браузера.'
        dnsRestoreDone = 'Фикс удалён. Закройте и откройте браузер, затем повторите проверку сайтов.'
        dnsRestoreMissing = 'Фикс не найден. Его не нужно удалять.'
        tgAppFixStart = 'Запустить локальный Telegram proxy и открыть его в Telegram?'
        tgAppFixDone = 'Локальный Telegram proxy запущен. Если Telegram спросит подтверждение, нажмите подключение proxy.'
        tgProxyMissing = 'TG WS Proxy не найден'
        tgProxyStarting = 'Запускаю локальный TG WS Proxy.'
        tgProxyRunning = 'TG WS Proxy уже запущен.'
        tgProxyReady = 'TG WS Proxy слушает 127.0.0.1'
        tgProxyNotReady = 'TG WS Proxy запущен, но порт пока не отвечает. Подождите несколько секунд и нажмите ещё раз.'
        tgProxyPortBusy = 'Порт TG proxy уже занят другим приложением'
        tgProxyStopped = 'TG WS Proxy остановлен.'
        tgProxyLinkCopied = 'Локальная ссылка Telegram proxy скопирована в буфер обмена.'
        extraStart = 'Запускаю дополнительные инструменты.'
        safeTest = 'Run Tests: запускаю встроенную проверку.'
        builtinTest = 'Run Tests: запускаю встроенную проверку сети.'
        appStarted = 'Приложение запущено. Версия доступа'
        bypassesFound = 'Найдено обходов'
        packageOk = 'Проверка файлов приложения пройдена.'
        packageMissing = 'Не найдены критичные файлы приложения:'
        startHint = 'Нажмите «Проверка сети», выберите обход и нажмите «Старт» или «Автостарт».'
        trayHint = 'Azapret свернут в трей. Чтобы закрыть полностью, используйте меню значка рядом с часами.'
        russian = 'Русский'
        english = 'Английский'
        chinese = 'Китайский'
        persian = 'Иранский'
    }
    en = @{
        appFull = 'Azapret'
        appPublic = 'Azapret - Public'
        brand = 'AZAPRET'
        main = 'Main Menu'
        settings = 'Settings'
        language = 'Language'
        siteCheck = 'Site Check'
        tg = 'Telegram'
        faq = 'Bypass List'
        help = 'Guide'
        titleFull = 'Azapret'
        titlePublic = 'Azapret'
        subtitle = 'Portable launch without installer'
        bypass = 'Bypass'
        checkNetwork = 'Network Check'
        fastCheckNetwork = 'Fast Check'
        stopNetworkCheck = 'Stop Check'
        checkUpdates = 'Check Updates'
        start = 'Start'
        restartBypass = 'Restart Bypass'
        restartBypassAsk = 'Restart bypass now?'
        copyLog = 'Copy Log'
        copyLogDone = 'Log copied to clipboard.'
        copyLogEmpty = 'Log is empty.'
        stop = 'Stop'
        autostart = 'Autostart'
        removeAutostart = 'Disable Autostart'
        autostartRemoved = 'Application autostart is disabled. If bypass autostart was installed as a service, confirm service removal.'
        extra = 'Tools'
        service = 'Service Actions'
        log = 'Log'
        install = 'Install Service'
        remove = 'STOP ALL'
        status = 'Check Status'
        game = 'Game Filter'
        ipset = 'IPSet Filter'
        autoUpdate = 'Auto-Update Check'
        updateIp = 'Update IPSet List'
        updateHosts = 'Update Hosts File'
        serviceUpdates = 'Check for Updates'
        diagnostics = 'Run Diagnostics'
        runTest = 'Run Tests'
        csQuickCheck = 'CS/Faceit check'
        csStopTtl = 'Stop FACEIT TTL'
        dnsRepair = 'Inst and Facebook'
        dnsRestore = 'Stop Inst and FB'
        tgAppFix = 'Fix TG App'
        tgProxyChannel = 'All TG Proxies'
        tgProxyPopupTitle = 'All Telegram Proxies'
        tgProxyOpenChannel = 'Open Channel'
        tgDownload = 'Download TG'
        tgStopProxy = 'Stop TG proxy'
        tgProxyScreensHint = 'Screenshots will appear here. Put PNG/JPG files into app\telegram-proxy-screens.'
        tgProxyChannelOpen = 'Opening Telegram proxy channel.'
        tgProxyChannelAsk = 'Open Telegram and go to the proxy channel?'
        tgDownloadOpen = 'Opening Telegram Desktop download page.'
        runSiteCheck = 'Check Sites'
        checkOneSite = 'Check Site'
        siteInputPlaceholder = 'Paste URL or domain'
        siteCheckTitle = 'Site Availability Check'
        siteCheckHint = 'Start a bypass, then run the check. ICMP ping is not used because many sites block it; DNS, TCP 443 and HTTPS are checked instead.'
        siteCheckStart = 'Site check started.'
        siteCheckDone = 'Site check finished.'
        clearCache = 'Clear Browser Cache'
        cacheConfirm = 'Chrome and Edge will be closed and site cache will be cleared. Continue?'
        stopBeforeStart = 'Stop old bypass before starting a new one'
        startWithWindows = 'Start Azapret with Windows'
        save = 'Save'
        selectLanguage = 'Select interface language'
        faqTitle = 'Bypass List'
        helpTitle = 'How to use Azapret'
        firstRunTitle = 'First Launch'
        firstRunStep1Title = '1. Network Check'
        firstRunStep1Body = 'Click Network Check so Azapret can select the best bypass for your network.'
        firstRunStep2Title = '2. Start'
        firstRunStep2Body = 'Click Start. If your browser is already open, reload the tab or restart the browser.'
        firstRunStep3Title = '3. Autostart'
        firstRunStep3Body = 'If the bypass works, click Autostart - the selected bypass will start automatically with Windows.'
        firstRunDontShow = 'Do not show again'
        firstRunOk = 'Got it'
        faqTextVip = 'This edition includes bypass for:'
        faqTextPublic = 'This edition includes bypass for:'
        faqApps = 'App bypass:'
        settingsSaved = 'Settings saved.'
        networkStart = 'Network check started.'
        networkStopped = 'Network check stopped.'
        noBypassSelected = 'Select a bypass first.'
        stoppingOld = 'Stopping the old bypass before starting a new one.'
        stopMissing = 'Emergency stop file was not found, skipping stop.'
        startDone = 'Bypass started. If the browser was open, reload the tab or restart the browser.'
        startHidden = 'Bypass started in the background, command window is hidden.'
        statusStopped = 'Stopped'
        statusStarting = 'Starting...'
        statusRunning = 'Running'
        statusFailed = 'Not started'
        processStarted = 'Bypass is running. PID:'
        processMissing = 'Bypass is not visible after start. Try Start again or run as administrator.'
        accessCheckStart = 'Checking site availability after bypass start.'
        accessReady = 'Ready. Available sites were checked, you can open them in the browser.'
        accessProblems = 'Bypass started, but some sites did not respond yet. Wait 10-20 seconds and refresh the page.'
        autostartInstalling = 'Installing the selected bypass into Windows autostart.'
        autostartDone = 'Autostart is installed. You do not need to open this app every time: the selected bypass will start automatically with Windows. You can close the app and use the internet normally.'
        fileMissing = 'File not found'
        saveFailed = 'Failed to save settings'
        adminFailed = 'Failed to start as administrator'
        checkError = 'check error'
        bestChoice = 'Check completed. Best choice for your network'
        checkBad = 'Check completed with errors'
        recommended = 'Recommended bypass'
        noBypasses = 'Check completed, but no bypasses were found.'
        updatesStart = 'Checking zapret updates availability.'
        updatesOk = 'Update checking is disabled in this build.'
        updatesFail = 'Update checking is disabled'
        launching = 'Starting'
        serviceOpen = 'Opening service.bat menu. Choose the needed action in the console.'
        serviceActionStart = 'Starting service action'
        serviceActionDone = 'Service action completed'
        stopAllDone = 'Bypass processes stopped and zapret/WinDivert autostart services removed.'
        gameFilterAsk = 'Select game filter mode'
        gameFilterDone = 'Game filter updated. Restart bypass to apply changes.'
        ipsetDone = 'IPSet filter switched.'
        ipsetUpdateDone = 'IPSet list updated.'
        diagnosticsDone = 'Diagnostics started. Answer console prompts manually if they appear.'
        clearCacheStart = 'Starting browser cache cleanup.'
        dnsRepairStart = 'Starting DNS repair. Confirm administrator rights if Windows asks.'
        dnsRepairDone = 'DNS repair started. Restart the browser, then run the site check again.'
        dnsRestoreStart = 'Restoring DNS saved before repair.'
        dnsRestoreDone = 'DNS restore started. Restart the browser, then run the site check again.'
        dnsRestoreMissing = 'Saved DNS was not found. Use Repair DNS first or configure DNS manually.'
        tgAppFixStart = 'Start local Telegram proxy and open it in Telegram?'
        tgAppFixDone = 'Local Telegram proxy is running. If Telegram asks, confirm proxy connection.'
        tgProxyMissing = 'TG WS Proxy was not found'
        tgProxyStarting = 'Starting local TG WS Proxy.'
        tgProxyRunning = 'TG WS Proxy is already running.'
        tgProxyReady = 'TG WS Proxy is listening on 127.0.0.1'
        tgProxyNotReady = 'TG WS Proxy started, but the port is not responding yet. Wait a few seconds and try again.'
        tgProxyPortBusy = 'TG proxy port is already used by another app'
        tgProxyStopped = 'TG WS Proxy stopped.'
        tgProxyLinkCopied = 'Local Telegram proxy link copied to clipboard.'
        extraStart = 'Starting additional tools.'
        safeTest = 'Run Tests: starting built-in check.'
        builtinTest = 'Run Tests: starting built-in network check.'
        appStarted = 'Application started. Access edition'
        bypassesFound = 'Bypasses found'
        packageOk = 'Application files check passed.'
        packageMissing = 'Critical application files are missing:'
        startHint = 'Click Network Check, select a bypass, then click Start or Autostart.'
        trayHint = 'Azapret was minimized to tray. To exit completely, use the tray icon menu near the clock.'
        russian = 'Russian'
        english = 'English'
        chinese = 'Chinese'
        persian = 'Persian'
    }
    zh = @{
        appFull = 'Azapret'
        appPublic = 'Azapret - Public'
        brand = 'AZAPRET'
        main = '主菜单'
        settings = '设置'
        language = '语言'
        siteCheck = '网站检查'
        tg = 'Telegram / 电报'
        faq = '绕过列表'
        help = '说明'
        titleFull = 'Azapret'
        titlePublic = 'Azapret'
        subtitle = '免安装便携启动'
        bypass = '绕过方案'
        checkNetwork = '网络检查'
        fastCheckNetwork = '快速检查'
        stopNetworkCheck = '停止检查'
        checkUpdates = '检查更新'
        start = '启动'
        restartBypass = '重启绕过'
        restartBypassAsk = '现在重启绕过方案吗？'
        copyLog = '复制日志'
        copyLogDone = '日志已复制到剪贴板。'
        copyLogEmpty = '日志为空。'
        stop = '停止'
        autostart = '自动启动'
        removeAutostart = '禁用自动启动'
        autostartRemoved = '应用自动启动已禁用。如果绕过方案作为服务安装，请确认移除服务。'
        extra = 'Tools'
        service = '服务操作'
        log = '日志'
        runTest = '运行测试'
        dnsRepair = 'Instagram 和 Facebook'
        dnsRestore = '停止 Instagram/FB'
        tgAppFix = '修复 TG 应用'
        tgProxyChannel = '所有 TG 代理'
        tgProxyPopupTitle = '所有 Telegram 代理'
        tgProxyOpenChannel = '打开频道'
        tgDownload = '下载 TG'
        tgProxyScreensHint = '截图会显示在这里。请将 PNG/JPG 文件放入 app\telegram-proxy-screens。'
        tgProxyChannelOpen = '正在打开 Telegram proxy 频道。'
        tgProxyChannelAsk = '打开 Telegram 并进入 proxy 频道吗？'
        tgDownloadOpen = '正在打开 Telegram Desktop 下载页。'
        runSiteCheck = '检查网站'
        checkOneSite = '检查单个网站'
        siteInputPlaceholder = '粘贴链接或域名'
        siteCheckTitle = '网站可用性检查'
        siteCheckHint = '启动绕过方案后运行检查。不使用 ICMP ping，因为许多网站会阻止它；改为检查 DNS、TCP 443 和 HTTPS。'
        siteCheckStart = '网站检查已开始。'
        siteCheckDone = '网站检查已完成。'
        install = '安装服务'
        remove = '全部停止'
        status = '检查状态'
        game = '游戏过滤'
        ipset = 'IPSet 过滤'
        autoUpdate = '自动更新检查'
        updateIp = '更新 IPSet 列表'
        updateHosts = '更新 Hosts 文件'
        serviceUpdates = '检查更新'
        diagnostics = '运行诊断'
        clearCache = '清理浏览器缓存'
        cacheConfirm = 'Chrome 和 Edge 将关闭，网站缓存将被清理。继续吗？'
        stopBeforeStart = '启动新方案前停止旧方案'
        startWithWindows = '随 Windows 启动 Azapret'
        save = '保存'
        selectLanguage = '选择界面语言'
        faqTitle = '绕过列表'
        helpTitle = '如何使用 Azapret'
        firstRunTitle = '首次启动'
        firstRunStep1Title = '1. 网络检查'
        firstRunStep1Body = '点击“网络检查”，让 Azapret 为当前网络选择最佳绕过方案。'
        firstRunStep2Title = '2. 启动'
        firstRunStep2Body = '点击“启动”。如果浏览器已打开，请刷新标签页或重启浏览器。'
        firstRunStep3Title = '3. 自动启动'
        firstRunStep3Body = '如果绕过方案工作正常，请点击“自动启动”，所选方案会随 Windows 自动启动。'
        firstRunDontShow = '不再显示'
        firstRunOk = '明白'
        faqTextVip = '此版本包含以下网站的绕过：'
        faqTextPublic = '此版本包含以下网站的绕过：'
        faqApps = '应用和服务：'
        settingsSaved = '设置已保存。'
        networkStart = '开始网络检查。'
        networkStopped = '网络检查已停止。'
        noBypassSelected = '请先选择一个绕过方案。'
        stoppingOld = '正在启动新方案前停止旧方案。'
        stopMissing = '未找到紧急停止文件，跳过停止。'
        startDone = '绕过已启动。如果浏览器已打开，请刷新标签页或重启浏览器。'
        startHidden = '绕过已在后台启动，命令窗口已隐藏。'
        statusStopped = '未启动'
        statusStarting = '正在启动...'
        statusRunning = '已启动'
        statusFailed = '未启动'
        processStarted = '绕过方案已启动。PID:'
        processMissing = '启动后未检测到绕过方案。请再次点击启动或以管理员身份运行。'
        accessCheckStart = '启动绕过后正在检查网站可用性。'
        accessReady = '完成。可用网站已检查，可以在浏览器中打开。'
        accessProblems = '绕过已启动，但部分网站暂时没有响应。请等待 10-20 秒后刷新页面。'
        autostartInstalling = '正在把所选方案安装到 Windows 自动启动。'
        autostartDone = '自动启动已安装。以后不需要每次打开此应用：所选绕过方案会随 Windows 自动启动。现在可以关闭应用并正常上网。'
        fileMissing = '找不到文件'
        saveFailed = '保存设置失败'
        adminFailed = '无法以管理员身份启动'
        checkError = '检查错误'
        bestChoice = '检查完成。适合当前网络的最佳选择'
        checkBad = '检查完成，但有错误'
        recommended = '推荐绕过方案'
        noBypasses = '检查完成，但没有找到绕过方案。'
        updatesStart = '正在检查 zapret 更新。'
        updatesOk = '此版本已禁用更新检查。'
        updatesFail = '更新检查已禁用'
        launching = '正在启动'
        serviceOpen = '正在打开 service.bat 菜单，请在控制台选择需要的操作。'
        serviceActionStart = '正在启动服务操作'
        serviceActionDone = '服务操作已完成'
        stopAllDone = '绕过进程已停止，zapret/WinDivert 自动启动服务已移除。'
        gameFilterAsk = '选择游戏过滤模式'
        gameFilterDone = '游戏过滤已更新。请重启绕过方案以应用更改。'
        ipsetDone = 'IPSet 过滤已切换。'
        ipsetUpdateDone = 'IPSet 列表已更新。'
        diagnosticsDone = '诊断已启动。如控制台有提示，请手动回答。'
        clearCacheStart = '正在启动浏览器缓存清理。'
        dnsRepairStart = '正在启动 DNS 修复。如 Windows 提示，请确认管理员权限。'
        dnsRepairDone = 'DNS 修复已启动。请重启浏览器，然后再次检查网站。'
        dnsRestoreStart = '正在恢复修复前保存的 DNS。'
        dnsRestoreDone = 'DNS 恢复已启动。请重启浏览器，然后再次检查网站。'
        dnsRestoreMissing = '未找到保存的 DNS。请先使用“修复 DNS”或手动配置 DNS。'
        tgAppFixStart = '正在打开 Telegram Desktop 和 MTProxy。如果未安装 Telegram，将打开下载页面。'
        tgAppFixDone = '如果已安装 Telegram Desktop，请在 Telegram 中确认连接 proxy。'
        extraStart = '正在启动附加工具。'
        safeTest = '运行测试：启动内置检查。'
        builtinTest = '运行测试：启动内置网络检查。'
        appStarted = '应用已启动。访问版本'
        bypassesFound = '找到的绕过方案'
        packageOk = '应用文件检查通过。'
        packageMissing = '缺少关键应用文件：'
        startHint = '点击网络检查，选择绕过方案，然后点击启动或自动启动。'
        trayHint = 'Azapret 已最小化到托盘。要完全退出，请使用时钟旁边的托盘图标菜单。'
        russian = '俄语'
        english = '英语'
        chinese = '中文'
        persian = '波斯语'
    }
    fa = @{
        appFull = 'Azapret'
        appPublic = 'Azapret - Public'
        brand = 'AZAPRET'
        main = 'منوی اصلی'
        settings = 'تنظیمات'
        language = 'زبان'
        siteCheck = 'بررسی سایت'
        tg = 'تلگرام'
        faq = 'فهرست عبور'
        help = 'راهنما'
        titleFull = 'Azapret'
        titlePublic = 'Azapret'
        subtitle = 'اجرای پرتابل بدون نصب'
        bypass = 'روش عبور'
        checkNetwork = 'بررسی شبکه'
        fastCheckNetwork = 'بررسی سریع'
        stopNetworkCheck = 'توقف بررسی'
        checkUpdates = 'بررسی بروزرسانی'
        start = 'شروع'
        restartBypass = 'راه اندازی دوباره عبور'
        restartBypassAsk = 'عبور اکنون دوباره شروع شود؟'
        copyLog = 'کپی گزارش'
        copyLogDone = 'گزارش در کلیپ بورد کپی شد.'
        copyLogEmpty = 'گزارش خالی است.'
        stop = 'توقف'
        autostart = 'شروع خودکار'
        removeAutostart = 'غیرفعال کردن شروع خودکار'
        autostartRemoved = 'شروع خودکار برنامه غیرفعال شد. اگر عبور به عنوان سرویس نصب شده است، حذف سرویس را تأیید کنید.'
        extra = 'Tools'
        service = 'عملیات سرویس'
        log = 'گزارش'
        runTest = 'اجرای تست'
        dnsRepair = 'Instagram و Facebook'
        dnsRestore = 'توقف Instagram/FB'
        tgAppFix = 'تعمیر برنامه TG'
        tgProxyChannel = 'همه پراکسی های TG'
        tgProxyPopupTitle = 'همه پراکسی های Telegram'
        tgProxyOpenChannel = 'باز کردن کانال'
        tgDownload = 'دانلود TG'
        tgProxyScreensHint = 'اسکرین شات ها اینجا نمایش داده می شوند. فایل های PNG/JPG را در app\telegram-proxy-screens قرار دهید.'
        tgProxyChannelOpen = 'کانال پراکسی Telegram باز می شود.'
        tgProxyChannelAsk = 'Telegram باز شود و به کانال پراکسی بروید؟'
        tgDownloadOpen = 'صفحه دانلود Telegram Desktop باز می شود.'
        runSiteCheck = 'بررسی سایت ها'
        checkOneSite = 'بررسی سایت'
        siteInputPlaceholder = 'URL یا دامنه را وارد کنید'
        siteCheckTitle = 'بررسی دسترسی سایت ها'
        siteCheckHint = 'بعد از شروع عبور، بررسی را اجرا کنید. ICMP ping استفاده نمی شود چون بسیاری از سایت ها آن را مسدود می کنند؛ DNS، TCP 443 و HTTPS بررسی می شوند.'
        siteCheckStart = 'بررسی سایت ها شروع شد.'
        siteCheckDone = 'بررسی سایت ها کامل شد.'
        install = 'نصب سرویس'
        remove = 'توقف همه'
        status = 'بررسی وضعیت'
        game = 'فیلتر بازی'
        ipset = 'فیلتر IPSet'
        autoUpdate = 'بررسی خودکار بروزرسانی'
        updateIp = 'بروزرسانی فهرست IPSet'
        updateHosts = 'بروزرسانی فایل Hosts'
        serviceUpdates = 'بررسی بروزرسانی'
        diagnostics = 'اجرای عیب یابی'
        clearCache = 'پاک کردن کش مرورگر'
        cacheConfirm = 'Chrome و Edge بسته می شوند و کش سایت پاک می شود. ادامه می دهید؟'
        stopBeforeStart = 'قبل از شروع روش جدید، روش قبلی متوقف شود'
        startWithWindows = 'اجرای Azapret همراه Windows'
        save = 'ذخیره'
        selectLanguage = 'زبان رابط را انتخاب کنید'
        faqTitle = 'فهرست عبور'
        helpTitle = 'نحوه استفاده از Azapret'
        firstRunTitle = 'اولین اجرا'
        firstRunStep1Title = '1. بررسی شبکه'
        firstRunStep1Body = 'Network Check را بزنید تا Azapret بهترین عبور را برای شبکه شما انتخاب کند.'
        firstRunStep2Title = '2. شروع'
        firstRunStep2Body = 'Start را بزنید. اگر مرورگر باز است، تب یا مرورگر را دوباره باز کنید.'
        firstRunStep3Title = '3. شروع خودکار'
        firstRunStep3Body = 'اگر عبور کار می کند، Autostart را بزنید تا عبور انتخاب شده همراه Windows خودکار اجرا شود.'
        firstRunDontShow = 'دیگر نشان نده'
        firstRunOk = 'فهمیدم'
        faqTextVip = 'این نسخه شامل عبور برای سایت های زیر است:'
        faqTextPublic = 'این نسخه شامل عبور برای سایت های زیر است:'
        faqApps = 'برنامه ها و سرویس ها:'
        settingsSaved = 'تنظیمات ذخیره شد.'
        networkStart = 'بررسی شبکه شروع شد.'
        networkStopped = 'بررسی شبکه متوقف شد.'
        noBypassSelected = 'ابتدا یک روش عبور انتخاب کنید.'
        stoppingOld = 'قبل از شروع روش جدید، روش قبلی متوقف می شود.'
        stopMissing = 'فایل توقف اضطراری پیدا نشد، توقف رد شد.'
        startDone = 'عبور فعال شد. اگر مرورگر باز بود، تب را تازه سازی یا مرورگر را دوباره باز کنید.'
        startHidden = 'عبور در پس زمینه اجرا شد و پنجره فرمان پنهان است.'
        statusStopped = 'متوقف'
        statusStarting = 'در حال شروع...'
        statusRunning = 'در حال اجرا'
        statusFailed = 'شروع نشد'
        processStarted = 'عبور اجرا شد. PID:'
        processMissing = 'بعد از شروع، عبور دیده نشد. دوباره Start را بزنید یا با دسترسی مدیر اجرا کنید.'
        accessCheckStart = 'در حال بررسی دسترسی سایت ها بعد از شروع عبور.'
        accessReady = 'آماده است. سایت های قابل دسترس بررسی شدند و می توانید آنها را در مرورگر باز کنید.'
        accessProblems = 'عبور اجرا شد، اما بعضی سایت ها هنوز پاسخ ندادند. 10 تا 20 ثانیه صبر کنید و صفحه را تازه سازی کنید.'
        autostartInstalling = 'روش انتخاب شده در شروع خودکار Windows نصب می شود.'
        autostartDone = 'شروع خودکار نصب شد. دیگر لازم نیست هر بار برنامه را باز کنید: روش انتخاب شده همراه Windows اجرا می شود. می توانید برنامه را ببندید و عادی از اینترنت استفاده کنید.'
        fileMissing = 'فایل پیدا نشد'
        saveFailed = 'ذخیره تنظیمات ناموفق بود'
        adminFailed = 'اجرای با دسترسی مدیر ناموفق بود'
        checkError = 'خطای بررسی'
        bestChoice = 'بررسی کامل شد. بهترین انتخاب برای شبکه شما'
        checkBad = 'بررسی با خطا کامل شد'
        recommended = 'روش پیشنهادی'
        noBypasses = 'بررسی کامل شد، اما هیچ روش عبوری پیدا نشد.'
        updatesStart = 'در حال بررسی بروزرسانی zapret.'
        updatesOk = 'بررسی بروزرسانی در این نسخه غیرفعال است.'
        updatesFail = 'بررسی بروزرسانی غیرفعال است'
        launching = 'در حال شروع'
        serviceOpen = 'منوی service.bat باز می شود. عملیات لازم را در کنسول انتخاب کنید.'
        serviceActionStart = 'عملیات سرویس شروع می شود'
        serviceActionDone = 'عملیات سرویس کامل شد'
        stopAllDone = 'فرآیندهای عبور متوقف و سرویس های شروع خودکار zapret/WinDivert حذف شدند.'
        gameFilterAsk = 'حالت فیلتر بازی را انتخاب کنید'
        gameFilterDone = 'فیلتر بازی به روز شد. برای اعمال تغییرات، عبور را دوباره شروع کنید.'
        ipsetDone = 'فیلتر IPSet تغییر کرد.'
        ipsetUpdateDone = 'فهرست IPSet به روز شد.'
        diagnosticsDone = 'عیب یابی شروع شد. اگر در کنسول سوالی بود، دستی پاسخ دهید.'
        clearCacheStart = 'پاک کردن کش مرورگر شروع می شود.'
        dnsRepairStart = 'تعمیر DNS شروع می شود. اگر ویندوز درخواست کرد، دسترسی مدیر را تایید کنید.'
        dnsRepairDone = 'تعمیر DNS شروع شد. مرورگر را دوباره باز کنید و سپس بررسی سایت را تکرار کنید.'
        dnsRestoreStart = 'DNS ذخیره شده قبل از تعمیر بازگردانی می شود.'
        dnsRestoreDone = 'بازگردانی DNS شروع شد. مرورگر را دوباره باز کنید و سپس بررسی سایت را تکرار کنید.'
        dnsRestoreMissing = 'DNS ذخیره شده پیدا نشد. ابتدا Repair DNS را اجرا کنید یا DNS را دستی تنظیم کنید.'
        tgAppFixStart = 'Telegram Desktop و MTProxy باز می شوند. اگر Telegram نصب نباشد، صفحه دانلود باز می شود.'
        tgAppFixDone = 'اگر Telegram Desktop نصب است، اتصال proxy را در Telegram تایید کنید.'
        extraStart = 'ابزارهای اضافی شروع می شوند.'
        safeTest = 'اجرای تست: بررسی داخلی شروع می شود.'
        builtinTest = 'اجرای تست: بررسی داخلی شبکه شروع می شود.'
        appStarted = 'برنامه اجرا شد. نسخه دسترسی'
        bypassesFound = 'روش های پیدا شده'
        packageOk = 'بررسی فایل های برنامه موفق بود.'
        packageMissing = 'فایل های ضروری برنامه پیدا نشدند:'
        startHint = 'Network Check را بزنید، یک روش انتخاب کنید، سپس Start یا Autostart را بزنید.'
        trayHint = 'Azapret به tray منتقل شد. برای خروج کامل از منوی آیکن کنار ساعت استفاده کنید.'
        russian = 'روسی'
        english = 'انگلیسی'
        chinese = 'چینی'
        persian = 'فارسی'
    }
}

function Tr {
    param([string]$Key)
    if ($script:T.ContainsKey($script:Lang) -and $script:T[$script:Lang].ContainsKey($Key)) { return $script:T[$script:Lang][$Key] }
    return $script:T['ru'][$Key]
}

function Load-Settings {
    if (-not (Test-Path -LiteralPath $SettingsFile)) { return }
    try {
        $json = Get-Content -LiteralPath $SettingsFile -Raw -Encoding UTF8 | ConvertFrom-Json
        foreach ($name in @($script:Settings.Keys)) {
            if ($json.PSObject.Properties.Name -contains $name) { $script:Settings[$name] = $json.$name }
        }
        if ($script:T.ContainsKey([string]$script:Settings.language)) { $script:Lang = [string]$script:Settings.language }
    } catch {}
}

function Save-Settings {
    param([bool]$Silent = $false)
    try {
        $script:Settings.language = $script:Lang
        $script:Settings.lastBypass = [string]$combo.SelectedItem
        $selected = $script:Bypasses | Where-Object { $_.Label -eq ([string]$combo.SelectedItem) } | Select-Object -First 1
        $script:Settings.lastBypassFile = if ($selected) { [string]$selected.Name } else { '' }
        $script:Settings.stopBeforeStart = [bool]$stopCheck.Checked
        $script:Settings.startWithWindows = [bool]$startupCheck.Checked
        $script:Settings.theme = if ($themeToggle.Checked) { 'dark' } else { 'light' }
        ($script:Settings | ConvertTo-Json) | Set-Content -LiteralPath $SettingsFile -Encoding UTF8
        Set-WindowsStartup -Enabled ([bool]$startupCheck.Checked)
        if (-not $Silent) { Add-Log (Tr 'settingsSaved') }
    } catch {
        Add-Log ((Tr 'saveFailed') + ": $($_.Exception.Message)")
    }
}

function Save-FirstRunGuideShown {
    try {
        $script:Settings.firstRunGuideShown = $true
        ($script:Settings | ConvertTo-Json) | Set-Content -LiteralPath $SettingsFile -Encoding UTF8
    } catch {
        Add-Log ((Tr 'saveFailed') + ": $($_.Exception.Message)")
    }
}

function Set-WindowsStartup {
    param([bool]$Enabled)
    $runKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
    $name = 'Azapret'
    try {
        if ($Enabled) {
            $exe = Join-Path $PackageRoot 'Azapret.exe'
            if (Test-Path -LiteralPath $exe) {
                Set-ItemProperty -Path $runKey -Name $name -Value ('"' + $exe + '"')
            } else {
                $ps = Join-Path $Root 'Azapret Launcher.ps1'
                if (-not (Test-Path -LiteralPath $ps)) { $ps = Join-Path $Root 'Zapret Launcher.ps1' }
                Set-ItemProperty -Path $runKey -Name $name -Value ('powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "' + $ps + '"')
            }
        } else {
            Remove-ItemProperty -Path $runKey -Name $name -ErrorAction SilentlyContinue
        }
    } catch {}
}

function Get-BypassFiles {
    $searchRoot = if (Test-Path -LiteralPath $BypassDir) { $BypassDir } else { $Root }
    $files = Get-ChildItem -LiteralPath $searchRoot -Filter 'general*.bat' -File |
        Sort-Object { [Regex]::Replace($_.Name, '(\d+)', { $args[0].Value.PadLeft(8, '0') }) }

    $items = @()
    $index = 1
    foreach ($file in $files) {
        $profile = [Regex]::Replace($file.BaseName, '^general\s*', '')
        $label = "Обход $index"
        if (-not [string]::IsNullOrWhiteSpace($profile) -and $profile -notmatch '^\(ALT11 BETA\)$' -and $profile -notmatch '^\(ALT([2-9]|1[0-9])?\)$') { $label += " $profile" }
        $items += [pscustomobject]@{ Label = $label; Path = $file.FullName; Name = $file.Name; Index = $index }
        $index++
    }
    return $items
}

function Test-PackageIntegrity {
    $missing = New-Object System.Collections.Generic.List[string]
    foreach ($relative in @(
        'bin\winws.exe',
        'bin\WinDivert.dll',
        'bin\WinDivert64.sys',
        'assets\azapret.ico',
        'service.bat',
        'stop-zapret-emergency.bat'
    )) {
        if (-not (Test-Path -LiteralPath (Join-Path $Root $relative))) { $missing.Add($relative) | Out-Null }
    }
    if (-not (Get-BypassFiles)) { $missing.Add('bypasses\general*.bat') | Out-Null }

    if ($missing.Count -gt 0) {
        $message = (Tr 'packageMissing') + "`r`n" + ($missing -join "`r`n")
        Add-Log $message ([System.Drawing.Color]::FromArgb(248, 113, 113)) $true
        [System.Windows.Forms.MessageBox]::Show($message, 'Azapret', 'OK', 'Warning') | Out-Null
        return $false
    }
    Add-Log (Tr 'packageOk') ([System.Drawing.Color]::FromArgb(74, 222, 128)) $false
    return $true
}

function Add-Log {
    param([string]$Text, [object]$Color = $null, [bool]$Bold = $false)
    $time = Get-Date -Format 'HH:mm:ss'
    if (-not $Color) { $Color = [System.Drawing.Color]::FromArgb(225, 232, 240) }
    foreach ($box in @($logBox, $serviceLogBox)) {
        if (-not $box) { continue }
        $box.SelectionStart = $box.TextLength
        $box.SelectionColor = $Color
        if ($Bold) { $box.SelectionFont = New-Object System.Drawing.Font($box.Font, [System.Drawing.FontStyle]::Bold) }
        $box.AppendText("[$time] $Text`r`n")
        $box.SelectionFont = $box.Font
        $box.SelectionColor = $box.ForeColor
        $box.SelectionStart = $box.TextLength
        $box.ScrollToCaret()
    }
}

function Add-SuccessLog {
    param([string]$Text)
    Add-Log $Text ([System.Drawing.Color]::FromArgb(74, 222, 128)) $false
}

function Add-RecommendLog {
    param([string]$Text)
    Add-Log $Text ([System.Drawing.Color]::FromArgb(74, 222, 128)) $true
}

function Copy-LogToClipboard {
    $seen = @{}
    $lines = New-Object System.Collections.Generic.List[string]
    foreach ($box in @($logBox, $serviceLogBox)) {
        if (-not $box -or -not $box.Text) { continue }
        foreach ($line in ($box.Text -split "`r?`n")) {
            $clean = $line.TrimEnd()
            if (-not $clean) { continue }
            if ($seen.ContainsKey($clean)) { continue }
            $seen[$clean] = $true
            $lines.Add($clean) | Out-Null
        }
    }
    if ($lines.Count -eq 0) {
        Add-Log (Tr 'copyLogEmpty') ([System.Drawing.Color]::FromArgb(250, 204, 21)) $true
        return
    }
    try {
        [System.Windows.Forms.Clipboard]::SetText(($lines -join "`r`n"))
        Add-RecommendLog (Tr 'copyLogDone')
    } catch {
        Add-Log ((Tr 'adminFailed') + ": $($_.Exception.Message)")
    }
}

function Start-ElevatedFile {
    param([string]$FilePath, [string]$Arguments = '')
    if (-not (Test-Path -LiteralPath $FilePath)) {
        Add-Log ((Tr 'fileMissing') + ": $FilePath")
        return
    }
    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $FilePath
        $psi.WorkingDirectory = $Root
        $psi.Verb = 'runas'
        if ($Arguments) { $psi.Arguments = $Arguments }
        [System.Diagnostics.Process]::Start($psi) | Out-Null
    } catch {
        Add-Log ((Tr 'adminFailed') + ": $($_.Exception.Message)")
    }
}

function Start-ElevatedHiddenCommand {
    param([string]$Command, [bool]$Wait = $false)
    try {
        $cmdPath = Join-Path $env:SystemRoot 'System32\cmd.exe'
        $runtimeDir = Join-Path $Root 'runtime'
        if (-not (Test-Path -LiteralPath $runtimeDir)) { New-Item -ItemType Directory -Path $runtimeDir | Out-Null }
        $logPath = Join-Path $runtimeDir 'service-actions.log'
        $cmdFile = Join-Path $runtimeDir ('azapret-action-' + [Guid]::NewGuid().ToString('N') + '.cmd')
        $vbsPath = Join-Path $env:TEMP ('azapret-hidden-' + [Guid]::NewGuid().ToString('N') + '.vbs')
        $cmdContent = '@echo off' + "`r`n" +
            'cd /d "' + ($Root.Replace('"', '""')) + '"' + "`r`n" +
            $Command + ' >> "' + ($logPath.Replace('"', '""')) + '" 2>&1' + "`r`n" +
            'exit /b %errorlevel%' + "`r`n"
        [System.IO.File]::WriteAllText($cmdFile, $cmdContent, [System.Text.Encoding]::ASCII)
        $commandLine = '"' + $cmdPath + '" /c "' + $cmdFile + '"'
        $waitFlag = if ($Wait) { 'True' } else { 'False' }
        $vbs = 'Set sh = CreateObject("WScript.Shell")' + "`r`n" +
            'sh.CurrentDirectory = "' + ($Root.Replace('"', '""')) + '"' + "`r`n" +
            'sh.Run "' + ($commandLine.Replace('"', '""')) + '", 0, ' + $waitFlag + "`r`n"
        [System.IO.File]::WriteAllText($vbsPath, $vbs, [System.Text.Encoding]::ASCII)
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = (Join-Path $env:SystemRoot 'System32\wscript.exe')
        $psi.Arguments = '"' + $vbsPath + '"'
        $psi.WorkingDirectory = $Root
        $psi.Verb = 'runas'
        $psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
        [System.Diagnostics.Process]::Start($psi) | Out-Null
        return $true
    } catch {
        Add-Log ((Tr 'adminFailed') + ": $($_.Exception.Message)")
        return $false
    }
}

function Test-ZapretServiceRunning {
    try {
        $svc = Get-Service -Name 'zapret' -ErrorAction SilentlyContinue
        return [bool]($svc -and $svc.Status -eq 'Running')
    } catch {
        return $false
    }
}

function Start-ElevatedServiceInstall {
    param([int]$Choice, [bool]$Wait = $true)
    try {
        $runtimeDir = Join-Path $Root 'runtime'
        if (-not (Test-Path -LiteralPath $runtimeDir)) { New-Item -ItemType Directory -Path $runtimeDir | Out-Null }
        $logPath = Join-Path $runtimeDir 'service-actions.log'
        $cmdFile = Join-Path $runtimeDir ('azapret-service-install-' + [Guid]::NewGuid().ToString('N') + '.cmd')
        $cmdPath = Join-Path $env:SystemRoot 'System32\cmd.exe'
        Add-Content -LiteralPath $logPath -Value ('Launcher requested autostart install. Choice=' + $Choice + ' Time=' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) -Encoding ASCII
        $cmdContent = '@echo off' + "`r`n" +
            'echo Elevated installer started. Choice=' + $Choice + ' Time=%DATE% %TIME% >> "' + ($logPath.Replace('"', '""')) + '"' + "`r`n" +
            'cd /d "' + ($Root.Replace('"', '""')) + '"' + "`r`n" +
            'call service.bat admin_install ' + $Choice + ' >> "' + ($logPath.Replace('"', '""')) + '" 2>&1' + "`r`n" +
            'echo Elevated installer finished. ErrorLevel=%ERRORLEVEL% Time=%DATE% %TIME% >> "' + ($logPath.Replace('"', '""')) + '"' + "`r`n" +
            'exit /b %ERRORLEVEL%' + "`r`n"
        [System.IO.File]::WriteAllText($cmdFile, $cmdContent, [System.Text.Encoding]::ASCII)
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $cmdPath
        $psi.Arguments = '/s /c ""' + ($cmdFile.Replace('"', '""')) + '""'
        $psi.WorkingDirectory = $Root
        $psi.Verb = 'runas'
        $psi.UseShellExecute = $true
        $psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal
        $process = [System.Diagnostics.Process]::Start($psi)
        if ($Wait -and $process) { $process.WaitForExit(45000) | Out-Null }
        return $true
    } catch {
        Add-Log ((Tr 'adminFailed') + ": $($_.Exception.Message)")
        return $false
    }
}

function Start-ElevatedHiddenServiceInput {
    param([string[]]$Lines)
    try {
        $runtimeDir = Join-Path $Root 'runtime'
        if (-not (Test-Path -LiteralPath $runtimeDir)) { New-Item -ItemType Directory -Path $runtimeDir | Out-Null }
        $logPath = Join-Path $runtimeDir 'service-actions.log'
        $inputFile = Join-Path $runtimeDir ('azapret-input-' + [Guid]::NewGuid().ToString('N') + '.txt')
        $cmdFile = Join-Path $runtimeDir ('azapret-action-' + [Guid]::NewGuid().ToString('N') + '.cmd')
        [System.IO.File]::WriteAllText($inputFile, (($Lines -join "`r`n") + "`r`n"), [System.Text.Encoding]::ASCII)
        $cmdContent = '@echo off' + "`r`n" +
            'cd /d "' + ($Root.Replace('"', '""')) + '"' + "`r`n" +
            'call service.bat admin < "' + ($inputFile.Replace('"', '""')) + '" >> "' + ($logPath.Replace('"', '""')) + '" 2>&1' + "`r`n" +
            'exit /b %errorlevel%' + "`r`n"
        [System.IO.File]::WriteAllText($cmdFile, $cmdContent, [System.Text.Encoding]::ASCII)
        Start-ElevatedHiddenCommand ('"' + $cmdFile + '"')
    } catch {
        Add-Log ((Tr 'adminFailed') + ": $($_.Exception.Message)")
    }
}

function Start-ElevatedHiddenBatch {
    param([string]$FilePath)
    if (-not (Test-Path -LiteralPath $FilePath)) {
        Add-Log ((Tr 'fileMissing') + ": $FilePath")
        return
    }
    $quote = [char]34
    Start-ElevatedHiddenCommand ('call ' + $quote + $FilePath + $quote)
}

function Repair-SystemDns {
    Add-Log (Tr 'dnsRepairStart')
    try {
        $runtimeDir = Join-Path $Root 'runtime'
        if (-not (Test-Path -LiteralPath $runtimeDir)) { New-Item -ItemType Directory -Path $runtimeDir | Out-Null }
        $repairScript = Join-Path $runtimeDir 'azapret-dns-repair.ps1'
        $backupFile = Join-Path $runtimeDir 'azapret-dns-backup.json'
        $scriptText = @'
param([string]$BackupFile)
$ErrorActionPreference = 'Continue'
$hostsPath = Join-Path $env:SystemRoot 'System32\drivers\etc\hosts'
$markerStart = '# BEGIN Azapret site fix'
$markerEnd = '# END Azapret site fix'
$entries = @(
    '57.144.254.34 instagram.com',
    '57.144.254.34 www.instagram.com',
    '57.144.254.192 static.cdninstagram.com',
    '57.144.120.192 scontent.cdninstagram.com',
    '57.144.120.192 i.instagram.com',
    '57.144.254.192 graph.instagram.com',
    '57.144.68.192 edge-chat.instagram.com',
    '163.70.128.19 gateway.instagram.com',
    '57.144.120.34 help.instagram.com',
    '57.144.68.141 about.instagram.com',
    '57.144.68.34 privacycenter.instagram.com',
    '57.144.254.1 facebook.com',
    '57.144.68.1 www.facebook.com',
    '57.144.68.1 m.facebook.com',
    '57.144.254.141 web.facebook.com',
    '57.144.254.128 static.xx.fbcdn.net',
    '57.144.254.128 scontent.xx.fbcdn.net',
    '57.144.254.129 video.xx.fbcdn.net',
    '57.144.254.128 connect.facebook.net',
    '157.240.30.18 graph.facebook.com',
    '57.144.68.141 www.messenger.com',
    '149.154.167.99 telegram.org',
    '149.154.167.99 web.telegram.org',
    '149.154.174.200 kws1.web.telegram.org',
    '149.154.174.200 kws1-1.web.telegram.org',
    '149.154.167.99 kws2.web.telegram.org',
    '149.154.167.99 kws2-1.web.telegram.org',
    '149.154.174.200 kws3.web.telegram.org',
    '149.154.174.200 kws3-1.web.telegram.org',
    '149.154.167.99 kws4.web.telegram.org',
    '149.154.167.99 kws4-1.web.telegram.org',
    '149.154.171.5 kws5.web.telegram.org',
    '149.154.171.5 kws5-1.web.telegram.org',
    '149.154.174.200 zws1.web.telegram.org',
    '149.154.167.99 zws2.web.telegram.org',
    '149.154.174.200 zws3.web.telegram.org',
    '149.154.167.99 zws4.web.telegram.org',
    '149.154.167.99 venus.web.telegram.org',
    '149.154.175.209 pluto.web.telegram.org',
    '149.154.170.96 flora.web.telegram.org',
    '149.154.166.110 api.telegram.org',
    '149.154.167.99 desktop.telegram.org',
    '149.154.167.99 t.me'
)
$policyPaths = @(
    'HKCU:\Software\Policies\Google\Chrome',
    'HKCU:\Software\Policies\Microsoft\Edge',
    'HKLM:\Software\Policies\Google\Chrome',
    'HKLM:\Software\Policies\Microsoft\Edge'
)
$policyBackup = foreach ($path in $policyPaths) {
    $props = if (Test-Path -LiteralPath $path) { Get-ItemProperty -LiteralPath $path -ErrorAction SilentlyContinue } else { $null }
    [pscustomobject]@{
        Path = $path
        QuicAllowed = if ($props -and ($props.PSObject.Properties.Name -contains 'QuicAllowed')) { $props.QuicAllowed } else { $null }
        DnsOverHttpsMode = if ($props -and ($props.PSObject.Properties.Name -contains 'DnsOverHttpsMode')) { $props.DnsOverHttpsMode } else { $null }
        DnsOverHttpsTemplates = if ($props -and ($props.PSObject.Properties.Name -contains 'DnsOverHttpsTemplates')) { $props.DnsOverHttpsTemplates } else { $null }
    }
}
$content = @(Get-Content -LiteralPath $hostsPath -ErrorAction SilentlyContinue)
[pscustomobject]@{ BrowserPolicies = @($policyBackup) } | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $BackupFile -Encoding UTF8
$result = New-Object System.Collections.Generic.List[string]
$skip = $false
foreach ($line in $content) {
    if ($line -eq $markerStart) { $skip = $true; continue }
    if ($line -eq $markerEnd) { $skip = $false; continue }
    if (-not $skip) { $result.Add($line) }
}
$result.Add('')
$result.Add($markerStart)
foreach ($entry in $entries) { $result.Add($entry) }
$result.Add($markerEnd)
Set-Content -LiteralPath $hostsPath -Value $result -Encoding ASCII
ipconfig /flushdns | Out-Null
foreach ($path in $policyPaths) {
    if (-not (Test-Path -LiteralPath $path)) { New-Item -Path $path -Force | Out-Null }
    New-ItemProperty -LiteralPath $path -Name 'QuicAllowed' -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -LiteralPath $path -Name 'DnsOverHttpsMode' -Value 'secure' -PropertyType String -Force | Out-Null
    New-ItemProperty -LiteralPath $path -Name 'DnsOverHttpsTemplates' -Value 'https://cloudflare-dns.com/dns-query' -PropertyType String -Force | Out-Null
}
'@
        [System.IO.File]::WriteAllText($repairScript, $scriptText, [System.Text.Encoding]::UTF8)
        $quote = [char]34
        Start-ElevatedHiddenCommand ('powershell.exe -NoProfile -ExecutionPolicy Bypass -File ' + $quote + $repairScript + $quote + ' -BackupFile ' + $quote + $backupFile + $quote)
        Add-SuccessLog (Tr 'dnsRepairDone')
    } catch {
        Add-Log ((Tr 'adminFailed') + ": $($_.Exception.Message)")
    }
}

function Restore-SystemDns {
    $runtimeDir = Join-Path $Root 'runtime'
    $backupFile = Join-Path $runtimeDir 'azapret-dns-backup.json'
    $hostsPath = Join-Path $env:SystemRoot 'System32\drivers\etc\hosts'
    $hasFix = $false
    if (Test-Path -LiteralPath $hostsPath) {
        $hasFix = [bool](@(Get-Content -LiteralPath $hostsPath -ErrorAction SilentlyContinue | Where-Object { $_ -eq '# BEGIN Azapret site fix' }).Count)
    }
    if ((-not $hasFix) -and (-not (Test-Path -LiteralPath $backupFile))) {
        Add-Log (Tr 'dnsRestoreMissing')
        return
    }
    Add-Log (Tr 'dnsRestoreStart')
    try {
        $restoreScript = Join-Path $runtimeDir 'azapret-dns-restore.ps1'
        $scriptText = @'
param([string]$BackupFile)
$ErrorActionPreference = 'Continue'
$hostsPath = Join-Path $env:SystemRoot 'System32\drivers\etc\hosts'
$markerStart = '# BEGIN Azapret site fix'
$markerEnd = '# END Azapret site fix'
$content = @(Get-Content -LiteralPath $hostsPath -ErrorAction SilentlyContinue)
$result = New-Object System.Collections.Generic.List[string]
$skip = $false
foreach ($line in $content) {
    if ($line -eq $markerStart) { $skip = $true; continue }
    if ($line -eq $markerEnd) { $skip = $false; continue }
    if (-not $skip) { $result.Add($line) }
}

Set-Content -LiteralPath $hostsPath -Value $result -Encoding ASCII
ipconfig /flushdns | Out-Null
if (Test-Path -LiteralPath $BackupFile) {
    $data = Get-Content -LiteralPath $BackupFile -Raw | ConvertFrom-Json
    if ($data.PSObject.Properties.Name -contains 'BrowserPolicies') {
        foreach ($policy in @($data.BrowserPolicies)) {
            if (-not (Test-Path -LiteralPath $policy.Path)) { New-Item -Path $policy.Path -Force | Out-Null }
            if ($null -ne $policy.QuicAllowed) {
                New-ItemProperty -LiteralPath $policy.Path -Name 'QuicAllowed' -Value ([int]$policy.QuicAllowed) -PropertyType DWord -Force | Out-Null
            } else {
                Remove-ItemProperty -LiteralPath $policy.Path -Name 'QuicAllowed' -ErrorAction SilentlyContinue
            }
            if ($null -ne $policy.DnsOverHttpsMode) {
                New-ItemProperty -LiteralPath $policy.Path -Name 'DnsOverHttpsMode' -Value $policy.DnsOverHttpsMode -PropertyType String -Force | Out-Null
            } else {
                Remove-ItemProperty -LiteralPath $policy.Path -Name 'DnsOverHttpsMode' -ErrorAction SilentlyContinue
            }
            if ($null -ne $policy.DnsOverHttpsTemplates) {
                New-ItemProperty -LiteralPath $policy.Path -Name 'DnsOverHttpsTemplates' -Value $policy.DnsOverHttpsTemplates -PropertyType String -Force | Out-Null
            } else {
                Remove-ItemProperty -LiteralPath $policy.Path -Name 'DnsOverHttpsTemplates' -ErrorAction SilentlyContinue
            }
        }
    }
}
'@
        [System.IO.File]::WriteAllText($restoreScript, $scriptText, [System.Text.Encoding]::UTF8)
        $quote = [char]34
        Start-ElevatedHiddenCommand ('powershell.exe -NoProfile -ExecutionPolicy Bypass -File ' + $quote + $restoreScript + $quote + ' -BackupFile ' + $quote + $backupFile + $quote)
        Add-SuccessLog (Tr 'dnsRestoreDone')
    } catch {
        Add-Log ((Tr 'adminFailed') + ": $($_.Exception.Message)")
    }
}

function Get-TgWsProxyExe {
    return (Join-Path $Root 'tools\tg-ws-proxy\TgWsProxy_windows.exe')
}

function Get-TgWsProxyAppDir {
    return (Join-Path $env:APPDATA 'TgWsProxy')
}

function Set-TgProxyWindowsStartup {
    param([bool]$Enabled)
    $runKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
    $name = 'AzapretTGProxy'
    try {
        if ($Enabled) {
            $starter = Join-Path $Root 'Start-TG-Proxy.ps1'
            if (-not (Test-Path -LiteralPath $starter)) { return $false }
            Set-ItemProperty -Path $runKey -Name $name -Value ('powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "' + $starter + '"')
        } else {
            Remove-ItemProperty -Path $runKey -Name $name -ErrorAction SilentlyContinue
        }
        return $true
    } catch {
        Add-Log ((Tr 'adminFailed') + ": $($_.Exception.Message)") ([System.Drawing.Color]::FromArgb(248, 113, 113)) $true
        return $false
    }
}

function Get-TgWsProxyConfigPath {
    return (Join-Path (Get-TgWsProxyAppDir) 'config.json')
}

function Sync-TgProxySecretFromConfig {
    $configPath = Get-TgWsProxyConfigPath
    if (-not (Test-Path -LiteralPath $configPath)) { return $false }
    try {
        $cfg = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
        $cfgSecret = [string]$cfg.secret
        if ($cfgSecret -match '^[0-9a-fA-F]{32}$') {
            $script:Settings.tgProxySecret = $cfgSecret.ToLowerInvariant()
            Save-Settings -Silent $true
            return $true
        }
    } catch {}
    return $false
}

function Get-TgProxySecret {
    $secret = [string]$script:Settings.tgProxySecret
    if ($secret -match '^[0-9a-fA-F]{32}$') { return $secret.ToLowerInvariant() }
    if (Sync-TgProxySecretFromConfig) { return $script:Settings.tgProxySecret }
    $bytes = New-Object byte[] 16
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    $secret = -join ($bytes | ForEach-Object { $_.ToString('x2') })
    $script:Settings.tgProxySecret = $secret
    Save-Settings -Silent $true
    return $secret
}

function Get-TgProxyPort {
    $port = 1443
    try { $port = [int]$script:Settings.tgProxyPort } catch { $port = 1443 }
    if ($port -lt 1 -or $port -gt 65535) { $port = 1443 }
    return $port
}

function Get-TgProxyPortCandidates {
    $ports = New-Object System.Collections.Generic.List[int]
    $ports.Add((Get-TgProxyPort))
    foreach ($fallback in @(1443, 2443, 3443, 8443, 9443, 10443)) {
        if (-not $ports.Contains([int]$fallback)) { $ports.Add([int]$fallback) }
    }
    return @($ports)
}

function Set-TgProxyPort {
    param([int]$Port)
    if ($Port -lt 1 -or $Port -gt 65535) { $Port = 1443 }
    $script:Settings.tgProxyPort = $Port
    Save-Settings -Silent $true
}

function Get-AvailableTgProxyPort {
    foreach ($port in (Get-TgProxyPortCandidates)) {
        if (-not (Test-TcpPortLocal -Port $port)) { return [int]$port }
    }
    return 0
}

function Get-TgProxyUrl {
    $port = Get-TgProxyPort
    $secret = Get-TgProxySecret
    return "tg://proxy?server=127.0.0.1&port=$port&secret=dd$secret"
}

function Test-TcpPortLocal {
    param([int]$Port)
    $client = $null
    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $iar = $client.BeginConnect('127.0.0.1', $Port, $null, $null)
        if (-not $iar.AsyncWaitHandle.WaitOne(900, $false)) { return $false }
        $client.EndConnect($iar)
        return $true
    } catch {
        return $false
    } finally {
        if ($client) { $client.Close() }
    }
}

function Get-TgWsProxyProcesses {
    $exe = (Get-TgWsProxyExe).ToLowerInvariant()
    try {
        return @(Get-CimInstance Win32_Process -Filter "name = 'TgWsProxy_windows.exe' OR name = 'TgWsProxy.exe'" -ErrorAction SilentlyContinue |
            Where-Object {
                $path = [string]$_.ExecutablePath
                $cmd = [string]$_.CommandLine
                ($path -and $path.ToLowerInvariant() -eq $exe) -or ($cmd -and $cmd.ToLowerInvariant().Contains($exe))
            })
    } catch {
        return @()
    }
}

function Write-TgWsProxyConfig {
    $appDir = Get-TgWsProxyAppDir
    if (-not (Test-Path -LiteralPath $appDir)) { New-Item -ItemType Directory -Path $appDir -Force | Out-Null }
    $configPath = Get-TgWsProxyConfigPath
    $config = [ordered]@{
        host = '127.0.0.1'
        port = Get-TgProxyPort
        secret = Get-TgProxySecret
        dc_ip = @('2:149.154.167.220', '4:149.154.167.220')
        verbose = $false
        buf_kb = 256
        pool_size = 4
        log_max_mb = 5.0
        check_updates = $false
        cfproxy = $true
        cfproxy_user_domain = @()
        cfproxy_worker_domain = @()
        appearance = 'auto'
        autostart = [bool]$script:Settings.tgProxyAutostart
    }
    [System.IO.File]::WriteAllText($configPath, ($config | ConvertTo-Json -Depth 5), (New-Object System.Text.UTF8Encoding($false)))
    New-Item -ItemType File -Path (Join-Path $appDir '.first_run_done_mtproto') -Force | Out-Null
    New-Item -ItemType File -Path (Join-Path $appDir '.ipv6_warned') -Force | Out-Null
    return $configPath
}

function Start-LocalTelegramProxy {
    $exe = Get-TgWsProxyExe
    if (-not (Test-Path -LiteralPath $exe)) {
        Add-Log ((Tr 'tgProxyMissing') + ": $exe") ([System.Drawing.Color]::FromArgb(248, 113, 113)) $true
        return $false
    }
    $currentPort = Get-TgProxyPort

    if (@(Get-TgWsProxyProcesses).Count -gt 0) {
        Stop-LocalTelegramProxy
        for ($i = 0; $i -lt 20 -and (Test-TcpPortLocal -Port $currentPort); $i++) { Start-Sleep -Milliseconds 250 }
    }

    $port = Get-AvailableTgProxyPort
    if ($port -eq 0) {
        Add-Log ((Tr 'tgProxyPortBusy') + ": " + ((Get-TgProxyPortCandidates) -join ', ')) ([System.Drawing.Color]::FromArgb(248, 113, 113)) $true
        return $false
    }
    if ($port -ne $currentPort) { Add-Log ((Tr 'tgProxyPortBusy') + ": $currentPort -> 127.0.0.1:$port") }
    Set-TgProxyPort -Port $port

    Write-TgWsProxyConfig | Out-Null
    Add-Log (Tr 'tgProxyStarting')
    try {
        Start-Process -FilePath $exe -WorkingDirectory (Split-Path -Parent $exe) -WindowStyle Hidden | Out-Null
    } catch {
        Add-Log ((Tr 'adminFailed') + ": $($_.Exception.Message)") ([System.Drawing.Color]::FromArgb(248, 113, 113)) $true
        return $false
    }
    for ($i = 0; $i -lt 20 -and -not (Test-TcpPortLocal -Port $port); $i++) { Start-Sleep -Milliseconds 250 }
    if (Test-TcpPortLocal -Port $port) {
        Sync-TgProxySecretFromConfig | Out-Null
        $script:Settings.tgProxyAutostart = $true
        Save-Settings -Silent $true
        Set-TgProxyWindowsStartup -Enabled $true | Out-Null
        Write-TgWsProxyConfig | Out-Null
        Add-SuccessLog ((Tr 'tgProxyReady') + ":$port")
        return $true
    }
    Add-Log (Tr 'tgProxyNotReady') ([System.Drawing.Color]::FromArgb(250, 204, 21)) $true
    return $false
}

function Stop-LocalTelegramProxy {
    $procs = @(Get-TgWsProxyProcesses)
    foreach ($proc in $procs) {
        try { Stop-Process -Id ([int]$proc.ProcessId) -Force -ErrorAction SilentlyContinue } catch {}
    }
    $script:Settings.tgProxyAutostart = $false
    Save-Settings -Silent $true
    Set-TgProxyWindowsStartup -Enabled $false | Out-Null
    Write-TgWsProxyConfig | Out-Null
    Add-SuccessLog (Tr 'tgProxyStopped')
}

function Invoke-TelegramAppFix {
    if (-not (Show-DarkConfirm -Message (Tr 'tgAppFixStart'))) { return }
    if (-not (Start-LocalTelegramProxy)) { return }
    Sync-TgProxySecretFromConfig | Out-Null
    $proxyUrl = Get-TgProxyUrl
    $webProxyUrl = $proxyUrl.Replace('tg://proxy', 'https://t.me/proxy')
    try {
        [System.Windows.Forms.Clipboard]::SetText($webProxyUrl)
        Add-SuccessLog (Tr 'tgProxyLinkCopied')
    } catch {}
    Add-Log ("Telegram local proxy URL: $webProxyUrl")
    try { Start-Process $proxyUrl } catch { Add-Log ((Tr 'adminFailed') + ": $($_.Exception.Message)") }
    Add-SuccessLog (Tr 'tgAppFixDone')
}

function Show-DarkConfirm {
    param([string]$Message)
    $dialog = New-Object System.Windows.Forms.Form
    $dialog.Text = 'Azapret'
    $dialog.StartPosition = 'CenterParent'
    $dialog.Size = New-Object System.Drawing.Size(420, 190)
    $dialog.FormBorderStyle = 'FixedDialog'
    $dialog.MaximizeBox = $false
    $dialog.MinimizeBox = $false
    $dialog.BackColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
    $dialog.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
    $dialog.Font = New-Object System.Drawing.Font('Segoe UI', 10)

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Message
    $label.Location = New-Object System.Drawing.Point(24, 24)
    $label.Size = New-Object System.Drawing.Size(360, 58)
    $label.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
    $dialog.Controls.Add($label)

    $yes = New-Button -Text 'OK' -X 116 -Y 100 -W 82 -H 34 -Click { $dialog.DialogResult = [System.Windows.Forms.DialogResult]::Yes; $dialog.Close() } -Accent $true
    $no = New-Button -Text 'Cancel' -X 214 -Y 100 -W 96 -H 34 -Click { $dialog.DialogResult = [System.Windows.Forms.DialogResult]::No; $dialog.Close() }
    $dialog.Controls.AddRange(@($yes, $no))
    return ([System.Windows.Forms.DialogResult]::Yes -eq $dialog.ShowDialog($form))
}

function Open-TelegramDownload {
    Add-Log (Tr 'tgDownloadOpen')
    try { Start-Process 'https://github.com/telegramdesktop/tdesktop/releases/latest' } catch { Add-Log ((Tr 'adminFailed') + ": $($_.Exception.Message)") }
}

function Open-TelegramProxyChannel {
    if (-not (Show-DarkConfirm -Message (Tr 'tgProxyChannelAsk'))) { return }
    Add-Log (Tr 'tgProxyChannelOpen')
    try { Start-Process 'tg://resolve?domain=ProxyMTProto' } catch { Add-Log ((Tr 'adminFailed') + ": $($_.Exception.Message)") }
}

function Show-ImagePreview {
    param([string]$ImagePath)
    if (-not (Test-Path -LiteralPath $ImagePath)) { return }
    $viewer = New-Object System.Windows.Forms.Form
    $viewer.Text = Tr 'tgProxyPopupTitle'
    $viewer.StartPosition = 'CenterParent'
    $viewer.Size = New-Object System.Drawing.Size(900, 700)
    $viewer.BackColor = [System.Drawing.Color]::FromArgb(2, 6, 23)
    $viewer.FormBorderStyle = 'FixedDialog'
    $viewer.MaximizeBox = $false
    $close = New-Button -Text 'X' -X 830 -Y 16 -W 42 -H 34 -Click { $viewer.Close() } -Accent $true
    $viewer.Controls.Add($close)
    $picture = New-Object System.Windows.Forms.PictureBox
    $picture.Location = New-Object System.Drawing.Point(18, 62)
    $picture.Size = New-Object System.Drawing.Size(846, 580)
    $picture.SizeMode = 'Zoom'
    try { $picture.Image = [System.Drawing.Image]::FromFile($ImagePath) } catch { return }
    $viewer.Controls.Add($picture)
    [void]$viewer.ShowDialog($form)
}

function Show-TelegramProxyChannelPopup {
    $popup = New-Object System.Windows.Forms.Form
    $popup.Text = Tr 'tgProxyPopupTitle'
    $popup.StartPosition = 'CenterParent'
    $popup.Size = New-Object System.Drawing.Size(620, 660)
    $popup.MinimumSize = New-Object System.Drawing.Size(520, 420)
    $popup.BackColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
    $popup.FormBorderStyle = 'FixedDialog'
    $popup.MaximizeBox = $false

    $openButton = New-Button -Text (Tr 'tgProxyOpenChannel') -X 18 -Y 18 -W 566 -H 42 -Click { Open-TelegramProxyChannel } -Accent $true
    $popup.Controls.Add($openButton)

    $screensPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $screensPanel.Location = New-Object System.Drawing.Point(18, 78)
    $screensPanel.Size = New-Object System.Drawing.Size(566, 530)
    $screensPanel.Anchor = 'Top,Bottom,Left,Right'
    $screensPanel.AutoScroll = $true
    $screensPanel.BackColor = [System.Drawing.Color]::FromArgb(30, 41, 59)
    $screensPanel.FlowDirection = 'TopDown'
    $screensPanel.WrapContents = $false
    $popup.Controls.Add($screensPanel)

    $screensDir = Join-Path $Root 'telegram-proxy-screens'
    $steps = @(
        @{ File = 'p1'; Text = "1. Заходим в группу.`r`n2. Нажимаем Connect." },
        @{ File = 'p2'; Text = "1. Откроется окно коннекта.`r`n2. Нажимаем Check Status." },
        @{ File = 'p4'; Text = "Если видим Not Available, значит proxy не рабочий.`r`nИщем тот, который работает именно у вас." },
        @{ File = 'p3'; Text = "Находим рабочий proxy: проверка покажет Available и ваш ping.`r`nЧем меньше ping, тем лучше." },
        @{ File = 'p5'; Text = "Нажимаем Connect Proxy." },
        @{ File = 'p6'; Text = "1. Выбираем Use custom proxy.`r`n2. Ставим Auto-switch proxies и выбираем 5-10 секунд.`r`n3. Видим наш connect.`r`nДобавляйте все рабочие proxy: они будут переключаться автоматически." }
    )

    $hasScreens = $false
    if (-not (Test-Path -LiteralPath $screensDir)) {
        $fallbackDir = 'C:\Users\Artur\zapret\tg'
        if (Test-Path -LiteralPath $fallbackDir) { $screensDir = $fallbackDir }
    }

    if (-not (Test-Path -LiteralPath $screensDir)) {
        $hint = New-Object System.Windows.Forms.Label
        $hint.Text = Tr 'tgProxyScreensHint'
        $hint.Font = New-Object System.Drawing.Font('Segoe UI', 10)
        $hint.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
        $hint.Size = New-Object System.Drawing.Size(530, 80)
        $hint.Margin = New-Object System.Windows.Forms.Padding(16, 18, 16, 8)
        $screensPanel.Controls.Add($hint)
    } else {
        foreach ($step in $steps) {
            $screen = $null
            foreach ($ext in @('.png', '.jpg', '.jpeg', '.bmp', '.gif')) {
                $candidate = Join-Path $screensDir ($step.File + $ext)
                if (Test-Path -LiteralPath $candidate) { $screen = $candidate; break }
            }
            if (-not $screen) { continue }
            $hasScreens = $true
            $text = New-Object System.Windows.Forms.Label
            $text.Text = $step.Text
            $text.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
            $text.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
            $text.Size = New-Object System.Drawing.Size(530, 74)
            $text.Margin = New-Object System.Windows.Forms.Padding(16, 18, 16, 0)
            $screensPanel.Controls.Add($text)
            try {
                $image = [System.Drawing.Image]::FromFile($screen)
                $picture = New-Object System.Windows.Forms.PictureBox
                $picture.Image = $image
                $picture.SizeMode = 'Zoom'
                $picture.Size = New-Object System.Drawing.Size(530, 320)
                $picture.Margin = New-Object System.Windows.Forms.Padding(16, 8, 16, 10)
                $picture.Cursor = [System.Windows.Forms.Cursors]::Hand
                $picture.Tag = $screen
                $picture.Add_Click({ Show-ImagePreview -ImagePath ([string]$this.Tag) })
                $screensPanel.Controls.Add($picture)
            } catch {}
        }
        if (-not $hasScreens) {
            $hint = New-Object System.Windows.Forms.Label
            $hint.Text = Tr 'tgProxyScreensHint'
            $hint.Font = New-Object System.Drawing.Font('Segoe UI', 10)
            $hint.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
            $hint.Size = New-Object System.Drawing.Size(530, 80)
            $hint.Margin = New-Object System.Windows.Forms.Padding(16, 18, 16, 8)
            $screensPanel.Controls.Add($hint)
        }
    }

    [void]$popup.ShowDialog($form)
}

function Stop-BypassHidden {
    Add-Log (Tr 'stoppingOld')
    Start-ElevatedHiddenCommand 'taskkill /IM winws.exe /F >nul 2>&1 & net stop zapret >nul 2>&1 & net stop WinDivert >nul 2>&1 & net stop WinDivert14 >nul 2>&1 & ipconfig /flushdns >nul 2>&1' -Wait $true
}

function Stop-CsFaceitBypassHidden {
    Add-Log 'CS/Faceit: останавливаю только ранее запущенный TTL-профиль, основной обход не трогаю.'
    $runtimeDir = Join-Path $Root 'runtime'
    if (-not (Test-Path -LiteralPath $runtimeDir)) { New-Item -ItemType Directory -Path $runtimeDir | Out-Null }
    $pidFile = Join-Path $runtimeDir 'faceit-ttl.pid'
    $stopScript = Join-Path $runtimeDir 'azapret-faceit-ttl-stop.ps1'
    $scriptText = @'
param([string]$PidFile)
$ErrorActionPreference = 'Continue'
if (Test-Path -LiteralPath $PidFile) {
    $pidText = (Get-Content -LiteralPath $PidFile -ErrorAction SilentlyContinue | Select-Object -First 1)
    $pidValue = 0
    if ([int]::TryParse($pidText, [ref]$pidValue)) {
        Stop-Process -Id $pidValue -Force -ErrorAction SilentlyContinue
    }
    Remove-Item -LiteralPath $PidFile -Force -ErrorAction SilentlyContinue
}
Get-CimInstance Win32_Process -Filter "name = 'winws.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -like '*--dpi-desync-ttl=*' -and $_.CommandLine -like '*--filter-udp=1024-65535*' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
'@
    [System.IO.File]::WriteAllText($stopScript, $scriptText, [System.Text.Encoding]::UTF8)
    Start-ElevatedHiddenCommand ('powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' + $stopScript.Replace('"', '""') + '" -PidFile "' + $pidFile.Replace('"', '""') + '"') -Wait $true
}

function Get-CsFaceitWinwsArgs {
    param([string]$ProfilePath)
    if (-not (Test-Path -LiteralPath $ProfilePath)) { return $null }

    $text = Get-Content -LiteralPath $ProfilePath -Raw -Encoding UTF8
    if ($text -notmatch '--dpi-desync-ttl=(\d+)') { return $null }
    $ttl = [int]$Matches[1]
    $binDir = Join-Path $Root 'bin\'
    $listsDir = Join-Path $Root 'lists\'
    return '--wf-udp=1024-65535 --filter-udp=1024-65535 --ipset-exclude="' + $listsDir + 'ipset-exclude.txt" --ipset-exclude="' + $listsDir + 'ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=10 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n4 --dpi-desync-ttl=' + $ttl + ' --dpi-desync-fake-unknown-udp="' + $binDir + 'stun.bin"'
}

function Start-CsFaceitProfileJoint {
    param([object]$Profile)
    $args = Get-CsFaceitWinwsArgs -ProfilePath $Profile.Path
    if (-not $args) {
        Add-Log "CS/Faceit: не удалось разобрать winws args из $($Profile.Name)." ([System.Drawing.Color]::FromArgb(248, 113, 113)) $true
        return $false
    }

    $bin = Join-Path $Root 'bin\winws.exe'
    $runtimeDir = Join-Path $Root 'runtime'
    if (-not (Test-Path -LiteralPath $runtimeDir)) { New-Item -ItemType Directory -Path $runtimeDir | Out-Null }
    $faceitLog = Join-Path $runtimeDir 'faceit-ttl.log'
    $pidFile = Join-Path $runtimeDir 'faceit-ttl.pid'
    $launchScript = Join-Path $runtimeDir ('azapret-faceit-ttl-' + [Guid]::NewGuid().ToString('N') + '.ps1')
    $escape = { param([string]$Value) $Value.Replace("'", "''") }
    $scriptText = @"
`$ErrorActionPreference = 'Continue'
`$winws = '$(& $escape $bin)'
`$arguments = @'
$args
'@
`$workDir = '$(& $escape $Root)'
`$pidFile = '$(& $escape $pidFile)'
`$logFile = '$(& $escape $faceitLog)'
`$profileName = '$(& $escape $Profile.Name)'
Add-Content -LiteralPath `$logFile -Value ('FACEIT TTL launcher ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + ' profile=' + `$profileName)
try {
    `$process = Start-Process -FilePath `$winws -ArgumentList `$arguments -WorkingDirectory `$workDir -WindowStyle Minimized -PassThru -ErrorAction Stop
    if (`$process) {
        Set-Content -LiteralPath `$pidFile -Value `$process.Id -Encoding ASCII
        Add-Content -LiteralPath `$logFile -Value ('FACEIT TTL pid=' + `$process.Id)
    }
} catch {
    Add-Content -LiteralPath `$logFile -Value ('FACEIT TTL start failed: ' + `$_.Exception.Message)
}
"@
    [System.IO.File]::WriteAllText($launchScript, $scriptText, [System.Text.Encoding]::UTF8)
    Add-Log 'CS/Faceit: запускаю отдельный CS-only winws свернутым рядом с основным обходом.'
    $psArgs = '-NoProfile -ExecutionPolicy Bypass -File "' + $launchScript.Replace('"', '""') + '"'
    $ps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    Start-ElevatedFile -FilePath $ps -Arguments ('-WindowStyle Minimized ' + $psArgs)
    return $true
}

function Stop-Bypass {
    $stopBat = Join-Path $Root 'stop-zapret-emergency.bat'
    if (Test-Path -LiteralPath $stopBat) {
        Add-Log (Tr 'stoppingOld')
        Start-ElevatedFile -FilePath $stopBat
    } else {
        Add-Log (Tr 'stopMissing')
    }
}

function Get-ExtraFile {
    param([string]$Name)
    $extraPath = Join-Path (Join-Path $Root 'extra') $Name
    if (Test-Path -LiteralPath $extraPath) { return $extraPath }
    return (Join-Path $Root $Name)
}

function Test-UrlFast {
    param([string]$Url)
    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 8 -Method Get -Headers @{ 'User-Agent' = 'ZapretLauncher/1.1.1' }
        $sw.Stop()
        $code = [int]$response.StatusCode
        return [pscustomobject]@{ Ok = $true; Code = $code; Ms = $sw.ElapsedMilliseconds; Error = ''; Body = [string]$response.Content }
    } catch {
        $response = $_.Exception.Response
        if ($response -and $response.StatusCode) {
            $body = ''
            try {
                $stream = $response.GetResponseStream()
                if ($stream) {
                    $reader = New-Object System.IO.StreamReader($stream)
                    $body = $reader.ReadToEnd()
                    $reader.Close()
                }
            } catch {}
            return [pscustomobject]@{ Ok = $true; Code = [int]$response.StatusCode; Ms = 0; Error = ''; Body = $body }
        }
        return [pscustomobject]@{ Ok = $false; Code = ''; Ms = 0; Error = $_.Exception.Message; Body = '' }
    }
}

function Get-BlockPageReason {
    param([string]$Body)
    if (-not $Body) { return '' }
    $text = $Body.ToLowerInvariant()
    $patterns = @(
        'роскомнадзор',
        'ркн',
        'доступ ограничен',
        'доступ к информационному ресурсу ограничен',
        'заблокирован',
        'заблокировано',
        'blocked by',
        'access denied by',
        'registry.rkn.gov.ru',
        'eais.rkn.gov.ru'
    )
    foreach ($pattern in $patterns) {
        if ($text.Contains($pattern)) { return $pattern }
    }
    return ''
}

function Get-NetworkTargets {
    param([bool]$Fast = $false)
    $targets = New-Object System.Collections.Generic.List[object]
    if ($Fast) {
        $targets.Add([pscustomobject]@{ Name = 'DiscordGateway'; Url = 'https://gateway.discord.gg'; Priority = 1 }) | Out-Null
        $targets.Add([pscustomobject]@{ Name = 'YouTubeWeb'; Url = 'https://www.youtube.com'; Priority = 2 }) | Out-Null
        return $targets
    }
    $targets.Add([pscustomobject]@{ Name = 'DiscordMain'; Url = 'https://discord.com'; Priority = 1 }) | Out-Null
    $targets.Add([pscustomobject]@{ Name = 'DiscordGateway'; Url = 'https://gateway.discord.gg'; Priority = 1 }) | Out-Null
    $targets.Add([pscustomobject]@{ Name = 'DiscordCDN'; Url = 'https://cdn.discordapp.com'; Priority = 1 }) | Out-Null
    $targets.Add([pscustomobject]@{ Name = 'DiscordUpdates'; Url = 'https://updates.discord.com'; Priority = 1 }) | Out-Null
    $targets.Add([pscustomobject]@{ Name = 'YouTubeWeb'; Url = 'https://www.youtube.com'; Priority = 2 }) | Out-Null
    $targets.Add([pscustomobject]@{ Name = 'YouTubeImage'; Url = 'https://i.ytimg.com'; Priority = 2 }) | Out-Null
    return $targets
}

function Get-NetworkTargetHost {
    param([object]$Target)
    try { return ([System.Uri]$Target.Url).Host } catch { return '' }
}

function Test-NetworkPing {
    param([string]$HostName)
    if (-not $HostName) { return [pscustomobject]@{ Ok = $false; Ms = 999999 } }
    try {
        $ping = New-Object System.Net.NetworkInformation.Ping
        $values = New-Object System.Collections.Generic.List[int]
        for ($i = 0; $i -lt 2; $i++) {
            try {
                $reply = $ping.Send($HostName, 700)
                if ($reply -and $reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) { $values.Add([int]$reply.RoundtripTime) | Out-Null }
            } catch {}
        }
        if ($values.Count -eq 0) { return [pscustomobject]@{ Ok = $false; Ms = 999999 } }
        $avg = ($values | Measure-Object -Average).Average
        return [pscustomobject]@{ Ok = $true; Ms = [int]$avg }
    } catch {
        return [pscustomobject]@{ Ok = $false; Ms = 999999 }
    }
}

function Test-NetworkCurlTarget {
    param([object]$Target)
    $tests = @(
        @{ Label = 'HTTP'; Args = @('--http1.1') },
        @{ Label = 'TLS1.2'; Args = @('--tlsv1.2', '--tls-max', '1.2') },
        @{ Label = 'TLS1.3'; Args = @('--tlsv1.3', '--tls-max', '1.3') }
    )
    $httpOk = 0
    $httpBad = 0
    $httpMs = 0
    foreach ($test in $tests) {
        try {
            [System.Windows.Forms.Application]::DoEvents()
            if ($script:CancelNetworkCheck) { break }
            $curlArgs = @('-I', '-s', '-m', '2', '-o', 'NUL', '-w', '%{http_code} %{time_total}') + $test.Args + @($Target.Url)
            $output = & curl.exe @curlArgs 2>&1
            $exitCode = $LASTEXITCODE
            $text = ($output | Out-String).Trim()
            if ($exitCode -eq 0 -and $text -match '(?<code>\d{3})\s+(?<time>[\d\.]+)$') {
                $httpOk++
                $httpMs += [int]([double]$matches['time'] * 1000)
            } else {
                $httpBad++
            }
        } catch {
            $httpBad++
        }
    }
    $hostName = Get-NetworkTargetHost -Target $Target
    $ping = Test-NetworkPing -HostName $hostName
    return [pscustomobject]@{
        Name = $Target.Name
        Priority = [int]$Target.Priority
        HttpOk = $httpOk
        HttpBad = $httpBad
        HttpMs = $httpMs
        PingOk = [bool]$ping.Ok
        PingMs = [int]$ping.Ms
    }
}

function Get-NetworkCheckBypasses {
    param([bool]$Fast)
    if (-not $Fast) { return @($script:Bypasses) }
    $patterns = @('Обход 12', 'ALT11', 'ALT12', 'ALT7', 'ALT4', 'ALT6', 'ALT5', 'ALT3', 'Обход 23')
    $selected = New-Object System.Collections.Generic.List[object]
    foreach ($pattern in $patterns) {
        $match = @($script:Bypasses | Where-Object { $_.Name -match $pattern -or $_.Label -match $pattern } | Select-Object -First 1)
        if ($match.Count -gt 0 -and -not ($selected | Where-Object { $_.Path -eq $match[0].Path })) { $selected.Add($match[0]) | Out-Null }
    }
    if ($selected.Count -lt 5) {
        foreach ($item in $script:Bypasses) {
            if ($selected.Count -ge 9) { break }
            if (-not ($selected | Where-Object { $_.Path -eq $item.Path })) { $selected.Add($item) | Out-Null }
        }
    }
    return @($selected | Select-Object -First 9)
}

function Get-SiteCheckTargets {
    $targets = New-Object System.Collections.Generic.List[object]
    $seen = @{}
    $listsDir = Join-Path $Root 'lists'
    if (Test-Path -LiteralPath $listsDir) {
        $files = Get-ChildItem -LiteralPath $listsDir -Filter 'list*.txt' -File | Where-Object { $_.Name -notmatch 'exclude' }
        foreach ($file in $files) {
            foreach ($line in (Get-Content -LiteralPath $file.FullName -Encoding UTF8)) {
                $domain = $line.Trim().ToLowerInvariant()
                if (-not $domain -or $domain.StartsWith('#') -or $domain -eq 'domain.example.abc') { continue }
                if ($domain -match '[*/\s]' -or $domain -notmatch '^[a-z0-9.-]+\.[a-z]{2,}$') { continue }
                if ($seen.ContainsKey($domain)) { continue }
                $seen[$domain] = $true
                $targets.Add([pscustomobject]@{ Name = $domain; Host = $domain; Url = ('https://' + $domain + '/') })
            }
        }
    }
    return @($targets | Sort-Object Host)
}

function Test-TcpPort {
    param([string]$Host, [int]$Port = 443, [int]$TimeoutMs = 3000)
    $connected = $false
    try {
        foreach ($address in [System.Net.Dns]::GetHostAddresses($Host)) {
            $client = New-Object System.Net.Sockets.TcpClient($address.AddressFamily)
            try {
                $async = $client.BeginConnect($address, $Port, $null, $null)
                if ($async.AsyncWaitHandle.WaitOne($TimeoutMs, $false)) {
                    $client.EndConnect($async)
                    $connected = $true
                    break
                }
            } catch {
            } finally {
                $client.Close()
            }
        }
    } catch {
        $connected = $false
    }
    return [bool]$connected
}

function Add-SiteResult {
    param([string]$Text, [object]$Color)
    if ($siteResultsBox) {
        $siteResultsBox.SelectionColor = $Color
        $siteResultsBox.AppendText($Text + "`r`n")
        $siteResultsBox.ScrollToCaret()
    }
    try { Add-Content -LiteralPath $SiteCheckFile -Value $Text -Encoding UTF8 } catch {}
    Add-Log $Text $Color $false
}

function Reset-SiteCheckOutput {
    param([string]$Title)
    $siteResultsBox.Clear()
    $header = @(
        'Azapret site check',
        ('Time: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')),
        ('Mode: ' + $Title),
        ''
    )
    try { Set-Content -LiteralPath $SiteCheckFile -Value $header -Encoding UTF8 } catch {}
}

function Convert-ToSiteTarget {
    param([string]$InputText)
    $value = $InputText.Trim()
    if (-not $value) { return $null }
    if ($value -notmatch '^[a-zA-Z][a-zA-Z0-9+.-]*://') { $value = 'https://' + $value.Trim('/') + '/' }
    try {
        $uri = [System.Uri]$value
        if (-not $uri.Host) { return $null }
        return [pscustomobject]@{ Name = $uri.Host.ToLowerInvariant(); Host = $uri.Host.ToLowerInvariant(); Url = $uri.AbsoluteUri }
    } catch {
        return $null
    }
}

function Test-SiteTarget {
    param([object]$Target)
    $dnsOk = $false
    try { $dnsOk = @([System.Net.Dns]::GetHostAddresses($Target.Host)).Count -gt 0 } catch {}
    $tcpOk = [bool]($(if ($dnsOk) { Test-TcpPort -Host $Target.Host -Port 443 } else { $false }))
    $http = Test-UrlFast -Url $Target.Url
    $blockReason = Get-BlockPageReason -Body $http.Body
    $isTlsError = (($http.Error -match 'SSL/TLS') -or ($http.Error -match 'trust') -or ($http.Error -match 'certificate') -or ($http.Error -match 'довер'))
    $isGeoIpDeny = [bool]($http.Ok -and [int]$http.Code -eq 403 -and $http.Body -match '(?i)page forbidden|forbidden|your ip|service nodes')
    $status = if ($blockReason) { 'BLOCK PAGE / INTERCEPT' } elseif ($isGeoIpDeny) { 'REAL SERVER 403 / GEO-IP DENY' } elseif ($http.Ok -and [int]$http.Code -ge 400) { "REAL SERVER $($http.Code)" } elseif ($http.Ok) { 'OK' } elseif ($isTlsError) { 'TLS/CERT WARN' } elseif ($tcpOk) { 'TCP OK / HTTPS FAIL' } elseif ($dnsOk) { 'DNS OK / TCP FAIL' } else { 'DNS FAIL' }
    $details = if ($blockReason) { "matched: $blockReason" } elseif ($http.Ok) { "HTTP $($http.Code), $($http.Ms) ms" } elseif ($http.Error) { $http.Error } else { '' }
    return [pscustomobject]@{ Text = ("{0}: {1} | DNS={2} TCP443={3} | {4}" -f $Target.Name, $status, ([bool]$dnsOk).ToString(), ([bool]$tcpOk).ToString(), $details); Ok = [bool]($http.Ok -and -not $blockReason -and [int]$http.Code -lt 400); Warn = [bool]($blockReason -or $isGeoIpDeny -or ($http.Ok -and [int]$http.Code -ge 400) -or $isTlsError -or $tcpOk) }
}

function Run-OneSiteCheck {
    $target = Convert-ToSiteTarget -InputText $siteInputBox.Text
    if (-not $target) { return }
    Reset-SiteCheckOutput 'single site'
    Add-Log (Tr 'siteCheckStart')
    $okColor = [System.Drawing.Color]::FromArgb(34, 197, 94)
    $warnColor = [System.Drawing.Color]::FromArgb(245, 158, 11)
    $badColor = [System.Drawing.Color]::FromArgb(248, 113, 113)
    Add-SiteResult ("File: $SiteCheckFile") $warnColor
    $result = Test-SiteTarget -Target $target
    $color = if ($result.Ok) { $okColor } elseif ($result.Warn) { $warnColor } else { $badColor }
    Add-SiteResult $result.Text $color
    Add-SiteResult (Tr 'siteCheckDone') $okColor
}

function Run-SiteCheck {
    Add-Log (Tr 'siteCheckStart')
    Reset-SiteCheckOutput 'all sites'
    $okColor = [System.Drawing.Color]::FromArgb(34, 197, 94)
    $warnColor = [System.Drawing.Color]::FromArgb(245, 158, 11)
    $badColor = [System.Drawing.Color]::FromArgb(248, 113, 113)
    $targets = @(Get-SiteCheckTargets)
    Add-SiteResult ("File: $SiteCheckFile") $warnColor
    Add-SiteResult ("Targets: $($targets.Count)") $warnColor
    foreach ($target in $targets) {
        $result = Test-SiteTarget -Target $target
        $color = if ($result.Ok) { $okColor } elseif ($result.Warn) { $warnColor } else { $badColor }
        Add-SiteResult $result.Text $color
    }
    Add-SiteResult (Tr 'siteCheckDone') $okColor
}

function Get-WinwsProcess {
    @(Get-CimInstance Win32_Process -Filter "name = 'winws.exe'" -ErrorAction SilentlyContinue)
}

function Set-BypassStatus {
    param([string]$Key, [object]$Color)
    if (-not $statusLabel) { return }
    $statusLabel.Text = Tr $Key
    $statusLabel.ForeColor = $Color
}

function Verify-BypassStarted {
    Start-Sleep -Seconds 3
    $procs = @(Get-WinwsProcess)
    if ($procs.Count -gt 0) {
        $script:BypassRunning = $true
        Set-BypassStatus 'statusRunning' ([System.Drawing.Color]::FromArgb(34, 197, 94))
        Apply-Language
        Add-SuccessLog ((Tr 'processStarted') + ' ' + (($procs | ForEach-Object { $_.ProcessId }) -join ', '))
    } else {
        $script:BypassRunning = $false
        Set-BypassStatus 'statusFailed' ([System.Drawing.Color]::FromArgb(239, 68, 68))
        Apply-Language
        Add-Log (Tr 'processMissing') ([System.Drawing.Color]::FromArgb(248, 113, 113)) $true
    }
}

function Stop-NetworkCheck {
    if (-not $script:IsNetworkChecking) { return }
    $script:CancelNetworkCheck = $true
    Add-Log (Tr 'networkStopped') ([System.Drawing.Color]::FromArgb(245, 158, 11)) $true
}

function Update-NetworkCheckButtons {
    $text = if ($script:IsNetworkChecking) { Tr 'stopNetworkCheck' } else { Tr 'checkNetwork' }
    if ($checkButton) { $checkButton.Text = $text }
    if ($fastCheckButton) { $fastCheckButton.Text = if ($script:IsNetworkChecking) { Tr 'stopNetworkCheck' } else { Tr 'fastCheckNetwork' } }
}

function Wait-NetworkCheck {
    param([int]$Seconds)
    $until = (Get-Date).AddSeconds($Seconds)
    while ((Get-Date) -lt $until) {
        [System.Windows.Forms.Application]::DoEvents()
        if ($script:CancelNetworkCheck) { return $false }
        Start-Sleep -Milliseconds 150
    }
    return (-not $script:CancelNetworkCheck)
}

function Run-NetworkCheck {
    param([bool]$Fast = $false)
    if ($script:IsNetworkChecking) {
        Stop-NetworkCheck
        return
    }
    $script:IsNetworkChecking = $true
    $script:CancelNetworkCheck = $false
    Update-NetworkCheckButtons
    Add-Log (Tr 'networkStart')
    try {
        $targets = Get-NetworkTargets -Fast $Fast
        $checkBypasses = @(Get-NetworkCheckBypasses -Fast $Fast)
        if ($checkBypasses.Count -eq 0) {
            Add-Log (Tr 'noBypasses')
            return
        }

        $results = New-Object System.Collections.Generic.List[object]
        $total = $checkBypasses.Count
        $index = 0
        foreach ($item in $checkBypasses) {
            [System.Windows.Forms.Application]::DoEvents()
            if ($script:CancelNetworkCheck) { break }
            $index++
            $percent = [int](($index / [Math]::Max(1, $total)) * 100)
            Add-Log ("[$index/$total] $percent%: $($item.Label) - $($item.Name)")
            Stop-BypassHidden
            if (-not (Wait-NetworkCheck -Seconds 1)) { break }
            Start-ElevatedHiddenBatch -FilePath $item.Path
            if (-not (Wait-NetworkCheck -Seconds 4)) { break }

            $httpOk = 0
            $httpBad = 0
            $httpMs = 0
            $pingOk = 0
            $pingBad = 0
            $pingMs = 0
            $primaryBad = 0
            $primaryPingMs = 999999
            $primaryHttpMs = 0
            foreach ($target in $targets) {
                [System.Windows.Forms.Application]::DoEvents()
                if ($script:CancelNetworkCheck) { break }
                Add-Log "  Проверяю $($target.Name)..."
                $result = Test-NetworkCurlTarget -Target $target
                $httpOk += [int]$result.HttpOk
                $httpBad += [int]$result.HttpBad
                $httpMs += [int]$result.HttpMs
                if ($result.PingOk) { $pingOk++; $pingMs += [int]$result.PingMs } else { $pingBad++ }
                if ([int]$target.Priority -eq 1) {
                    $primaryBad += [int]$result.HttpBad
                    $primaryHttpMs += [int]$result.HttpMs
                    if ($result.PingOk -and [int]$result.PingMs -lt $primaryPingMs) { $primaryPingMs = [int]$result.PingMs }
                }
                $pingText = if ($result.PingOk) { "$($result.PingMs) ms" } else { 'Timeout' }
                Add-Log "  $($target.Name): HTTP OK $($result.HttpOk)/3, Ping $pingText."
            }
            if ($script:CancelNetworkCheck) { break }
            $avgHttp = if ($httpOk -gt 0) { [int]($httpMs / $httpOk) } else { 999999 }
            $avgPing = if ($pingOk -gt 0) { [int]($pingMs / $pingOk) } else { 999999 }
            $primaryPingBucket = [int]([Math]::Floor($primaryPingMs / 10))
            $avgPingBucket = [int]([Math]::Floor($avgPing / 10))
            Add-Log ("  Итог: HTTP OK=$httpOk, HTTP ошибок=$httpBad, Ping OK=$pingOk, Discord ping=$primaryPingMs ms, средний ping=$avgPing ms.")
            $results.Add([pscustomobject]@{ Item = $item; CandidateIndex = $index; HttpOkSort = -$httpOk; HttpBad = $httpBad; AvgHttp = $avgHttp; PingOkSort = -$pingOk; PingBad = $pingBad; AvgPing = $avgPing; AvgPingBucket = $avgPingBucket; PrimaryBad = $primaryBad; PrimaryPingMs = $primaryPingMs; PrimaryPingBucket = $primaryPingBucket; PrimaryHttpMs = $primaryHttpMs }) | Out-Null
        }

        Stop-BypassHidden
        if ($script:CancelNetworkCheck) { return }
        $best = $results | Sort-Object PrimaryBad, HttpBad, PrimaryPingBucket, AvgPingBucket, CandidateIndex, PrimaryPingMs, AvgPing, HttpOkSort, AvgHttp | Select-Object -First 1
        if ($best) {
            $combo.SelectedItem = $best.Item.Label
            Save-Settings
            Add-RecommendLog ((Tr 'bestChoice') + ': ' + $best.Item.Label + ". Discord ping: $($best.PrimaryPingMs) ms, средний ping: $($best.AvgPing) ms, HTTP ошибок: $($best.HttpBad).")
        }
    } catch {
        Add-Log ("Ошибка проверки сети: $($_.Exception.Message)") ([System.Drawing.Color]::FromArgb(248, 113, 113)) $true
    } finally {
        $script:IsNetworkChecking = $false
        $script:CancelNetworkCheck = $false
        Update-NetworkCheckButtons
    }
}

function Test-AccessAfterStart {
    Add-Log (Tr 'accessCheckStart')
    Start-Sleep -Seconds 4
    $bad = 0
    foreach ($target in (Get-NetworkTargets)) {
        $result = Test-UrlFast -Url $target.Url
        if ($result.Ok) {
            Add-Log "$($target.Name): OK, HTTP $($result.Code), $($result.Ms) ms."
        } else {
            $bad++
            Add-Log "$($target.Name): $(Tr 'checkError') - $($result.Error)"
        }
    }
    if ($bad -eq 0) {
        Add-RecommendLog (Tr 'accessReady')
    } else {
        Add-RecommendLog (Tr 'accessProblems')
    }
}

function Check-Updates {
    Add-Log (Tr 'updatesStart')
    Add-Log (Tr 'updatesOk')
}

function Run-SelectedBypass {
    param([bool]$SkipPreStop = $false)
    if ($script:BypassRunning) {
        Stop-BypassHidden
        $script:BypassRunning = $false
        Apply-Language
        Set-BypassStatus 'statusStopped' ([System.Drawing.Color]::FromArgb(148, 163, 184))
        Add-SuccessLog (Tr 'stop')
        return
    }

    $selectedLabel = [string]$combo.SelectedItem
    $selected = $script:Bypasses | Where-Object { $_.Label -eq $selectedLabel } | Select-Object -First 1
    if (-not $selected) {
        Add-Log (Tr 'noBypassSelected')
        return
    }
    if ($stopCheck.Checked -and -not $SkipPreStop) {
        Stop-BypassHidden
        Start-Sleep -Milliseconds 900
    }
    $script:Settings.lastBypass = $selected.Label
    Save-Settings
    Add-Log ((Tr 'launching') + ' ' + $selected.Label + ': ' + $selected.Name + '.')
    Set-BypassStatus 'statusStarting' ([System.Drawing.Color]::FromArgb(234, 179, 8))
    Start-ElevatedHiddenBatch -FilePath $selected.Path
    $script:BypassRunning = $true
    Apply-Language
    Add-SuccessLog (Tr 'startHidden')
    $script:StartVerifyTimer = New-Object System.Windows.Forms.Timer
    $script:StartVerifyTimer.Interval = 3000
    $script:StartVerifyTimer.Add_Tick({ $this.Stop(); $this.Dispose(); Verify-BypassStarted })
    $script:StartVerifyTimer.Start()
}

function Restart-SelectedBypass {
    $selectedLabel = [string]$combo.SelectedItem
    $selected = $script:Bypasses | Where-Object { $_.Label -eq $selectedLabel } | Select-Object -First 1
    if (-not $selected) {
        Add-Log (Tr 'noBypassSelected')
        return
    }
    Add-Log (Tr 'restartBypass')
    Stop-BypassHidden
    Start-Sleep -Milliseconds 900
    $script:BypassRunning = $false
    Run-SelectedBypass -SkipPreStop $true
}

function Run-ExtraSetup {
    return
    Add-Log (Tr 'extraStart')
    Start-ElevatedFile -FilePath (Get-ExtraFile 'extra-tools.bat')
}

function Install-SelectedBypassService {
    $selectedLabel = [string]$combo.SelectedItem
    $selected = $script:Bypasses | Where-Object { $_.Label -eq $selectedLabel } | Select-Object -First 1
    if (-not $selected) {
        Add-Log (Tr 'noBypassSelected')
        return
    }

    Save-Settings
    Add-Log (Tr 'autostartInstalling')
    $choice = [int]$selected.Index
    if (-not (Start-ElevatedServiceInstall -Choice $choice -Wait $true)) { return }
    $ok = $false
    for ($i = 0; $i -lt 40; $i++) {
        if (Test-ZapretServiceRunning) { $ok = $true; break }
        Start-Sleep -Milliseconds 750
    }
    if ($ok) {
        $script:BypassRunning = $true
        Set-BypassStatus 'statusRunning' ([System.Drawing.Color]::FromArgb(34, 197, 94))
        Add-SuccessLog (Tr 'autostartDone')
    } else {
        $script:BypassRunning = $false
        Set-BypassStatus 'statusFailed' ([System.Drawing.Color]::FromArgb(239, 68, 68))
        Add-Log 'Автостарт не подтвердился: служба zapret не запущена. Проверьте, появилось ли окно UAC, и пришлите runtime\service-actions.log.' ([System.Drawing.Color]::FromArgb(248, 113, 113)) $true
    }
}

function Disable-Autostart {
    $startupCheck.Checked = $false
    $script:Settings.startWithWindows = $false
    Set-WindowsStartup -Enabled $false
    Save-Settings
    Add-SuccessLog (Tr 'autostartRemoved')
    Open-ServiceChoice 2
}

function Open-ServiceManager {
    Add-Log (Tr 'serviceOpen')
    $cmd = Join-Path $env:SystemRoot 'System32\cmd.exe'
    $quote = [char]34
    $args = '/k cd /d ' + $quote + $Root + $quote + ' ' + [char]38 + ' service.bat admin'
    Start-ElevatedFile -FilePath $cmd -Arguments $args
}

function Open-ServiceChoice {
    param([int]$Choice)
    Add-Log ((Tr 'serviceActionStart') + ": $Choice")
    Start-ElevatedHiddenCommand ('call service.bat admin_choice ' + $Choice)
}

function Stop-AllBypassAndServices {
    Add-Log ((Tr 'serviceActionStart') + ': STOP ALL')
    Start-ElevatedHiddenCommand 'taskkill /IM winws.exe /F >nul 2>&1 & net stop zapret >nul 2>&1 & sc delete zapret >nul 2>&1 & net stop WinDivert >nul 2>&1 & sc delete WinDivert >nul 2>&1 & net stop WinDivert14 >nul 2>&1 & sc delete WinDivert14 >nul 2>&1 & ipconfig /flushdns >nul 2>&1'
    Add-SuccessLog (Tr 'stopAllDone')
}

function Set-GameFilterMode {
    $dialog = New-Object System.Windows.Forms.Form
    $dialog.Text = Tr 'gameFilterAsk'
    $dialog.StartPosition = 'CenterParent'
    $dialog.Size = New-Object System.Drawing.Size(540, 310)
    $dialog.FormBorderStyle = 'FixedDialog'
    $dialog.MaximizeBox = $false
    $dialog.MinimizeBox = $false
    $dialog.BackColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
    $dialog.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)

    $title = New-Label -Text (Tr 'gameFilterAsk') -X 22 -Y 18 -Size 12 -Bold $true
    $title.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
    $dialog.Controls.Add($title)

    $options = @(
        @{ Choice = '0'; Mode = 'Off'; Text = 'Off (выключить игровой фильтр)' },
        @{ Choice = '1'; Mode = 'TCP + UDP'; Text = 'TCP + UDP (для большинства игр, максимальный охват)' },
        @{ Choice = '2'; Mode = 'TCP only'; Text = 'TCP only (если игра использует TCP/логин/лаунчер)' },
        @{ Choice = '3'; Mode = 'UDP only'; Text = 'UDP only (если нужен игровой трафик, голос, матчмейкинг)' }
    )
    $y = 58
    foreach ($option in $options) {
        $choiceValue = $option.Choice
        $modeValue = $option.Mode
        $button = New-Button -Text $option.Text -X 22 -Y $y -W 480 -H 34 -Click { $script:GameFilterDialogChoice = $choiceValue; $script:GameFilterDialogMode = $modeValue; Add-Log ((Tr 'gameFilterAsk') + ': ' + $modeValue); $dialog.Close() }.GetNewClosure()
        $dialog.Controls.Add($button)
        Set-ButtonTheme -Button $button -Accent $false
        $y += 44
    }
    $cancel = New-Button -Text 'Cancel' -X 390 -Y 236 -W 112 -H 34 -Click { $script:GameFilterDialogChoice = $null; $dialog.Close() }
    $dialog.Controls.Add($cancel)
    Set-ButtonTheme -Button $cancel -Accent $true

    $script:GameFilterDialogChoice = $null
    $script:GameFilterDialogMode = $null
    [void]$dialog.ShowDialog($form)
    $choice = $script:GameFilterDialogChoice
    if ($choice -notmatch '^[0-3]$') { return }
    $utilsDir = Join-Path $Root 'utils'
    if (-not (Test-Path -LiteralPath $utilsDir)) { New-Item -ItemType Directory -Path $utilsDir | Out-Null }
    $flag = Join-Path $utilsDir 'game_filter.enabled'
    if ($choice -eq '0') {
        Remove-Item -LiteralPath $flag -Force -ErrorAction SilentlyContinue
    } elseif ($choice -eq '1') {
        Set-Content -LiteralPath $flag -Value 'all' -Encoding ASCII
    } elseif ($choice -eq '2') {
        Set-Content -LiteralPath $flag -Value 'tcp' -Encoding ASCII
    } else {
        Set-Content -LiteralPath $flag -Value 'udp' -Encoding ASCII
    }
    Add-SuccessLog ((Tr 'gameFilterDone') + ' ' + $script:GameFilterDialogMode)
}

function Set-GameFilterUdpOnly {
    $utilsDir = Join-Path $Root 'utils'
    if (-not (Test-Path -LiteralPath $utilsDir)) { New-Item -ItemType Directory -Path $utilsDir | Out-Null }
    Set-Content -LiteralPath (Join-Path $utilsDir 'game_filter.enabled') -Value 'udp' -Encoding ASCII
    Add-RecommendLog 'Game Filter переключен в UDP only для CS/Faceit проверки.'
}

function Convert-ToCsServerTarget {
    param([string]$InputText)
    $value = ([string]$InputText).Trim()
    if (-not $value) { return $null }
    if ($value -match '^(.+):(\d+)$') {
        return [pscustomobject]@{ Host = $Matches[1].Trim(); Port = [int]$Matches[2] }
    }
    return [pscustomobject]@{ Host = $value; Port = 27015 }
}

function Test-CsQuickTarget {
    param([object]$Target)
    if (-not $Target) {
        Add-Log 'CS server не указан: проверка CS пропущена.' ([System.Drawing.Color]::FromArgb(245, 158, 11)) $true
        return [pscustomobject]@{ PingOk = $false; AvgMs = 999999; LossPct = 100; UdpSent = $false }
    }

    Add-Log "CS server: $($Target.Host):$($Target.Port)"
    try {
        $ping = @(Test-Connection -ComputerName $Target.Host -Count 4 -ErrorAction Stop)
        $avg = [math]::Round(($ping | Measure-Object -Property ResponseTime -Average).Average, 1)
        $loss = 100 - [math]::Round(($ping.Count / 4) * 100, 0)
        Add-Log "CS ping: OK avg=$avg ms, loss=$loss%."
        $pingOk = $true
    } catch {
        Add-Log "CS ping: FAIL или ICMP заблокирован - $($_.Exception.Message)" ([System.Drawing.Color]::FromArgb(248, 113, 113)) $true
        $pingOk = $false
        $avg = 999999
        $loss = 100
    }

    try {
        $client = [Net.Sockets.UdpClient]::new()
        $client.Client.SendTimeout = 2000
        $payload = [Text.Encoding]::ASCII.GetBytes('Azapret-CS2-UDP-probe')
        [void]$client.Send($payload, $payload.Length, $Target.Host, $Target.Port)
        $client.Close()
        Add-Log "CS UDP probe: SENT to $($Target.Host):$($Target.Port). Это не доказывает игровой connect, но показывает отправку UDP."
        $udpSent = $true
    } catch {
        Add-Log "CS UDP probe: FAIL - $($_.Exception.Message)" ([System.Drawing.Color]::FromArgb(248, 113, 113)) $true
        $udpSent = $false
    }

    return [pscustomobject]@{ PingOk = $pingOk; AvgMs = $avg; LossPct = $loss; UdpSent = $udpSent }
}

function Start-CsAutoTtlTest {
    param([string]$ServerText)
    $scriptPath = Join-Path (Join-Path $Root 'tools') 'test-cs-ttl-auto.ps1'
    if (-not (Test-Path -LiteralPath $scriptPath)) {
        Add-Log "AUTO TTL test script not found: $scriptPath" ([System.Drawing.Color]::FromArgb(248, 113, 113)) $true
        return
    }

    Set-GameFilterUdpOnly
    Add-RecommendLog 'AUTO TTL3-7: проверяю введенный CS IP по всем TTL и применяю лучший временно. Автостарт службы не переписывается.'
    $ps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    $args = '-NoProfile -ExecutionPolicy Bypass -File "' + $scriptPath.Replace('"', '\"') + '" -CsServer "' + ([string]$ServerText).Replace('"', '\"') + '" -ApplyBest'
    Start-ElevatedFile -FilePath $ps -Arguments $args
    Add-Log 'AUTO TTL3-7: после завершения смотри лог app\test-results\cs-ttl-auto-*.txt.'
}

function Run-CsTtlIpCheck {
    param(
        [string]$ServerText,
        [object[]]$Profiles
    )

    $target = Convert-ToCsServerTarget -InputText $ServerText
    if (-not $target) {
        Add-Log 'CS/Faceit: сначала укажите CS server IP:PORT.' ([System.Drawing.Color]::FromArgb(248, 113, 113)) $true
        return $null
    }

    Set-GameFilterUdpOnly
    Add-RecommendLog "CS/Faceit IP check: проверяю $($target.Host):$($target.Port) по всем FACEIT TTL профилям. Основной обход/автостарт не останавливается."

    $results = New-Object System.Collections.Generic.List[object]
    try {
        foreach ($profile in $Profiles) {
            if ($profile.Name -notmatch 'TTL(\d+)') { continue }
            $ttl = [int]$Matches[1]
            Add-Log "================ TTL$ttl ================"
            Add-Log "CS/Faceit: временно запускаю $($profile.Name) совместно с основным обходом."
            [System.Windows.Forms.Application]::DoEvents()
            Stop-CsFaceitBypassHidden
            Start-Sleep -Milliseconds 900
            [void](Start-CsFaceitProfileJoint -Profile $profile)
            Start-Sleep -Seconds 5
            $test = Test-CsQuickTarget -Target $target
            $results.Add([pscustomobject]@{ TTL = $ttl; Profile = $profile; PingOk = $test.PingOk; AvgMs = $test.AvgMs; LossPct = $test.LossPct; UdpSent = $test.UdpSent }) | Out-Null
            [System.Windows.Forms.Application]::DoEvents()
        }
    } finally {
        Stop-CsFaceitBypassHidden
        if (Test-ZapretServiceRunning) {
            $script:BypassRunning = $true
            Set-BypassStatus 'statusRunning' ([System.Drawing.Color]::FromArgb(34, 197, 94))
            Apply-Language
            Add-SuccessLog 'Основной обход/служба остались запущены.'
        }
    }

    Add-Log '================ CS/Faceit TTL summary ================'
    foreach ($item in $results) {
        Add-Log "TTL$($item.TTL): pingOk=$($item.PingOk), avg=$($item.AvgMs) ms, loss=$($item.LossPct)%, udpSent=$($item.UdpSent)."
    }
    $best = $results | Sort-Object @{ Expression = { if ($_.PingOk) { 0 } else { 1 } } }, LossPct, AvgMs, TTL | Select-Object -First 1
    if ($best) {
        Add-RecommendLog "Рекомендация для этого IP: FACEIT CS2 TTL$($best.TTL), ping $($best.AvgMs) ms, loss $($best.LossPct)%. Выберите этот TTL и нажмите «Запустить выбранный TTL»."
        return $best
    } else {
        Add-Log 'CS/Faceit: не удалось выбрать TTL.' ([System.Drawing.Color]::FromArgb(248, 113, 113)) $true
        return $null
    }
}

function Run-CsQuickCheck {
    $profiles = @($script:Bypasses | Where-Object { $_.Name -like 'general (FACEIT CS2 TTL*).bat' } | Sort-Object Name)
    if ($profiles.Count -eq 0) {
        Add-Log 'FACEIT CS2 TTL профили не найдены в app\bypasses.' ([System.Drawing.Color]::FromArgb(248, 113, 113)) $true
        return
    }

    $dialog = New-Object System.Windows.Forms.Form
    $dialog.Text = 'CS/Faceit quick check'
    $dialog.StartPosition = 'CenterParent'
    $dialog.Size = New-Object System.Drawing.Size(620, 360)
    $dialog.FormBorderStyle = 'FixedDialog'
    $dialog.MaximizeBox = $false
    $dialog.MinimizeBox = $false
    $dialog.BackColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
    $dialog.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)

    $title = New-Label -Text 'CS/Faceit quick check' -X 24 -Y 18 -Size 14 -Bold $true
    $title.ForeColor = [System.Drawing.Color]::FromArgb(125, 211, 252)
    $dialog.Controls.Add($title)

    $hint = New-Object System.Windows.Forms.Label
    $hint.Text = '1) Введите CS/FACEIT server IP:PORT. 2) Нажмите «Проверить IP по всем TTL». 3) Выберите рекомендованный TTL и нажмите «Запустить выбранный TTL». Основной обход/автостарт остается работать совместно.'
    $hint.Location = New-Object System.Drawing.Point(24, 52)
    $hint.Size = New-Object System.Drawing.Size(560, 70)
    $hint.Font = New-Object System.Drawing.Font('Segoe UI', 9.5)
    $hint.ForeColor = [System.Drawing.Color]::FromArgb(203, 213, 225)
    $hint.BackColor = $dialog.BackColor
    $dialog.Controls.Add($hint)

    $serverLabel = New-Label -Text 'CS server IP:PORT' -X 24 -Y 132 -Size 10 -Bold $true
    $serverLabel.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
    $dialog.Controls.Add($serverLabel)

    $serverBox = New-Object System.Windows.Forms.TextBox
    $serverBox.Location = New-Object System.Drawing.Point(24, 156)
    $serverBox.Size = New-Object System.Drawing.Size(250, 28)
    $serverBox.Text = '217.168.247.79:27345'
    $dialog.Controls.Add($serverBox)

    $ttlLabel = New-Label -Text 'TTL профиль' -X 314 -Y 132 -Size 10 -Bold $true
    $ttlLabel.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
    $dialog.Controls.Add($ttlLabel)

    $ttlBox = New-Object System.Windows.Forms.ComboBox
    $ttlBox.DropDownStyle = 'DropDownList'
    $ttlBox.Location = New-Object System.Drawing.Point(314, 156)
    $ttlBox.Size = New-Object System.Drawing.Size(260, 28)
    foreach ($profile in $profiles) { [void]$ttlBox.Items.Add($profile.Name) }
    $default = $profiles | Where-Object { $_.Name -like '*TTL5*' } | Select-Object -First 1
    if ($default) { $ttlBox.SelectedItem = $default.Name } else { $ttlBox.SelectedIndex = 0 }
    $dialog.Controls.Add($ttlBox)

    $resultLabel = New-Object System.Windows.Forms.Label
    $resultLabel.Text = 'Результат появится здесь и в журнале справа.'
    $resultLabel.Location = New-Object System.Drawing.Point(24, 196)
    $resultLabel.Size = New-Object System.Drawing.Size(560, 38)
    $resultLabel.Font = New-Object System.Drawing.Font('Segoe UI', 9.5, [System.Drawing.FontStyle]::Bold)
    $resultLabel.ForeColor = [System.Drawing.Color]::FromArgb(203, 213, 225)
    $resultLabel.BackColor = $dialog.BackColor
    $dialog.Controls.Add($resultLabel)

    $check = New-Button -Text 'Проверить IP по всем TTL' -X 24 -Y 252 -W 230 -H 38 -Click {
        $check.Enabled = $false
        $start.Enabled = $false
        $resultLabel.Text = 'Идет проверка IP по всем FACEIT TTL...'
        [System.Windows.Forms.Application]::DoEvents()
        Add-Log "CS/Faceit check: server=$([string]$serverBox.Text), action=check-all-ttl."
        $best = Run-CsTtlIpCheck -ServerText ([string]$serverBox.Text) -Profiles $profiles
        if ($best) {
            $recommendedName = $best.Profile.Name
            $ttlBox.SelectedItem = $recommendedName
            $resultLabel.Text = "Лучший для этого IP: TTL$($best.TTL), ping $($best.AvgMs) ms, loss $($best.LossPct)%. Теперь нажмите «Запустить выбранный TTL»."
        } else {
            $resultLabel.Text = 'Не удалось выбрать TTL. Смотрите журнал справа.'
        }
        $check.Enabled = $true
        $start.Enabled = $true
    }.GetNewClosure() -Accent $false
    $dialog.Controls.Add($check)
    Set-ButtonTheme -Button $check -Accent $false

    $start = New-Button -Text 'Запустить выбранный TTL' -X 270 -Y 252 -W 200 -H 38 -Click {
        $selectedText = [string]$ttlBox.SelectedItem
        $serverText = [string]$serverBox.Text
        Add-Log "CS/Faceit check: server=$serverText, action=start-selected, profile=$selectedText."
        $selectedProfile = $profiles | Where-Object { $_.Name -eq $selectedText } | Select-Object -First 1
        if (-not $selectedProfile) {
            $resultLabel.Text = 'Выберите TTL профиль.'
            return
        }

        Set-GameFilterUdpOnly
        Add-RecommendLog 'CS/Faceit профиль запускается временно совместно с основным обходом. Автостарт службы не переписывается.'
        Stop-CsFaceitBypassHidden
        Start-Sleep -Milliseconds 900

        Add-Log "CS/Faceit: запускаю $($selectedProfile.Name)."
        Set-BypassStatus 'statusStarting' ([System.Drawing.Color]::FromArgb(234, 179, 8))
        [void](Start-CsFaceitProfileJoint -Profile $selectedProfile)
        $script:BypassRunning = $true
        Apply-Language
        Start-Sleep -Seconds 5
        Verify-BypassStarted

        $result = Test-CsQuickTarget -Target (Convert-ToCsServerTarget -InputText $serverText)
        if ($result.PingOk -and $result.UdpSent) {
            $resultLabel.Text = "$($selectedProfile.Name) запущен временно. Ping $($result.AvgMs) ms, loss $($result.LossPct)%."
            Add-RecommendLog "CS/Faceit: $($selectedProfile.Name) применен. Ping $($result.AvgMs) ms, loss $($result.LossPct)%. Проверьте connect/loss в игре."
        } else {
            $resultLabel.Text = "$($selectedProfile.Name) запущен, но проверка IP не подтвердилась. Смотрите журнал."
        }
    }.GetNewClosure() -Accent $true
    $dialog.Controls.Add($start)
    Set-ButtonTheme -Button $start -Accent $true

    $stopTtl = New-Button -Text 'Стоп TTL' -X 482 -Y 252 -W 80 -H 38 -Click {
        Stop-CsFaceitBypassHidden
        $resultLabel.Text = 'FACEIT TTL остановлен. Основной обход не тронут.'
        Add-SuccessLog 'FACEIT TTL остановлен. Основной обход не тронут.'
    }.GetNewClosure()
    $dialog.Controls.Add($stopTtl)
    Set-ButtonTheme -Button $stopTtl -Accent $false

    $cancel = New-Button -Text 'X' -X 570 -Y 252 -W 34 -H 38 -Click { $dialog.Close() }.GetNewClosure()
    $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $dialog.Controls.Add($cancel)
    Set-ButtonTheme -Button $cancel -Accent $false
    $dialog.CancelButton = $cancel

    [void]$dialog.ShowDialog($form)
}

function Switch-IpSetFilter {
    $listFile = Join-Path (Join-Path $Root 'lists') 'ipset-all.txt'
    $backupFile = $listFile + '.backup'
    $newMode = ''
    if (-not (Test-Path -LiteralPath (Split-Path -Parent $listFile))) { New-Item -ItemType Directory -Path (Split-Path -Parent $listFile) | Out-Null }
    $content = @()
    if (Test-Path -LiteralPath $listFile) { $content = @(Get-Content -LiteralPath $listFile -ErrorAction SilentlyContinue | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) }
    $isNone = ($content.Count -eq 1 -and ([string]$content[0]).Trim() -eq '203.0.113.113/32')
    $isAny = ($content.Count -eq 0)
    if (-not $isNone -and -not $isAny) {
        Copy-Item -LiteralPath $listFile -Destination $backupFile -Force
        Set-Content -LiteralPath $listFile -Value '203.0.113.113/32' -Encoding ASCII
        $newMode = 'None (выключен: IPSet-правила почти ничего не задевают)'
    } elseif ($isNone) {
        Set-Content -LiteralPath $listFile -Value '' -Encoding ASCII
        $newMode = 'Any (пустой список: IPSet-правила применяются максимально широко)'
    } elseif (Test-Path -LiteralPath $backupFile) {
        Copy-Item -LiteralPath $backupFile -Destination $listFile -Force
        $newMode = 'Loaded (включен: используется список ipset-all.txt)'
    } else {
        Add-Log 'IPSet: нет backup для восстановления. Нажмите «Обновить список IPSet».' ([System.Drawing.Color]::FromArgb(248, 113, 113)) $true
        return
    }
    Add-SuccessLog ((Tr 'ipsetDone') + ' ' + $newMode)
}

function Update-IpSetList {
    Add-Log ((Tr 'serviceActionStart') + ': IPSet update')
    $listFile = Join-Path (Join-Path $Root 'lists') 'ipset-all.txt'
    $url = 'https://raw.githubusercontent.com/Flowseal/zapret-discord-youtube/refs/heads/main/.service/ipset-service.txt'
    try {
        Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 20 -OutFile $listFile
        Add-SuccessLog (Tr 'ipsetUpdateDone')
    } catch {
        Add-Log ((Tr 'updatesFail') + ": $($_.Exception.Message)")
    }
}

function Run-ServiceDiagnosticsVisible {
    Add-Log ((Tr 'serviceActionStart') + ': diagnostics')
    Start-ElevatedFile -FilePath (Join-Path $Root 'service.bat') -Arguments 'admin_choice 10'
    Add-SuccessLog (Tr 'diagnosticsDone')
}

function Run-Action {
    param([string]$Action)
    switch ($Action) {
        'install' { Install-SelectedBypassService }
        'remove' { Stop-AllBypassAndServices }
        'restart' { Restart-SelectedBypass }
        'copyLog' { Copy-LogToClipboard }
        'status' { Open-ServiceChoice 3 }
        'game' { Set-GameFilterMode }
        'ipset' { Switch-IpSetFilter }
        'autoUpdate' { Open-ServiceChoice 6 }
        'update' { Update-IpSetList }
        'hosts' { Open-ServiceChoice 8 }
        'serviceUpdates' { Open-ServiceChoice 9 }
        'diagnostics' { Run-ServiceDiagnosticsVisible }
        'csQuickCheck' { Run-CsQuickCheck }
        'csStopTtl' { Stop-CsFaceitBypassHidden; Add-SuccessLog 'FACEIT TTL остановлен. Основной обход не тронут.' }
        'dnsRepair' { Repair-SystemDns }
        'dnsRestore' { Restore-SystemDns }
        'tgAppFix' { Invoke-TelegramAppFix }
        'tgStopProxy' { Stop-LocalTelegramProxy }
        'tgProxyChannel' { Show-TelegramProxyChannelPopup }
        'tgDownload' { Open-TelegramDownload }
        'clearCache' {
            if (-not (Show-DarkConfirm -Message (Tr 'cacheConfirm'))) { return }
            $cacheBat = Join-Path $Root 'clear-browser-site-cache.bat'
            Add-Log (Tr 'clearCacheStart')
            Start-ElevatedHiddenBatch -FilePath $cacheBat
        }
        'test' {
            $testBat = $null
            if ($testBat -and (Test-Path -LiteralPath $testBat)) {
                Add-Log (Tr 'safeTest')
                Start-ElevatedFile -FilePath $testBat
            } else {
                Add-Log (Tr 'builtinTest')
                Run-NetworkCheck
            }
        }
    }
}

function New-Label {
    param([string]$Text, [int]$X, [int]$Y, [int]$Size = 10, [bool]$Bold = $false)
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Text
    $label.AutoSize = $true
    $style = if ($Bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
    $label.Font = New-Object System.Drawing.Font('Segoe UI', $Size, $style)
    $label.Location = New-Object System.Drawing.Point($X, $Y)
    return $label
}

function New-RoundRectPath {
    param([System.Drawing.Rectangle]$Rect, [int]$Radius)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $diameter = $Radius * 2
    $path.AddArc($Rect.X, $Rect.Y, $diameter, $diameter, 180, 90)
    $path.AddArc($Rect.Right - $diameter, $Rect.Y, $diameter, $diameter, 270, 90)
    $path.AddArc($Rect.Right - $diameter, $Rect.Bottom - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($Rect.X, $Rect.Bottom - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    return $path
}

function New-Button {
    param([string]$Text, [int]$X, [int]$Y, [int]$W, [int]$H, [scriptblock]$Click, [bool]$Accent = $false)
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Location = New-Object System.Drawing.Point($X, $Y)
    $button.Size = New-Object System.Drawing.Size($W, $H)
    $button.FlatStyle = 'Flat'
    $button.UseVisualStyleBackColor = $false
    $button.FlatAppearance.BorderSize = 0
    $button.Font = New-Object System.Drawing.Font('Segoe UI', 9.5, [System.Drawing.FontStyle]::Bold)
    $button.Cursor = [System.Windows.Forms.Cursors]::Hand
    $button.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
    $button.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
    $button.Add_Paint({
        param($sender, $e)
        $e.Graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $e.Graphics.Clear($sender.Parent.BackColor)
        $rect = New-Object System.Drawing.Rectangle(0, 0, ($sender.Width - 1), ($sender.Height - 1))
        $path = New-RoundRectPath -Rect $rect -Radius 14
        if ($sender.Tag -and $sender.Tag.Glow) {
            $glowRect = New-Object System.Drawing.Rectangle(1, 1, ($sender.Width - 3), ($sender.Height - 3))
            $glowPath = New-RoundRectPath -Rect $glowRect -Radius 14
            $glowBrush = New-Object System.Drawing.SolidBrush($sender.Tag.Glow)
            $e.Graphics.FillPath($glowBrush, $glowPath)
            $glowBrush.Dispose(); $glowPath.Dispose()
        }
        $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $sender.BackColor, $(if ($sender.Tag -and $sender.Tag.Gradient) { $sender.Tag.Gradient } else { $sender.BackColor }), [System.Drawing.Drawing2D.LinearGradientMode]::Horizontal)
        $e.Graphics.FillPath($brush, $path)
        $brush.Dispose()
        if ($sender.Tag -and $sender.Tag.Border) {
            $pen = New-Object System.Drawing.Pen($sender.Tag.Border, 1)
            $e.Graphics.DrawPath($pen, $path)
            $pen.Dispose()
        }
        $flags = [System.Windows.Forms.TextFormatFlags]::HorizontalCenter -bor [System.Windows.Forms.TextFormatFlags]::VerticalCenter -bor [System.Windows.Forms.TextFormatFlags]::EndEllipsis
        [System.Windows.Forms.TextRenderer]::DrawText($e.Graphics, $sender.Text, $sender.Font, $rect, $sender.ForeColor, $flags)
        $path.Dispose()
    })
    $button.Add_Click($Click)
    return $button
}

function New-Card {
    param([int]$X, [int]$Y, [int]$W, [int]$H)
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Location = New-Object System.Drawing.Point($X, $Y)
    $panel.Size = New-Object System.Drawing.Size($W, $H)
    $panel.BackColor = [System.Drawing.Color]::FromArgb(250, 252, 255)
    $panel.BorderStyle = 'FixedSingle'
    return $panel
}

function Show-FirstRunGuide {
    $dialog = New-Object System.Windows.Forms.Form
    $dialog.Text = Tr 'firstRunTitle'
    $dialog.StartPosition = 'CenterParent'
    $dialog.Size = New-Object System.Drawing.Size(600, 420)
    $dialog.FormBorderStyle = 'FixedDialog'
    $dialog.MaximizeBox = $false
    $dialog.MinimizeBox = $false
    $dialog.BackColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
    $dialog.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)

    $title = New-Label -Text (Tr 'firstRunTitle') -X 28 -Y 22 -Size 15 -Bold $true
    $title.ForeColor = [System.Drawing.Color]::FromArgb(125, 211, 252)
    $dialog.Controls.Add($title)

    $steps = @(
        @{ Title = Tr 'firstRunStep1Title'; Body = Tr 'firstRunStep1Body' },
        @{ Title = Tr 'firstRunStep2Title'; Body = Tr 'firstRunStep2Body' },
        @{ Title = Tr 'firstRunStep3Title'; Body = Tr 'firstRunStep3Body' }
    )
    $y = 70
    foreach ($step in $steps) {
        $panel = New-Object System.Windows.Forms.Panel
        $panel.Location = New-Object System.Drawing.Point(28, $y)
        $panel.Size = New-Object System.Drawing.Size(528, 72)
        $panel.BackColor = [System.Drawing.Color]::FromArgb(2, 48, 71)
        $dialog.Controls.Add($panel)

        $stepTitle = New-Object System.Windows.Forms.Label
        $stepTitle.Text = $step.Title
        $stepTitle.Location = New-Object System.Drawing.Point(14, 8)
        $stepTitle.Size = New-Object System.Drawing.Size(500, 24)
        $stepTitle.Font = New-Object System.Drawing.Font('Segoe UI', 10.5, [System.Drawing.FontStyle]::Bold)
        $stepTitle.ForeColor = [System.Drawing.Color]::White
        $stepTitle.BackColor = $panel.BackColor
        $panel.Controls.Add($stepTitle)

        $body = New-Object System.Windows.Forms.Label
        $body.Text = $step.Body
        $body.Location = New-Object System.Drawing.Point(14, 34)
        $body.Size = New-Object System.Drawing.Size(500, 32)
        $body.Font = New-Object System.Drawing.Font('Segoe UI', 9.5)
        $body.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
        $body.BackColor = $panel.BackColor
        $panel.Controls.Add($body)
        $y += 86
    }

    $dontShow = New-Object System.Windows.Forms.CheckBox
    $dontShow.Text = Tr 'firstRunDontShow'
    $dontShow.Checked = $true
    $dontShow.Location = New-Object System.Drawing.Point(30, 334)
    $dontShow.Size = New-Object System.Drawing.Size(260, 28)
    $dontShow.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
    $dontShow.BackColor = $dialog.BackColor
    $dontShow.UseVisualStyleBackColor = $false
    $dialog.Controls.Add($dontShow)

    $ok = New-Button -Text (Tr 'firstRunOk') -X 424 -Y 330 -W 132 -H 36 -Click { Save-FirstRunGuideShown; $dialog.Close() }.GetNewClosure() -Accent $true
    $dialog.Controls.Add($ok)
    Set-ButtonTheme -Button $ok -Accent $true
    [void]$dialog.ShowDialog($form)
}

function Show-Page {
    param([string]$Name)
    $mainPage.Visible = ($Name -eq 'main')
    $settingsPage.Visible = ($Name -eq 'settings')
    $languagePage.Visible = ($Name -eq 'language')
    $siteCheckPage.Visible = ($Name -eq 'siteCheck')
    $tgPage.Visible = ($Name -eq 'tg')
    $servicePage.Visible = ($Name -eq 'service')
    $faqPage.Visible = ($Name -eq 'faq')
    $helpPage.Visible = ($Name -eq 'help')
}

function Get-FaqDomains {
    $listNames = @('list-general-user.txt', 'list-google.txt')

    $domains = New-Object System.Collections.Generic.List[string]
    foreach ($name in $listNames) {
        $path = Join-Path (Join-Path $Root 'lists') $name
        if (-not (Test-Path -LiteralPath $path)) { continue }
        foreach ($line in (Get-Content -LiteralPath $path -Encoding UTF8)) {
            $value = $line.Trim()
            if (-not $value) { continue }
            if ($value.StartsWith('#')) { continue }
            if ($value -eq 'domain.example.abc') { continue }
            if ($domains -notcontains $value) { $domains.Add($value) | Out-Null }
        }
    }
    return @($domains | Sort-Object)
}

function Update-FaqDomains {
    $domains = @(Get-FaqDomains)
    $mid = [Math]::Ceiling($domains.Count / 2)
    if ($domains.Count -eq 0) {
        $faqLeft.Text = ''
        $faqRight.Text = ''
        $faqApps.Text = ''
        return
    }
    $left = @($domains | Select-Object -First $mid)
    $right = @($domains | Select-Object -Skip $mid)
    $faqLeft.Text = ($left -join "`r`n")
    $faqRight.Text = ($right -join "`r`n")
    $apps = @(
        'Discord',
        'YouTube',
        'Google / Google Play',
        'Telegram / Telegram Web',
        'Facebook',
        'Instagram',
        'GitHub',
        'Amnezia',
        'RDP Monster',
        'SoundCloud',
        'Lineage / L2 Reborn',
        'Scryde',
        'AnimeLib / AniLib',
        'AniLibria',
        'AniMedia'
    )
    $faqApps.Text = ($apps -join "`r`n")
}

function Get-HelpText {
    switch ($script:Lang) {
        'en' { return @'
🚀 Quick Start
1. Click Network Check. The app checks all bypass BAT files and selects the best one for your network.
2. Click Start to run the selected bypass now.
3. Click Autostart if you want the selected bypass to start with Windows.

🧭 Main Menu
Network Check - tests every general*.bat bypass, shows progress in the log, checks site access, and selects the best result.
Start / Stop - starts the selected bypass or stops the running background bypass.
Autostart - installs the selected bypass as a Windows startup service.
Bypass list - choose a bypass manually if you already know which one works best.

🛠 Service Actions
STOP ALL - stops winws.exe, removes zapret/WinDivert services, and clears DNS cache.
Game Filter - chooses game traffic mode: off, TCP+UDP, TCP only, or UDP only.
IPSet Filter - switches IPSet list mode.
Update IPSet List - downloads the latest IPSet list.
Run Diagnostics - opens service diagnostics for conflicts and system checks.
Inst and Facebook - applies the Instagram/Facebook fix.
Stop Inst and FB - removes that fix and restores previous settings.
Clear Browser Cache - clears browser site cache for blocked sites.

📲 Telegram / TG
Fix TG App - opens Telegram proxy settings directly in Telegram.
All TG Proxies - opens the Telegram proxy channel and shows screenshots with steps.
Download TG - opens the Telegram Desktop GitHub release page.

🔎 Site Check
Check Site - checks one pasted domain or URL.
Check Sites - checks the built-in site list after a bypass is running.

⚙ Settings
Stop old bypass before starting a new one - recommended, prevents conflicts.
Start Azapret with Windows - starts the app with Windows.
Disable Autostart - removes app/service autostart.
'@ }
        'zh' { return @'
🚀 快速开始
1. 点击“网络检查”。程序会测试所有 general*.bat 绕过文件，并为当前网络选择最佳项。
2. 点击“启动”，立即运行选中的绕过方案。
3. 点击“自动启动”，让选中的绕过方案随 Windows 启动。

🧭 主菜单
网络检查 - 测试每个 general*.bat，在日志中显示进度，检查网站访问，并选择最佳结果。
启动 / 停止 - 启动选中的绕过方案，或停止正在运行的后台绕过。
自动启动 - 将选中的绕过方案安装为 Windows 启动服务。
绕过列表 - 如果你已经知道哪个方案更适合，可以手动选择。

🛠 服务操作
全部停止 - 停止 winws.exe，移除 zapret/WinDivert 服务，并清理 DNS 缓存。
游戏过滤 - 选择游戏流量模式：关闭、TCP+UDP、仅 TCP、仅 UDP。
IPSet 过滤 - 切换 IPSet 列表模式。
更新 IPSet 列表 - 下载最新 IPSet 列表。
运行诊断 - 打开服务诊断，检查冲突和系统状态。
Instagram 和 Facebook - 应用 Instagram/Facebook 修复。
停止 Instagram/FB - 移除该修复并恢复之前设置。
清理浏览器缓存 - 清理被阻止网站的浏览器缓存。

📲 Telegram / TG
修复 TG 应用 - 直接在 Telegram 中打开 proxy 设置。
所有 TG 代理 - 打开 Telegram proxy 频道，并显示步骤截图。
下载 TG - 打开 Telegram Desktop 的 GitHub 发布页。

🔎 网站检查
检查单个网站 - 检查输入的域名或链接。
检查网站 - 在绕过运行后检查内置网站列表。

⚙ 设置
启动新方案前停止旧方案 - 推荐开启，避免冲突。
随 Windows 启动 Azapret - Windows 启动时打开应用。
禁用自动启动 - 移除应用/服务自动启动。
'@ }
        'fa' { return @'
🚀 شروع سریع
1. بررسی شبکه را بزنید. برنامه همه فایل های general*.bat را تست می کند و بهترین گزینه را برای شبکه شما انتخاب می کند.
2. Start را بزنید تا روش انتخاب شده همین حالا اجرا شود.
3. Autostart را بزنید اگر می خواهید روش انتخاب شده همراه Windows اجرا شود.

🧭 منوی اصلی
بررسی شبکه - همه bypass های general*.bat را تست می کند، پیشرفت را در گزارش نشان می دهد، دسترسی سایت ها را بررسی و بهترین نتیجه را انتخاب می کند.
Start / Stop - روش انتخاب شده را شروع می کند یا bypass در حال اجرا را متوقف می کند.
Autostart - روش انتخاب شده را به عنوان سرویس شروع خودکار Windows نصب می کند.
فهرست عبور - اگر می دانید کدام روش بهتر کار می کند، دستی انتخاب کنید.

🛠 عملیات سرویس
توقف همه - winws.exe را متوقف، سرویس های zapret/WinDivert را حذف و کش DNS را پاک می کند.
فیلتر بازی - حالت ترافیک بازی را انتخاب می کند: خاموش، TCP+UDP، فقط TCP، فقط UDP.
فیلتر IPSet - حالت فهرست IPSet را تغییر می دهد.
بروزرسانی فهرست IPSet - آخرین فهرست IPSet را دانلود می کند.
اجرای عیب یابی - عیب یابی سرویس را برای بررسی تداخل ها باز می کند.
Instagram و Facebook - تعمیر Instagram/Facebook را اعمال می کند.
توقف Instagram/FB - این تعمیر را حذف و تنظیمات قبلی را بازگردانی می کند.
پاک کردن کش مرورگر - کش سایت های مسدود شده را پاک می کند.

📲 Telegram / TG
تعمیر برنامه TG - تنظیمات proxy را مستقیم در Telegram باز می کند.
همه پراکسی های TG - کانال proxy تلگرام و تصاویر راهنما را باز می کند.
دانلود TG - صفحه GitHub نسخه های Telegram Desktop را باز می کند.

🔎 بررسی سایت
بررسی سایت - یک دامنه یا لینک وارد شده را بررسی می کند.
بررسی سایت ها - بعد از اجرای bypass فهرست داخلی سایت ها را بررسی می کند.

⚙ تنظیمات
قبل از شروع روش جدید، روش قبلی متوقف شود - توصیه می شود، از تداخل جلوگیری می کند.
اجرای Azapret همراه Windows - برنامه را همراه Windows باز می کند.
غیرفعال کردن شروع خودکار - شروع خودکار برنامه/سرویس را حذف می کند.
'@ }
        default { return @'
🚀 Быстрый запуск
1. Нажмите «Проверка сети». Приложение проверит все BAT-обходы general*.bat и выберет лучший для вашей сети.
2. Нажмите «Старт», чтобы запустить выбранный обход сейчас.
3. Нажмите «Автостарт», если хотите, чтобы выбранный обход запускался сам вместе с Windows.

🧭 Главное меню
Проверка сети - тестирует каждый general*.bat, показывает прогресс в журнале, проверяет доступность сайтов и выбирает лучший результат.
Старт / Стоп - запускает выбранный обход или останавливает работающий обход.
Автостарт - устанавливает выбранный обход в автозапуск Windows как службу.
Список обхода - позволяет вручную выбрать обход, если вы уже знаете рабочий вариант.

🛠 Сервисные действия
СТОП ВСЕ - останавливает winws.exe, удаляет службы zapret/WinDivert и очищает DNS-кеш.
Игровой фильтр - выбирает режим игрового трафика: выключен, TCP+UDP, только TCP или только UDP.
IPSet фильтр - переключает режим списка IPSet.
Обновить список IPSet - скачивает свежий IPSet-список.
Запустить диагностику - открывает диагностику сервиса для проверки конфликтов и системы.
Инст и Фейсбук - применяет фикс для Instagram/Facebook.
Стоп инст и ф. - убирает этот фикс и возвращает прежние настройки.
Очистить кеш браузера - очищает кеш сайтов в браузерах.

📲 Telegram / TG
Прокси для TG - открывает настройки proxy прямо в Telegram.
Все прокси для TG - открывает Telegram-канал с proxy и показывает пошаговые скриншоты.
Скачать TG - открывает GitHub-страницу загрузки Telegram Desktop.

🔎 Проверка сайтов
Проверить сайт - проверяет один введенный домен или ссылку.
Проверить сайты - проверяет встроенный список сайтов после запуска обхода.

⚙ Настройки
Останавливать старый обход перед запуском нового - рекомендуется, чтобы не было конфликтов.
Запускать Azapret вместе с Windows - открывает приложение при старте Windows.
Отключить автозапуск - убирает автозапуск приложения/службы.
'@ }
    }
}

function Add-HelpCard {
    param([string]$Title, [string]$Icon, [string]$Body, [string[]]$Screens = @())
    if (-not $helpCardsPanel) { return }
    $card = New-Object System.Windows.Forms.Panel
    $card.Size = New-Object System.Drawing.Size(626, $(if ($Screens.Count -gt 0) { 486 } else { 230 }))
    $card.Margin = New-Object System.Windows.Forms.Padding(12, 10, 12, 4)
    $card.BackColor = if ($script:Settings.theme -eq 'dark') { [System.Drawing.Color]::FromArgb(15, 23, 42) } else { [System.Drawing.Color]::FromArgb(255, 255, 255) }
    $card.BorderStyle = 'FixedSingle'

    $iconPath = Join-Path (Join-Path $Root 'assets\help') $Icon
    if (Test-Path -LiteralPath $iconPath) {
        $pic = New-Object System.Windows.Forms.PictureBox
        $pic.Location = New-Object System.Drawing.Point(16, 16)
        $pic.Size = New-Object System.Drawing.Size(38, 38)
        $pic.SizeMode = 'Zoom'
        try { $pic.Image = [System.Drawing.Image]::FromFile($iconPath) } catch {}
        $card.Controls.Add($pic)
    }

    $title = New-Object System.Windows.Forms.Label
    $title.Text = $Title
    $title.Location = New-Object System.Drawing.Point(64, 14)
    $title.Size = New-Object System.Drawing.Size(540, 28)
    $title.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)
    $title.ForeColor = if ($script:Settings.theme -eq 'dark') { [System.Drawing.Color]::FromArgb(125, 211, 252) } else { [System.Drawing.Color]::FromArgb(2, 132, 199) }
    $card.Controls.Add($title)

    $textPanel = New-Object System.Windows.Forms.Panel
    $textPanel.Location = New-Object System.Drawing.Point(64, 48)
    $textPanel.Size = New-Object System.Drawing.Size(540, 158)
    $textPanel.BackColor = [System.Drawing.Color]::FromArgb(2, 48, 71)
    $textPanel.Tag = $Body
    $textPanel.Add_Paint({
        $font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
        $rect = New-Object System.Drawing.Rectangle(12, 8, 516, 142)
        [System.Windows.Forms.TextRenderer]::DrawText($args[1].Graphics, [string]$this.Tag, $font, $rect, [System.Drawing.Color]::White, [System.Windows.Forms.TextFormatFlags]::WordBreak -bor [System.Windows.Forms.TextFormatFlags]::Left -bor [System.Windows.Forms.TextFormatFlags]::Top)
        $font.Dispose()
    })
    $card.Controls.Add($textPanel)

    if ($Screens.Count -gt 0) {
        $i = 0
        foreach ($name in $Screens) {
            $screen = Join-Path (Join-Path $Root 'telegram-proxy-screens') $name
            if (-not (Test-Path -LiteralPath $screen)) { continue }
            $shot = New-Object System.Windows.Forms.PictureBox
            $col = $i % 3
            $row = [math]::Floor($i / 3)
            $shot.Location = New-Object System.Drawing.Point((34 + ($col * 190)), (224 + ($row * 112)))
            $shot.Size = New-Object System.Drawing.Size(170, 104)
            $shot.SizeMode = 'Zoom'
            $shot.Cursor = [System.Windows.Forms.Cursors]::Hand
            $shot.Tag = $screen
            try { $shot.Image = [System.Drawing.Image]::FromFile($screen) } catch {}
            $shot.Add_Click({ Show-ImagePreview -ImagePath ([string]$this.Tag) })
            $card.Controls.Add($shot)
            $i++
        }
    }

    $helpCardsPanel.Controls.Add($card)
}

function Populate-HelpCards {
    if (-not $helpCardsPanel) { return }
    $helpCardsPanel.Controls.Clear()
    Add-HelpCard -Title '🚀 Быстрый запуск' -Icon 'rocket.png' -Body "1. Сначала нажмите «Проверка сети»: приложение переберет доступные general*.bat и покажет прогресс в журнале.`r`n2. Когда лучший вариант выбран, нажмите «Старт». Если обход уже запущен, эта же кнопка остановит его.`r`n3. Если вариант работает стабильно, включите «Автостарт», чтобы запускать его вместе с Windows."
    Add-HelpCard -Title '🧭 Главное меню' -Icon 'compass.png' -Body "1. «Обход» - список BAT-профилей. Можно выбрать вручную или доверить выбор проверке сети.`r`n2. «Журнал» - здесь видны запуски, остановки, ошибки и итог проверки.`r`n3. «Список обхода» - справка по сайтам и приложениям, для которых подготовлен пакет."
    Add-HelpCard -Title '🛠 Сервис: остановка и фильтры' -Icon 'tools.png' -Body "1. «СТОП ВСЕ» - закрывает winws.exe, удаляет службы zapret/WinDivert/WinDivert14 и очищает DNS-кеш.`r`n2. «Игровой фильтр» - выбор Off, TCP+UDP, TCP only или UDP only для игр, лаунчеров и голосового чата.`r`n3. «IPSet фильтр» - отключает список, включает пустой режим или возвращает сохранённый IPSet."
    Add-HelpCard -Title '🛠 Сервис: списки и диагностика' -Icon 'search.png' -Body "1. «Обновить список IPSet» - скачивает свежий ipset-service.txt и заменяет локальный список в папке lists.`r`n2. «Запустить диагностику» - открывает service.bat в отдельном окне с правами администратора.`r`n3. Журнал справа показывает запуск действия, ошибки и зелёный итог при успешном выполнении."
    Add-HelpCard -Title '🛠 Сервис: фиксы и кеш' -Icon 'gear.png' -Body "1. «Инст и Фейсбук» - применяет фикс для Instagram/Facebook и сохраняет состояние для отката.`r`n2. «Стоп инст и ф.» - отключает этот фикс и возвращает прежние настройки, если они были сохранены.`r`n3. «Очистить кеш браузера» - очищает кеш сайтов. После этого закройте и заново откройте браузер."
    Add-HelpCard -Title '📲 Telegram / TG' -Icon 'telegram.png' -Body "1. «Прокси для TG» открывает MTProto proxy прямо в Telegram Desktop.`r`n2. «Все прокси для TG» открывает канал с актуальными proxy и показывает пошаговые скриншоты.`r`n3. Нажмите на любой скрин ниже, чтобы открыть его крупно: канал, выбор proxy, подтверждение." -Screens @('p1.png','p2.png','p4.png','p3.png','p5.png','p6.png')
    Add-HelpCard -Title '🔎 Проверка сайтов' -Icon 'search.png' -Body "1. «Проверить сайт» проверяет один домен или ссылку, которую вы ввели вручную.`r`n2. «Проверить сайты» проходит по встроенному списку после запуска обхода.`r`n3. Результат показывает, где всё OK, где таймаут, а где нужен другой BAT-профиль."
    Add-HelpCard -Title '⚙ Настройки' -Icon 'gear.png' -Body "1. «Останавливать старый обход перед запуском нового» лучше держать включенным, чтобы не было конфликтов.`r`n2. «Запускать Azapret вместе с Windows» открывает приложение при входе в систему.`r`n3. Смена языка и темы применяется сразу, без перезапуска."
}

function Apply-Language {
    $form.Text = Tr 'appPublic'
    $mainNav.Text = Tr 'main'
    $settingsNav.Text = Tr 'settings'
    $languageNav.Text = Tr 'language'
    $siteCheckNav.Text = Tr 'siteCheck'
    $tgNav.Text = Tr 'tg'
    $serviceNav.Text = Tr 'service'
    $faqNav.Text = Tr 'faq'
    $helpNav.Text = Tr 'help'
    $titleLabel.Text = Tr 'titlePublic'
    $subtitleLabel.Text = Tr 'subtitle'
    $statusLabel.Text = if ($script:BypassRunning) { Tr 'statusRunning' } else { Tr 'statusStopped' }
    $bypassLabel.Text = Tr 'bypass'
    Update-NetworkCheckButtons
    $startButton.Text = if ($script:BypassRunning) { Tr 'stop' } else { Tr 'start' }
    $autostartButton.Text = Tr 'autostart'
    if ($removeAutostartButton) { $removeAutostartButton.Text = Tr 'removeAutostart' }
    $extraButton.Text = Tr 'extra'
    $logLabel.Text = Tr 'log'
    $stopCheck.Text = Tr 'stopBeforeStart'
    $startupCheck.Text = Tr 'startWithWindows'
    $saveButton.Text = Tr 'save'
    $updateButton.Text = Tr 'checkUpdates'
    $languageTitle.Text = Tr 'selectLanguage'
    $siteCheckTitle.Text = Tr 'siteCheckTitle'
    $tgTitle.Text = Tr 'tg'
    $siteCheckHint.Text = Tr 'siteCheckHint'
    $runSiteCheckButton.Text = Tr 'runSiteCheck'
    $runOneSiteButton.Text = Tr 'checkOneSite'
    if ($siteInputBox.Text -eq '' -or $siteInputBox.Text -eq (Tr 'siteInputPlaceholder')) { $siteInputBox.Text = Tr 'siteInputPlaceholder' }
    $serviceTitle.Text = Tr 'service'
    $faqTitle.Text = Tr 'faqTitle'
    $helpTitle.Text = Tr 'helpTitle'
    Populate-HelpCards
    $faqText.Text = Tr 'faqTextPublic'
    $faqAppsTitle.Text = Tr 'faqApps'
    $versionLabel.Text = 'Version 1.1.1'
    Update-FaqDomains
    $ruRadio.Text = Tr 'russian'
    $enRadio.Text = Tr 'english'
    $zhRadio.Text = Tr 'chinese'
    $faRadio.Text = Tr 'persian'
    $ruRadio.Checked = ($script:Lang -eq 'ru')
    $enRadio.Checked = ($script:Lang -eq 'en')
    $zhRadio.Checked = ($script:Lang -eq 'zh')
    $faRadio.Checked = ($script:Lang -eq 'fa')
    foreach ($key in $script:ActionButtons.Keys) {
        $script:ActionButtons[$key].Text = Tr $key
    }
    Apply-Theme
}

function Set-ButtonTheme {
    param([System.Windows.Forms.Button]$Button, [bool]$Accent = $false, [bool]$Danger = $false)
    $Button.UseVisualStyleBackColor = $false
    $Button.FlatStyle = 'Flat'
    $Button.FlatAppearance.BorderSize = 0
    $Button.FlatAppearance.BorderColor = [System.Drawing.Color]::Transparent
    if ($Danger) {
        $Button.BackColor = [System.Drawing.Color]::FromArgb(239, 68, 68)
        $Button.ForeColor = [System.Drawing.Color]::White
        $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(220, 38, 38)
        $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(185, 28, 28)
        $Button.Tag = [pscustomobject]@{ Border = [System.Drawing.Color]::FromArgb(252, 165, 165) }
        $Button.Invalidate()
        return
    }
    if ($script:Settings.theme -eq 'dark') {
        if ($Accent) {
            $Button.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 252)
            $Button.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
            $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
            $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(203, 213, 225)
            $Button.Tag = [pscustomobject]@{ Border = [System.Drawing.Color]::FromArgb(255, 255, 255) }
        } else {
            $Button.BackColor = [System.Drawing.Color]::FromArgb(30, 41, 59)
            $Button.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
            $Button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(51, 65, 85)
            $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(51, 65, 85)
            $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
            $Button.Tag = [pscustomobject]@{ Border = [System.Drawing.Color]::FromArgb(71, 85, 105) }
        }
    } else {
        if ($Accent) {
            $Button.BackColor = [System.Drawing.Color]::FromArgb(6, 182, 212)
            $Button.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
            $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(8, 145, 178)
            $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(14, 116, 144)
            $Button.Tag = [pscustomobject]@{ Border = [System.Drawing.Color]::FromArgb(103, 232, 249) }
        } else {
            $Button.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
            $Button.ForeColor = [System.Drawing.Color]::FromArgb(8, 145, 178)
            $Button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(186, 230, 253)
            $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(240, 249, 255)
            $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(224, 242, 254)
            $Button.Tag = [pscustomobject]@{ Border = [System.Drawing.Color]::FromArgb(186, 230, 253) }
        }
    }
    $Button.Invalidate()
}

function Set-PrimaryButtonTheme {
    param([System.Windows.Forms.Button]$Button)
    $Button.UseVisualStyleBackColor = $false
    $Button.FlatStyle = 'Flat'
    $Button.FlatAppearance.BorderSize = 0
    if ($script:Settings.theme -eq 'dark') {
        $Button.BackColor = [System.Drawing.Color]::FromArgb(245, 247, 250)
        $Button.ForeColor = [System.Drawing.Color]::FromArgb(2, 6, 23)
        $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
        $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(203, 213, 225)
        $Button.Tag = [pscustomobject]@{ Border = [System.Drawing.Color]::FromArgb(255, 255, 255); Gradient = [System.Drawing.Color]::FromArgb(226, 232, 240); Glow = [System.Drawing.Color]::FromArgb(40, 255, 255, 255) }
    } else {
        $Button.BackColor = [System.Drawing.Color]::FromArgb(0, 194, 255)
        $Button.ForeColor = [System.Drawing.Color]::White
        $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(0, 169, 224)
        $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(0, 132, 180)
        $Button.Tag = [pscustomobject]@{ Border = [System.Drawing.Color]::FromArgb(125, 249, 255); Gradient = [System.Drawing.Color]::FromArgb(14, 165, 233); Glow = [System.Drawing.Color]::FromArgb(70, 125, 249, 255) }
    }
    $Button.Invalidate()
}

function Set-ComboTheme {
    $dark = ($script:Settings.theme -eq 'dark')
    $combo.BackColor = if ($dark) { [System.Drawing.Color]::FromArgb(15, 23, 42) } else { [System.Drawing.Color]::FromArgb(255, 255, 255) }
    $combo.ForeColor = if ($dark) { [System.Drawing.Color]::FromArgb(226, 232, 240) } else { [System.Drawing.Color]::FromArgb(15, 23, 42) }
    if ($comboButton) {
        Set-ButtonTheme -Button $comboButton -Accent $false
        $comboButton.Text = if ($combo.SelectedItem) { ([string]$combo.SelectedItem + '   v') } else { 'Select bypass   v' }
    }
    $combo.Invalidate()
}

function Show-BypassMenu {
    if (-not $comboButton) { return }
    $menu = New-Object System.Windows.Forms.ContextMenuStrip
    $dark = ($script:Settings.theme -eq 'dark')
    $menu.ShowImageMargin = $false
    $menu.BackColor = if ($dark) { [System.Drawing.Color]::FromArgb(15, 23, 42) } else { [System.Drawing.Color]::FromArgb(255, 255, 255) }
    $menu.ForeColor = if ($dark) { [System.Drawing.Color]::FromArgb(226, 232, 240) } else { [System.Drawing.Color]::FromArgb(15, 23, 42) }
    foreach ($item in $script:Bypasses) {
        $menuItem = $menu.Items.Add($item.Label)
        $menuItem.Tag = $item.Label
        $menuItem.Add_Click({ $combo.SelectedItem = [string]$this.Tag; $comboButton.Text = ([string]$combo.SelectedItem + '   v'); Save-Settings })
    }
    $menu.Show($comboButton, 0, $comboButton.Height + 4)
}

function Apply-Theme {
    $dark = ($script:Settings.theme -eq 'dark')
    $window = if ($dark) { [System.Drawing.Color]::FromArgb(15, 23, 42) } else { [System.Drawing.Color]::FromArgb(248, 251, 255) }
    $panel = if ($dark) { [System.Drawing.Color]::FromArgb(17, 24, 39) } else { [System.Drawing.Color]::FromArgb(224, 242, 254) }
    $card = if ($dark) { [System.Drawing.Color]::FromArgb(30, 41, 59) } else { [System.Drawing.Color]::FromArgb(250, 252, 255) }
    $text = if ($dark) { [System.Drawing.Color]::FromArgb(226, 232, 240) } else { [System.Drawing.Color]::FromArgb(23, 32, 51) }
    $muted = if ($dark) { [System.Drawing.Color]::FromArgb(148, 163, 184) } else { [System.Drawing.Color]::FromArgb(71, 85, 105) }
    $field = if ($dark) { [System.Drawing.Color]::FromArgb(15, 23, 42) } else { [System.Drawing.Color]::FromArgb(255, 255, 255) }

    $form.BackColor = $window
    $sidebar.BackColor = if ($dark) { [System.Drawing.Color]::FromArgb(2, 6, 23) } else { [System.Drawing.Color]::FromArgb(219, 234, 254) }
    $content.BackColor = $window
    foreach ($page in @($mainPage, $settingsPage, $languagePage, $siteCheckPage, $tgPage, $servicePage, $faqPage, $helpPage)) { $page.BackColor = $window }
    foreach ($cardPanel in @($topCard, $settingsCard, $languageCard, $siteCheckCard, $tgCard, $serviceCard, $faqCard, $helpCard)) { $cardPanel.BackColor = $card }
    foreach ($label in @($titleLabel, $bypassLabel, $logLabel, $languageTitle, $siteCheckTitle, $siteCheckHint, $tgTitle, $serviceTitle, $faqTitle, $helpTitle, $faqText, $faqAppsTitle, $versionLabel)) { $label.ForeColor = $text }
    if (-not $script:BypassRunning) { $statusLabel.ForeColor = $muted }
    $subtitleLabel.ForeColor = $muted
    $editionLabel.ForeColor = if ($dark) { [System.Drawing.Color]::FromArgb(191, 219, 254) } else { [System.Drawing.Color]::FromArgb(37, 99, 235) }
    foreach ($box in @($faqLeft, $faqRight, $faqApps, $siteResultsBox, $siteInputBox, $serviceLogBox)) { if ($box) { $box.BackColor = $field; $box.ForeColor = $text } }
    if ($helpCardsPanel) { $helpCardsPanel.BackColor = $card }
    $siteResultsBox.BackColor = if ($dark) { [System.Drawing.Color]::FromArgb(2, 6, 23) } else { [System.Drawing.Color]::FromArgb(245, 250, 255) }
    $siteResultsBox.ForeColor = if ($dark) { [System.Drawing.Color]::FromArgb(226, 232, 240) } else { [System.Drawing.Color]::FromArgb(15, 23, 42) }
    if ($serviceLogBox) { $serviceLogBox.BackColor = if ($dark) { [System.Drawing.Color]::FromArgb(2, 6, 23) } else { [System.Drawing.Color]::FromArgb(245, 250, 255) }; $serviceLogBox.ForeColor = if ($dark) { [System.Drawing.Color]::FromArgb(226, 232, 240) } else { [System.Drawing.Color]::FromArgb(15, 23, 42) } }
    $siteInputBox.BackColor = if ($dark) { [System.Drawing.Color]::FromArgb(15, 23, 42) } else { [System.Drawing.Color]::FromArgb(255, 255, 255) }
    $siteInputBox.ForeColor = if ($dark) { [System.Drawing.Color]::FromArgb(226, 232, 240) } else { [System.Drawing.Color]::FromArgb(15, 23, 42) }
    Set-ComboTheme
    $logBox.BackColor = if ($dark) { [System.Drawing.Color]::FromArgb(2, 6, 23) } else { [System.Drawing.Color]::FromArgb(15, 23, 42) }
    $logBox.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
    $stopCheck.ForeColor = $text
    $startupCheck.ForeColor = $text
    foreach ($radio in @($ruRadio, $enRadio, $zhRadio, $faRadio)) { $radio.ForeColor = $text; $radio.BackColor = $card; $radio.UseVisualStyleBackColor = $false }
    $themeToggle.ForeColor = $text
    $themeToggle.BackColor = if ($dark) { [System.Drawing.Color]::FromArgb(30, 41, 59) } else { [System.Drawing.Color]::FromArgb(255, 255, 255) }
    $themeToggle.FlatAppearance.BorderColor = if ($dark) { [System.Drawing.Color]::FromArgb(71, 85, 105) } else { [System.Drawing.Color]::FromArgb(186, 230, 253) }
    $themeToggle.Text = if ($dark) { 'Dark Network' } else { 'Clean Sky' }

    if ($script:BypassRunning) { Set-ButtonTheme -Button $startButton -Accent $true -Danger $true } else { Set-PrimaryButtonTheme -Button $startButton }
    Set-PrimaryButtonTheme -Button $autostartButton
    foreach ($button in @($extraButton, $camButton, $saveButton, $runSiteCheckButton, $runOneSiteButton)) { if ($button) { Set-ButtonTheme -Button $button -Accent $true } }
    foreach ($button in @($mainNav, $serviceNav, $tgNav, $settingsNav, $languageNav, $siteCheckNav, $faqNav, $helpNav, $checkButton, $updateButton, $removeAutostartButton, $comboButton)) { Set-ButtonTheme -Button $button -Accent $false }
    foreach ($button in $script:ActionButtons.Values) { Set-ButtonTheme -Button $button -Accent $false }
}

Load-Settings
$script:BypassRunning = $false

$form = New-Object System.Windows.Forms.Form
$form.Text = Tr 'appPublic'
$form.Size = New-Object System.Drawing.Size(980, 650)
$form.MinimumSize = New-Object System.Drawing.Size(980, 650)
$form.MaximumSize = New-Object System.Drawing.Size(980, 650)
$form.FormBorderStyle = 'FixedSingle'
$form.MaximizeBox = $false
$form.StartPosition = 'CenterScreen'
$form.BackColor = [System.Drawing.Color]::FromArgb(238, 242, 247)
$form.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$form.ShowInTaskbar = $true
$iconPath = Join-Path (Join-Path $Root 'assets') 'azapret.ico'
if (Test-Path -LiteralPath $iconPath) {
    try { $form.Icon = New-Object System.Drawing.Icon($iconPath) } catch {}
}

$sidebar = New-Object System.Windows.Forms.Panel
$sidebar.Location = New-Object System.Drawing.Point(0, 0)
$sidebar.Size = New-Object System.Drawing.Size(210, 650)
$sidebar.Anchor = 'Top,Bottom,Left'
$sidebar.BackColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
$sidebar.AutoScroll = $true
$form.Controls.Add($sidebar)

$mainLogo = New-Object System.Windows.Forms.PictureBox
$mainLogo.Location = New-Object System.Drawing.Point(81, 18)
$mainLogo.Size = New-Object System.Drawing.Size(48, 48)
$mainLogo.SizeMode = 'StretchImage'
if (Test-Path -LiteralPath $iconPath) { try { $mainLogo.Image = [System.Drawing.Image]::FromFile($iconPath) } catch {} }
$mainPageLogo = New-Object System.Windows.Forms.PictureBox
$mainPageLogo.Location = New-Object System.Drawing.Point(640, 2)
$mainPageLogo.Size = New-Object System.Drawing.Size(56, 56)
$mainPageLogo.SizeMode = 'StretchImage'
if (Test-Path -LiteralPath $iconPath) { try { $mainPageLogo.Image = [System.Drawing.Image]::FromFile($iconPath) } catch {} }
$sidebar.Controls.Add($mainLogo)
$themeToggle = New-Object System.Windows.Forms.CheckBox
$themeToggle.Appearance = 'Button'
$themeToggle.FlatStyle = 'Flat'
$themeToggle.UseVisualStyleBackColor = $false
$themeToggle.Location = New-Object System.Drawing.Point(20, 104)
$themeToggle.Size = New-Object System.Drawing.Size(180, 36)
$themeToggle.Checked = ([string]$script:Settings.theme -eq 'dark')
$themeToggle.Add_CheckedChanged({ $script:Settings.theme = if ($themeToggle.Checked) { 'dark' } else { 'light' }; Apply-Theme; Save-Settings })

$mainNav = New-Button -Text (Tr 'main') -X 18 -Y 86 -W 174 -H 40 -Click { Show-Page 'main' } -Accent $true
$serviceNav = New-Button -Text (Tr 'service') -X 18 -Y 136 -W 174 -H 40 -Click { Show-Page 'service' }
$tgNav = New-Button -Text (Tr 'tg') -X 18 -Y 186 -W 174 -H 40 -Click { Show-Page 'tg' }
$settingsNav = New-Button -Text (Tr 'settings') -X 18 -Y 236 -W 174 -H 40 -Click { Show-Page 'settings' }
$languageNav = New-Button -Text (Tr 'language') -X 18 -Y 286 -W 174 -H 40 -Click { Show-Page 'language' }
$siteCheckNav = New-Button -Text (Tr 'siteCheck') -X 18 -Y 336 -W 174 -H 40 -Click { Show-Page 'siteCheck' }
$faqNav = New-Button -Text (Tr 'faq') -X 18 -Y 386 -W 174 -H 40 -Click { Show-Page 'faq' }
$helpNav = New-Button -Text (Tr 'help') -X 18 -Y 436 -W 174 -H 40 -Click { Show-Page 'help' }
$sidebar.Controls.AddRange(@($mainNav, $serviceNav, $tgNav, $settingsNav, $languageNav, $siteCheckNav, $faqNav, $helpNav))
$script:ActionButtons = @{}

$displayEdition = if ($Edition -eq 'Public') { 'Public - Beta' } else { $Edition }
$editionLabel = New-Label -Text $displayEdition -X 24 -Y 560 -Size 10 -Bold $true
$editionLabel.ForeColor = [System.Drawing.Color]::FromArgb(191, 219, 254)
$editionLabel.Anchor = 'Bottom,Left'
$sidebar.Controls.Add($editionLabel)

$content = New-Object System.Windows.Forms.Panel
$content.Location = New-Object System.Drawing.Point(230, 18)
$content.Size = New-Object System.Drawing.Size(720, 585)
$content.Anchor = 'Top,Bottom,Left,Right'
$content.BackColor = [System.Drawing.Color]::FromArgb(238, 242, 247)
$form.Controls.Add($content)

$mainPage = New-Object System.Windows.Forms.Panel
$mainPage.Dock = 'Fill'
$mainPage.BackColor = $content.BackColor
$content.Controls.Add($mainPage)

$settingsPage = New-Object System.Windows.Forms.Panel
$settingsPage.Dock = 'Fill'
$settingsPage.BackColor = $content.BackColor
$settingsPage.Visible = $false
$content.Controls.Add($settingsPage)

$languagePage = New-Object System.Windows.Forms.Panel
$languagePage.Dock = 'Fill'
$languagePage.BackColor = $content.BackColor
$languagePage.Visible = $false
$content.Controls.Add($languagePage)

$siteCheckPage = New-Object System.Windows.Forms.Panel
$siteCheckPage.Dock = 'Fill'
$siteCheckPage.BackColor = $content.BackColor
$siteCheckPage.Visible = $false
$content.Controls.Add($siteCheckPage)

$tgPage = New-Object System.Windows.Forms.Panel
$tgPage.Dock = 'Fill'
$tgPage.BackColor = $content.BackColor
$tgPage.Visible = $false
$content.Controls.Add($tgPage)

$servicePage = New-Object System.Windows.Forms.Panel
$servicePage.Dock = 'Fill'
$servicePage.BackColor = $content.BackColor
$servicePage.Visible = $false
$content.Controls.Add($servicePage)

$faqPage = New-Object System.Windows.Forms.Panel
$faqPage.Dock = 'Fill'
$faqPage.BackColor = $content.BackColor
$faqPage.Visible = $false
$content.Controls.Add($faqPage)

$helpPage = New-Object System.Windows.Forms.Panel
$helpPage.Dock = 'Fill'
$helpPage.BackColor = $content.BackColor
$helpPage.Visible = $false
$content.Controls.Add($helpPage)

$titleLabel = New-Label -Text '' -X 4 -Y 4 -Size 20 -Bold $true
$mainPage.Controls.Add($titleLabel)
$mainPage.Controls.Add($mainPageLogo)
$subtitleLabel = New-Label -Text '' -X 6 -Y 42 -Size 10
$subtitleLabel.ForeColor = [System.Drawing.Color]::FromArgb(90, 96, 105)
$mainPage.Controls.Add($subtitleLabel)
$statusLabel = New-Label -Text '' -X 500 -Y 46 -Size 10 -Bold $true
$statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(148, 163, 184)
$mainPage.Controls.Add($statusLabel)

$topCard = New-Card -X 4 -Y 80 -W 700 -H 112
$topCard.Anchor = 'Top,Left,Right'
$mainPage.Controls.Add($topCard)

$bypassLabel = New-Label -Text '' -X 18 -Y 18 -Size 10 -Bold $true
$topCard.Controls.Add($bypassLabel)
$combo = New-Object System.Windows.Forms.ComboBox
$combo.DropDownStyle = 'DropDownList'
$combo.DrawMode = [System.Windows.Forms.DrawMode]::OwnerDrawFixed
$combo.ItemHeight = 30
$combo.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$combo.Location = New-Object System.Drawing.Point(18, 46)
$combo.Size = New-Object System.Drawing.Size(266, 34)
$combo.Visible = $false
$combo.Add_DrawItem({
    param($sender, $e)
    if ($e.Index -lt 0) { return }
    $dark = ($script:Settings.theme -eq 'dark')
    $selected = (($e.State -band [System.Windows.Forms.DrawItemState]::Selected) -eq [System.Windows.Forms.DrawItemState]::Selected)
    $back = if ($selected) {
        if ($dark) { [System.Drawing.Color]::FromArgb(51, 65, 85) } else { [System.Drawing.Color]::FromArgb(207, 250, 254) }
    } else {
        if ($dark) { [System.Drawing.Color]::FromArgb(15, 23, 42) } else { [System.Drawing.Color]::FromArgb(255, 255, 255) }
    }
    $fore = if ($dark) { [System.Drawing.Color]::FromArgb(226, 232, 240) } else { [System.Drawing.Color]::FromArgb(15, 23, 42) }
    $e.Graphics.FillRectangle((New-Object System.Drawing.SolidBrush($back)), $e.Bounds)
    $textRect = New-Object System.Drawing.Rectangle(($e.Bounds.X + 12), $e.Bounds.Y, ($e.Bounds.Width - 18), $e.Bounds.Height)
    $flags = [System.Windows.Forms.TextFormatFlags]::VerticalCenter -bor [System.Windows.Forms.TextFormatFlags]::EndEllipsis
    [System.Windows.Forms.TextRenderer]::DrawText($e.Graphics, [string]$sender.Items[$e.Index], $sender.Font, $textRect, $fore, $flags)
})
$combo.Add_SelectedIndexChanged({ $script:Settings.lastBypass = [string]$combo.SelectedItem; if ($comboButton) { $comboButton.Text = ([string]$combo.SelectedItem + '   v') } })
$topCard.Controls.Add($combo)
$comboButton = New-Button -Text 'Select bypass   v' -X 18 -Y 43 -W 266 -H 38 -Click { Show-BypassMenu }
$topCard.Controls.Add($comboButton)

$fastCheckButton = New-Button -Text '' -X 292 -Y 43 -W 126 -H 38 -Click { Run-NetworkCheck -Fast $true }
$checkButton = New-Button -Text '' -X 426 -Y 43 -W 112 -H 38 -Click { Run-NetworkCheck }
$startButton = New-Button -Text '' -X 546 -Y 43 -W 72 -H 38 -Click { Run-SelectedBypass } -Accent $true
$autostartButton = New-Button -Text '' -X 626 -Y 43 -W 68 -H 38 -Click { Install-SelectedBypassService } -Accent $true
$extraButton = New-Button -Text '' -X 657 -Y 43 -W 42 -H 34 -Click { Run-ExtraSetup } -Accent $true
$topCard.Controls.AddRange(@($fastCheckButton, $checkButton, $startButton, $autostartButton, $extraButton))
$extraButton.Visible = $false

$logLabel = New-Label -Text '' -X 6 -Y 220 -Size 11 -Bold $true
$mainPage.Controls.Add($logLabel)
$logBox = New-Object System.Windows.Forms.RichTextBox
$logBox.Multiline = $true
$logBox.ScrollBars = 'Vertical'
$logBox.ReadOnly = $true
$logBox.BorderStyle = 'None'
$logBox.BackColor = [System.Drawing.Color]::FromArgb(20, 24, 31)
$logBox.ForeColor = [System.Drawing.Color]::FromArgb(225, 232, 240)
$logBox.Font = New-Object System.Drawing.Font('Consolas', 10)
$logBox.Location = New-Object System.Drawing.Point(4, 250)
$logBox.Size = New-Object System.Drawing.Size(700, 310)
$logBox.Anchor = 'Top,Bottom,Left,Right'
$mainPage.Controls.Add($logBox)

$settingsCard = New-Card -X 4 -Y 20 -W 700 -H 230
$settingsPage.Controls.Add($settingsCard)
$stopCheck = New-Object System.Windows.Forms.CheckBox
$stopCheck.Location = New-Object System.Drawing.Point(20, 28)
$stopCheck.Size = New-Object System.Drawing.Size(640, 28)
$stopCheck.Checked = [bool]$script:Settings.stopBeforeStart
$settingsCard.Controls.Add($stopCheck)
$startupCheck = New-Object System.Windows.Forms.CheckBox
$startupCheck.Location = New-Object System.Drawing.Point(20, 66)
$startupCheck.Size = New-Object System.Drawing.Size(640, 28)
$startupCheck.Checked = [bool]$script:Settings.startWithWindows
$settingsCard.Controls.Add($startupCheck)
$settingsCard.Controls.Add($themeToggle)
$saveButton = New-Button -Text '' -X 218 -Y 104 -W 132 -H 36 -Click { Save-Settings } -Accent $true
$updateButton = New-Button -Text '' -X 366 -Y 104 -W 190 -H 36 -Click { Open-ServiceChoice 9 }
$removeAutostartButton = New-Button -Text '' -X 20 -Y 150 -W 220 -H 36 -Click { Disable-Autostart }
$versionLabel = New-Label -Text '' -X 20 -Y 196 -Size 10 -Bold $true
$versionLabel.ForeColor = [System.Drawing.Color]::FromArgb(55, 65, 81)
$settingsCard.Controls.Add($saveButton)
$settingsCard.Controls.Add($updateButton)
$settingsCard.Controls.Add($removeAutostartButton)
$settingsCard.Controls.Add($versionLabel)

$languageCard = New-Card -X 4 -Y 20 -W 700 -H 210
$languagePage.Controls.Add($languageCard)
$languageTitle = New-Label -Text '' -X 20 -Y 20 -Size 13 -Bold $true
$languageCard.Controls.Add($languageTitle)
$ruRadio = New-Object System.Windows.Forms.RadioButton
$enRadio = New-Object System.Windows.Forms.RadioButton
$zhRadio = New-Object System.Windows.Forms.RadioButton
$faRadio = New-Object System.Windows.Forms.RadioButton
$radios = @(
    @{ Control = $ruRadio; Lang = 'ru'; Y = 60 },
    @{ Control = $enRadio; Lang = 'en'; Y = 90 },
    @{ Control = $zhRadio; Lang = 'zh'; Y = 120 },
    @{ Control = $faRadio; Lang = 'fa'; Y = 150 }
)
foreach ($radioSpec in $radios) {
    $radio = $radioSpec.Control
    $langCode = $radioSpec.Lang
    $radio.Location = New-Object System.Drawing.Point(24, $radioSpec.Y)
    $radio.Size = New-Object System.Drawing.Size(260, 24)
    $radio.Tag = $langCode
    $radio.UseVisualStyleBackColor = $false
    $radio.Checked = ($script:Lang -eq $langCode)
    $radio.Add_CheckedChanged({ if ($this.Checked) { $script:Lang = [string]$this.Tag; Apply-Language; Save-Settings } })
    $languageCard.Controls.Add($radio)
}

$siteCheckCard = New-Card -X 4 -Y 20 -W 700 -H 520
$siteCheckPage.Controls.Add($siteCheckCard)
$siteCheckTitle = New-Label -Text '' -X 20 -Y 18 -Size 13 -Bold $true
$siteCheckCard.Controls.Add($siteCheckTitle)
$siteCheckHint = New-Object System.Windows.Forms.Label
$siteCheckHint.Location = New-Object System.Drawing.Point(20, 56)
$siteCheckHint.Size = New-Object System.Drawing.Size(620, 48)
$siteCheckHint.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$siteCheckCard.Controls.Add($siteCheckHint)
$siteInputBox = New-Object System.Windows.Forms.TextBox
$siteInputBox.Location = New-Object System.Drawing.Point(20, 116)
$siteInputBox.Size = New-Object System.Drawing.Size(290, 28)
$siteInputBox.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$siteInputBox.BorderStyle = 'FixedSingle'
$siteInputBox.Text = Tr 'siteInputPlaceholder'
$siteInputBox.Add_Enter({ if ($this.Text -eq (Tr 'siteInputPlaceholder')) { $this.Text = '' } })
$siteCheckCard.Controls.Add($siteInputBox)
$runOneSiteButton = New-Button -Text '' -X 328 -Y 112 -W 140 -H 38 -Click { Run-OneSiteCheck } -Accent $true
$siteCheckCard.Controls.Add($runOneSiteButton)
$runSiteCheckButton = New-Button -Text '' -X 486 -Y 112 -W 134 -H 38 -Click { Run-SiteCheck } -Accent $true
$siteCheckCard.Controls.Add($runSiteCheckButton)
$siteResultsBox = New-Object System.Windows.Forms.RichTextBox
$siteResultsBox.Multiline = $true
$siteResultsBox.ScrollBars = 'Vertical'
$siteResultsBox.ReadOnly = $true
$siteResultsBox.BorderStyle = 'FixedSingle'
$siteResultsBox.WordWrap = $true
$siteResultsBox.Font = New-Object System.Drawing.Font('Consolas', 10)
$siteResultsBox.Location = New-Object System.Drawing.Point(20, 166)
$siteResultsBox.Size = New-Object System.Drawing.Size(620, 326)
$siteCheckCard.Controls.Add($siteResultsBox)

$tgCard = New-Card -X 4 -Y 20 -W 700 -H 220
$tgPage.Controls.Add($tgCard)
$tgTitle = New-Label -Text '' -X 20 -Y 18 -Size 13 -Bold $true
$tgCard.Controls.Add($tgTitle)
$tgActions = @(
    @{ Text = 'tgAppFix'; Action = 'tgAppFix' },
    @{ Text = 'tgProxyChannel'; Action = 'tgProxyChannel' },
    @{ Text = 'tgDownload'; Action = 'tgDownload' },
    @{ Text = 'tgStopProxy'; Action = 'tgStopProxy' }
)
$tgX = 20
$tgY = 62
foreach ($action in $tgActions) {
    $actionName = $action.Action
    $textKey = $action.Text
    $button = New-Button -Text (Tr $textKey) -X $tgX -Y $tgY -W 205 -H 38 -Click { Run-Action $actionName }.GetNewClosure()
    $script:ActionButtons[$textKey] = $button
    $tgCard.Controls.Add($button)
    $tgX += 220
    if ($tgX -gt 460) { $tgX = 20; $tgY += 52 }
}

$serviceCard = New-Card -X 4 -Y 20 -W 700 -H 520
$servicePage.Controls.Add($serviceCard)
$serviceTitle = New-Label -Text '' -X 20 -Y 18 -Size 13 -Bold $true
$serviceCard.Controls.Add($serviceTitle)
$serviceActions = @(
    @{ Text = 'remove'; Action = 'remove' },
    @{ Text = 'restartBypass'; Action = 'restart' },
    @{ Text = 'game'; Action = 'game' },
    @{ Text = 'ipset'; Action = 'ipset' },
    @{ Text = 'updateIp'; Action = 'update' },
    @{ Text = 'diagnostics'; Action = 'diagnostics' },
    @{ Text = 'csQuickCheck'; Action = 'csQuickCheck' },
    @{ Text = 'csStopTtl'; Action = 'csStopTtl' },
    @{ Text = 'dnsRepair'; Action = 'dnsRepair' },
    @{ Text = 'dnsRestore'; Action = 'dnsRestore' },
    @{ Text = 'clearCache'; Action = 'clearCache' },
    @{ Text = 'copyLog'; Action = 'copyLog' }
)
$serviceX = 20
$serviceY = 62
foreach ($action in $serviceActions) {
    $actionName = $action.Action
    $textKey = $action.Text
    $button = New-Button -Text (Tr $textKey) -X $serviceX -Y $serviceY -W 205 -H 34 -Click { Run-Action $actionName }.GetNewClosure()
    $script:ActionButtons[$textKey] = $button
    $serviceCard.Controls.Add($button)
    $serviceX += 220
    if ($serviceX -gt 460) { $serviceX = 20; $serviceY += 48 }
}

$serviceLogBox = New-Object System.Windows.Forms.RichTextBox
$serviceLogBox.Multiline = $true
$serviceLogBox.ScrollBars = 'Vertical'
$serviceLogBox.ReadOnly = $true
$serviceLogBox.BorderStyle = 'None'
$serviceLogBox.BackColor = [System.Drawing.Color]::FromArgb(2, 6, 23)
$serviceLogBox.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
$serviceLogBox.Font = New-Object System.Drawing.Font('Consolas', 10)
$serviceLogBox.Location = New-Object System.Drawing.Point(20, 258)
$serviceLogBox.Size = New-Object System.Drawing.Size(660, 230)
$serviceCard.Controls.Add($serviceLogBox)

$faqCard = New-Card -X 4 -Y 20 -W 700 -H 520
$faqPage.Controls.Add($faqCard)
$faqTitle = New-Label -Text '' -X 20 -Y 20 -Size 13 -Bold $true
$faqCard.Controls.Add($faqTitle)
$faqText = New-Object System.Windows.Forms.Label
$faqText.Location = New-Object System.Drawing.Point(20, 62)
$faqText.Size = New-Object System.Drawing.Size(420, 28)
$faqText.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$faqText.ForeColor = [System.Drawing.Color]::FromArgb(31, 41, 55)
$faqCard.Controls.Add($faqText)
$faqLeft = New-Object System.Windows.Forms.TextBox
$faqLeft.Location = New-Object System.Drawing.Point(24, 104)
$faqLeft.Size = New-Object System.Drawing.Size(200, 380)
$faqLeft.Multiline = $true
$faqLeft.ScrollBars = 'Vertical'
$faqLeft.ReadOnly = $true
$faqLeft.BorderStyle = 'None'
$faqLeft.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$faqLeft.ForeColor = [System.Drawing.Color]::FromArgb(31, 41, 55)
$faqCard.Controls.Add($faqLeft)
$faqRight = New-Object System.Windows.Forms.TextBox
$faqRight.Location = New-Object System.Drawing.Point(244, 104)
$faqRight.Size = New-Object System.Drawing.Size(200, 380)
$faqRight.Multiline = $true
$faqRight.ScrollBars = 'Vertical'
$faqRight.ReadOnly = $true
$faqRight.BorderStyle = 'None'
$faqRight.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$faqRight.ForeColor = [System.Drawing.Color]::FromArgb(31, 41, 55)
$faqCard.Controls.Add($faqRight)
$faqAppsTitle = New-Label -Text '' -X 464 -Y 76 -Size 10 -Bold $true
$faqCard.Controls.Add($faqAppsTitle)
$faqApps = New-Object System.Windows.Forms.TextBox
$faqApps.Location = New-Object System.Drawing.Point(464, 104)
$faqApps.Size = New-Object System.Drawing.Size(200, 380)
$faqApps.Multiline = $true
$faqApps.ScrollBars = 'Vertical'
$faqApps.ReadOnly = $true
$faqApps.BorderStyle = 'None'
$faqApps.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$faqApps.ForeColor = [System.Drawing.Color]::FromArgb(31, 41, 55)
$faqCard.Controls.Add($faqApps)

$helpCard = New-Card -X 4 -Y 20 -W 700 -H 520
$helpPage.Controls.Add($helpCard)
$helpTitle = New-Label -Text '' -X 20 -Y 20 -Size 13 -Bold $true
$helpCard.Controls.Add($helpTitle)
$helpCardsPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$helpCardsPanel.Location = New-Object System.Drawing.Point(14, 58)
$helpCardsPanel.Size = New-Object System.Drawing.Size(672, 442)
$helpCardsPanel.AutoScroll = $true
$helpCardsPanel.FlowDirection = 'TopDown'
$helpCardsPanel.WrapContents = $false
$helpCardsPanel.BorderStyle = 'None'
$helpCardsPanel.BackColor = [System.Drawing.Color]::FromArgb(250, 252, 255)
$helpCard.Controls.Add($helpCardsPanel)

$script:Bypasses = Get-BypassFiles
foreach ($item in $script:Bypasses) { [void]$combo.Items.Add($item.Label) }
if ($combo.Items.Count -gt 0) {
    $last = [string]$script:Settings.lastBypass
    $lastFile = [string]$script:Settings.lastBypassFile
    $lastByFile = if ($lastFile) { $script:Bypasses | Where-Object { $_.Name -eq $lastFile } | Select-Object -First 1 } else { $null }
    if ($lastByFile) {
        $combo.SelectedItem = $lastByFile.Label
    } elseif ($last -and $combo.Items.Contains($last)) {
        $combo.SelectedItem = $last
    } else {
        $recommended = $script:Bypasses | Where-Object { $_.Name -like '*ALT11*' -and $_.Name -notlike '*MTS*' } | Select-Object -First 1
        if (-not $recommended) { $recommended = $script:Bypasses | Where-Object { $_.Name -like '*ALT11*' } | Select-Object -First 1 }
        if ($recommended) { $combo.SelectedItem = $recommended.Label } else { $combo.SelectedIndex = 0 }
    }
    Save-Settings
}

Process-PendingAutostart

Apply-Language

$form.Add_Shown({
    Add-Log ((Tr 'appStarted') + ': ' + $Edition + '.')
    Test-PackageIntegrity | Out-Null
    Add-Log ((Tr 'bypassesFound') + ': ' + $script:Bypasses.Count + '.')
    Add-Log (Tr 'startHint')
    if (-not [bool]$script:Settings.firstRunGuideShown) { Show-FirstRunGuide }
})

$script:ReallyExit = $false
$tray = New-Object System.Windows.Forms.NotifyIcon
$tray.Text = 'Azapret Public'
if ($form.Icon) { $tray.Icon = $form.Icon } else { $tray.Icon = [System.Drawing.SystemIcons]::Shield }
$tray.Visible = $true
$trayMenu = New-Object System.Windows.Forms.ContextMenuStrip
$openItem = $trayMenu.Items.Add('Open Azapret')
$exitItem = $trayMenu.Items.Add('Exit')
$openItem.Add_Click({ $form.ShowInTaskbar = $true; $form.Show(); $form.WindowState = 'Normal'; $form.Activate() })
$exitItem.Add_Click({ $script:ReallyExit = $true; $tray.Visible = $false; $form.Close() })
$tray.ContextMenuStrip = $trayMenu
$tray.Add_DoubleClick({ $form.ShowInTaskbar = $true; $form.Show(); $form.WindowState = 'Normal'; $form.Activate() })

$form.Add_Resize({
    if ($form.WindowState -eq 'Minimized') {
        $form.ShowInTaskbar = $true
    }
})

$form.Add_FormClosing({
    if (-not $script:ReallyExit) {
        $_.Cancel = $true
        $form.ShowInTaskbar = $false
        $form.Hide()
        Add-Log (Tr 'trayHint')
    }
})

[void]$form.ShowDialog()
$tray.Visible = $false
