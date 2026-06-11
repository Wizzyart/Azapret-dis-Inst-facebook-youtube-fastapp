# Azapret Public: встроенный Telegram proxy

Это основной Public-релиз Azapret для Windows. В нём добавлен встроенный локальный Telegram proxy и исправлен его автозапуск после перезагрузки.

## Скачать

Нужен только этот файл:

```text
AzapretApp-Public.zip
```

Архивы с CSGO2 / FACEIT TTL в этом релизе не нужны. Основной Public-релиз - это `AzapretApp-Public.zip`.

## Как запустить

1. Скачайте `AzapretApp-Public.zip`.
2. Полностью распакуйте архив в отдельную папку.
3. Запустите `Azapret.exe`.
4. Для обычного обхода нажмите `Проверка сети`, затем `Старт`.
5. Для Telegram откройте вкладку `Телеграм` и нажмите `Прокси для TG`.
6. В Telegram подтвердите подключение proxy.

## Что нового в Telegram

- Встроен локальный Telegram MTProto proxy.
- Proxy запускается на `127.0.0.1`.
- Azapret сам открывает Telegram с правильной proxy-ссылкой.
- Добавлен отдельный автозапуск Telegram proxy в Windows.
- Исправлена проблема, когда после перезагрузки менялся `secret` и Telegram показывал `connecting`.
- Config proxy теперь пишется UTF-8 без BOM.
- Добавлена кнопка `Стоп TG прокси`.

## Скриншоты и инструкция

### 1. Откройте вкладку Telegram в Azapret

![Telegram в Azapret](https://raw.githubusercontent.com/Wizzyart/Azapret-dis-Inst-facebook-youtube-fastapp/main/docs/screenshots/telegram/telegram-main.jpg)

### 2. Нажмите `Прокси для TG`

Azapret запустит локальный proxy и откроет Telegram с правильной ссылкой.

![Кнопка Telegram proxy](https://raw.githubusercontent.com/Wizzyart/Azapret-dis-Inst-facebook-youtube-fastapp/main/docs/screenshots/telegram/telegram-proxy-1.jpg)

### 3. Подтвердите proxy в Telegram

Если Telegram показывает старые записи `127.0.0.1:1443`, удалите их и добавьте proxy заново через Azapret.

![Настройки proxy в Telegram](https://raw.githubusercontent.com/Wizzyart/Azapret-dis-Inst-facebook-youtube-fastapp/main/docs/screenshots/telegram/telegram-proxy-2.jpg)

### 4. Убедитесь, что proxy подключился

После подключения Telegram может использовать локальный proxy автоматически.

![Telegram proxy подключён](https://raw.githubusercontent.com/Wizzyart/Azapret-dis-Inst-facebook-youtube-fastapp/main/docs/screenshots/telegram/telegram-proxy-3.jpg)

## Автозапуск Telegram proxy

После успешного запуска Azapret создаёт отдельный автозапуск:

```text
AzapretTGProxy
```

Он запускает:

```text
app\Start-TG-Proxy.ps1
```

Этот wrapper перед стартом proxy записывает корректный `%APPDATA%\TgWsProxy\config.json`, чтобы Telegram proxy поднимался после перезагрузки с тем же `secret`.

## Если Telegram не подключается

1. Удалите старые proxy `127.0.0.1:1443` в Telegram.
2. В Azapret нажмите `Стоп TG прокси`.
3. Нажмите `Прокси для TG` заново.
4. Подтвердите новый proxy в Telegram.

## Проверено перед релизом

- PowerShell syntax.
- Наличие `TgWsProxy_windows.exe`.
- Автозапуск через `AzapretTGProxy`.
- Стабильность `secret` после cold-start теста.
- Локальный listener `127.0.0.1:1443`.
- Реальное подключение Telegram через `kws*.web.telegram.org`.

## Third-party notice

Локальный Telegram proxy использует `Flowseal/tg-ws-proxy` под MIT License. Notice включён в архиве:

```text
app\docs\TG-WS-PROXY-NOTICE.md
```
