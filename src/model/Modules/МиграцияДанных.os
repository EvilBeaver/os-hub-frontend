
Перем ПакетыХаба;
Перем ВерсииПакетовХаба;

Перем Канал;
Перем КартаИмен;

Функция ЗапуститьИмпортВБД() Экспорт
	
	Сообщить("Запущена миграция данных", СтатусСообщения.Внимание);
	Результат = Истина;
	
	// не мигрируем данные, если есть записи в таблице Пакеты
	КоллекцияПакеты = МенеджерБазыДанных.МенеджерСущностей.Получить(Тип("Пакет"));
		
	Попытка
		ОчиститьБазуДанных();
		ПрочитатьКартуИмен();
		ПодготовитьДанные();
		ЗагрузитьДанные();
	Исключение
		Сообщить(ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()), СтатусСообщения.ОченьВажное);
		ВызватьИсключение;
	КонецПопытки;
	
	Сообщить("Завершена миграция данных", СтатусСообщения.Внимание);

	Возврат Результат;
	
КонецФункции

// Функция СоздатьМодельДанныхСДиска() Экспорт

// 	ПрочитатьКартуИмен();
// 	ПодготовитьДанные();

	

// КонецФункции

Процедура ПрочитатьКартуИмен()
	ФайлКарты = ОбъединитьПути(СтартовыйСценарий().Каталог, "nameRemap.json");
	
	Если ФС.ФайлСуществует(ФайлКарты) Тогда
		КартаИмен = ОбщегоНазначения.ПрочитатьJson(ФайлКарты);
	Иначе
		КартаИмен = Новый Соответствие;
	КонецЕсли;
	
КонецПроцедуры

