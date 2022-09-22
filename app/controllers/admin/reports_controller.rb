class Admin::ReportsController < ApplicationController
  layout "admin"
  expose :reports
  expose :report

  def index
    @q = Report.ransack(params[:q])
    @q.sorts = 'id desc' if @q.sorts.empty?
    self.reports = @q.result(distinct: true).page(params[:page])
  end

  def show
     respond_to do |format|
       format.js { render layout: false }
   end
  end

  def change_status
    report.update_attributes(status: params[:status].to_i)
    redirect_back(fallback_location: admin_reports_path)
  end

end
