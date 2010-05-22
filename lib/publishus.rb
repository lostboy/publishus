begin
  require "vestal_versions"
rescue
  gem "vestal_versions"
  require "vestal_versions"
end

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
      before_destroy :choose_fait
      include InstanceMethods
    end
    
  end
  
  module InstanceMethods
    
    def current?
      self.published_at.nil? || (self.published_at >= self.updated_at)
    end
    
    def live
      returning self do |publishable|
        publishable.revert_to(publishable.published_at) unless publishable.current?
      end
    end

    attr_accessor :proper_destroy

    def real_destroy
      @proper_destroy = true
      destroy
    end

    def publish!(time=nil)
      self.update_attribute(:published_at, time||Time.now)
    end
    
    def publish_all!
      time = Time.now
      all.each { |publishable| publishable.publish!(time) }
    end
    
    def published?
      !self.published_at.nil?
    end   
    
    private
    
    def choose_fait
      unless @proper_destroy
        self.update_attribute(:deleted_at, Time.now)
        false
      end
    end
  end
  
end

ActiveRecord::Base.send(:include, Publishus)