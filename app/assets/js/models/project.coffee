class NG.Project extends NG.Model
  @encode "title", "body"

  @attachment 'picture', {thumb: "80x80>", medium: "260x260>"}
