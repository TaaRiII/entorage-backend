class Admin::GroupStatusesController < ApplicationController
  layout "admin"
  #load_and_authorize_resource
  expose :group_statuses
  expose :group_status

  def index
    unless params[:query].present?
     params[:query] = {"status_type_eq": "0"}
    end
    @status_type = params[:query][:status_type_eq]
    @q = GroupStatus.kept.ransack(params[:query], search_key: :query)
    @q.sorts = 'position asc' if @q.sorts.empty?
    self.group_statuses = @q.result(distinct: true)
  end

  def create
    if group_status.save
      redirect_to admin_group_statuses_path(query: {status_type_eq: GroupStatus.status_types[group_status.status_type]})
      flash[:success]= "Group Status Created"
    else
      render :new
    end
  end

  def update
    if group_status.update(group_status_params)
      redirect_to admin_group_statuses_path(query: {status_type_eq: GroupStatus.status_types[group_status.status_type]})
      flash[:success]= "Group Status Updated"
    else
      render :edit
    end
  end

  def show
     respond_to do |format|
       format.js { render layout: false }
   end
  end

  def destroy
    group_status.discard
    redirect_to admin_group_statuses_path(query: {status_type_eq: GroupStatus.status_types[group_status.status_type]})
    flash[:alert]= "Group Status Deleted"
  end

  def set_position
    pos = params[:position].to_i + 1
    group_status.set_list_position(pos)
    render json:true
  end


private
  def group_status_params
      params.require(:group_status).permit(:name, :icon, :status_type, :address, :latitude, :longitude)
  end
end
