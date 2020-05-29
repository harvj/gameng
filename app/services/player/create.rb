class Player::Create < Services::Create
  def apply_post_processing
    @subject.game_session.frames.create!(action: :player_created, active_player: @subject, subject: @subject)
  end
end
