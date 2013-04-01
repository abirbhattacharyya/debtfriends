# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
 include GoogleVisualization


   def get_current_time

    time = Time.now.in_time_zone("Pacific Time (US & Canada)")

    return time


  end

   def month_options

    from = get_current_time.to_date
    to  = from + 30.days
    months = Array.new
    months.push(from.month)
    months.push(to.month)

    return months.uniq
  end

  def day_options

    from = get_current_time.day
    to  = get_current_time.end_of_month.day
    days = Array.new
    from.upto(to) do |i|
    days.push(i)
    end

    return days
  end

  def year_options
    from  = get_current_time
    to  = from + 30.days
    year = Array.new
    year.push(from.year)
    year.push(to.year)

    return year.uniq
  end
end
