#  (c) Aaron Gustafson
#  https://github.com/aarongustafson/jekyll-webmention_io 
#  Licence : MIT
#  
#  Base webmention tag
#   
module Jekyll
  class WebmentionTag < Liquid::Tag
    include WebmentionIO

    def initialize(tagName, text, tokens)
      super
      @text = text
      @targets = []
      @template = ''
      @data = {}
    end

    def set_template(template)
      supported_templates = ['all','count','likes','replies','reposts']
      
      log 'error', "#{template} is not supported" if ! supported_templates.include? template

      if @config['templates'].has_key? template
        template_file = @config['templates'][template]
      else
        template_file = File.join(File.dirname(File.expand_path(__FILE__)), "../../templates/#{template}.html")
      end

      handler = File.open(template_file, 'rb')
      @template = handler.read
    end
    
    def set_data(data)
      @data = data
    end

    def render_template()
      if @template
        template = Liquid::Template.parse(@template)
        template.render(@data, { strict_variables: true })
      else
        log 'warn', 'No template provided'
        ""
      end
    end

    def render(context)
      output = super
      
      args = @text.split(/\s+/).map(&:strip)
      args.each do |url|
        target = lookup(context, url)
        @targets.push(target)
        if @config.has_key? 'legacy_domains'
          log 'info', 'adding legacy URLs'
          @config['legacy_domains'].each do |domain|
            legacy = target.sub @jekyll_config['url'], domain
            log 'info', "adding #{legacy}"
            @targets.push(legacy)
          end
        end
      end
      
      # execute the API
      api_params = @targets.collect { |v| "target[]=#{v}" }.join('&')
      response = get_response(api_params)
      log 'info', response.inspect

      # set the data
      set_data( response )
      
      # render the template
      render_template()
    end
  end
end