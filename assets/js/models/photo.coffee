class Frei.Photo extends Frei.Model
  @encode "title", "description"

  @attachment 'picture', {thumb: "80x80>", medium: "260x260>"}
