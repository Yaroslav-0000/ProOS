term.clear()
term.setCursorPos(1,1)

local level = 1

while true do
  if level == 1 then
    -- Level 1: соглашение пользователя
    term.clear()
    print("ProOS Installer")
    print("----------------")
    print("Пожалуйста, прочитайте соглашение пользователя.")
    print("[Принять]   [Отказаться]")

    local event, key, y, button = os.pullEvent()
    if event == "mouse_click" then
      -- тут проверка координат кнопок
      level = 2 -- если принять
    elseif event == "key" and key == keys.enter then
      level = 2 -- тоже принять для примера
    end

  elseif level == 2 then
    -- Level 2: соглашение установки / выбор опций
    term.clear()
    print("Настройка установки ProOS")
    print("Выберите директорию или диск")
    print("[Начать установку]   [Назад]")
    -- обработка нажатий
    level = 3 -- после подтверждения

  elseif level == 3 then
    -- Level 3: прогресс бар установки
    term.clear()
    print("Установка ProOS...")
    for i=1,50 do
      term.write("=")
      sleep(0.1) -- имитация скачивания/установки
    end
    print("\nУстановка завершена!")
    level = 4

  elseif level == 4 then
    -- Level 4: окно с кнопкой перезагрузить
    term.clear()
    print("ProOS успешно установлен!")
    print("[Перезагрузить ПК для запуска ProOS]")
    local event, key, y, button = os.pullEvent()
    if event == "mouse_click" or (event == "key" and key == keys.enter) then
      os.reboot()
    end
  end
end
