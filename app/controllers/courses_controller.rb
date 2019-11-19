class CoursesController < ApplicationController

  before_action :student_logged_in, only: [:select, :quit, :list]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update, :open, :close]#add open by qiao
  before_action :logged_in, only: :index

  #-------------------------for teachers----------------------
  def new
    @course=Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      current_user.teaching_courses<<@course
      redirect_to courses_path, flash: {success: "新课程申请成功"}
    else
      flash[:warning] = "信息填写有误,请重试"
      render 'new'
    end
  end

  def edit
    @course=Course.find_by_id(params[:id])
  end

  def update
    @course = Course.find_by_id(params[:id])
    if @course.update_attributes(course_params)
      flash={:info => "更新成功"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to courses_path, flash: flash
  end

  def open
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open: true)
    redirect_to courses_path, flash: {:success => "已经成功开启该课程:#{ @course.name}"}
  end

  def close
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open: false)
    redirect_to courses_path, flash: {:success => "已经成功关闭该课程:#{ @course.name}"}
  end

  def destroy
    @course=Course.find_by_id(params[:id])
    current_user.teaching_courses.delete(@course)
    @course.destroy
    flash={:success => "成功删除课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  #-------------------------for students----------------------

  def credit
    @courses = current_user.courses
    @degree_credit = 0
    @get_degree_credit=0
    @sum_credit=0
    @get_sum_credit=0
    @public_credit=0
    @get_public_credit=0
    @public_must_credit=""
    @get_public_must_credit=0

    @courses.each do |course|
      @credit = course.credit[3..5]

      if course.name == "中国特色社会主义理论与实践研究"
        @public_must_credit = @public_must_credit + course.name+"("+@credit + "学分"+")"+"\n"
      end

      if course.name == "自然辩证法概论"
        @public_must_credit = @public_must_credit + course.name+"("+@credit + "学分"+")"+"\n"
      end

      if course.name == "硕士学位英语"
        @public_must_credit = @public_must_credit + course.name+"("+@credit + "学分"+")"+"\n"
      end


      if course.course_type=="公共必修课"
        current_user.grades.each do |grade|
          if grade.grade != nil
            if grade.course.name == course.name && grade.grade >= 60
              @get_public_must_credit += @credit.to_f
            end
          end
        end
      end

      current_user.grades.each do |grade|
        if grade.course.name == course.name
          if grade.isDegree == true
            @degree_credit += @credit.to_f
          end
          if grade.grade != nil
            if grade.grade >= 60
              @get_degree_credit += @credit.to_f
            end
          end
        end
      end


      if course.course_type=="公共选修课"
        @public_credit += @credit.to_f
        current_user.grades.each do |grade|
          if grade.grade != nil
            if grade.course.name == course.name && grade.grade >= 60
              @get_public_credit += @credit.to_f
            end
          end
        end
      end

      @sum_credit += @credit.to_f

    end

    current_user.grades.each do |grade|
      if grade.grade != nil && grade.grade >= 60
        @get_sum_credit += @credit.to_f
      end
    end

  end
  
  def list
    #-------QiaoCode--------
    @courses = Course.where(:open=>true).paginate(page: params[:page], per_page: 4)
    @course = @courses-current_user.courses
    tmp=[]
    @course.each do |course|
      if course.open==true
        tmp<<course
      end
    end
    @course=tmp
  end

  def select
    @course=Course.find_by_id(params[:id])
    current_user.courses<<@course
    flash={:suceess => "成功选择课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    flash={:success => "成功退选课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end


  #-------------------------for both teachers and students----------------------

  def index
    @course=current_user.teaching_courses.paginate(page: params[:page], per_page: 4) if teacher_logged_in?
    @course=current_user.courses.paginate(page: params[:page], per_page: 4) if student_logged_in?
    @courses = current_user.courses if student_logged_in?
  end


  private

  # Confirms a student logged-in user.
  def student_logged_in
    unless student_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  def course_params
    params.require(:course).permit(:course_code, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week)
  end


end
