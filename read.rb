# Программа для чтения записей из БД

require_relative './lib/post.rb'
require_relative './lib/link.rb'
require_relative './lib/memo.rb'
require_relative './lib/task.rb'
require 'optparse'

# Все опции командной строки, которые умеем обрабатывать, перед запуском нашей программы
options = {}
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

# Если не передали в консоли параметр id, то ищем все записи
if options[:id].nil?
  result = Post.find_all(options[:limit], options[:type])
else
  # Если передали в консоли параметр id, то выводим данные по этому id
  result = Post.find_by_id(options[:id])
end

# показываем конкретный пост
if result.is_a? Post
  puts "Запись #{result.class.name}, id = #{options[:id]}"
  result.to_strings.each { |line| puts line }

# показываем таблицу результатов
else
  print "| id\t| @type\t| @created_at\t\t\t| @text\t\t\t| @url\t\t| @due_date \t\n"
  print "_"*100

  result.each do |row|
    puts
    # puts '_'*150
    row.each do |element|
      print "| #{element.to_s.delete("\\n\\r")[0...40]}\t"
    end
  end
end

puts
