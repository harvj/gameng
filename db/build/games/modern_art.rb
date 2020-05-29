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

    %w(lite_metal yoko cristin_p karl_gitter krypto).each_with_index do |name, name_sort|
      %w(double sealed open once_around fixed).each_with_index do |value, value_sort|
        create_card(
          game_id: game.id,
          name: name,
          name_sort: name_sort,
          value: value,
          value_sort: value_sort,
          color: STYLE_ATTRS[name.to_sym][:color],
          icon_class: STYLE_ATTRS[value.to_sym][:icon_class],
        )
      end
    end
  end
end
