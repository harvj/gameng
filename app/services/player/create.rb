class Player::Create < Services::Create
  def initialize(player, params)
    super(player, params.merge(
      action_phase: 'inactive'
    ))
  end

  def apply_post_processing
    SessionFrame::Create.(subject.session,
      action: :player_created,
      acting_player: subject,
      subject: subject
    )
  end
end
