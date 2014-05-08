module FunkyWorldCup
  module Helpers
    def authenticate(user)
      session[:user] = user
    end

    def logout
      session[:user] = nil
      res.redirect "/"
    end

    def current_user
      session[:user]
    end

    def user_authenticated?
      !session[:user].nil?
    end

    def flash
      session['fwc.flash'] = (@env['rack.session']['fwc.flash'] || {})
      session['fwc.flash']
    end
  end
end
