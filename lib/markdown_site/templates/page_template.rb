module MarkdownSite
    class PageTemplate < Template
        def initialize(site)
            super(site)
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

        def generate(site_pages, lang=nil)
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
            site_pages.each do |page|
                filename = "#{@site_config.publish_dir}/#{lang}#{page.item_name}.html"
                f = File.new(filename, "w")
                f.puts template.render(
                    'config'=>{'title'=>@site_config.title},
                    'page_title' => page.item_name,
                    'page_html' => page.html)
                f.close
            end
        end
    end
end