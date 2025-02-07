Feedjira.configure do |config|
  config.parsers = [
    Feedjira::Parser::RSS,
    Feedjira::Parser::Atom,
    Feedjira::Parser::AtomYoutube,
    Feedjira::Parser::AtomYoutubeEntry
  ]
end
