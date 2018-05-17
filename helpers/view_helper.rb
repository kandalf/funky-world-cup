class Cuba
  module Render::Helper
    BR_HTML_TAG = "<br>".freeze

    def show_flash_message
      [].tap { |markup|
        [:info, :success, :warning, :error].each do |flash_key|
          if flash.key?(flash_key)
            markup << partial("shared/_flash_message.html", klass: flash_key, message: flash[flash_key])
            flash.delete(flash_key)
          end
        end
      }.join(BR_HTML_TAG)
    end

    def show_notifications
      markup = ""
      if session.has_key?(:notifications) && session[:notifications].any?
        markup = "<div class='alert alert-dismissable alert-info'><button type='button' class='close' data-dismiss='alert'>&times;</button><ul>"
        session[:notifications].each do |notification|
          if notification.match_prediction
            markup += "<li>#{I18n.t("notifications.#{notification.message}",
                                      host: I18n.t(".teams.#{notification.match_prediction.match.host_team.iso_code}"),
                                      rival: I18n.t(".teams.#{notification.match_prediction.match.rival_team.iso_code}")
                                    )}</li>"
          elsif notification.match_penalties_prediction
            markup += "<li>#{I18n.t("notifications.#{notification.message}",
                                      host: I18n.t(".teams.#{notification.match_penalties_prediction.match.host_team.iso_code}"),
                                      rival: I18n.t(".teams.#{notification.match_penalties_prediction.match.rival_team.iso_code}")
                                    )}</li>"
          else
            markup += "<li class='text-success'><strong>#{I18n.t("notifications.#{notification.message}")}</strong></li>"
          end
        end
        markup += "</ul></div>"
        session.delete(:notifications)
      end
      markup
    end

    def class_for_index(index)
     case index
      when 0, 1
        'success'
      when 2
        'warning'
      else
        'danger'
      end
    end

    def class_for_path(path)
      'active' if req.path =~ /\A#{path}/
    end

    def translate_description(description)
      rank, part = description.downcase.split(" of ")
      part.gsub!("group", I18n.t('.common.group')) if part.include? "group"
      rank = I18n.t(".common.#{rank}_of")
      "#{rank} #{part}"
    end

    def prizes_to_vue_json(prizes)
      prizes.map(&:to_hash).to_json
    end

    def match_date(dt, tz, format = "%d %^b")
      dt.to_datetime.new_offset(tz).strftime(format)
    end

    def match_time(dt, tz, format = "%H:%M")
      dt.to_datetime.new_offset(tz).strftime(format)
    end
  end
end
