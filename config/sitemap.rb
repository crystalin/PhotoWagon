%w(dubai japon zurich).each do |subdomain|
  SitemapGenerator::Sitemap.default_host = "http://#{subdomain}.crystalin.fr"
  SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/#{subdomain}"
  SitemapGenerator::Sitemap.create do

    Post.on_site(subdomain).each do |post|
      add post_path(post), :lastmod => post.updated_at
    end
  end
end