module MarkdownSite
    class JournalTemplate < Template
        def initialize(site)
            super(site)
        end
        def generate(site_journals)
            journal_list = []
            site_journals.reverse.each do |journal|
                journal_template = Liquid::Template.parse(File.read(@site_config.journal_template))
                journal_html = journal_template.render('title'=>journal.item_name, 'content'=>journal.html)
                journal_list << journal_html
            end

            template = Liquid::Template.parse(File.read(@site_config.journals_template))
            page_count = (journal_list.size / 20) + 1
            1.upto(page_count) do |page_number|
                pagination, f = get_pagination("index", page_count, page_number)
                page_start = (page_number-1)*20
                if page_number == page_count        
                    f.puts(template.render('config'=>{'title'=>@site_config.title}, 'journal_list'=>journal_list[page_start..-1], 'pagination'=>pagination))
                else
                    f.puts(template.render('config'=>{'title'=>@site_config.title}, 'journal_list'=>journal_list[page_start..page_start+19], 'pagination'=>pagination))
                end
                f.close
            end
        end
    end
end