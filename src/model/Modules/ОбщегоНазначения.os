#Использовать logos
#Использовать json
#Использовать fs
#Использовать github

Перем Лог;

#Область ОбщийФункционал

Функция ПолучитьЛог() Экспорт
	Возврат Логирование.ПолучитьЛог("oscript.web.hub-frontend");
КонецФункции

Функция ПрочитатьJSON(Знач Путь, Знач КакСтруктуру = Ложь) Экспорт
	Файл = Новый ЧтениеТекста(Путь);
	Текст = Файл.Прочитать();
	Файл.Закрыть();
	Парсер = Новый ПарсерJSON;
	Данные = Парсер.ПрочитатьJSON(Текст,,,КакСтруктуру);
	Возврат Данные;
КонецФункции

Функция ЗначениеПеременнойСреды(ИмяПараметра) Экспорт
	
	ЗначениеПеременной = ПолучитьПеременнуюСреды(ИмяПараметра);
	Возврат Строка(ЗначениеПеременной); // неопределено в строку
	
КонецФункции

Функция ДвоичныеДанныеИзHTTPЗапроса(ЗапросHTTP) Экспорт
	
	Поток = ЗапросHTTP.ПолучитьТелоКакПоток();
	ЧтениеДанных = Новый ЧтениеДанных(Поток);
	Возврат ЧтениеДанных.Прочитать().ПолучитьДвоичныеДанные();
	
КонецФункции

Функция ВычислитьКодОшибки(ИнформацияОбОшибке) Экспорт
	
	ПараметрыОшибки = ИнформацияОбОшибке.Параметры;
	Если ПараметрыОшибки = Неопределено Тогда
		ПараметрыОшибки = 500;
	КонецЕсли;
	Возврат ПараметрыОшибки;
	
КонецФункции

Функция КаталогПубликации() Экспорт
	
	КаталогПубликации = ЗначениеПеременнойСреды("PATH_TO_OSCRIPT_HUB");
	Если Не ЗначениеЗаполнено(КаталогПубликации) Тогда
		КаталогПубликации = "/var/www/hub.oscript.io";
	КонецЕсли;
	
	Возврат КаталогПубликации;
	
КонецФункции

Процедура ПроверитьИСоздатьПользовательБекОфиса() Экспорт

	Логин = ЗначениеПеременнойСреды("OSHUB_DEFAULT_USER");
	Если ПустаяСтрока(Логин) Тогда
		Логин = "admin";
	КонецЕсли;
	Пароль = ЗначениеПеременнойСреды("OSHUB_DEFAULT_PASSWORD");
	Если ПустаяСтрока(Пароль) Тогда
		Пароль = "admin";
	КонецЕсли;

	Пользователь = ПользователиИнформационнойБазы.НайтиПоИмени(Логин);
	Если Пользователь = Неопределено Тогда
		Пользователь = ПользователиИнформационнойБазы.СоздатьПользователя();
		Пользователь.Имя = Логин;
		Пользователь.Пароль = Пароль;
		Пользователь.Записать();
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область РаботаСПакетом

Процедура ЗафиксироватьПакет(Каталог, ДвоичныеДанные, Знач ИмяФайла, ОписаниеПакета, ЭтоТестоваяСборка) Экспорт
	
	ПутьККаталогуПакета = ОбъединитьПути(Каталог, ОписаниеПакета.Идентификатор);
	ФС.ОбеспечитьКаталог(ПутьККаталогуПакета);
	Если ЭтоТестоваяСборка Тогда
		// Записываем файл как SNAPSHOT
		ИмяФайла = СтрШаблон("%1-SNAPSHOT.ospx", ОписаниеПакета.Идентификатор);
	Иначе
		// Фиксируем присланный файл как последний
		ДвоичныеДанные.Записать(ОбъединитьПути(ПутьККаталогуПакета, ОписаниеПакета.Идентификатор + ".ospx"));
	КонецЕсли;

	// Фиксируем присланный файл с версией
	ПутьКФайлу = ОбъединитьПути(ПутьККаталогуПакета, ИмяФайла);
	ДвоичныеДанные.Записать(ПутьКФайлу);

	ЗафиксироватьПакетВБД(ОписаниеПакета, ПутьККаталогуПакета, ИмяФайла, ЭтоТестоваяСборка);
	СформироватьList(Каталог);
	
КонецПроцедуры

