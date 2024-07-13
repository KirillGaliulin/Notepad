# Программа для сохранения новой записи в БД

require_relative './lib/post'
require_relative './lib/memo'
require_relative './lib/task'
require_relative './lib/link'

puts "Привет, я твой блокнот! Версия 2 + Sqlite"
puts "Что хотите записать в блокнот?"

choices = Post.post_types.keys
choice = -1

# Пока не выбран один из существующих типов записи, спрашиваем пользователя
until choice >= 0 && choice < choices.size
  choices.each_with_index do |type, index|
    puts "\t#{index}. #{type}"
  end

  # Запишем выбор пользователя в переменную choice
  choice = STDIN.gets.chomp.to_i
end

# выбор сделан, создаем запись с помощью стат. метода класса Post
entry = Post.create(choices[choice])

# Просим пользователя ввести пост (каким бы он ни был)
entry.read_from_console

# Сохраняем пост в файл
id = entry.save_to_db

puts "Ура, запись сохранена id = #{id}"