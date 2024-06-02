require_relative 'post.rb'
require_relative 'link.rb'
require_relative 'memo.rb'
require_relative 'task.rb'

# будем обрабатывать параметры командной строки по-взрослому с помощью спец. библиотеки руби
require 'optparse'

# Все наши опции будут записаны сюда
options = {}
# заведем нужные нам опции
OptionParser.new do |opt|
  opt.banner = 'Usage: read.rb [options]'

  opt.on('-h', 'Prints this help') do
    puts opt
    exit
  end

  opt.on('--type POST_TYPE', 'какой тип постов показывать (по умолчанию любой)') { |o| options[:type] = o } #
  opt.on('--id POST_ID', 'если задан id - показываем подробно только этот пост') { |o| options[:id] = o } #
  opt.on('--limit NUMBER', 'сколько последних постов показать (по умолчанию все)') { |o| options[:limit] = o} #

end.parse!

result = Post.find(options[:limit], options[:type], options[:id])

# показываем конкретный пост
if result.is_a? Post
  puts "Запись #{result.class.name}, id = #{options[:id]}"
  # выведем весь пост на экран и закроемся
  result.to_strings.each do |line|
    puts line
  end

# показываем таблицу результатов
else
  print "| id\t| @type\t| @created_at\t\t\t| @text\t\t\t| @url\t\t| @due_date \t"

  result.each do |row|
    puts
    # puts '_'*80
    row.each do |element|
      print "| #{element.to_s.delete("\\n\\r")[0...40]}\t"
    end
  end
end

puts

# Фигурные скобки {...} после вызова метода в простых случаях аналогичны конструкции do ... end
# Они ограничивают блок кода который будет выполняться этим методов
# 
# см. http://stackoverflow.com/questions/5587264/do-end-vs-curly-braces-for-blocks-in-ruby