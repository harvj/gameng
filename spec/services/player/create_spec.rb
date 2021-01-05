require 'rails_helper'

RSpec.describe 'Player::Create' do
  let(:game)    { create(:game, :cards) }
  let(:user)    { create(:user) }
  let(:session) { game.play_class.().subject }

  let(:player_create) { Player::Create.(user, game_session: session) }

  it 'creates a player on a joinable session' do
    player = player_create.subject
    expect(player.user).to eq user
    expect(player.session).to eq session
    expect(player).not_to be_moderator
  end

  it 'add a session frame when a player joins' do
    player = player_create.subject
    frame = session.frames.last
    expect(frame.action).to eq 'player_created'
    expect(frame.acting_player).to eq player
    expect(frame.subject).to eq player
  end

  it 'does not create a player for session in progress' do
    session.start!
    expect(player_create.errors.first).to eq 'Game session in progress'
    expect(Player.count).to eq 0
  end

  it 'does not create a player for a session with max players' do
    game.update_attribute(:max_players, 1)
    player_create
    attempt = Player::Create.(create(:user, username: 'mariah'), game_session: session)
    expect(attempt.errors.first).to eq 'Game session has maximum number of players'
    expect(Player.count).to eq 1
  end
end
