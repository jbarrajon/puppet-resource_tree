class resource_tree (
  $collections       = {},
  $apply = [],
) {
  $allcollections = hiera_hash('resource_tree::collections', $collections)
  $allapply = hiera_array('resource_tree::apply', $apply)
  
  if is_hash($allcollections) and is_array($allapply) and (size(intersection($allapply, keys($allcollections))) > 0) {
      $uniq_resources = parseyaml(inline_template('<%= @allcollections.reject {|k,v| !(@allapply.include? k) }.values().inject({}) {|a,b| a.merge(b) }.map {|k,v| Hash[v.map {|a,b| [k+"-"+a,{"type" => k, "rt_notify" => b.fetch("rt_notify",nil), "rt_requires" => b.fetch("rt_requires",nil), "rt_resources" => b.fetch("rt_resources",nil),"params" => {a=>b.reject {|x,y| ["rt_resources", "rt_requires", "rt_notify"].include? x }}}]}] }.flatten(1).inject({}) {|a,b| a.merge(b) }.to_yaml %>'))
      create_resources('resource_tree::resource', $uniq_resources, {})
  }
}
