require "fileutils"

module MarkdownSite
    class PageTemplate < Template
        def initialize(site)
            super(site)
            @summary_page = {}
        end

        def add_page(page)
            if @site.references[page.item_name]
                return {
                    "item_name"=>page.item_name, 
                    "references"=>@site.references[page.item_name].size,
                    "ctime"=>page.ctime,
                    "mtime"=>page.mtime
                }
            else
                return {"item_name"=>page.item_name, "references"=>0, "ctime"=>page.ctime, "mtime"=>page.mtime}
            end
        end

        def get_summary_html(lang=nil, dir=nil)
            if @summary_page[lang] == nil
                temp_file = false
                path = @site.pages_path+"/"+lang+"summary.md"
                unless File.exist?(path)
                    temp_file = true
                    f = File.new(path, 'w')
                    parent_path = []
                    @site_pages.each do |page|
                        if page.path.include?("/")
                            output_str = ""
                            paths = page.path.split("/")
                            0.upto(paths.length-2) do |i|
                                if parent_path[i]
                                    if parent_path[i] == paths[i]
                                        output_str = output_str + "    "
                                    else
                                        output_str = output_str + "* " + paths[i] + "\n" + "    "*(i+1)
                                        parent_path[i] = paths[i]
                                        parent_path = parent_path[0..i]
                                    end
                                else
                                    output_str = output_str + "* " + paths[i] + "\n" + "    "*(i+1)
                                    parent_path << paths[i]
                                end
                            end
                            output_str = output_str + "* [" + paths[-1] + "](#{page.path}.html)\n"
                            f.puts(output_str)
                        else
                            f.puts("* [#{page.path}](#{page.path}.html)\n")
                        end
                    end
                    f.close
                end
                @summary_page[lang] = MarkdownExtension::Summary.new(@site_config, lang)
                File.delete(path) if temp_file
                return @summary_page[lang].html(dir)
            else
                return @summary_page[lang].html(dir)
            end
        end

        def generate(site_pages, lang=nil)
            @site_pages = site_pages
            template = Liquid::Template.parse(File.read(@site_config.pages_template))
            page_count = (site_pages.size / 20) + 1
            1.upto(page_count) do |page_number|
                pagination, f = get_pagination("#{lang}pages", page_count, page_number)
                page_start = (page_number-1)*20
                pages = []
                if page_number == page_count
                    site_pages[page_start..-1].each do |page|
                        pages << add_page(page)
                    end
                else
                    site_pages[page_start..page_start+20].each do |page|
                        pages << add_page(page)
                    end
                end
                f.puts(template.render('config'=>{'title'=>@site_config.title}, 'pages'=>pages, 'pagination'=>pagination))
                f.close
            end
            template = Liquid::Template.parse(File.read(@site_config.page_template))
            default_lang = @site_config.languages.first[1]
            site_pages.each do |page|
                if page.path.include?("/")
                    dir = "#{@site_config.publish_dir}/#{lang}#{page.path.split("/")[0..-2].join("/")}"
                    FileUtils.mkdir_p(dir)
                end
                filename = "#{@site_config.publish_dir}/#{lang}#{page.path}.html"
                f = File.new(filename, "w")
                f.puts template.render(
                    'config'=>{'title'=>@site_config.title},
                    'default_lang'=>default_lang,
                    'languages' => @site.languages,
                    'summary_html' => get_summary_html(lang, page.path.split("/")[0..-2].join("/")),
                    'page_title' => page.item_name,
                    'page_html' => page.html)
                f.close
            end
        end
    end
end