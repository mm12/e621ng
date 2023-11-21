require 'csv'
CurrentUser.user=user.find(1)
CurrentUser.ip_addr = '0.0.0.0'
def do_import(fileName='sampleData.csv')
  csv_text = File.read(Rails.root.join('db', '', fileName))
  csv = CSV.parse(csv_text, :headers => true)
  csv.each_entry do |row|
    t=as_post(row)
    t.save
    #puts(Post.find(t.id))
    #UploadService?
  end
end
  def as_post(row)
    t = Post.new
    t.id = row['id']
    t.created_at = row['created_at']
    t.updated_at = row['updated_at']
    t.up_score = row['up_score']
    t.down_score = row['down_score']
    t.score = row['score']
    t.source = ''#row['source']
    t.md5 = row['md5']
    t.rating = row['rating']
    t.is_note_locked = row['is_note_locked']
    t.is_rating_locked = row['is_rating_locked']
    t.is_status_locked = row['is_status_locked']
    t.uploader_id = 2 #row['uploader_id']
    t.image_width = row['image_width']
    t.image_height = row['image_height']
    t.tag_string = ""#row['tag_string']
    t.locked_tags = ""#row['locked_tags']
    t.fav_count = row['fav_count']
    t.file_ext = row['file_ext']
    t.parent_id = row['parent_id']
    t.change_seq = row['change_seq']
    t.approver_id = 1 #row['approver_id']
    t.file_size = row['file_size']
    t.comment_count = row['comment_count']
    t.description = row['description']
    t.duration = row['duration']
    t.is_deleted = row['is_deleted']
    t.is_pending = row['is_pending']
    t.is_flagged = row['is_flagged']
    t.uploader_ip_addr = '0.0.0.0'
    t.fav_string = ""
    t.pool_string = ""
    t.last_noted_at = nil
    t.generated_samples = nil
    t.bg_color = nil
    t.tag_count_lore = 0
    t.tag_count_invalid = 0
    t.tag_count_species = 0
    t.tag_count_meta = 0
    t.bit_flags = 0
    t.has_active_children = false
    t.last_commented_at = 0
    t.has_children = false
    t.last_noted_at= nil
    t.last_comment_bumped_at= nil
    t.tag_count= 0
    t.tag_count_general = 0
    t.tag_count_artist= 0
    t.tag_count_character=0
    t.tag_count_copyright = 0
    return t
  end

