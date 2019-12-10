class GradesController < ApplicationController

  before_action :teacher_logged_in, only: [:update]

  def update
    @grade=Grade.find_by_id(params[:id])
    @grade_credit = @grade.course.credit.split('/')[1].to_f
    @student= @grade.user
    @student_credits = @student.credits
    if !@grade.has_gain_credit && params[:grade][:grade].to_i >= 60
      if @grade.update_attributes!(:has_gain_credit => true,:grade => params[:grade][:grade]) \
        && @student.update_attributes!(:credits => @student.credits + @grade_credit)
        flash={:success => "#{@grade.user.name} #{@grade.course.name}的成绩已成功修改为 #{@grade.grade}"}
      else
        flash={:danger => "上传失败.请重试"}
      end

    elsif @grade.has_gain_credit && params[:grade][:grade].to_i < 60
      if @grade.update_attributes!(:has_gain_credit => false,:grade => params[:grade][:grade]) \
        && @student.update_attributes!(:credits => @student.credits - @grade_credit)
        flash={:success => "#{@grade.user.name} #{@grade.course.name}的成绩已成功修改为 #{@grade.grade}"}
      else
        flash={:danger => "上传失败.请重试"}
      end
    else
      if @grade.update_attributes!(:grade => params[:grade][:grade])
        flash={:success => "#{@grade.user.name} #{@grade.course.name}的成绩已成功修改为 #{@grade.grade}"}
      else
        flash={:danger => "上传失败.请重试"}
      end
    end
    redirect_to grades_path(course_id: params[:course_id]), flash: flash
  end

  def index
    #binding.pry
    if teacher_logged_in?
      @course = Course.find_by_id(params[:course_id])
      @grades = @course.grades.order(created_at: "desc").paginate(page: params[:page], per_page: 4)
    elsif student_logged_in?
      @grades=current_user.grades.paginate(page: params[:page], per_page: 4)
    else
      redirect_to root_path, flash: {:warning=>"请先登陆"}
    end
  end

  def degree
    if teacher_logged_in?
      @course=Course.find_by_id(params[:course_id])
      @grades=@course.grades
    elsif student_logged_in?
      @grades=current_user.grades
    else
      redirect_to root_path, flash: {:warning=>"请先登陆"}
    end
  end

  def setDegree
    @grade=Grade.find_by_id(params[:id])
    @grade.update_attributes(:isDegree=>true)
    redirect_to grades_degree_path, flash: {:success => "已经成功设置#{ @grade.course.name}为学位课！"}
  end
  def setUnDegree
    @grade=Grade.find_by_id(params[:id])
    @grade.update_attributes(:isDegree=>false)
    redirect_to grades_degree_path, flash: {:success => "已经成功设置#{ @grade.course.name}为非学位课！"}
  end

  private

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

end
