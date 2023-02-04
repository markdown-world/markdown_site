module MarkdownSite
    class KnowledgeGraphTemplate < Template
        def initialize(site)
            super(site)
        end
        def generate
            kg_template = Liquid::Template.parse(File.read(@site_config.knowledge_graph_template))
            f = File.new(@site_config.publish_dir + @site_config.knowledge_graph, "w")
            f.puts(kg_template.render('config'=>{'title'=>@site_config.title}))
            f.close
        end
    end
end