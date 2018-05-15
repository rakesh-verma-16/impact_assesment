class ImpactController < ApplicationController
  
  def cut(param_x, param_y)
  	/ Eiffel Tower coordinates/
  	set_cartesian_values(param_x, param_y)
  	x = convert_x(@lat, @long)
  	y = convert_y(@lat, @long)
  	z = convert_z(@lat)
  	[x,y,z]
  end

  def index
  	p "params: #{params}"
  	loc = cut(params['lattitude'].to_i, params['longitude'].to_i)
  	volume = ActiveRecord::Base.connection.execute("select tss.sawlogvolume,
  		tss.pulpwoodvolume
  		from treestandsummary as tss 
  		left outer join treestand as ts 
  		on tss.treestandid = ts.id 
  		left outer join stand as  s on ts.standid = s.id 
  		left outer join rtree_stand_geometry as r on r.id = s.id 
  		where r.minx > "+ loc[0].to_s + " and r.maxx<"+ loc[0].to_s + " and r.miny > " + loc[1].to_s + " and r.maxy < " + loc[1].to_s)
  	p "volume: #{volume}"
  	render volume
  end

  def set_cartesian_values(lat, long)
  	p "lat ling: #{lat}, #{long}"
  	@lat = lat * Math::PI / 180
    @long = long * Math::PI / 180
    @r=6371.0
  end

  def convert_y(lat, long)
    y = @r * Math::cos(lat) * Math::sin(long)
  end

  def convert_x(lat, long)
    x = @r * Math::cos(lat) * Math::cos(long)
  end

  def convert_z(lat)
    z = @r * Math::sin(lat)
  end

end
