require "htmlentities"
require "json"
require "terminal-table"
require "colorize"
require_relative "presenter"
require_relative "requester"
require_relative "trivia"

class TriviaGenerator
  include Presenterable
  include Requesterable

  def initialize(filename)
    @questions = []
    @decoder = HTMLEntities.new
    @score = 0
    @filename = filename
    File.open(@filename, "w") unless File.exist?(@filename)
    jsonstring = File.read(@filename)
    @report = jsonstring.empty? ? [] : JSON.parse(jsonstring)
  end

  def start
    print_welcome
    action = select_main_menu_action
    until action == "exit"
      case action
      when "random" then random_trivia
      when "scores" then print_scores
      when "exit" then puts "Thank you for using the CLIVIA app.\n-Sam P."
      end
      print_welcome
      action = select_main_menu_action
    end
  end

  def random_trivia
    load_questions.each do |questions|
      puts "Category: #{@decoder.decode(questions[:category])} | Difficulty: #{@decoder.decode(questions[:difficulty])}"
      ask_questions(questions)
      puts ""
    end
    print_score(@score)
    puts "-" * 50
    will_save?(@score)
    puts ""
  end

  def ask_questions(questions)
    correct_index = 0
    selected_alternative = ""
    puts "Question: #{@decoder.decode(questions[:question])}"
    @alternatives = questions[:incorrect_answers].push(questions[:correct_answer]).shuffle
    @alternatives.each_with_index.map do |e, index|
      puts "#{index + 1}. #{@decoder.decode(e)}"
      correct_index = index + 1 if e == questions[:correct_answer]
    end
    selection = get_number(questions[:incorrect_answers].length + 1)
    @alternatives.each_with_index.map do |e, index|
      selected_alternative = e if selection == index + 1
    end
    ask_questions_refactorizing(selection, correct_index, selected_alternative, questions)
  end

  def ask_questions_refactorizing(selection, correct_index, selected_alternative, questions)
    if selection == correct_index
      puts "#{@decoder.decode(selected_alternative)}... Correct!"
      @score += 10
    else
      puts "#{selected_alternative}... Incorrect!"
      puts "The correct answer was: #{questions[:correct_answer]}"
    end
  end

  def save(data)
    @report << data
    File.open(@filename, "w") do |file|
      file.write @report.to_json
    end
    @score = 0
  end

  def load_questions
    @questions = TriviaAPI.index[:results]
  end

  def print_scores
    jsonstring = File.read(@filename)
    @report = jsonstring.empty? ? [] : JSON.parse(jsonstring)
    table = Terminal::Table.new
    table.title = "Top Scores"
    table.headings = %w[Name Score]
    report_sorted = @report.sort { |x, y| y["score"] <=> x["score"] }.map { |unit| [unit["name"], unit["score"]] }
    report_fifth = []
    report_sorted.each_with_index { |e, index| (report_fifth << e if index < 5) }
    table.rows = report_fifth
    puts table
    puts ""
  end
end

