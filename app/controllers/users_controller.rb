
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

  def session_labgroup
    authorize current_user
    @session_location = { labgroup: session[:labgroup]}
  end

  def session_labgroup_set
    authorize current_user
    p = params.require(:ss).permit(:labgroup)
    puts p
    unless Labgroup.find(p[:labgroup])
      raise "cannot invalid labgroup"
    end
    session[:labgroup] = p[:labgroup]

    redirect_to session_lab_users_path
  end

  def session_lab
    authorize current_user
    @session_location = { labgroup: session[:labgroup], lab: session[:lab] }
  end

  def session_lab_set
    authorize current_user
    p = params.require(:ss).permit(:lab)
    puts p
    unless Labgroup.find(session[:labgroup]).labs.includes(Lab.find(p[:lab]))
      raise "cannot reconcile lab with group"
    end
    session[:lab] = p[:lab]

    redirect_to staff_dashboard_path
  end

  def create_staff
    authorize User
    generated_password = Devise.friendly_token.first(12)
    @api_key = User.roles[user_params[:role]] == User.roles[:staff] ? nil : SecureRandom.base64(16)
    @user = User.new(user_params.merge!({password: generated_password, password_confirmation: generated_password, api_key: @api_key}))
    respond_to do |format|
      if @user.save
        if @user.patient?
          format.html { redirect_to @user, notice: 'Patient was successfully created.' }
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
      @user = authorize User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:email, :role, :security_question_answer, :security_question_id)
    end
end
