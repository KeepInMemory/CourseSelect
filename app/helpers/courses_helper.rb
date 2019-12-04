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

  def week_param_to_num(week)
    params ={
        '周一' => 0,
        '周二' => 1,
        '周三' => 2,
        '周四' => 3,
        '周五' => 4,
        '周六' => 5,
        '周天' => 6,
        '周日' => 6
    }
    params[week]
  end

  def split_course(course)
    course_times = String(course.course_time).split(',')

    week = course.course_week
    week_times = String(week[1..week.length-1]).split(',')
    course_times_length = course_times.length
    # logger.info(course_times_length)
    week_times_length = week_times.length
    # logger.info(week_times_length)
    time_array = { id: course.id, name: course.name,
                  class_time: Array.new(course_times_length, {weekday:'',start:'',end:''}),
                  week_time: Array.new(week_times_length, {start:'',end:''})}
    for i in (0...course_times_length)
      course_time = String(course_times[i])
      index_start = course_time.index('(').to_i
      index_end = course_time.index(')').to_i
      num = week_param_to_num(course_time[0..index_start-1])
      # logger.info(course_time[0..index_start-1])
      # logger.info(num)
      class_time = String(course_time[index_start+1..index_end])
      time_array[:class_time][i] ={
          'weekday' => num,
          'start' => class_time.split('-')[0].to_i,
          'end' => class_time.split('-')[1].to_i,
      }
    end

    for j in (0...week_times_length)
      week_time = String(week_times[j])
      time_array[:week_time][j] = {
          'start' => week_time.split('-')[0].to_i,
          'end' => week_time.split('-')[1].to_i
      }
    end
    time_array
  end

  def check_confict?(time1,time2)
    flag=true
    for i in (0...time1.length)
      for j in (0...time2.length)
        if time2[j]["end"] < time1[i]["start"] || time2[j]["start"] > time1[i]["end"]
          flag = false
        else
          return true
        end
      end
    end
    flag
  end


  def check_weekday_confict?(time1,time2)
    flag=true
    # logger.info(time2)
    for i in (0...time1.length)
      # logger.info(time1)
      for j in (0...time2.length)
        # logger.info(time2[j])
        # logger.info(time1[i].class)
        # logger.info(time1[i])
        if time2[j]["weekday"] != time1[i]["weekday"]
          # logger.info(time1)
          # logger.info(time2)
          flag=false
        else
          return true
        end
      end
    end
    flag
  end

  def courses_conflict(chosed_courses,to_select_course)
    if chosed_courses && to_select_course
      # logger.info("-----------")
      to_select_course_time_array = split_course(to_select_course)
      # logger.info(to_select_course_time_array)
      # logger.info("-----------")
      chosed_courses.each do |course|
        chosed_courses_time_array = split_course(course)
        # logger.info(chosed_courses_time_array)
        # 课程冲突
        if !check_confict?(chosed_courses_time_array[:week_time], to_select_course_time_array[:week_time])
          # logger.info("1-----------not conflict")
          next
        else
          # logger.info("1-----------conflict")
          if !check_weekday_confict?(chosed_courses_time_array[:class_time],to_select_course_time_array[:class_time])
            # logger.info('2-------not conflict')
            next
          else
            if !check_confict?(chosed_courses_time_array[:class_time],to_select_course_time_array[:class_time])
              next
            else
              return {conflict: true,course_name:course.name}
            end
          end
        end
      end
    end
    {conflict: false,course_name:nil}
  end

end