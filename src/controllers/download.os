
Функция Download() Экспорт

	Путь = Сред(ЗапросHttp.Путь,2);
	ПутьКФайлу = ОбъединитьПути(УправлениеКонтентом.КаталогХраненияПакетов(), Путь);
	ИскомыйФайл = Новый Файл(ПутьКФайлу);
	
	Если ИскомыйФайл.Существует() и ИскомыйФайл.ЭтоФайл() Тогда
		Возврат Файл(ПутьКФайлу, "application/octet-stream", ИскомыйФайл.Имя);
	КонецЕсли;

	Возврат КодСостояния(404);

КонецФункции