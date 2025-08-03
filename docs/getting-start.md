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
Можно обойтись просто созданием папки, без загрузки и разворачиванеия бекапа, хаб будет пустой.

+ Устанавливаем переменные среды в docker-compose.yml:
```
OSHUB_BINARY_ROOT=/opt/opm-hub/packages
GITHUB_SUPER_TOKEN=
POSTGRES_PASSWORD=
PGADMIN_DEFAULT_EMAIL=
PGADMIN_DEFAULT_PASSWORD=
OSWEB_DATABASE__CONNECTIONSTRING=Host=db;Username=postgres;Password=postgres;Database=postgres;port=5432;
OSWEB_Database__DBTYPE=postgres #Тип СУБД 
OSHUB_DEFAULT_USER=admin
OSHUB_DEFAULT_PASSWORD=admin
OSHUB_TG_NOTIFICATION=true #Отправка уведомлений в телеграм
TELEGRAM_TOKEN= #Токен к боту для отправки уведомлений
TELEGRAM_GROUP_ID= #Группа в которую будет отправляться уведомления
```
+ Запускаем сервис db с postgresql и pgadmin
```
docker-compose up -d db
docker-compose up -d pgadmin
```
+ Загружаем бекап (пока вручную через pgadmin).

+ Запускаем сервисы через docker-compose
```
docker-compose up --build -d
```
