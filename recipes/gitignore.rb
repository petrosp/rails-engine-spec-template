say "Ignore some more files, it is not personal..."

append_to_file '.gitignore' do
"vendor/bundle
.idea/
.rbenv-gemsets
.rvmrc
.ruby-gemset
.ruby-version\n"
end

git_commit "Do not pollute the repo"
