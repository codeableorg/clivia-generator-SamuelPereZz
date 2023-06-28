require_relative "clivia_generator"

# capture command line arguments (ARGV)
new_file = ARGV.shift
trivia = TriviaGenerator.new(new_file.nil? ? "scores.json" : new_file)
trivia.start

