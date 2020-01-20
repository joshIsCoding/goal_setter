class Session < ApplicationRecord
   EASY_BROWSERS = {
      ["Firefox\/", "Seamonkey\/"] => "Firefox",
      ["Seamonkey\/"] => "Seamonkey",
      ["Chromium\/"] => "Chromium",
      ["Safari\/", "Chrom(e|ium)\/"] => "Safari",
      ["OPR\/"] => "Opera",
      ["Opera\/"] => "Opera",
      ["Trident/7.0; \.\*rv:"] => "Internet Explorer",
      ["; MSIE "] => "Internet Explorer"
   }.freeze
   
   TRICKY_BROWSERS = {
      ["Chrome\/"] => "Chrome"
   }.freeze

   DEVICES = [
      "iPhone",
      "iPad",
      "Windows Phone",
      "Linux",
      "Android",
      "BlackBerry" #though this would seem unlikely
   ].freeze
   after_initialize :ensure_session_token   
   validates :session_token, presence: true, uniqueness: true, on: :create
   
   before_create :parse_user_agent
   belongs_to :user

   def self.generate_session_token
      SecureRandom::urlsafe_base64(16)
   end

   private
   def ensure_session_token
      self.session_token ||= self.class.generate_session_token
   end

   def parse_user_agent
      if self.user_agent
         set_browser_from_user_agent
         set_device_from_user_agent
      end
   end

   def set_browser_from_user_agent
      browser_conditions = [EASY_BROWSERS, TRICKY_BROWSERS] # easy browsers must
      # be ruled out first as the tricky ones overlap
      browser_conditions.each do |browser_condition_list|
         browser_condition_list.each do |condition, browser|
            next unless self.user_agent.match?(browser_version_regex(condition.first))
            if condition.length == 2
               next if self.user_agent.match?(browser_version_regex(condition.last))
            end
            self.browser = browser
            return
         end
      end
      self.browser = "Unrecognised"
   end

   def set_device_from_user_agent
      DEVICES.each do |device| 
         if self.user_agent.include?(device)
            self.device = device
            return
         end 
      end
            
      if self.user_agent.include?("Mobi")
         self.device = "Mobile Device"
      else
         self.device = "Desktop"
      end
   end

   def browser_version_regex(insert)
      /#{insert}\d+\.\d+/
   end
end
