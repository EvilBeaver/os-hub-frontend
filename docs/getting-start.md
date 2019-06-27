# Развертывание зеркала хаба hub.oscript.io

Зеркало хаба состоит из:
* Базы данных PostgreSQL
* Каталог с статическими файлами пакетов
* Веб-приложение os-hub

## Развертка с помощью docker

Развертка через docker, требуется установки на сервере docker и docker-compose. Пример установки [тут](https://www.digitalocean.com/community/tutorials/docker-ubuntu-18-04-1-ru).

Этапы:
+ Клонируем проект https://github.com/EvilBeaver/os-hub-frontend.git.
```
git clone https://github.com/EvilBeaver/os-hub-frontend.git
```
+ Копируем на сервер каталог hub.oscript.io ./docker/share
+ Копируем на сервер бекап базы PostgreSQL hub.oscript.io в каталог ./docker/database
+ Запускаем сервисы через docker-compose
```
docker-compose up --build -d
```