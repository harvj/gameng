class GameBuild::ModernArt < GameBuild::Base
  def add_game
    game = create_game(name: 'Modern Art', slug: 'modern_art')

    %w(lite_metal yoko cristin_p karl_gitter krypto).each do |name|
      %w(fixed_price open sealed once_around double).each do |value|
        create_card(game_id: game.id, name: name, value: value)
      end
    end
  end
end
