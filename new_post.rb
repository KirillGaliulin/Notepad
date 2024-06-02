require_relative 'post'
require_relative 'memo'
require_relative 'task'
require_relative 'link'

puts "Привет, я твой блокнот! Версия 2 + Sqlite"
puts "Что хотите записать в блокнот?"

choices = Post.post_types.keys
choice = -1

# Пока юзер не выбрал правильно (от 0 до длины массива вариантов), спрашиваем
# у него число и выводим список возможных вариантов для записи.
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