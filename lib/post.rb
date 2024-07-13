require 'sqlite3'
require 'time'

class Post
  def initialize
    @created_at = Time.now
    @text = []
  end

  # Статическое поле класса или class variable
  SQLITE_DB_FILE = './db/notepad.sqlite'.freeze

  # Связь между классом и его именем в виде строки, для удобства работы с БД
  def self.post_types
    {'Memo' => Memo, 'Link' => Link, 'Task' => Task}
  end

  def self.create(type)
    return post_types[type].new
  end

  def read_from_console
    # todo: должен реализовываться детьми, которые знают как именно считывать свои данные из консоли
  end

  def to_strings
    # todo: должен реализовываться детьми, которые знают как именно хранить себя в файле
  end

  # Метод возвращает хэш вида {'имя_столбца' => 'значение'} для сохранения в БД новой записи
  def to_db_hash
    # дочерние классы сами знают свое представление, но общие для всех классов поля
    # можно заполнить уже сейчас в базовом классе
    {
      'type' => self.class.name,
      'created_at' => @created_at.to_s
    }
    # todo: дочерние классы должны дополнять этот хэш массив своими полями
  end

  # Метод, сохраняющий состояние объекта в БД
  def save_to_db
    db = SQLite3::Database.open(SQLITE_DB_FILE)
    db.results_as_hash = true # настройка соединения к базе: результаты из БД преобразуются в хэши

    # запрос к БД на вставку новой записи в соответствии с хэшом, сформированным дочерним классом to_db_hash
    begin
      db.execute(
        "INSERT INTO posts (" +
          to_db_hash.keys.join(', ') + # все поля, перечисленные через запятую
          ")" +
          " VALUES (" +
            ('?,'*to_db_hash.keys.size).chomp(',') + # строка из заданного числа _плейсхолдеров_ ?,?,?...
          ")",
          to_db_hash.values # массив значений хэша, которые будут вставлены в запрос вместо _плейсхолдеров_
      )
      # db.execute("INSERT INTO posts (" + to_db_hash.keys.join(', ') + ")" + " VALUES (" + ('?,'*to_db_hash.keys.size).chomp(',') + ")", to_db_hash.values)
    rescue SQLite3::SQLException => e
      puts "Не удалось выполнить запрос в базе #{SQLITE_DB_FILE}"
      abort e.message
    end

    insert_id = db.last_insert_row_id
    db.close

    # возвращаем идентификатор записи в базе
    return insert_id
  end

  # Чтение из БД по id
  # Находит в БД запись по идентификатору или массив записей, который будет показан в виде таблицы в консоли
  def self.find_by_id(id)
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    db.results_as_hash = true

    begin
      # выполнение запроса, возвращающего массив результатов, в нашем случае из одного элемента по id
      result = db.execute("SELECT * FROM posts WHERE id = ?", id)
    rescue SQLite3::SQLException => e
      puts "Не удалось выполнить запрос в базе #{SQLITE_DB_FILE}"
      abort e.message
    end

    # получаем единственный результат (если вдруг вернулся массив)
    result = result[0] if result.is_a? Array
    db.close

    # если записи в БД нет по указанному id - возвращаем nil и выводим запись об этом
    if result.empty?
      puts "Такой id #{id} не найден в базе :("
      return nil
    else
      # создаем с помощью метода create экземпляр поста и будем его наполнять с помощью метода load_data;
      # тип поста взяли из массива результатов [:type];
      # номер этого типа в нашем массиве post_types нашли с помощью метода Array#find_index
      post = create(result['type'])

      # заполним этот пост содержимым и вернем его
      post.load_data(result)
      return post
    end
  end

  # Получает на вход хэш массив данных и должен заполнить поля класса
  def load_data(data_hash)
    @created_at = Time.parse(data_hash['created_at'])
    #  todo: остальные специфичные поля должны заполнить дочерние классы
  end

  # Чтение из БД всех записей
  # Находит в базе все записи по указанным параметрам и выводит их
  def self.find_all(limit, type)
    db = SQLite3::Database.open(SQLITE_DB_FILE)
    db.results_as_hash = false

    # формируем запрос в базу с нужными условиями
    query = "SELECT * FROM posts "
    query += "WHERE type = :type " unless type.nil? # если задан тип, надо добавить условие
    query += "ORDER by id DESC "
    query += "LIMIT :limit " unless limit.nil? # если задан лимит, надо добавить условие

    # готовим запрос в базу
    begin
      statement = db.prepare(query)
    rescue SQLite3::SQLException => e
      puts "Не удалось выполнить запрос в базе #{SQLITE_DB_FILE}"
      abort e.message
    end
    
    statement.bind_param('type', type) unless type.nil? # загружаем в запрос тип вместо плейсхолдера
    statement.bind_param('limit', limit) unless limit.nil? # загружаем  в запрос лимит вместо плейсхолдера

    begin
      result = statement.execute! # выполняем подготовленный запрос
    rescue => exception
      
    end

    statement.close
    db.close

    return result
  end
end
