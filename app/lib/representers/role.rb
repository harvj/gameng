module Representers
  class Role
    include ActionView::Helpers::AssetTagHelper

    def build_object(role)
      {
        id: role.id,
        img_path: image_path("#{role.name}.png")
        name: role.name
      }
    end
  end
end
