class GameBuild::ModernArt < GameBuild::Base
  STYLE_ATTRS = {
    lite_metal:   { color: 'yellow' },
    yoko:         { color: 'light-green' },
    cristin_p:    { color: 'dark-pink' },
    karl_gitter:  { color: 'light-purple' },
    krypto:       { color: 'light-brown' },
    fixed:        { icon_class: 'dollar-sign' },
    open:         { icon_class: 'arrows-alt' },
    sealed:       { icon_class: 'circle' },
    once_around:  { icon_class: 'redo' },
    double:       { icon_class: 'equals' }
  }

  def add_game
    game = create_game(name: 'Modern Art', slug: 'modern_art')

    %w(lite_metal yoko cristin_p karl_gitter krypto).each_with_index do |name, i|
      %w(double open sealed once_around fixed).each_with_index do |value, j|
        create_card(
          game_id: game.id,
          name: name,
          value: value,
          color: STYLE_ATTRS[name.to_sym][:color],
          icon_class: STYLE_ATTRS[value.to_sym][:icon_class],
          game_logical_sort: i * 10 + j
        )
      end
    end
  end
end
