# Publishy
module Publishus
  
  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end
  
  module ClassMethods
    
    def publishable
      versioned
      named_scope :published, :conditions => "#{name.tableize}.published_at is not null and (#{name.tableize}.deleted_at < #{name.tableize}.published_at or #{name.tableize}.deleted_at is null)" do
        def live
          collect do |publishable|
            publishable.live
          end
        end
      end
      
      include InstanceMethods
    end
    
  end
  
  module InstanceMethods
    def live
      returning self do |publishable|
        publishable.revert_to(publishable.published_at) if publishable.published_at < publishable.updated_at unless publishable.published_at.nil?
      end
    end

    def destroy
      self.update_attribute(:deleted_at, Time.now)
    end
    
    def publish!
      self.update_attribute(:published_at, Time.now)
    end 
    
    def published?
      !self.published_at.nil?
    end   
  end
  
end

ActiveRecord::Base.send(:include, Publishus)