class Frei.Store extends Frei.Model
  @encode "title", "description", "phone", "website", "street", "city", "state", "zip"

  @attachment 'picture', {thumb: "80x80>", medium: "260x260>", large: "640x640>"}

  @childOf 'user'