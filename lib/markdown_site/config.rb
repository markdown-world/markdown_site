require "tomlrb"

module MarkdownSite
    class Config
        attr_accessor :raw_config, :file, :type

        def load_file(file)
            @raw_config = begin
                Tomlrb.load_file(file)
            rescue
                {}
            end
        end

        def initialize(file, type)
            @file = file
            @type = type
            load_file(file)
            return self
        end

        def get_base_info(name)
            if @raw_config
                if @raw_config[@type.to_s]
                    return @raw_config[@type.to_s][name]
                end
            end
            ""
        end

        def get_generate_info(name)
            if @raw_config["generate"]
                return @raw_config["generate"][name]
            end
        end

        def get_template_info(name)
            if @raw_config["template"]
                return @raw_config["template"][name]
            end
        end

        def title
            get_base_info("title")
        end

        def src
            get_base_info("src")
        end

        def pages
            get_base_info("pages")
        end

        def journals
            get_base_info("journals")
        end

        def preprocessing
            if @raw_config
                return @raw_config["preprocessing"]
            end
        end

        def giscus
            if @raw_config
                return @raw_config["giscus"]
            end
        end

        def citation
            if @raw_config
                return @raw_config["citation"]
            end
        end

        def languages
            if @raw_config
                return @raw_config["languages"]
            end
        end
        
        def publish_dir
            return get_generate_info("publish_dir")
        end

        def assets_dir
            return get_generate_info("assets_dir")
        end

        def copy_files
            return get_generate_info("copy_files")
        end

        def knowledge_graph
            return get_generate_info("knowledge_graph")
        end

        def knowledge_graph_template
            return get_template_info("knowledge_graph_template")
        end

        def pages_template
            return get_template_info("pages_template")
        end
        
        def page_template
            return get_template_info("page_template")
        end

        def journal_template
            return get_template_info("journal_template")
        end

        def journals_template
            return get_template_info("journals_template")
        end        
    end
end