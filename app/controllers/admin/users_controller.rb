class Admin::UsersController < ApplicationController
  layout "admin"
  #load_and_authorize_resource
  expose :users
  expose :user

  def index
    @q = User.ransack(params[:q])
    @q.sorts = 'id desc' if @q.sorts.empty?
    self.users = @q.result(distinct: true).page(params[:page])
  end

  def active
    @q = User.active.ransack(params[:q])
    @q.sorts = 'id desc' if @q.sorts.empty?
    self.users = @q.result(distinct: true).page(params[:page])
  end

  def new
    user.photos.build
  end

  def create
    if user.save
      redirect_to admin_users_path
      flash[:success]= "User Created"
    else
      render :new
    end
  end

  def edit
     user.photos.build unless user.photos.present?
  end

  def update
    if user.update(user_params)
      redirect_to admin_users_path
      flash[:success]= "User Updated"
    else
      render :edit
    end
  end

  def award
    if params[:type]== "Spotlight"
      user.update_columns(spot_light_allow: 1)
      user.groups.joined_group.update_all(spot_light_allow: 1)
    else
      user.update_columns(instant_match_allow: 1)
      user.groups.joined_group.update_all(instant_match_allow: 1)
    end    
    flash[:success]= "#{params[:type]} awarded"
    redirect_back(fallback_location: admin_users_path)

  end

  def show
     respond_to do |format|
       format.js { render layout: false }
   end
  end

  def destroy
    user.destroy
    redirect_to(admin_users_path)
    flash[:alert]= "User Deleted"
  end

  def toggle_block
    user.update_attributes(is_blocked: params[:operation])
    redirect_back(fallback_location: admin_users_path)
  end

  def save_setting
    admin = Admin.first
    admin.ios_version = params[:nothing][:ios_version]
    admin.base_url = params[:nothing][:base_url]
    admin.save
    redirect_back(fallback_location: setting_admin_users_path)
  end


private
 def user_params
    params.require(:user).permit(:user_name,:phone_number, :gender, :latitude, :longitude, :dob, :bio, photos_attributes:[:id, :image, :_destroy])
  end
end
