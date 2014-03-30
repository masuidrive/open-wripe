class StatsController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        render json: { 
          users: User.where(active: true).count,
          pages: Page.count,
          page_histories: PageHistory.count,
          day_registers: User.where('created_at >= ?', 1.day.ago).count,
          day_users: User.where('actived_at >= ?', 1.day.ago).count,
          week_users: User.where('actived_at >= ?', 1.week.ago).count,
          month_users: User.where('actived_at >= ?', 1.month.ago).count,
          dropbox_users: DropboxUser.count,
          evernote_users: EvernoteUser.count
        }
      end
    end
  end
end
