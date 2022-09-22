module ApplicationHelper
  def report_status status=""
    case status
    when "pending"
      color = "btn-info"
    when "ignore"
      color = "btn-success"
    when "ban"
      color = "btn-danger"
    end
  end
end
