RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.order = :random

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before do
    DatabaseCleaner.strategy = :transaction
  end
end

# --- GameSession helper methods

def new_session
  game.play_class.().subject
end

def add_player
  Player::Create.(user, game_session: session)
end

def session_proceed
  game.play_class.(session, user)
end

def create_and_start_session
  new_session
  start_session
end

def start_session
  add_player
  session_proceed
end
