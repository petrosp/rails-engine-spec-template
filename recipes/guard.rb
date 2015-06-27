say "Installing guard..."

inject_into_file GEMSPEC_FILE, before: %r{^end$} do
%{
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'guard-bundler'
  s.add_development_dependency 'guard-zeus'
}
end

bundle

run 'bundle exec zeus init'

inject_into_file 'custom_plan.rb', before: /require \'zeus\/rails\'/ do
  %{
ROOT_PATH = File.expand_path(Dir.pwd)
ENVIRONMENT_PATH  = File.expand_path("spec/dummy/config/environment",  ROOT_PATH)
ENV_PATH  = File.expand_path("spec/dummy/config/environment",  ROOT_PATH)
BOOT_PATH = File.expand_path("spec/dummy/config/boot",  ROOT_PATH)
APP_PATH  = File.expand_path("spec/dummy/config/application",  ROOT_PATH)
ENGINE_ROOT = File.expand_path(Dir.pwd)
ENGINE_PATH = File.expand_path("lib/#{name}/engine", ENGINE_ROOT)\n
}
end
# run 'bundle exec guard init'

create_file 'Guardfile' do
<<-'RUBY'
guard :bundler do
  watch("Gemfile")
  watch(/^.+\.gemspec/)
end

watch_directives = Proc.new do
  require "ostruct"

  # Generic Ruby apps
  rspec = OpenStruct.new
  rspec.spec = ->(m) { "spec/#{m}_spec.rb" }
  rspec.spec_dir = "spec"
  rspec.spec_helper = "spec/spec_helper.rb"

  watch(%r{^spec/.+_spec\.rb$})
  # watch(%r{^lib/(.+)\.rb$})     { |m| rspec.spec.("lib/#{m[1]}") }
  watch(rspec.spec_helper)      { rspec.spec_dir }

  # Rails example
  rails = OpenStruct.new
  rails.app = %r{^app/(.+)\.rb$}
  rails.views_n_layouts = %r{^app/(.*)(\.erb|\.haml|\.slim)$}
  rails.controllers = %r{^app/controllers/(.+)_controller\.rb$}
  rails.routes = "config/routes.rb"
  rails.app_controller = "app/controllers/application_controller.rb"
  rails.spec_helper = "spec/rails_helper.rb"
  rails.spec_support = %r{^spec/support/(.+)\.rb$}
  rails.views = %r{^app/views/(.+)/.*\.(erb|haml|slim)$}

  watch(rails.app) { |m| rspec.spec.(m[1]) }
  watch(rails.views_n_layouts) { |m| rspec.spec.("#{m[1]}#{m[2]}") }
  watch(rails.controllers) do |m|
    [
      rspec.spec.("routing/#{m[1]}_routing"),
      rspec.spec.("controllers/#{m[1]}_controller"),
      rspec.spec.("acceptance/#{m[1]}")
    ]
  end

  watch(rails.spec_support)    { rspec.spec_dir }
  watch(rails.spec_helper)     { rspec.spec_dir }
  watch(rails.routes)          { "spec/routing" }
  watch(rails.app_controller)  { "spec/controllers" }

  # Capybara features specs
  watch(rails.views)     { |m| rspec.spec.("features/#{m[1]}") }

end

# you can now add
# guard :rspec, cmd: "bundle exec rspec" do, &watch_directives
# and you'll only need to keep track of one set of directives

guard :zeus, cmd: "zeus rspec", &watch_directives

RUBY
end


git_commit "Installed guard"
