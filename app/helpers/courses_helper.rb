require 'time'
module CoursesHelper

  def get_course_select_end_time()
    end_time = ExInfo.where(name: 'select_course_end').take
    Time.parse(end_time[:value])
  end

  def get_course_select_start_time()
    start_time = ExInfo.where(name: 'select_course_start').take
    Time.parse(start_time[:value])
  end

  def in_course_select_time?()
    time_now = Time.new
    start_time = get_course_select_start_time
    end_time = get_course_select_end_time
    in_course_select_time = (time_now<end_time && time_now >start_time)
  end
  def find_grades_by_course(_course)
    # puts _course.id
    grade = Grade.joins(:course).where(:course_id => _course.id).take
  end



end