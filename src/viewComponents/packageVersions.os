
Функция ОбработкаВызова(model)

	ТабВерсий = Новый ТаблицаЗначений();
	ТабВерсий.Колонки.Добавить("НомерВерсии");
	ТабВерсий.Колонки.Добавить("ФайлВерсии");
	ТабВерсий.Колонки.Добавить("ДатаВерсии");
	Для Каждого СтрокаВерсии Из model.Версии Цикл
		
		Путь = ОбъединитьПути(
			УправлениеКонтентом.КаталогХраненияПакетов(),
			"download",
			model.Название,
			model.Название+"-"+СтрокаВерсии.НомерВерсии+".ospx");

		ФайлВерсии = Новый Файл(Путь);
		Если ФайлВерсии.Существует() Тогда
			Версия = ТабВерсий.Добавить();
			Версия.НомерВерсии = СтрокаВерсии.НомерВерсии;
			Версия.ФайлВерсии = "/download/"+model.Название+"/"+ФайлВерсии.Имя;
			Версия.ДатаВерсии = СтрокаВерсии.ДатаВерсии;
		КонецЕсли;
	КонецЦикла;

	Возврат Представление("Default", ТабВерсий);

КонецФункции