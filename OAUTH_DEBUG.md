# OAuth Debug Guide

## 🔐 Проблема
OAuth авторизация не работает - получаем ошибки при обмене кода на токен.

## 🛠️ Инструменты для отладки

### 1. Детальное логирование в приложении
Добавлено логирование в `AuthManager.swift`:
- PKCE параметры (verifier, challenge)
- Все параметры запроса
- Ответы от GitHub API
- Ошибки и их детали

### 2. Тестовый скрипт curl
Файл: `test_oauth.sh`

**Использование:**
```bash
# Получить authorization URL
./test_oauth.sh

# Тестировать token exchange
./test_oauth.sh <CODE>
```

### 3. Тестовая функция PKCE
В `AuthManager` добавлена функция `testPKCE()` для проверки корректности генерации PKCE параметров.

## 📋 Пошаговая отладка

### Шаг 1: Проверить PKCE параметры
1. Запустить приложение
2. В логах найти секцию "🔐 OAuth Flow Start:"
3. Проверить:
   - Code Verifier: 64 символа
   - Code Challenge: корректный base64url
   - Client ID: правильный

### Шаг 2: Проверить authorization URL
1. Скопировать URL из логов
2. Открыть в браузере
3. Убедиться, что GitHub показывает правильное приложение
4. Проверить redirect URI в настройках GitHub OAuth App

### Шаг 3: Тестировать через curl
1. Запустить `./test_oauth.sh`
2. Открыть полученный URL
3. Авторизоваться
4. Скопировать код из redirect URL
5. Запустить `./test_oauth.sh <CODE>`
6. Проверить ответ

### Шаг 4: Сравнить параметры
Сравнить параметры из curl и из приложения:
- client_id
- redirect_uri
- code_verifier
- code_challenge

## 🔍 Возможные проблемы

### 1. Неправильный Client ID
- Проверить в настройках GitHub OAuth App
- Убедиться, что используется правильный ID

### 2. Неправильный Redirect URI
- В GitHub: `zimransui://oauth-callback`
- В коде: `zimransui://oauth-callback`
- Должны совпадать точно!

### 3. Проблемы с PKCE
- Code verifier: 64 символа
- Code challenge: SHA256(verifier) в base64url
- Method: S256

### 4. Дублирующиеся OAuth Apps
- Удалить неиспользуемые OAuth Apps
- Оставить только один активный

### 5. URL Scheme в iOS
- В Xcode добавить URL Type: `zimransui`
- Проверить в Info.plist

## 📊 Логи для анализа

### Успешный OAuth Flow:
```
🔐 OAuth Flow Start:
   State: abc123...
   Code Verifier: def456...
   Code Challenge: ghi789...
   Client ID: Ov23liEI45VHtjMirJdp
   Redirect URI: zimransui://oauth-callback
   Scopes: user:email

🔐 OAuth Token Exchange:
   Client ID: Ov23liEI45VHtjMirJdp
   Redirect URI: zimransui://oauth-callback
   Code: xyz789...
   Code Verifier: def456...
   Token Endpoint: https://github.com/login/oauth/access_token
   Request Body: client_id=...&code=...&redirect_uri=...&grant_type=authorization_code&code_verifier=...
   Headers: ["Accept": "application/json", "Content-Type": "application/x-www-form-urlencoded"]
   Response Status: 200
   Response Body: {"access_token":"gho_...","token_type":"bearer","scope":"user:email"}
   ✅ Access Token received: gho_1234567...
```

### Ошибка:
```
🔐 OAuth Token Exchange:
   ...
   Response Status: 400
   Response Body: {"error":"bad_verification_code","error_description":"The code passed is incorrect or expired."}
   GitHub Error: bad_verification_code - The code passed is incorrect or expired.
```

## 🎯 Следующие шаги

1. **Запустить приложение** и попробовать OAuth
2. **Проанализировать логи** - найти где именно происходит ошибка
3. **Сравнить с curl тестом** - убедиться, что проблема в Swift коде или в настройках GitHub
4. **Проверить настройки GitHub OAuth App** - убедиться, что все параметры правильные
5. **Удалить дублирующиеся OAuth Apps** если есть
