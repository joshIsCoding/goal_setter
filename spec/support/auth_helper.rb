module AuthHelper

  def register(username, pass_override = nil)
    visit register_path
    within 'form.user' do
      fill_in 'user_username', with: username 
      fill_in(
        'user_password', with: pass_override ? pass_override : "password"
      )
      click_button 'SIGN UP'
    end
  end
  
  def login(user, pass_override = nil)
    visit login_path
    within 'form.user' do
      fill_in 'user_username', with: user.username 
      fill_in(
        'user_password', with: pass_override ? pass_override : user.password
      )
      click_button 'Sign In'
    end
  end

end