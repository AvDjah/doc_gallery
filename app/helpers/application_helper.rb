module ApplicationHelper
  def get_category_selected_params(params)
    d = {}
    d["id"] = nil

    subcategory_regex = /^subcategory_(\d+)$/

    filtered = params.each.select do |key, val|
        if key.match subcategory_regex
            true
        end
    end

    mx = -1


    filtered.each do |key, val|
      _, key_num = key.split "_"
      key_num = key_num.to_i

      if key_num > mx
        next if val.empty? or val.to_i == 0
        mx = key_num
        d["id"] = val.to_i
      end
    end
    d
  end
end
