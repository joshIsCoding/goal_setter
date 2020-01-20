require 'rails_helper'

RSpec.describe Session, type: :model do
  let(:user) { User.create!(username: "test", password: "test_pass") }
  
  describe "Validations" do
    subject(:unique_session) do
      Session.create!(
        user: user, 
        session_token: Session.generate_session_token,
        user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1"
      )
    end
    it { should validate_presence_of(:session_token).on(:create) }
    it { should validate_uniqueness_of(:session_token).on(:create) }
  end

  describe "Associations" do
    it { should belong_to(:user) }
  end

  describe "Methods" do
    
    describe("Session token callback") do
      it "should ensure a session_token is set after initialize" do
        new_session = Session.new(user: user)
        expect(new_session.session_token).not_to be nil
        expect{new_session.save!}.not_to raise_error
      end
    end
    
    describe("#set_browser_from_user_agent") do
      
      it "Should set the correct browser according to the user_agent string" do
        user_agents = {
          "Safari" => "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1",
          "Internet Explorer" => "Mozilla/5.0 (compatible; MSIE 9.0; Windows Phone OS 7.5; Trident/5.0; IEMobile/9.0)",
          "Opera" => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36 OPR/38.0.2220.41",
          "Chrome" => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36",
          "Firefox" => "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
        }
        user_agents.each do |browser, user_agent|
          current_session = Session.create!(user: user, user_agent: user_agent)
          expect(current_session.browser).to eq(browser)
        end
      end
    end

    describe("#set_device_from_user_agent") do
      
      it "Should set the correct browser according to the user_agent string" do
        devices = {
          "iPhone" => "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1",
          "Windows Phone" => "Mozilla/5.0 (compatible; MSIE 9.0; Windows Phone OS 7.5; Trident/5.0; IEMobile/9.0)",
          "Linux" => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36",
          "Desktop" => "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
        }
        devices.each do |device, user_agent|
          current_session = Session.create!(user: user, user_agent: user_agent)
          expect(current_session.device).to eq(device)
        end
      end
    end
  end
end
