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
# Note: this method is built to provide custom logic for specific plans outlined in the constants above. Please
# check to see if you need to update one of those constants before changing the logic in these methods.
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
### All helper methods return an Award                                                         ###

# Calculate the new quality and expires_in for awards that HAVE NOT expired
def handle_aging(award)
  # Handle awards that decrease value as they age
  unless INCREASE_AS_AGE_AWARDS.include?(award.name)

    # These awards decrease quality as they age
    apply_quality_decrease(award)
    return award
  end

  # Handle non-variable increase awards
  unless VARIABLE_INCREASE_AWARDS.include?(award.name)
    award.change_quality_by 1
    return award
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

  award
end

# Calculate the new quality and expires_in for awards that HAVE expired
def handle_expiration(award)
  # Handle awards that increase quality after expiration
  if INCREASE_AFTER_EXPIRATION_AWARDS.include?(award.name)
    award.change_quality_by 2
    return award
  end

  # Handle awards that lose all quality when they expire
  if ZERO_AFTER_EXPIRATION_AWARDS.include?(award.name)
    award.quality = 0
    return award
  end

  # Update the quality for awards that decrease quality when expired
  apply_quality_decrease(award, base_decrease: -2)

  award
end

# Given a base quality decrease, applies modifiers to it based on the award name
def apply_quality_decrease(award, base_decrease: -1)
  # We need to determine the total decrease based on plan and base decrease
  diff = base_decrease
  diff *= 2 if DOUBLE_DECREASE_AS_AGE_AWARDS.include?(award.name)
  award.change_quality_by diff
  award
end
