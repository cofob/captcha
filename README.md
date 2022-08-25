# Каптча

[![wakatime](https://wakatime.com/badge/user/ebd31081-494e-4581-b228-7619d0fe1080/project/ede8089f-021e-4860-bd73-6ca2c81fa203.svg)](https://wakatime.com/badge/user/ebd31081-494e-4581-b228-7619d0fe1080/project/ede8089f-021e-4860-bd73-6ca2c81fa203)

Простая каптча для телеграмма. Бот просит новых участников нажать на кнопку, которая переводит пользователя в чат с ботом и передаёт код авторизации.
Бот проверяет код авторизации и если он совпадает то снимает ограничения с пользователя и удаляет сообщение.

## Запуск

### Подготовка env

```
API_ID=с my.telegram.org
API_HASH=с my.telegram.org
TOKEN=из @botfather
SECRET=случайная строка
```

### NixOS flake

```nix
services.tg-captcha = {
    enable = true;
    envFile = "/path/to/env/secrets";
};
```


Сделано специально для чата [Yggdrasil](https://t.me/yggdrasil_re)
