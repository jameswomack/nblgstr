class Frei.Photo extends Frei.Model
  @attachment 'picture', {thumb: "80x80>", medium: "260x260>", large: "640x640>"}

  @childOf 'stores'