Процедура ПодготовитьДанные()
	
	ПакетыХаба = Новый ТаблицаЗначений;
	ПакетыХаба.Колонки.Добавить("Имя");
	ПакетыХаба.Колонки.Добавить("ИмяПроекта");
	ПакетыХаба.Колонки.Добавить("Описание");
	ПакетыХаба.Колонки.Добавить("Путь");
	ПакетыХаба.Колонки.Добавить("Автор");
	ПакетыХаба.Колонки.Добавить("КлючевыеСлова");
	ПакетыХаба.Колонки.Добавить("ПутьКОписанию");
	ПакетыХаба.Колонки.Добавить("Проект");
	ПакетыХаба.Колонки.Добавить("АктуальнаяВерсия");
	
	ВерсииПакетовХаба = Новый ТаблицаЗначений;
	ВерсииПакетовХаба.Колонки.Добавить("Имя");
	ВерсииПакетовХаба.Колонки.Добавить("Версия");
	ВерсииПакетовХаба.Колонки.Добавить("Путь");
	ВерсииПакетовХаба.Колонки.Добавить("Зависимости");
	ВерсииПакетовХаба.Колонки.Добавить("ДатаСоздания");
	
	КаталогХаба = УправлениеКонтентом.КаталогХраненияПакетов();
	
	Канал = "download";
	
	СписокПакетов = Новый Массив;
	ЭлементыКаталога = НайтиФайлы(ОбъединитьПути(КаталогХаба, Канал), "*");
	Для Каждого ЭлементКаталога Из ЭлементыКаталога Цикл
		Если ЭлементКаталога.ЭтоКаталог() Тогда
			Если СписокПакетов.Найти(ЭлементКаталога.Имя) = Неопределено Тогда
				СписокПакетов.Добавить(ЭлементКаталога.Имя);
				НовыйПакет = ПакетыХаба.Добавить();
				
				НовыйПакет.Имя = ЭлементКаталога.Имя;
				НовыйПакет.Путь = ОбъединитьПути(Канал, НовыйПакет.Имя);
				
				ИмяПакетаИзКарты = КартаИмен[НовыйПакет.Имя];
				НовыйПакет.ИмяПроекта = ?(ИмяПакетаИзКарты = Неопределено, НовыйПакет.Имя, ИмяПакетаИзКарты); 
				Сообщить("Найден пакет " + НовыйПакет.Путь);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого Пакет Из ПакетыХаба Цикл
		
		ПутьКМетаданным = ОбъединитьПути(КаталогХаба, Пакет.Путь, "meta.json");
		Попытка
			МетаОписание = ОбщегоНазначения.ПрочитатьJSON(ПутьКМетаданным);
		Исключение
			МетаОписание = Неопределено;
			Сообщить("Не удалось получить / прочитать meta.json пакета " + Пакет.Имя + ". Причина: " + ОписаниеОшибки());
		КонецПопытки;
		
		Если МетаОписание <> Неопределено Тогда
			Пакет.Описание = МетаОписание.Получить("Описание");
			Пакет.Автор = МетаОписание.Получить("Автор");
			Пакет.КлючевыеСлова = МетаОписание.Получить("КлючевыеСлова");
			Пакет.Проект = МетаОписание.Получить("АдресРепозитория");
			
			Пакет.АктуальнаяВерсия = МетаОписание.Получить("АктуальнаяВерсия");
		КонецЕсли;
		
		КаталогПакета = ОбъединитьПути(КаталогХаба, Канал, Пакет.Имя);
		Файлы = НайтиФайлы(КаталогПакета, "*-*.ospx");
		
		Для Каждого Файл Из Файлы Цикл
			
			НоваяВерсия = ВерсииПакетовХаба.Добавить();
			НоваяВерсия.Имя = Пакет.Имя;
			НоваяВерсия.Версия = ВерсияИзИмениФайла(НРег(Файл.ИмяБезРасширения), НРег(НоваяВерсия.Имя));
			НоваяВерсия.Путь = ОбъединитьПути(Канал, НоваяВерсия.Имя, Файл.Имя);
			НоваяВерсия.Зависимости = ПрочитатьЗависимостиПакета(Файл.ПолноеИмя);
			НоваяВерсия.ДатаСоздания = Файл.ПолучитьВремяИзменения();

			Сообщить("Найдена версия " + НоваяВерсия.Путь);
			
		КонецЦикла;
		
		ПутьКОписанию = ОбъединитьПути(Канал, Пакет.Имя, "readme.md");
		ФайлОписания = Новый Файл(ОбъединитьПути(КаталогХаба, ПутьКОписанию));
		Если ФайлОписания.Существует() Тогда
			Пакет.ПутьКОписанию = ПутьКОписанию;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗагрузитьДанные()
	
	Для Каждого СтрокаПакет Из ПакетыХаба Цикл
		
		Пакет = МенеджерБазыДанных.МенеджерСущностей.СоздатьЭлемент(Тип("Пакет"));
		Пакет.Код = СтрокаПакет.Имя; 
		Пакет.Название = Пакет.Код;
		
		Если ЗначениеЗаполнено(СтрокаПакет.Автор) Тогда
			Пакет.Автор = ПолучитьСоздатьАвтора(СтрокаПакет.Автор);
		КонецЕсли;
		
		Пакет.Описание = СтрокаПакет.Описание;
		Пакет.КлючевыеСлова = СтрокаПакет.КлючевыеСлова;
		Пакет.ИмяПроекта = СтрокаПакет.ИмяПроекта;
		Пакет.СсылкаНаПроект = СтрокаПакет.Проект;
		Пакет.ПутьКОписанию = СтрокаПакет.ПутьКОписанию;
		
		РезультатПоискаВерсий = ВерсииПакетовХаба.НайтиСтроки(Новый Структура("Имя", Пакет.Код));
		Если РезультатПоискаВерсий.Количество() = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		Пакет.Путь = ОбъединитьПути(Канал, Пакет.Код);
		Пакет.АктуальнаяВерсия = СтрокаПакет.АктуальнаяВерсия;
		Пакет.ДатаСоздания = ТекущаяДата();
		Пакет.ДатаОбновления = Пакет.ДатаСоздания;
		Пакет.Сохранить(); 
		
		Для Каждого СтрокаВерсии Из РезультатПоискаВерсий Цикл
			
			ВерсияПакета = МенеджерБазыДанных.МенеджерСущностей.СоздатьЭлемент(Тип("ВерсияПакета"));
			ВерсияПакета.Номер = СтрокаВерсии.Версия;
			ВерсияПакета.Пакет = Пакет.Код;
			ВерсияПакета.Путь = СтрокаВерсии.Путь;
			ВерсияПакета.Зависимости = ЗависимостиВерсииПакета(СтрокаВерсии.Зависимости);
			
			ВерсияПакета.ДатаСоздания = СтрокаВерсии.ДатаСоздания;
			ВерсияПакета.ДатаОбновления = СтрокаВерсии.ДатаСоздания;
			
			ВерсияПакета.Сохранить();
			
		КонецЦикла;

		Пакет.АктуальнаяВерсия = АктуальнаяВерсияПакетаИзКанала(Пакет);
		Пакет.Сохранить();
		
	КонецЦикла;
	
КонецПроцедуры

Функция АктуальнаяВерсияПакетаИзКанала(Пакет) Экспорт
	
	// выполним произвольный запрос
	Результат = Неопределено;
	
	Отбор = Новый Соответствие;
	Отбор.Вставить("Пакет", Пакет.Код); // TODO: хотелось бы Пакет = Пакет
	РезультатПоиска = МенеджерБазыДанных.МенеджерСущностей.Получить(Тип("ВерсияПакета"), Отбор);
	
	МассивВерсий = Новый Массив;
	Для Каждого Строка Из РезультатПоиска Цикл
		МассивВерсий.Добавить(Строка.Номер);
	КонецЦикла;
	
	// отсортировать по возврастанию
	Попытка	
		СортировкаВерсий.СортироватьВерсии(МассивВерсий, "Возр");
	Исключение
		Сообщить("Не удалось отсортировать версии пакета " + Пакет);
		Возврат Неопределено;
	КонецПопытки;
	
	// берем последнюю
	Если МассивВерсий.Количество() > 0 Тогда
		Результат = МассивВерсий[МассивВерсий.ВГраница()];
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция ЗависимостиВерсииПакета(Зависимости) Экспорт
	
	Массив = Новый Массив;
	
	Для Каждого СтрокаЗависимость Из Зависимости Цикл
		
		Зависимость = МенеджерБазыДанных.МенеджерСущностей.СоздатьЭлемент(Тип("Зависимость"));
		Зависимость.Пакет = СтрокаЗависимость.Пакет;
		Зависимость.Версия = СтрокаЗависимость.Версия;
		Зависимость.МаксимальнаяВерсия = СтрокаЗависимость.МаксимальнаяВерсия; 
		Зависимость.Сохранить();
		
		Массив.Добавить(Зависимость);
		
	КонецЦикла;
	
	Возврат Массив;
	