Процедура ЗафиксироватьПакетВБД(ОписаниеПакета, ПутьККаталогуПакета, ИмяФайла, ЭтоТестоваяСборка)
	
	Идентификатор = ОписаниеПакета.Идентификатор;
	ТекущаяДата = ТекущаяДата();
	
	// пишем в пакет
	Пакет = МенеджерБазыДанных.МенеджерСущностей.ПолучитьОдно(Тип("Пакет"), Идентификатор);
	Если Пакет = Неопределено Тогда
		Пакет = МенеджерБазыДанных.МенеджерСущностей.СоздатьЭлемент(Тип("Пакет"));
		Пакет.Код = Идентификатор; 
		Пакет.Название = Пакет.Код;
		Пакет.Путь = ОбъединитьПути(ГлобальныйКонтекст.КаталогПакетов, Пакет.Код);
		Пакет.ДатаСоздания = ТекущаяДата;
		
		Пакет.Сохранить();
	КонецЕсли;
	
	// Автор ?
	Если Не ЗначениеЗаполнено(Пакет.Автор) Тогда
		МетаданныеПакета = ОбщегоНазначения.МетаданныеПакета(ОбъединитьПути(ПутьККаталогуПакета, ИмяФайла));
		АвторИмя = "";
		МетаданныеПакета.Свойство("Автор", АвторИмя); 
		Если ЗначениеЗаполнено(АвторИмя) Тогда
			Пакет.Автор = МиграцияДанных.ПолучитьСоздатьАвтора(АвторИмя);
		КонецЕсли;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Пакет.СсылкаНаПроект) Тогда
		Пакет.СсылкаНаПроект = СсылкаНаПроектПоПакету(Пакет);
	КонецЕсли;
	
	Пакет.ДатаОбновления = ТекущаяДата;
	
	// пишем в версии пакетов
	Зависимости = МиграцияДанных.ПрочитатьЗависимостиПакета(ОбъединитьПути(ПутьККаталогуПакета, ИмяФайла));
	
	НомерВерсии  = ?(ЭтоТестоваяСборка, "SNAPSHOT", ОписаниеПакета.Версия);
	Отбор = Новый Соответствие();
	Отбор.Вставить("Номер", НомерВерсии);
	Отбор.Вставить("Пакет", Пакет.Код);
	ВерсияПакета = МенеджерБазыДанных.МенеджерСущностей.ПолучитьОдно(Тип("ВерсияПакета"), Отбор);
	Если ВерсияПакета = Неопределено Тогда
		
		ВерсияПакета = МенеджерБазыДанных.МенеджерСущностей.СоздатьЭлемент(Тип("ВерсияПакета"));
		ВерсияПакета.Номер 			= НомерВерсии;
		ВерсияПакета.Пакет 			= Пакет.Код;
		ВерсияПакета.Путь 			= ОбъединитьПути(ГлобальныйКонтекст.КаталогПакетов, Пакет.Код, ИмяФайла);
		ВерсияПакета.ДатаСоздания 	= ТекущаяДата;
		
	КонецЕсли;

	ВерсияПакета.ТестоваяСборка = ЭтоТестоваяСборка;
	ВерсияПакета.ДатаОбновления = ТекущаяДата;
	
	// чистить старые зависимости?
	ВерсияПакета.Зависимости = МиграцияДанных.ЗависимостиВерсииПакета(Зависимости);
	ВерсияПакета.Сохранить();
	
	Если Не ЭтоТестоваяСборка Тогда
		АктуальнаяВерсияДО = Пакет.АктуальнаяВерсия;
		АктуальнаяВерсия = МиграцияДанных.АктуальнаяВерсияПакетаИзКанала(Пакет);
		Пакет.АктуальнаяВерсия = ?(АктуальнаяВерсия = Неопределено, АктуальнаяВерсияДО, АктуальнаяВерсия);
	КонецЕсли;
	
	Пакет.Сохранить();
	
КонецПроцедуры

Процедура СформироватьList(КаталогПубликации)
	
	ПутьКСпискуПакетов = ОбъединитьПути(КаталогПубликации, "list.txt");
	НайденныеФайлы = НайтиФайлы(КаталогПубликации, ПолучитьМаскуВсеФайлы(), Ложь);
	ЗаписьТекста = Новый ЗаписьТекста(ПутьКСпискуПакетов, КодировкаТекста.UTF8NoBom);
	
	Для Каждого НайденныйФайл Из НайденныеФайлы Цикл
		
		Если НайденныйФайл.ЭтоФайл() Тогда
			Продолжить;
		КонецЕсли;
		
		ЗаписьТекста.ЗаписатьСтроку(НайденныйФайл.Имя);
		
	КонецЦикла;
	
	ЗаписьТекста.Закрыть();
	
