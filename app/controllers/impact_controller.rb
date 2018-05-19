class ImpactController < ApplicationController

  SOIL_TYPE = {
    40 => "Kivinen hienojakoinen kangasmaa",
    32 => "Kivinen karkea lajittunut maalaji",
    31 => "Kivinen karkea moreeni",
    30 => "Kivinen keskikarkea tai karkea kangasmaa",
    22 => "Hienojakoinen lajittunut maalaji",
    21 => "Hienoainesmoreeni",
    20 => "Hienojakoinen kangasmaa",
    12 => "Karkea lajittunut maalaji",
    11 => "Karkea moreeni",
    10 => "Keskikarkea tai karkea kangasmaa",
    70 => "Multamaa"
  }

  MAIN_TREE_SPIECES = {
    1 => "Mänty",
    2 => "Kuusi",
    3 => "Rauduskoivu", 
    4 => "Hieskoivu",
    5 => "Haapa",
    6 => "Harmaaleppä",
    7 => "Tervaleppä",
    8 => "Muu havupuu",
    9 => "Muu lehtipuu",
    10 => "Douglaskuusi"  ,
    11 => "Kataja",
    12 => "Kontortamänty"  ,
    13 => "Kynäjalava",
    14 => "Lehtikuusi",
    15 => "Metsälehmus" ,
    16 => "Mustakuusi",
    17 => "Paju",
    18 => "Pihlaja" ,
    19 => "Pihta",
    20 => "Raita",
    21 => "Saarni",
    22 => "Sembramänty",
    23 => "Serbiankuusi" ,
    24 => "Tammi",
    25 => "Tuomi" ,
    26 => "Vaahtera" ,
    27 => "Visakoivu",
    28 => "Vuorijalava" ,
    29 => "Lehtipuu" ,
    30 => "Havupuu"
  }

  def cut(param_x, param_y)
    / Eiffel Tower coordinates/
    set_cartesian_values(param_x, param_y)
    x = convert_x(@lat, @long)
    y = convert_y(@lat, @long)
    z = convert_z(@lat)
    [x,y,z]
  end

  def index
    total_price = 0
    x = params[:x]
    y = params[:y]
    volume = ActiveRecord::Base.connection.execute(
      "select tss.sawlogvolume, tss.pulpwoodvolume, r.minx, r.maxx, r.miny, r.maxy, s.standid, s.soiltype, s.maintreespecies
      from treestandsummary as tss
      left outer join treestand as ts on tss.treestandid = ts.treestandid
      left outer join stand as  s on ts.standid = s.standid
      left outer join rtree_stand_geometry as r on r.id = s.id
      where r.minx <= "+ x.to_s + " and r.maxx >= "+  x.to_s + " and r.miny <= " + y.to_s + " and r.maxy >= " + y.to_s)

    for v in volume do

      total_price = 58 * (v["sawlogvolume"].to_f)
      v["soiltype"] = SOIL_TYPE[v["soiltype"]]
      v["maintreespecies"] = MAIN_TREE_SPIECES[v["maintreespecies"]]
      v["total_price"] = total_price.to_s
    end

    # volume["total_price"] = total_price.to_s
    
    render json: volume.map{|elem| elem.select{|k,v| k.class != Fixnum }}.to_json
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
