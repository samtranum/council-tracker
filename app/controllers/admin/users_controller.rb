class Admin::UsersController < Admin::ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    authorize User
    @users = User.includes(:councils).order(:email_address)
  end

  def show
    authorize @user
  end

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize @user
    if @user.save
      assign_councils!(@user)
      redirect_to admin_users_path, notice: "User #{@user.email_address} created successfully."
    else
      render :new
    end
  end

  def edit
    authorize @user
  end

  def update
    authorize @user
    if @user.update(user_update_params)
      assign_councils!(@user)
      redirect_to admin_users_path, notice: "User #{@user.email_address} updated successfully."
    else
      render :edit
    end
  end

  def destroy
    authorize @user
    @user.destroy
    redirect_to admin_users_path, notice: "User deleted."
  end

  def change_password
    @user = current_user
    authorize @user, :change_password?
  end

  def update_password
    @user = current_user
    authorize @user, :change_password?

    if !@user.valid_password?(params[:current_password])
      flash.now[:alert] = "Current password is incorrect."
      render :change_password
    elsif params[:new_password] != params[:new_password_confirmation]
      flash.now[:alert] = "New password and confirmation do not match."
      render :change_password
    elsif params[:new_password].length < 8
      flash.now[:alert] = "New password must be at least 8 characters."
      render :change_password
    else
      @user.password = params[:new_password]
      @user.password_confirmation = params[:new_password_confirmation]
      if @user.save
        redirect_to admin_root_path, notice: "Password updated successfully."
      else
        flash.now[:alert] = @user.errors.full_messages.to_sentence
        render :change_password
      end
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation, :admin)
  end

  def user_update_params
    # Only update password if a new one was provided
    p = params.require(:user).permit(:email_address, :admin, :password, :password_confirmation)
    p.delete(:password) if p[:password].blank?
    p.delete(:password_confirmation) if p[:password_confirmation].blank?
    p
  end

  def assign_councils!(user)
    if current_user.is_admin?
      council_ids = params[:user][:council_ids].presence&.reject(&:blank?)&.map(&:to_i) || []
      user.user_councils.destroy_all
      council_ids.each { |id| user.user_councils.create!(council_id: id) }
    end
  end
end
