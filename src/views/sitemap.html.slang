ul
  - locals[:pages].each do |page|
    li
      a href=page[:url]
        | #{page[:file]}
