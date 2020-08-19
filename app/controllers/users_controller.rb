
class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :destroy]
  before_action :authenticate_user!
  after_action :verify_authorized

  # GET /users
  # GET /users.json
  def index
    @users = policy_scope(User.all)
    authorize User
  end

  def new
    @user = User.new
    authorize @user
  end
  # GET /users/1
  # GET /users/1.json
  def show
  end

  def patient_created
  end 


  def create_staff
    authorize User
    generated_password = Devise.friendly_token.first(8)
    @api_key = User.roles[user_params[:role]] == User.roles[:staff] ? nil : SecureRandom.base64(16)
    @user = User.new(user_params.merge!({password: generated_password, password_confirmation: generated_password, api_key: @api_key}))
    respond_to do |format|
      if @user.save
        if @user.patient?
          format.html { render :patient_created, notice: 'Patient was successfully created.' }
          format.json { render :show, status: :created, location: @user }
        else
          UserMailer.with(user: @user).staff_created_user.deliver_now
          format.html { redirect_to @user, notice: 'User was successfully created.' }
          format.json { render :show, status: :created, location: @user }
        end
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to root_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user =  authorize User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:name, :dob, :telno, :email, :role)
    end
end
