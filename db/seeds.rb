# frozen_string_literal: true

require "digest/md5"
require "net/http"
require "tempfile"

# Uncomment to see detailed logs
# ActiveRecord::Base.logger = ActiveSupport::Logger.new($stdout)

admin = User.find_or_create_by!(name: "admin") do |user|
  user.created_at = 2.weeks.ago
  user.password = "e621test"
  user.password_confirmation = "e621test"
  user.password_hash = ""
  user.email = "admin@e621.net"
  user.can_upload_free = true
  user.can_approve_posts = true
  user.level = User::Levels::ADMIN
end

User.find_or_create_by!(name: Danbooru.config.system_user) do |user|
  user.password = "ae3n4oie2n3oi4en23oie4noienaorshtaioresnt"
  user.password_confirmation = "ae3n4oie2n3oi4en23oie4noienaorshtaioresnt"
  user.password_hash = ""
  user.email = "system@e621.net"
  user.can_upload_free = true
  user.can_approve_posts = true
  user.level = User::Levels::JANITOR
end

ForumCategory.find_or_create_by!(name: "Tag Alias and Implication Suggestions") do |category|
  category.can_view = 0
end

def api_request(path)
  response = Faraday.get("https://e621.net#{path}", nil, user_agent: "e621ng/seeding")
  JSON.parse(response.body)
end

def import_posts # from https://github.com/DonovanDMC/e621ng/blob/test/db/seeds.rb#L68-L98
  ENV["DANBOORU_DISABLE_THROTTLES"] = "1"
  resources = YAML.load_file Rails.root.join("db/seeds.yml")
  if resources['tags']&.include?('order:random')
    resources['tags'] << "randseed:#{Digest::MD5.hexdigest(Time.now.to_s)}"
  end
  search_tags = resources['post_ids'].nil? || resources['post_ids'].empty? ? resources['tags'] : ["id:#{resources['post_ids'].join(',')}"]
  json = api_request("/posts.json?limit=#{ENV.fetch('SEED_POST_COUNT', 320)}&tags=#{search_tags.join('%20')}")
  json["posts"].each do |post|

    post["tags"].each do |category, tags|
      Tag.find_or_create_by_name_list(tags.map { |tag| "#{category}:#{tag}" })
    end

    #url = post["file"]["url"]
    url = "https://static1.e621.net/data/#{post['file']['md5'][0..1]}/#{post['file']['md5'][2..3]}/#{post['file']['md5']}.#{post['file']['ext']}"# if url.nil?
    puts url

    post["sources"] << "https://e621.net/posts/#{post['id']}"
    service = UploadService.new({
      uploader: CurrentUser.user,
      uploader_ip_addr: CurrentUser.ip_addr,
      direct_url: url,
      tag_string: post["tags"].values.flatten.join(" "),
      source: post["sources"].join("\n"),
      description: post["description"],
      rating: post["rating"],
    })
    #service.start!
  end
end

def import_mascots
  api_request("/mascots.json").each do |mascot|
    puts mascot["url_path"]
    Mascot.create!(
      creator: CurrentUser.user,
      mascot_file: Downloads::File.new(mascot["url_path"]).download!,
      display_name: mascot["display_name"],
      background_color: mascot["background_color"],
      artist_url: mascot["artist_url"],
      artist_name: mascot["artist_name"],
      available_on_string: Danbooru.config.app_name,
      active: mascot["active"],
    )
  end
end

unless Rails.env.test?
  CurrentUser.user = admin
  CurrentUser.ip_addr = "127.0.0.1"
  begin
    import_posts
    import_mascots
  rescue StandardError => e
    puts "--------"
    puts "#{e.class}: #{e.message}"
    puts "Failure during seeding, continuing on..."
    puts "--------"
  end
end
