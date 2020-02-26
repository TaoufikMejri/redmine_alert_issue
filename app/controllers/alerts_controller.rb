class AlertsController < ApplicationController

  helper :queries
  include QueriesHelper

  before_action :authorize_global

  def index
    retrieve_query(AlertQuery, false)

    if @query.valid?
      respond_to do |format|
        format.html {
          @alert_count = @query.alerts_count
          @alert_pages = Paginator.new @alert_count, per_page_option, params['page']
          @alerts = @query.alerts(:offset => @alert_pages.offset, :limit => @alert_pages.per_page)
          render :layout => !request.xhr?
        }
      end
    else
      respond_to do |format|
        format.html { render :layout => !request.xhr? }
      end
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def notifications
    if request.xhr?
      date = DateTime.current
      @notifications_count = Alert.where(created_at: date.beginning_of_day..date.end_of_day).count
      render :partial => "ajax"
    end
  end
end
