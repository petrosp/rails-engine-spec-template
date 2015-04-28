#! /usr/bin/env ruby
error = false

unless try(:name) && File.exist?(File.join(destination_root, 'lib', name, 'engine.rb'))
  say "ERROR: This is for engines only. You need to create a new engine with"
  say "       'rails plugin new' and specify '--mountable' or '--full'."
  error = true
end

if File.exist?(File.join(destination_root, 'test'))
  say "ERROR: You need to generate the plugin with -T specified so it doesn't"
  say "       create a test setup. Delete the plugin directory and try again."
  error = true
end

exit 1 if error

def git_commit(message)
  git add: '.'
  git commit: "-m '#{message}' -q"
end

def bundle
  run "bundle install --path vendor/bundle"
end

say "Creating git repository..."
git :init
apply File.join(RECIPE_PATH, "gitignore.rb")
git_commit "Initial commit of empty Rails engine."

run "echo '#{name} -global' >> .rbenv-gemsets"

GEMSPEC_FILE = File.join(destination_root, "#{name}.gemspec")
GITIGNORE_FILE = File.join(destination_root, ".gitignore")
RECIPE_PATH = File.join(File.dirname(rails_template), "recipes")
RECIPES = %w{dummy_app rspec guard developer_gems}

RECIPES.each do |recipe|
  apply File.join(RECIPE_PATH, "#{recipe}.rb")
end

say "Garbage collecting git..."
git gc: '--quiet'

say %{
  Things to do:
    - rake db:migrate
  Things done:
    - edited #{name}.gemspec and set correct info (TODO et al) to remove bundler warnings.
}
