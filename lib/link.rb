# Класс «Ссылка», разновидность базового класса «Запись»
class Link < Post
  def initialize
    super # дергаем родительский конструктор и дополняем новым полем
    @url = ''
  end

  # Метод записывает данные из консоли в переменные класса
  def read_from_console
    puts 'Адрес ссылки (url):'
    @url = STDIN.gets.chomp

    puts 'Что за ссылка?'
    @text = STDIN.gets.chomp
  end

  # Метод возвращает строки, которые будут записаны в БД
  def to_strings
    time_string = "Создано: #{@created_at.strftime('%Y.%m.%d, %H:%M:%S')} \n"
    [@url, @text, time_string]
  end

  # Метод на сохранение в БД: добавляет два ключа, соответствующие этому типу записи помимо родительских ключей, в хэш
  def to_db_hash
    return super.merge(
      {
        'text' => @text,
        'url' => @url
      }
    )
  end

  # Метод на чтение из БД данных для класса Link: считывает дополнительно url ссылки
  def load_data(data_hash)
    super # сперва дергаем родительский метод load_data для общего поля @created_at
    @url = data_hash['url']
  end
end
