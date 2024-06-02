require 'sqlite3'
require 'time'

class Post
  def initialize
    @created_at = Time.now
    @text = []
  end

  # Статическое поле класса или class variable
  # аналогично статическим методам принадлежит всему классу в целом
  # и доступно незвисимо от созданных объектов
  @@SQLITE_DB_FILE = 'notepad.sqlite'

  # Теперь нам нужно будет читать объекты из базы данных
  # поэтому удобнее всегда иметь под рукой связь между классом и его именем в виде строки
  def self.post_types
    {'Memo' => Memo, 'Link' => Link, 'Task' => Task}
  end

  # Параметром теперь является строковое имя нужного класса
  def self.create(type)
    return post_types[type].new
  end

  def read_from_console
    # todo: должен реализовываться детьми, которые знают как именно считывать свои данные из консоли
  end

  def to_strings
    # todo: должен реализовываться детьми, которые знают как именно хранить себя в файле
  end

  def save
    file = File.new(file_path, 'w')

    for item in to_strings do
      file.puts(item)
    end

    file.close
  end

  def file_path
    current_path = File.dirname(__FILE__)

    file_name = @created_at.strftime("#{self.class.name}_%Y-%m-%d %H-%M-%S.txt")

    return current_path + "/" + file_name
  end

  # Метод возвращает хэш вида {'имя_столбца' => 'значение'} для сохранения в БД новой записи
  def to_db_hash
    # дочерние классы сами знают свое представление, но общие для всех классов поля
    # можно заполнить уже сейчас в базовом классе!
    {
      # self - ключевое слово, указывает на 'этот объект'
      # то есть конкретный экземпляр класса, где выполняется в данный момент этот код
      'type' => self.class.name,
      # self ссылается на текущий экземпляр класса, в котором вызывается метод. 
      # .class получает доступ к классу экземпляра, 
      # .name - имя этого класса в виде строки. Это полезно для определения типа объекта в базе данных.
      'created_at' => @created_at.to_s
    }
    # todo: дочерние классы должны дополнять этот хэш массив своими полями
  end

    # Получает на вход хэш массив данных и должен заполнить свои поля
    def load_data(data_hash)
      @created_at = Time.parse(data_hash['created_at'])
      #  todo: остальные специфичные поля должны заполнить дочерние классы
    end

  # Метод, сохраняющий состояние объекта в БД
  def save_to_db
    db = SQLite3::Database.open(@@SQLITE_DB_FILE) # открываем соединение к базе SQLite
    db.results_as_hash = true # настройка соединения к базе
    # он результаты из БД преобразует в Руби хэши

    # запрос к БД на вставку новой записи в соответствии с хэшом, сформированным дочерним классом to_db_hash
    db.execute(
      "INSERT INTO posts (" +
        to_db_hash.keys.join(', ') + # все поля, перечисленные через запятую
        ")" +
        " VALUES (" +
          ('?,'*to_db_hash.keys.size).chomp(',') + # строка из заданного числа _плейсхолдеров_ ?,?,?...
        ")",
        to_db_hash.values # массив значений хэша, которые будут вставлены в запрос вместе _плейсхолдеров_
    )
    # db.execute("INSERT INTO posts (" + to_db_hash.keys.join(', ') + ")" + " VALUES (" + ('?,'*to_db_hash.keys.size).chomp(',') + ")", to_db_hash.values)

    insert_id = db.last_insert_row_id

    # закрываем соединение
    db.close

    # возвращаем идентификатор записи в базе
    return insert_id
  end

  # Находит в базе запись по идентификатору или массив записей из базы данных,
  # который можно например показать в виде таблицы на экране
  def self.find_by_id(id)
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    db.results_as_hash = true

    # выполняем наш запрос, он возвращает массив результатов, в нашем случае из одного элемента
    result = db.execute("SELECT * FROM posts WHERE id = ?", id)
    # получаем единственный результат (если вернулся массив)
    result = result[0] if result.is_a? Array
    db.close

    if result.empty?
      puts "Такой id #{id} не найден в базе :("
      return nil
    else
      # создаем с помощью нашего же метода create экземпляр поста и будем его наполнять с помощью метода load_data;
      # тип поста мы взяли из массива результатов [:type];
      # номер этого типа в нашем массиве post_type нашли с помощью метода Array#find_index
      post = create(result['type'])

      #   заполним этот пост содержимым
      post.load_data(result)

      # и вернем его
      return post
    end
  end

  # Находит в базе все записи по указанным параметрам и выводит их
  def self.find_all(limit, type)
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    db.results_as_hash = false

    # формируем запрос в базу с нужными условиями
    query = "SELECT * FROM posts "
    query += "WHERE type = :type " unless type.nil? # если задан тип, надо добавить условие
    query += "ORDER by id DESC "
    query += "LIMIT :limit " unless limit.nil? # если задан лимит, надо добавить условие

    # готовим запрос в базу
    statement = db.prepare(query)
    statement.bind_param('type', type) unless type.nil? # загружаем в запрос тип вместо плейсхолдера
    statement.bind_param('limit', limit) unless limit.nil? # загружаем  в запрос лимит вместо плейсхолдера

    result = statement.execute! #(query) # выполняем

    statement.close
    db.close

    return result
  end
end
