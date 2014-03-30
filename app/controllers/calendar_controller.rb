require 'icalendar'

class CalendarController < ApplicationController
  include ActionView::Helpers::TextHelper
  before_filter :required_login, except: [:export]

  def export
    prop = UserProperty.where(key: 'export-key', value: params[:key]).first
    if prop
      @user = prop.user
      @pages = @user.pages.inbox.date_range(90.days.ago, 90.days.from_now)
      respond_to do |format|
        format.ics {
          calendar = Icalendar::Calendar.new
          calendar.prodid = 'wri.pe'
          calendar.custom_property("X-WR-CALNAME;VALUE=TEXT", "wri.pe - #{@user.username}")
          calendar.custom_property("X-WR-CALDESC;VALUE=TEXT", "https://wri.pe/")
          calendar.custom_property("X-PUBLISHED-TTL", "PT1H")
          @pages.each do |page|
            page.dates.each do |date|
              event = Icalendar::Event.new
              event.dtstart = date.date
              event.dtstart.ical_params = { "VALUE" => "DATE" }
              event.dtend = date.date
              event.dtend.ical_params = { "VALUE" => "DATE" }
              event.summary = "#{page.title} - wri.pe"
              event.description = truncate(page.body, :length => 100)
              event.created = page.created_at.utc.strftime("%Y%m%dT%H%M%SZ")
              event.last_modified = page.updated_at.utc.strftime("%Y%m%dT%H%M%SZ")
              event.uid = page.url
              event.url = page.edit_url
              calendar.add_event(event)
            end
          end
          calendar.publish
          render text: calendar.to_ical
        }
      end
    else
      head 404
    end
  end

  def generate_export_key
    current_user.generate_export_key
    render text: "{}", status: 201
  end
end
