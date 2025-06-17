class SaveItemsJob < ProgressJob::Base
  # The "save" jobs are all "unsave" in the sense that multiple copies should not
  # run at the same moment, i.e. saving the same record at the same moment
  # So it is important to start them in a dedicated "resave" queue with only 1 worker
  # to ensure they are processed 1-by-1, In delayedjob use
  # --pool:resave to get 1 worker

  # See the ReindexItemsJob for an explanation of why we pass a separate obj id and class
  def initialize(parent_obj_id, parent_obj_class, relation = :referring_sources)
    @parent_obj_id = parent_obj_id
    @parent_obj_class = parent_obj_class
    @relation = relation
  end
  
  def enqueue(job)
    return if !@parent_obj_id || !@parent_obj_class

    # We want a class here
    return if !@parent_obj_class.is_a? Class

    job.parent_id = @parent_obj_id
    job.parent_type = @parent_obj_class
    job.save!
  end

  def perform(*args)
    # Sometimes, the record is deleted before the job is run
    begin
      parent_obj = @parent_obj_class.send("find", @parent_obj_id.to_i)
    rescue ActiveRecord::RecordNotFound
      complain("Parent item was deleted before this job could run!", __LINE__, @job.id, @parent_obj_class, @relation, @parent_obj_id, "none at this point")
      return # Just exit
    end
    
    items = parent_obj.send(@relation)
    
    update_progress_max(-1)
    update_stage("Look up #{@relation.to_s}")
    update_progress_max(items.count)
    
    count = 1
    items.each do |i|
      i.paper_trail_event = "auth save"
      # By the time the job executes, things can get stale
      if !i.class.exists?(i.id)
        complain("Item does not exist anymore :(", __LINE__, @job.id, @parent_obj_class, @relation, @parent_obj_id, i.id)
        next
      end
      # Force a reload of the object
      reloaded_element = i.class.find(i.id)
      # let the job crash in case
      reloaded_element.save
      reloaded_element = nil # Force it to free
      update_stage_progress("Saving record #{count}/#{items.count}", step: 1)
      count += 1
    end
    
    update_stage("Reindexing parent")
    # reindex the parent obj as needed
    if parent_obj.respond_to? :reindex
      parent_obj.reindex
    end
  end
  
  
  def destroy_failed_jobs?
    false
  end
  
  def max_attempts
    1
  end
  
  def queue_name
    'resave'
  end

  private
  
  def complain(message, line, jobid, model, relation, parentid, itemid)
    ActionMailer::Base.mail(
      from: "#{RISM::DEFAULT_EMAIL_NAME} Periodic Complaining Bot <#{RISM::DEFAULT_NOREPLY_EMAIL}>",
      to: RISM::NOTIFICATION_EMAILS,
      subject: "Save Items Job had a problem (job=#{jobid})",
      body: "Job #{jobid} for #{model} id #{parentid} relation #{relation} (item=#{itemid}) exited on line #{line} with message: #{message}"
    ).deliver_now
  end
end