module PaginationHelper
  def windowed_pages(current_page, total_pages, inner_window: 2, outer_window: 3)
    left = (1..outer_window).to_a
    right = ((total_pages - outer_window + 1)..total_pages).to_a
    inside = ((current_page - inner_window)..(current_page + inner_window)).to_a
    range = (left + inside + right).uniq.select { |x| x.between?(1, total_pages) }.sort

    result = []
    prev = nil
    range.each do |page|
      result << :gap if prev && page != prev + 1
      result << page
      prev = page
    end
    result
  end
end
