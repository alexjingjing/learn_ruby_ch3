class SessionsController < ApplicationController
  def new
  end
  
  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      # 登入用户，然后重定向到用户的资料页面
      log_in(@user)
      # 根据用户是否勾选“记住我”判断是否应该保存用户信息
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
      redirect_to user_url(@user)
    else
      # 创建一个错误消息
      flash.now[:danger] = 'Invalid email/password combination' # 不完全正确
      render 'new'
    end
  end
  
  # 返回 cookie 中记忆令牌对应的用户
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url()
  end
end
