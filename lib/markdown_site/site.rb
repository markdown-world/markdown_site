require "json"
require "liquid"
require "markdown_extension"

module MarkdownSite
    class Site
        attr_accessor :config, :pages_path, :pages, :journals, :references, :reverse_references
        attr_accessor :nodes, :links, :citations, :languages
    
        def initialize(config, type)
            @references = {}
            @reverse_references = {}
            @nodes = []
            @links = []
            @config = MarkdownSite::Config.new(config, type)            
            @languages = @config.languages
            if @config.type == :logseq
                @pages_path = @config.pages
            else
                @pages_path = @config.src
            end
            init_citations(type)
            if type == :wiki or type == :logseq or type == :obsidian
                init_pages
            end
            if type == :blog or type == :logseq
                init_journals
            end
            if type == :wiki or type == :obsidian
                init_summarys
            end
            gen_nodes_links
        end

        def init_citations(type)
            @citations = MarkdownExtension::Citations.new(@config, type) 
            files = Dir.glob(@pages_path + "/**/*.md")
            files.each do |file|
                unless file == @pages_path + "/summary.md"
                    if file.index("hls_")
                        @citations.add_inner_citation(file)
                    else
                        @citations.add_embed_citation(file)
                    end
                end
            end
        end
        
        def init_pages
            if @languages
                @pages_set = {}
                @languages.each do |lang|
                    @pages_set[lang[0]] = init_pages_by_lang("/"+lang[0])
                end
            else
                @pages = init_pages_by_lang
            end
        end
        
        def init_pages_by_lang(lang=nil)
            pages = []
            files = Dir.glob(@pages_path + lang.to_s + "/**/*.md")
            files.sort! do |a,b|
                folder_file_comparison(a,b)
            end
            files.each do |file|
                unless file == @pages_path + lang.to_s + "/summary.md"
                    unless file.index("hls_")
                        page = MarkdownExtension::Page.new(file, self, lang)
                        pages << page
                        gen_references(page.item_name , page.markdown)
                    end
                end
            end
            return pages
        end

        def folder_file_comparison(a,b)
            a_array = a.split("/")
            b_array = b.split("/")
            if a_array.length == 1
                if b_array.length == 1
                    return a<=>b
                else
                    return 1
                end
            else
                if a_array[0]==b_array[0]
                    return folder_file_comparison(a_array[1..-1].join("/"),b_array[1..-1].join("/"))
                else
                    return a_array[0]<=>b_array[0]
                end
            end
        end

        def pages(lang=nil)
            if @pages
                return @pages
            else
                if @pages_set
                    if lang
                        return @pages_set[lang]
                    else
                        return @pages_set[@languages.first[0]]
                    end
                end
            end
        end

        def init_journals
            @journals = []
            journal_files = Dir.glob(@config.journals + "/*.md")
            journal_files.each do |file|
                page = MarkdownExtension::Page.new(file, self)
                @journals << page
            end
        end

        def init_summarys
            if @languages
                @summarys = {}
                @languages.each do |lang|
                    @summarys[lang[0]] = MarkdownExtension::Summary.new(@config, lang[0])
                end
            else
                @summary = MarkdownExtension::Summary.new(@config)
            end
        end
    
        def summary(lang=nil)
            if @summary
                return @summary
            else
                if @summarys
                    if lang
                        return @summarys[lang]
                    else
                        return @summarys[@languages.first[0]]
                    end
                end
            end
        end
        
        def gen_references(item_name, text)
            text.gsub(/\[\[([^\]]+)\]\]/) do |s|
                s = s[2..-3]
                if @references[s]
                    @references[s] << item_name
                else
                    @references[s] = [item_name]
                end
                if @reverse_references[item_name]
                    @reverse_references[item_name] << s
                else
                    @reverse_references[item_name] = [s]
                end
            end
        end
    
        def gen_nodes_links
            @references.each do |k,v|
                val = @references[k] ? @references[k].size+1 : 1
                val = 5 if val > 5
                @nodes << {
                    "id" => k,
                    "name" => k,
                    "color" => "blue",
                    "val" => val
                }
                v.each do |item|
                    val = @references[item] ? @references[item].size+1 : 1
                    val = 5 if val > 5
                    @nodes << {
                        "id" => item,
                        "name" => item,    
                        "color" => "blue",
                        "val" => val
                    }
                    @links << {
                        "source" => item,
                        "target" => k
                    }
                end
            end
            @nodes = @nodes.uniq
            @links = @links.uniq
        end
    
        def write_data_json
            file = @config.publish_dir + "/data.json"
            data = {"nodes"=>@nodes, "links"=>@links}
            f = File.new(file, "w")
            f.puts JSON.generate(data)
            f.close
        end

        def init_publish_dir
            unless Dir.exist?(@config.publish_dir)
                Dir.mkdir(@config.publish_dir)
            end
            if @languages
                @languages.each do |lang|
                    unless Dir.exist?(@config.publish_dir+"/"+lang[0])
                        Dir.mkdir(@config.publish_dir+"/"+lang[0])
                    end
                end
            end
        end

        def copy_assets
            init_publish_dir
            if Dir.exist?(@config.assets_dir)
                `cp -r #{@config.assets_dir} #{@config.publish_dir}/#{@config.assets_dir}`
                @config.copy_files.each do |file|
                    `cp #{file} #{@config.publish_dir}/#{file}` 
                end
            end
        end

        def generate
            type = @config.type
            unless type == :logseq
                generate_index
            end
            if type == :wiki or type == :logseq or type == :obsidian
                generate_pages
            end
            if type == :blog or type == :logseq
                generate_journals
            end
            generate_knowledge_graph
        end

        def generate_index
            if @languages
                template = MarkdownSite::RootTemplate.new(self)
                template.generate()
            else
            end
        end

        def generate_pages
            template = MarkdownSite::PageTemplate.new(self)
            unless @languages
                template.generate(self.pages)
            else
                @languages.each do |lang|
                    template.generate(self.pages(lang[0]), "#{lang[0]}/")
                end
            end
        end

        def generate_journals
            template = MarkdownSite::JournalTemplate.new(self)
            template.generate(self.journals)
        end

        def generate_knowledge_graph
            template = MarkdownSite::KnowledgeGraphTemplate.new(self)
            template.generate()
        end
    end
end
