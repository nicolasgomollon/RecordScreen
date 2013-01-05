class String
  def self.colorize(text, color_code)
    "\e[#{color_code}m#{text}\e[0m"
  end

  def cyan
    self.class.colorize(self, 36)
  end

  def green
    self.class.colorize(self, 32)
  end
end

desc 'Set up dummy fonts'
task :setup do
  # Update and initialize the submodules in case they forget
  puts 'Updating submodules...'.cyan
  `git submodule update --init --recursive`

  # Make placeholder fonts
  puts 'Creating dummy fonts...'.cyan
  `mkdir -p Resources/Fonts`
  `touch Resources/Fonts/Gotham-Bold.otf`
  `touch Resources/Fonts/Gotham-BoldItalic.otf`
  `touch Resources/Fonts/Gotham-Book.otf`
  `touch Resources/Fonts/Gotham-BookItalic.otf`
  `touch Resources/Fonts/MyriadPro-Bold.otf`
  `touch Resources/Fonts/MyriadPro-Regular.otf`

  # Done!
  puts 'Done! You\'re ready to get started!'.green
end

# Run setup by default
task :default => :setup
