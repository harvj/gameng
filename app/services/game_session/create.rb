class GameSession::Create < Services::Create
  def apply_pre_processing
    @subject.uid = SecureRandom.uuid
    @subject.state = :waiting
  end
end
