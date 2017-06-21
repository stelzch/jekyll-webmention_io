#  (c) Aaron Gustafson
#  https://github.com/aarongustafson/jekyll-webmention_io 
#  Licence : MIT
#  
#  this liquid plugin insert a webmentions into your Octopress or Jekill blog
#  using http://webmention.io/ and the following syntax:
#
#    {% webmention_likes URL %}
#   
module Jekyll
  class WebmentionLikesTag < WebmentionTag

    def initialize(tagName, text, tokens)
      super
      set_template('likes')
    end

    def set_data(data)
      webmentions = extract_type 'likes', data
      @data = { 'webmentions' => webmentions }
    end

  end
end

Liquid::Template.register_tag('webmention_likes', Jekyll::WebmentionLikesTag)