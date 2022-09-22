module Pagination
  extend ActiveSupport::Concern
  included do

    helpers do
      params :pagination do
        optional :page, type: Integer, default: 1, desc: "Page number (default: 1)"
        optional :per_page, type: Integer, default: 20, desc: "Number of elements per page (default: 20)"
      end

      def pagination_dict(object)
        {
          current_page: object.current_page,
          next_page: object.next_page || -1,
          prev_page: object.prev_page || -1,
          total_pages: object.total_pages,
          total_count: object.total_count
        }
      end
    end
  end
end
