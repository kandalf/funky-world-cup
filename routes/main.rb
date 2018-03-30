module FunkyWorldCup
  class Main < Cuba
    settings[:render][:layout] = "layouts/application.html"

    define do
      on get do
        on "404" do
          not_found!
        end

        on "disclaimer" do
          res.write render("./views/layouts/home.html.erb") {
            render("./views/pages/disclaimer_#{session[:locale]}.html")
          }
        end

        on "tos" do
          res.write render("./views/layouts/home.html.erb") {
            render("./views/pages/tos.html.erb")
          }
        end

        on "rules" do
          res.write render("./views/layouts/application.html.erb") {
            render("./views/pages/rules.html.erb")
          }
        end

        on "lang/:locale" do |locale|
          locale = locale.to_sym

          if FunkyWorldCup::ALLOWED_LOCALES.include? locale
            session[:locale] = locale
            current_user.update(:locale => locale) if current_user
          end

          res.redirect (req.env["HTTP_REFERER"].gsub(/lang=(es|en)\&?/, "") || "/")
        end

        on current_user do
          @user_rank ||= UserScore.rank_for(current_user.id)

          on root do
            res.redirect "/dashboard"
          end

          on "logout" do
            logout
          end

          on "dashboard" do
            winners = total_played = matches = nil

            if FunkyWorldCup.finalized?
              winners      = UserScore.winners
              total_played = FunkyWorldCup.total_points
            else
              matches = Match.for_dashboard.all
            end

            res.write view("pages/dashboard.html",
              matches:      matches,
              winners:      winners,
              total_played: total_played || 0,
              params:       session.delete('fwc.contact_form') || {},
            )
          end

          on "rank" do
            raw_rank = UserScore.order(Sequel.desc(:score), :id).all
            key = 0
            score = 0
            @rank = Hash.new

            raw_rank.each do |rank|
              if score.zero? || score > rank.score
                score = rank.score
                key += 1
              end
              @rank[key] = Array.new unless @rank.has_key?(key)
              @rank[key] << rank
            end

            res.write render("./views/layouts/application.html.erb") {
              render("./views/pages/rank.html.erb")
            }
          end

          not_found!
        end

        on root do
          res.write render("./views/layouts/home.html.erb") {
            render("./views/pages/home.html.erb")
          }
        end

        on "auth/:provider/callback" do |provider|
          uid  = env['omniauth.auth']['uid']
          info = env['omniauth.auth']['info']
          info['nickname'] ||= info['name']

          unless user = User["#{provider}_user".to_sym => uid]
            user = User.create("#{provider}_user" => uid,
                              "nickname" => info['nickname'],
                              "name" => info['name'],
                              "image" => info['image'])
          else
            if (user.nickname != info['nickname'] || user.image != info['image'])
              user.update(:nickname => info['nickname'], :image => info['image'])
            end
          end

          if join_group_code = session.delete('fwc.join_group_code')
            if group = Group.find(link: join_group_code)
              begin
                GroupsUser.create(group_id: group.id, user_id: user.id)
                flash[:success] = "#{I18n.t('.messages.groups.part_of')} #{group.name}"
              rescue => e
                flash[:error] = "#{I18n.t('.messages.groups.cant_join')} #{group.name}, #{I18n.t('.messages.common.please')} #{I18n.t('.messages.common.try_again')}"
              end
            else
              flash[:error] = "#{I18n.t('.messages.groups.cant_join')} #{group.name}, #{I18n.t('.messages.common.please')} #{I18n.t('.messages.common.try_again')}"
            end
          end

          authenticate(user)

          res.redirect "/dashboard"
        end

        on "auth/failure" do
          flash[:error] = I18n.t(".errors.login_error")
          res.redirect "/"
        end

        on "dashboard" do
          res.redirect "/"
        end

        not_found!
      end

      not_found!
    end
  end
end