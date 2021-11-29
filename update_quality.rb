require 'award'

# Plans that increase quality as they age
INCREASE_AS_AGE_PLANS = ['Blue First', 'Blue Compare'].freeze

# Plans that increase quality after they expire
INCREASE_AFTER_EXPIRATION_PLANS = ['Blue First'].freeze

# Plans that lose all quality after they expire
ZERO_AFTER_EXPIRATION_PLANS = ['Blue Compare'].freeze

# Plans that increase quality variably as they age
VARIABLE_INCREASE_PLANS = ['Blue Compare'].freeze

# Plans that have a static quality of 80
STATIC_QUALITY_PLANS = ['Blue Distinction Plus'].freeze

def update_quality(awards)
  awards.each do |award|
    # Handle static plans
    if STATIC_QUALITY_PLANS.include?(award.name)
      award.quality = 80
      next
    end

    # Handle expired awards seperately from aging awards
    if award.expired?
      handle_expiration(award)
    # elsif award.expires_today?
    #   handle_expires_today(award)
    else
      handle_aging(award)
    end

    # Age the award
    award.decrement_expiration
  end
end

private

# def handle_expires_today(award)
#   # Handle plans that decrease value as they age
#   unless INCREASE_AS_AGE_PLANS.include?(award.name)

#     # These planse decrease quality as they age
#     award.change_quality_by -2
#     return
#   end

#   # Quality cannot exceed 50
#   return if award.maximum_quality_reached

#   # Handle non-variable increase plans
#   unless VARIABLE_INCREASE_PLANS.include?(award.name)
#     award.change_quality_by 2
#     return
#   end

#   # Variable plans zero out on the days they expire
#   award.quality = 0 if award.expires_today?
# end

def handle_aging(award)
  # Handle plans that decrease value as they age
  unless INCREASE_AS_AGE_PLANS.include?(award.name)

    # These planse decrease quality as they age
    award.change_quality_by -1
    return
  end

  # Quality cannot exceed 50
  return if award.maximum_quality_reached

  # Handle non-variable increase plans
  unless VARIABLE_INCREASE_PLANS.include?(award.name)
    award.change_quality_by 1
    return
  end

  # Variable plans increase quality by different rates depending on age
  if award.expires_in < 6
    # Variable Increase plans increase in quality by 3 if it expires in less than 6 days
    award.change_quality_by 3
  elsif award.expires_in < 11
    # Variable Increase plans increase in quality by 2 if it expires in less than 11 days
    award.change_quality_by 2
  else
    # Variable Increase plans increase in quality by one until they expire
    award.change_quality_by 1
  end
end

def handle_expiration(award)
  # Handle plans that increase quality after expiration
  if INCREASE_AFTER_EXPIRATION_PLANS.include?(award.name)
    award.change_quality_by 2
    return
  end

  # Blue Compare plans lose all quality when they expire
  if award.name == 'Blue Compare'
    award.quality = 0
    return
  end

  award.change_quality_by -2
end
