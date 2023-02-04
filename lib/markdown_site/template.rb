module MarkdownSite
    class Template
        attr_accessor :site_config

        def initialize(site)
            @site = site
            @site_config = site.config
        end

        def get_pagination(url, count, number)
            pagination = {}
            pagination["pages"] = []
            if number == 1
                f = File.new("#{@site_config.publish_dir}/#{url}.html", "w")
                pagination["previous"]="#"
                pagination["next"]="#{url}_#{number+1}.html"
            elsif number == 2
                f = File.new("#{@site_config.publish_dir}/#{url}_#{number}.html", "w")
                pagination["previous"]="#{url}.html"
                pagination["next"]="#{url}_#{number+1}.html"
            elsif number == count
                f = File.new("#{@site_config.publish_dir}/#{url}_#{number}.html", "w")        
                pagination["previous"]="#{url}_#{number-1}.html"
                pagination["next"]="#"
            else
                f = File.new("#{@site_config.publish_dir}/#{url}_#{number}.html", "w")
                pagination["previous"]="#{url}_#{number-1}.html"
                pagination["next"]="#{url}_#{number+1}.html"
            end
            1.upto(count) do |p_i|
                if p_i == 1
                    page_url = "#{url}.html"
                else
                    page_url = "#{url}_#{p_i}.html"
                end
                if number == p_i
                    pagination["pages"] << {"active"=>true, "url"=>page_url, "number"=>"#{p_i}"}
                else
                    pagination["pages"] << {"active"=>false, "url"=>page_url, "number"=>"#{p_i}"}
                end
            end
            return pagination, f
        end
    end
end