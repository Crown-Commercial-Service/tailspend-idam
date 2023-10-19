ALLOWED_CHARACTERS = [
  ('a'..'z').to_a,
  ('A'..'Z').to_a,
  (0..9).to_a,
  '=+-^$*.[]{}()?"!@#%&/\\,><\':;|_~`'.chars
].freeze

INVALID_CHARACTERS = ['£èöíäü'.chars].freeze

def generate_random_password(character_lists)
  password = []

  character_lists.each do |set|
    rand(3..5).times do
      password << set.sample
    end
  end

  password.shuffle.join
end

def generate_random_valid_password
  generate_random_password(ALLOWED_CHARACTERS)
end

def generate_random_invalid_password
  generate_random_password(ALLOWED_CHARACTERS + INVALID_CHARACTERS)
end