КонецФункции

Процедура ОчиститьБазуДанных()
	
	Сообщить("Очистка базы данных");
	МенеджерБазыДанных.МенеджерСущностей.ПолучитьКоннектор().ВыполнитьЗапрос("DELETE FROM ВерсияПакета_Зависимости");
	ОчиститьТаблицуСущности("ВерсияПакета");
	ОчиститьТаблицуСущности("Зависимость");
	ОчиститьТаблицуСущности("Пакет");
	ОчиститьТаблицуСущности("Автор");
	
	
КонецПроцедуры

Функция ВерсияИзИмениФайла(ИмяФайла, Пакет)
	
	Возврат СтрЗаменить(ИмяФайла, Пакет + "-", "");
	
КонецФункции

Процедура ОчиститьТаблицуСущности(Тип)
	
	Коллекция = МенеджерБазыДанных.МенеджерСущностей.Получить(Тип(Тип));
	Для Каждого ЭлементКоллекции Из Коллекция Цикл
		МенеджерБазыДанных.МенеджерСущностей.Удалить(ЭлементКоллекции);	
	КонецЦикла;
	
КонецПроцедуры

Функция ПрочитатьЗависимостиПакета(ИмяФайла) Экспорт
	
	КоллекцияЭлементов = Новый Массив;
	Архив = Новый ЧтениеZipФайла();
	Попытка
		Архив.Открыть(ИмяФайла,, КодировкаИменФайловВZipФайле.UTF8);
	Исключение
		Сообщить(ИмяФайла);
		Сообщить(ОписаниеОшибки());
		Возврат Новый Массив;
	КонецПопытки;
	ЭлементМанифеста = Архив.Элементы.Найти("opm-metadata.xml");
	Если ЭлементМанифеста = Неопределено Тогда
		Возврат КоллекцияЭлементов;
	КонецЕсли;
	
	ВременныйКаталог = ПолучитьИмяВременногоФайла();
	Попытка
		СоздатьКаталог(ВременныйКаталог);
	Исключение
		ВызватьИсключение "Не удалось создать временный каталог";
	КонецПопытки;
	Архив.Извлечь(ЭлементМанифеста, ВременныйКаталог);
	Архив.Закрыть();
	
	ПутьКМетаданным = ОбъединитьПути(ВременныйКаталог, "opm-metadata.xml");
	
	Чтение = Новый ЧтениеXML();
	Попытка
		Чтение.ОткрытьФайл(ПутьКМетаданным);
		Пока Чтение.Прочитать() Цикл
			Если Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента И Чтение.Имя = "depends-on" Тогда
				Зависимость = Новый Структура("Пакет, Версия, МаксимальнаяВерсия");
				Зависимость.Пакет = Чтение.ЗначениеАтрибута("name");
				Зависимость.Версия = Чтение.ЗначениеАтрибута("version");
				Если Не ЗначениеЗаполнено(Зависимость.Версия) Тогда
					Зависимость.Версия = "0";
				КонецЕсли;
				Зависимость.МаксимальнаяВерсия = "999";
				
				КоллекцияЭлементов.Добавить(Зависимость);
			КонецЕсли;
		КонецЦикла;
	Исключение
		Сообщить("Не удалось прочитать метаданные " + ИмяФайла);
	КонецПопытки;
	Чтение.Закрыть();
	
	Попытка
		УдалитьФайлы(ВременныйКаталог);
	Исключение
		Сообщить("Не удалось удалить временный каталог: " + ВременныйКаталог);
	КонецПопытки;
	
	Возврат КоллекцияЭлементов;
	
КонецФункции

Функция ПолучитьСоздатьАвтора(ИмяАвтора) Экспорт
	
	Если Не ЗначениеЗаполнено(ИмяАвтора) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	// todo: Переделать!
	МенеджерАвторов = Новый Автор();
	Автор = МенеджерАвторов.НайтиАвтораПоИмени(МенеджерБазыДанных.МенеджерСущностей, ИмяАвтора);
	Если Автор = Неопределено Тогда
		Автор = МенеджерБазыДанных.МенеджерСущностей.СоздатьЭлемент(Тип("Автор"));
	КонецЕсли;
	Автор.Имя = ИмяАвтора;
	Автор.Сохранить();
	
	Возврат Автор;
	
КонецФункции