КонецПроцедуры

Процедура ПроверитьКорректностьФайла(ИмяФайла) Экспорт
	Если НЕ СтрЗаканчиваетсяНа(ИмяФайла, ".ospx") Тогда
		ВызватьИсключение
		Новый ИнформацияОбОшибке("Недопустимое расширение файла пакета. Допускаются только файлы ospx.", 401);
	КонецЕсли;
КонецПроцедуры

Функция ОписаниеПакета(ИмяФайла) Экспорт
	
	Описание = Новый Структура;
	Описание.Вставить("Идентификатор", ИмяПакетаИзИмениФайла(ИмяФайла));
	Описание.Вставить("Версия", ВерсияПакетаИзИмениФайла(ИмяФайла));
	
	Возврат Описание;
	
КонецФункции

Функция ИмяПакетаИзИмениФайла(ИмяФайла)
	
	ИмяПакетаМассив = СтрРазделить(ИмяФайла, "-");
	ИмяПакета = "";
	Для сч = 0 По ИмяПакетаМассив.ВГраница() - 1 Цикл
		ИмяПакета = ИмяПакета + ИмяПакетаМассив[сч] + "-";
	КонецЦикла;
	ИмяПакета = Лев(ИмяПакета, СтрДлина(ИмяПакета) - 1);
	
	Возврат ИмяПакета;
	
КонецФункции

Функция ВерсияПакетаИзИмениФайла(ИмяФайла)
	
	ИмяПакетаМассив = СтрРазделить(ИмяФайла, "-");
	Версия = ИмяПакетаМассив[ИмяПакетаМассив.ВГраница()];
	Версия = СтрЗаменить(Версия, ".ospx", "");
	
	Возврат Версия;
	
КонецФункции

Функция ВерсияПакетаНайдена(ИмяПакета, НомерВерсии, ТестоваяСборка) Экспорт

	Результат = Ложь;

	Отбор = Новый Соответствие();
	Отбор.Вставить("Пакет", ИмяПакета);
	Отбор.Вставить("Номер", НомерВерсии);

	Версия = МенеджерБазыДанных.МенеджерСущностей.ПолучитьОдно(Тип("ВерсияПакета"), Отбор);
	Если Версия <> Неопределено Тогда
		Результат = Версия.ТестоваяСборка = ТестоваяСборка; // пока так, по идее там всегда булево?
	КонецЕсли;

	Возврат Результат;

КонецФункции

Функция СсылкаНаПроектПоПакету(Пакет)
	
	ТокенАвторизации = ЗначениеПеременнойСреды("GITHUB_AUTH_TOKEN");
	
	Сервер = "https://github.com";
	Соединение = Новый HTTPСоединение(Сервер);
	Адрес = СтрШаблон("oscript-library/%1", Пакет.ИмяПроекта);
	
	Запрос = Новый HTTPЗапрос(Адрес);
	Ответ = Соединение.Получить(Запрос);
	
	Если Ответ.КодСостояния = 200 Тогда
		Результат = Сервер + "/" + 	Адрес;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция МетаданныеПакета(Знач ФайлПакета) Экспорт
	ЧтениеПакета = Новый РаботаСФайламиПакетов;
	Возврат ЧтениеПакета.ПрочитатьМетаданныеПакета(ФайлПакета).Свойства();
КонецФункции

#КонецОбласти

#Область github

Функция ПользовательGitHubПоТокену(Токен) Экспорт
	
	Клиент = Новый КлиентGitHub(Токен);
	Возврат Клиент.ПолучитьПользователя(Новый ПользовательGitHub());
	
КонецФункции

Функция ЕстьРазрешениеОтправлятьВРепозиторий(ИмяПользователя, ИмяРепозитория) Экспорт
	
	Результат = Ложь;
	
	Организация = "oscript-library";
	Клиент = Новый КлиентGitHub(ОбщегоНазначения.ЗначениеПеременнойСреды("GITHUB_SUPER_TOKEN"));
	Сотрудники = Клиент.ПолучитьСотрудниковРепозитория(Организация, ИмяРепозитория);
	Для Каждого Сотрудник Из Сотрудники Цикл
		Если Сотрудник.Логин = ИмяПользователя Тогда
			Результат = Сотрудник.Разрешения.Отправка;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти

Лог = ПолучитьЛог();