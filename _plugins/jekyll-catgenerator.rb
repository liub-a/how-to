module Jekyll

  class CategoriesGenerator < Generator

    safe true

    def generate(site)
      site.data['categorys'].each do |category, data|
        posts = [category, posts_by_category(site, category)]
        build_subpages(site, 'category', posts)
      end
    end

    def build_subpages(site, type, posts)
      posts[1] = posts[1].sort_by { |p| -p.date.to_f }
      paginate(site, type, posts)
    end

    def paginate(site, type, posts)
      pages = Jekyll::Paginate::Pager.calculate_pages(posts[1], site.config['paginate'].to_i)
      (1..pages).each do |num_page|
        pager = Jekyll::Paginate::Pager.new(site, num_page, posts[1], pages)
        path = "/category/#{posts[0]}"
        if num_page > 1
          path = path + "/page#{num_page}"
        end
        newpage = GroupSubPageAuthor.new(site, site.source, path, type, posts[0])
        newpage.pager = pager
        site.pages << newpage

      end
    end

    private

    def posts_by_category(site, author)
      site.posts.docs.select { |post| post.data['category'] == author }
    end
  end

  class GroupSubPageAuthor < Page
    def initialize(site, base, dir, type, val)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), "category.html")
      self.data["grouptype"] = type
      self.data[type] = val
    end
  end
end
