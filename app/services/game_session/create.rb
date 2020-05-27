class GameSession::Create < Services::Create
  def apply_pre_processing
    @subject.uid = Passphrase::Passphrase.new(number_of_words: 4).passphrase.tr(' ','-')
    @subject.state = :waiting
  end
end
