# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_debt_friends_session',
  :secret      => 'ca1b707b0016ca2b311be3d8715e12fedeaab0bbe92345238612644b707d228a26cd92b9982e0a850d4ba0c5d512fb382ea7989d71eb92f0981732b2dba1e25a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
