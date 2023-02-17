module MarkdownSite
    class RootTemplate < Template
        def initialize(site)
            super(site)
        end
        def generate()
            template = Liquid::Template.parse(File.read(@site_config.root_template))            
            default_path = @site_config.languages.first[0]
            f = File.new(@site_config.publish_dir + "/index.html", "w")
            f.puts template.render(
                'url'=>"#{default_path}/index.html"
            )
            f.close
        end
    end
end