require "json"

module Requesterable
  def select_main_menu_action
    options = %w[random scores exit]
    gets_option(options)
  end

  def will_save?(_score)
    print "Do you want to save your score? y/n "
    options = %w[y n]
    action = gets.chomp.strip.downcase
    until options.include?(action)
      print "Choose a correct alternative: y/n ".red
      action = gets.chomp.strip.downcase
    end
    case action
    when "y" then saveif
    when "n" then @score = 0
    end
  end

  def saveif
    puts "Type the name to assign to the score:"
    print "> "
    name = gets.chomp
    name = name == "" ? "Anonymous" : name
    data = { score: @score, name: name }
    save(data)
  end

  def get_number(length)
    print "> "
    election = gets.chomp.to_i
    until election < length && election.positive?
      puts "Invalid option".red
      print "> "
      election = gets.chomp.to_i
    end
    election
  end

  def gets_option(options)
    puts options.join(" | ")
    print "> "
    input = gets.chomp.strip.downcase
    puts ""

    until options.include?(input)
      puts "Invalid option".red
      print "> "
      input = gets.chomp.strip.downcase
    end
    input
  end
end