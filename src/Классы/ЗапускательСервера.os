&ЛогПроксиСервера
Перем Лог;

&Пластилин Перем ОбработчикСоединений;
//АдресСервера
Перем АдресСервера Экспорт;
//ПортСервера
Перем ПортСервера Экспорт;
//ПортПрокси
Перем ПортПрокси Экспорт;
//ПутьКФайлуПроверок
Перем ПутьКФайлуПроверок Экспорт;

&Желудь
Процедура ПриСозданииОбъекта()
КонецПроцедуры 

Процедура Запустить() Экспорт
	ОбъектПроверок = РаботаСФайломПроверок.Подключить(ПутьКФайлуПроверок);
	Если ОбъектПроверок = Неопределено Тогда
		Возврат;
	КонецЕсли;
	Попытка
		Сервер = Новый TCPСервер(ПортПрокси);
		Сервер.Запустить();
		Шаблон = "Прокси-сервер запущен на порту %1 к хранилищу tcp://%2:%3";
		ТекстСообщения = СтрШаблон(Шаблон, ПортПрокси, АдресСервера, ПортСервера);
		Лог.Информация(ТекстСообщения);
	Исключение
		Шаблон =
		"
		|###################################################################################
		| >>> Ошибка запуска прокси-сервера на порту %1 к хранилищу tcp://%2:%3
		| >>> Возможно, порт %1 занят другой программой (или запущенным экземпляром этой)
		|###################################################################################
		|
		|%4";
		Сообщить(СтрШаблон(Шаблон, ПортПрокси, АдресСервера, ПортСервера, ОписаниеОшибки()));
	КонецПопытки;
	ОбработчикСоединений.ПроверкиПроксиСервера = ОбъектПроверок;
	ОбработчикСоединений.АдресСервера = АдресСервера;
	ОбработчикСоединений.ПортСервера = ПортСервера;
	Пока Истина Цикл
		Если РаботаСФайломПроверок.ФайлПроверокИзменился(ПутьКФайлуПроверок) Тогда
			ОбъектПроверок = РаботаСФайломПроверок.Подключить(ПутьКФайлуПроверок);
			Если ОбъектПроверок = Неопределено Тогда
				Сообщить("Не удалось подключить измененный файл %1, прокси-сервер остановлен.");
				Сервер.Остановить();
				Возврат;
			Иначе
				ОбработчикСоединений.ПроверкиПроксиСервера = ОбъектПроверок;
				Сообщить(СтрШаблон("Сценарий файла проверок перезагружен так как был изменен: %1", ПутьКФайлуПроверок));
			КонецЕсли;
		КонецЕсли;
		Соединение = Сервер.ОжидатьСоединения();
		МассивПараметров = Новый Массив;
		МассивПараметров.Добавить(Соединение);
		ФоновыеЗадания.Выполнить(ОбработчикСоединений, "ОбработатьСоединение", МассивПараметров);
	КонецЦикла;
КонецПроцедуры
