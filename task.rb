require 'date'
# Класс Задача, разновидность базового класса "Запись"
class Task < Post
  def initialize
    # Вызовем одноимённый метод (initialize) родителя (Post) методом super
    super

    # потом инициализируем специфичное для Задачи поле - @due_date
    @due_date = ''
  end

  # Этот метод будет спрашивать 2 строки - описание задачи и дату дедлайна.
  # Мы полностью переопределяем метод read_from_console родителя Post
  def read_from_console
    # Спросим у пользователя, что за задачу ему нужно сделать
    # Одной строчки будет достаточно
    puts "Что надо сделать?"
    @text = STDIN.gets.chomp

    # А теперь спросим у пользователя, до какого числа ему нужно это сделать
    # И подскажем формат, в котором нужно вводить дату
    puts "К какому числу? Укажите дату в формате ДД.ММ.ГГГГ, например 12.05.2003"
    input = STDIN.gets.chomp

    # Для того, чтобы записть дату в удобном формате, воспользуемся методом parse класса Time
    @due_date = Date.parse(input)
  end

  # Метод to_string должен вернуть все строки, которые мы хотим записать в
  # файл при записи нашей задачи: строку с дедлайном, описание задачи и дату
  # создания задачи.
  def to_strings
    time_strings = "Создано : #{@created_at.strftime("%Y.%m.%d, %H:%M:%S")}\n\r"
    deadline = "Крайник срок: #{@due_date}"

    return [deadline, @text, time_strings]
  end

  def to_db_hash
    return super.merge(
      {
        'text' => @text,
        'due_date' => @due_date.to_s
      }
    )
  end

  def load_data(data_hash)
    super(data_hash) # сперва дергаем родительский метод для инициализации общих полей

    # теперь прописывае свое специфичное поле
    @due_date = Date.parse(data_hash['due_date'])
  end
end