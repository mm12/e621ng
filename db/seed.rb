require 'csv'
#ActiveRecord::Base.logger.level = 1
CurrentUser.user=User.find(1)
CurrentUser.ip_addr = '0.0.0.0'
latest = "2023-11-21"



def do_import_posts(date)
  totalPosts = 4430739
  fileName = "posts-#{date}.csv"
  ActiveRecord::Base.logger.silence(Logger::ERROR) do
    warn "#{DateTime.now} ::: begining"
    diff = DateTime.now
    last_processed = Post.last.id
    CSV.foreach(Rails.root.join('db', '', fileName),headers:true) do |row|
      begin
      next if (last_processed >row['id'].to_i) 
      if (last_processed ==row['id'].to_i) 
        do_progress(row['id'], totalPosts, diff)
        warn "RESUMING"
        diff = DateTime.now
        next 
      end
      if(((row['id'].to_i) % 5000) ==0)
        warn "#{DateTime.now} ::: #{row['id']}\t#{TimeDiff(diff)}" #puts(t.id)
        diff=DateTime.now
        warn (((row['id'].to_f) / (4430739.to_f))*100).round(3)
      end
      t=as_post(row)
      t.save
    rescue ActiveRecord::RecordNotUnique => e
      #warn e
      next
    end
    rescue ActiveRecord::RecordInvalid => e
      #warn e
      next
    end
  end
end
def do_import_imply(date)
  totalImply = 52697
  fileName = "tag_implications-#{date}.csv"
  ActiveRecord::Base.logger.silence(Logger::WARN) do
    diff = DateTime.now
    CSV.foreach(Rails.root.join('db', '', fileName),headers:true) do |row|
      begin 
        next if (TagImplication.last.id >=row['id'].to_i) 
        t=to_imply(row).save!
        rescue ActiveRecord::RecordNotUnique => e
          #warn e
          next
        end
        rescue ActiveRecord::RecordInvalid => e
          #warn e
          next
        end
        if(row["id"]%5000 == 0) 
          warn (do_progress(row["id"], totalImply,diff))
          diff = DateTime.now
        end
        diff=do_every(diff,t.id,totalImply,5000)
  end
end
def do_import_alias(date)
  totalAlias = 64715
  fileName = "tag_aliases-#{date}.csv"
  ActiveRecord::Base.logger.silence(Logger::WARN) do
    diff = DateTime.now
    last = TagAlias.last.id
    CSV.foreach(Rails.root.join('db', '', fileName),headers:true) do |row|
    begin 
        next if (last >=(row['id'].to_i))
        to_alias(row).save!
      rescue ActiveRecord::RecordNotUnique => e
        #warn e
        next
      end
      rescue ActiveRecord::RecordInvalid => e
        #warn e
        next
      end
      #t.save!
      diff=do_every(diff,row['id'],totalAlias)  
    end
end

def do_import_tag(date)
  totalTags = 1262653
  fileName = "tags-#{date}.csv"
  last = Tag.last.id
  diff = DateTime.now
  ActiveRecord::Base.logger.silence(Logger::WARN) do
    CSV.foreach(Rails.root.join('db', '', fileName),headers:true) do |row|
      next if (last > (row['id'].to_i))
      if(row['id']%5000 == 0)
        warn "#{TimeDiff(diff)}"
        warn "#{DateTime.now}\t#{row['id']}\t"
        warn "#{((row['id'].to_f / totalTags.to_f)*100).round(3)}"
        diff = DateTime.now
      end
      t=to_tag(row)
      t.save
    end
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
  t.source = row['source']
  t.md5 = row['md5']
  t.rating = row['rating']
  t.is_note_locked = row['is_note_locked']
  t.is_rating_locked = row['is_rating_locked']
  t.is_status_locked = row['is_status_locked']
  t.uploader_id = 2 #row['uploader_id']
  t.image_width = row['image_width']
  t.image_height = row['image_height']
  t.tag_string = row['tag_string']
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
def to_imply(row)
  t = TagImplication.create
  t.id = row['id']
  t.antecedent_name = row['antecedent_name']
  t.consequent_name = row['consequent_name']
  t.created_at = row['created_at']
  t.creator_id = 2
  t.approver_id = 1
  t.status = row['status']
  t.creator_ip_addr = '0.0.0.0'
  return t
end
def to_alias(row)
  t = TagAlias.new
  t.id = row['id']
  t.antecedent_name = row['antecedent_name']
  t.consequent_name = row['consequent_name']
  t.created_at = row['created_at']
  t.creator_id = 2
  t.approver_id = 1
  t.status = row['status']
  t.creator_ip_addr = '0.0.0.0'
  return t 
end
def to_tag(row)
  t = Tag.new 
  t.name = (row['name'])
  t.category = row['category']
  t.id=row["id"]
  return t
end
def do_progress(currentID, tq, lastCall)
  return "#{DateTime.now} :: (#{TimeDiff(lastCall)}) \t#{currentID}\t#{((currentID.to_f / tq.to_f)*100).round(3)}"
end
def TimeDiff(oldTime)
  diff = DateTime.now - oldTime
  return Time.at(diff.days.seconds.to_i).utc.strftime("%H:%M:%S")
end
def do_every(lastDone, currentID, totals, interval=5000)
  if(currentID % interval !=0) 
    return lastDone 
  end 
  do_progress(currentID,totals,lastDone)
  return DateTime.now
end

def make_pool(row)
  t = Pool.new 
  t.id=row["id"]
  t.creator_id=2
  t.name = (row['name'])
  t.category = row['category']
  t.is_active = row["is_active"]
  t.category = row["category"]
  t.post_ids = row["post_ids"]
  return t
end

def do_import_pool(date)
  totalPools = 37654
  fileName = "pools-#{date}.csv"
  #last = Tag.last.id
  #diff = DateTime.now
  ActiveRecord::Base.logger.silence(Logger::WARN) do
    CSV.foreach(Rails.root.join('db', '', fileName),headers:true) do |row|
      #next if (last >= (row['id'].to_i))
      make_pool(row).save
    end
  end
end



def make_page(row)
  t = WikiPage.new 
  t.id=row["id"]
  t.creator_id=2
  t.is_locked = (row['is_locked'])
  t.body = row['body']
  t.title = row["title"]
  return t
end

def do_import_pages(date)
  totalPools = 55177
  fileName = "wiki_pages-#{date}.csv"
  ActiveRecord::Base.logger.silence(Logger::WARN) do
    CSV.foreach(Rails.root.join('db', '', fileName),headers:true) do |row|
      #next if (last >= (row['id'].to_i))
      make_page(row).save
    end
  end
end
