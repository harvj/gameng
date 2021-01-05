class Player::Create < Services::Create
  def apply_post_processing
    SessionFrame::Create.(subject.session,
      action: :player_created,
      acting_player: subject,
      subject: subject
    )
  end
end
