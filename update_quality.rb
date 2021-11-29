require 'award'

# Awards that increase quality as they age
INCREASE_AS_AGE_AWARDS = ['Blue First', 'Blue Compare'].freeze

# Awards that lose quality twice as fast
DOUBLE_DECREASE_AS_AGE_AWARDS = ['Blue Star'].freeze

# Awards that increase quality after they expire
INCREASE_AFTER_EXPIRATION_AWARDS = ['Blue First'].freeze

# Awards that lose all quality after they expire
ZERO_AFTER_EXPIRATION_AWARDS = ['Blue Compare'].freeze

# Awards that increase quality variably as they age
VARIABLE_INCREASE_AWARDS = ['Blue Compare'].freeze

# Awards that have a static quality of 80
STATIC_QUALITY_AWARDS = ['Blue Distinction Plus'].freeze

# Call on an array of Awards to calculate the new qualities and expires_in values for each
def update_quality(awards)
  awards.each do |award|
    # Handle static awards
    if STATIC_QUALITY_AWARDS.include?(award.name)
      award.quality = 80
      next
    end

    # Handle expired awards seperately from aging awards
    if award.expired?
      handle_expiration(award)
    else
      handle_aging(award)
    end

    # Age the award
    award.decrement_expiration
  end
end

private

### These helper methods are called by #update_quality and are not meant to be called directly ###

# This method calculates the new quality and expires_in for awards that have not yet expired
def handle_aging(award)
  # Handle awards that decrease value as they age
  unless INCREASE_AS_AGE_AWARDS.include?(award.name)

    # These awards decrease quality as they age
    apply_quality_decrease(award)
    return
  end

  # Quality cannot exceed 50
  return if award.maximum_quality_reached

  # Handle non-variable increase awards
  unless VARIABLE_INCREASE_AWARDS.include?(award.name)
    award.change_quality_by 1
    return
  end

  # Variable awards increase quality by different rates depending on age
  if award.expires_in < 6
    # Variable Increase awards increase in quality by 3 if it expires in less than 6 days
    award.change_quality_by 3
  elsif award.expires_in < 11
    # Variable Increase awards increase in quality by 2 if it expires in less than 11 days
    award.change_quality_by 2
  else
    # Variable Increase awards increase in quality by one until they expire
    award.change_quality_by 1
  end
end

# This method calculates the new quality and expires_in for awards that have expired
def handle_expiration(award)
  # Handle awards that increase quality after expiration
  if INCREASE_AFTER_EXPIRATION_AWARDS.include?(award.name)
    award.change_quality_by 2
    return
  end

  # Blue Compare awards lose all quality when they expire
  if award.name == 'Blue Compare'
    award.quality = 0
    return
  end

  apply_quality_decrease(award, base_decrease: -2)
end

# This utility method takes a base quality decrease and applies modifiers to is based on the award name
def apply_quality_decrease(award, base_decrease: -1)
  # We need to determine the total decrease based on plan and base decrease
  diff = base_decrease
  diff *= 2 if DOUBLE_DECREASE_AS_AGE_AWARDS.include?(award.name)
  award.change_quality_by diff
end
