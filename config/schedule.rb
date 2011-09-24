every 1.month do
  rake "db:backup"
  rake "sitemap:refresh"
end