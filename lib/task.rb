require 'date'

# Класс Задача, разновидность базового класса "Запись"
class Task < Post
  def initialize
    super # дергаем родительский конструктор и дополняем новым полем
    @due_date = ''
  end

  # Метод записывает данные из консоли в переменные класса
  def read_from_console
    # Спросим у пользователя, какую задачу нужно сделать
    puts "Что надо сделать?"
    @text = STDIN.gets.chomp

    # Спросим у пользователя, до какого числа ему нужно это сделать и подскажем формат для ввода даты
    puts "К какому числу? Укажите дату в формате ДД.ММ.ГГГГ, например 12.05.2003"
    input = STDIN.gets.chomp

    # Для того, чтобы записть дату в удобном формате, воспользуемся методом parse класса Time
    @due_date = Date.parse(input)
  end

  # Метод возвращает строки, которые будут записаны в БД
  def to_strings
    time_strings = "Создано : #{@created_at.strftime("%Y.%m.%d, %H:%M:%S")}\n\r"
    deadline = "Крайник срок: #{@due_date}"
    return [deadline, @text, time_strings]
  end

  # Метод на сохранение в БД: добавляет два ключа, соответствующие этому типу записи помимо родительских ключей, в хэш
  def to_db_hash
    return super.merge(
      {
        'text' => @text,
        'due_date' => @due_date.to_s
      }
    )
  end

  # Метод на чтение из БД данных для класса Task: считывает дополнительно due_date задачи
  def load_data(data_hash)
    super(data_hash) # сперва дергаем родительский метод load_data для общего поля @created_at
    @due_date = Date.parse(data_hash['due_date'])
  end
end