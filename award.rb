# Award = Struct.new(:name, :expires_in, :quality)

class Award
  attr_accessor :name, :expires_in, :quality

  def initialize(name, expires_in, quality)
    @name = name
    @expires_in = expires_in
    @quality = quality
  end


  # Increment / decrement the value of quality with a clamp of 0-50
  # This is the recommended method for changing quality, unless it is being set absolutely
  def change_quality_by(new_quality)
    @quality += new_quality
    @quality = 50 if @quality > 50
    @quality = 0 if @quality < 0
    @quality
  end

  ### Helpers ###
  def expired?
    @expires_in <= 0
  end

  # def expires_today?
  #   @expires_in == 0
  # end

  def decrement_expiration
    @expires_in -= 1
  end

  def maximum_quality_reached
    @quality >= 50
  end
end
