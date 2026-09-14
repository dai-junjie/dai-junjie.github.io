Jekyll::Hooks.register :posts, :pre_render do |post|
  post.content = post.content.gsub(
    /!\[([^\]]*)\]\((assets\/images\/[^)]+)\)/
  ) do |match|
    match.sub("(assets/", "(/assets/")
  end
end
